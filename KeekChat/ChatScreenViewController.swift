//
//  ChatScreenViewController.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 24/07/23.
//  Copyright © 2023 Riavera. All rights reserved.
// swiftlint:disable cyclomatic_complexity

import UIKit
import SwiftSignalRClient
import SafariServices

enum ChatType {
    case oneToOne
    case group
}

protocol ChatScreenViewControllerDelegate: class {
    func markAllRead(threadId: String)
    func lastMessageWasDeleted()
    func unblockUser(extAppUserId: String)
}

class ChatScreenViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var textMsgBtn: MyButton!
    @IBOutlet var chatInactiveLbl: UILabel!
    @IBOutlet var chatInactiveView: UIView!
    @IBOutlet var deleteBtn: UIButton!
    @IBOutlet var dayLbl: UILabel!
    @IBOutlet var messageTextfield: MyTextField!
    @IBOutlet var chatNameLbl: UILabel!
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var keyboardView: MyView!
    @IBOutlet var typingStateLbl: UILabel!
    //@IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var profilePicImgview: MyImageView!
    @IBOutlet var showGroupDetailsBtn: UIButton!
    @IBOutlet var profilePicBunchView: BunchProfilePicView!
    @IBOutlet var messageView: MyView!
    @IBOutlet var mediaMsgBtn: MyButton!
    @IBOutlet var labelTopConstraint: NSLayoutConstraint!
    var messages: [ChatMessage] = []
    var chatName = ""
    var threadInfoObj: ThreadInfo?
    var chatType: ChatType = .oneToOne
    var isLoadingMsgs = false
    var totalMsgCount = 0
    var allMsgsRowsLoaded = false
    private var typingTimer: Timer?
    private let typingStatusDelay: TimeInterval = 2.0
    var isTyping = false
    var isTimerTicking = false
    private var userTypingTimer: Timer?
    var orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return self.orientations }
        set { self.orientations = newValue }
    }
    var pageNo = 1
    var shouldMarkAsRead = false
    var apiDate: String = ""
    var delegate: ChatScreenViewControllerDelegate?
    var hasRefreshedData: Bool = true
    var unreadMsgCount = 0
    var modifiedDate = ""
    var selectedIndex: [Int] = []
    var deleteModeOn: Bool = false {
        didSet {
            if deleteModeOn {
                self.deleteBtn.isHidden = false
            } else {
                self.deleteBtn.isHidden = true
            }
        }
    }
    var isActive: Bool = true
    var shouldRemoveObserver: Bool = true
    var updatingGroup: Bool = false
    let imageMsgView = GroupAvatarUpdateView()
    var mediaData: MediaMessage?
    var selectedImage: UIImage?
    var shouldAddUnreadCount: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTable()
        messageTextfield.delegate = self
        if self.threadInfoObj?.userStatus == "Online" {
            typingStateLbl.text = "Online".localized
        } else if self.threadInfoObj?.userStatus == "Offline" {
            typingStateLbl.text = "Offline".localized
        } else {
            typingStateLbl.text = self.threadInfoObj?.userStatus
        }
        
        typingStateLbl.isHidden = false
        
        messageTextfield.inputAccessoryView = createDoneToolbar()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(receivedNewMessage(_:)), name: Notification.Name("ReceivedNewMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTypingLbl(_:)), name: Notification.Name("UpdateTypingStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkNetworkConnection(_:)), name: Notification.Name("ReachabilityStatusChangedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserStatus(_:)), name: Notification.Name("UpdateChatScreenUserStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateReadStatus(_:)), name: Notification.Name("UpdateMessageReadStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(socketConnected), name: Notification.Name("InformChatScreenSocketConnected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(socketDisconnected), name: Notification.Name("InformChatScreenSocketDisconnected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messageDeleted(_:)), name: Notification.Name("InformMessageDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupData(_:)), name: Notification.Name("GroupWasUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedMediaMsgUpdate(_:)), name: Notification.Name("MediaMsgUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(manageUserBlocked), name: Notification.Name("UserBlockedChatScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(manageUserUnBlocked), name: Notification.Name("UserUnBlockedChatScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unreadMsgWasDeleted(_:)), name: Notification.Name("UnreadMsgWasDeleted"), object: nil)
        
        self.manageGroupAccess()
        self.profilePicBunchView.isHidden = true
        self.loadProfilePicture()
        self.chatInactiveLbl.text = "chatInactive".localized
        self.messageTextfield.placeholder = "Message".localized + "..."
    }
    
    func loadProfilePicture() {
        if let url = self.threadInfoObj?.userAvatarUrl {
            profilePicImgview.sd_setImage(with: NSURL(string: url) as URL?, completed: { [self] (_, error, _, _) in
                if error != nil {
                    if chatType == .oneToOne {
                        self.profilePicImgview.image = UIImage(named: "profile")
                    } else {
                        self.profilePicImgview.image = UIImage(named: "groupProfile")
                    }
                }
            })
        } else {
            if chatType == .oneToOne {
                self.profilePicImgview.image = UIImage(named: "profile")
            } else {
                self.profilePicImgview.image = UIImage(named: "groupProfile")
            }
        }
    }
    func createDoneToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [flexSpace, doneButton]
        
        return toolbar
    }
    
    @objc func doneButtonTapped() {
        self.view.endEditing(true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        keyboardView.layer.cornerRadius = 16
        keyboardView.layer.masksToBounds = false
        keyboardView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        if self.chatType == .group {
            chatNameLbl.text = "\(chatName)"
        } else {
            chatNameLbl.text = "@\(chatName)"
        }
        self.view.bringSubviewToFront(dayLbl)
        dayLbl.layer.cornerRadius = 9
        dayLbl.layer.masksToBounds = true
        self.view.bringSubviewToFront(keyboardView)
        Reach().monitorReachabilityChanges()
        if self.chatType == .group {
            self.getGroupDetails()
        }
        if shouldRemoveObserver {
            self.configureTable()
        }
        shouldRemoveObserver = true
        ChatModel.sharedInstance.currentChatId = self.threadInfoObj?.threadID ?? ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if shouldRemoveObserver {
            NotificationCenter.default.removeObserver(self, name: Notification.Name("ReceivedNewMessage"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("UpdateTypingStatus"), object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("ReachabilityStatusChangedNotification"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("UpdateChatScreenUserStatus"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("UpdateMessageReadStatus"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("InformChatScreenSocketConnected"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("InformChatScreenSocketDisconnected"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("InformMessageDeleted"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("GroupWasUpdated"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("MediaMsgUpdated"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("UserBlockedChatScreen"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("UserUnBlockedChatScreen"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name("UnreadMsgWasDeleted"), object: nil)
            ChatModel.sharedInstance.currentChatId = ""
        }
        typingTimer?.invalidate()
        userTypingTimer?.invalidate()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if messages.count == 0 {
            if chatType == .oneToOne {
                ChatCoreDataHelper.sharedChatDBHelper.deletePrivateThread(threadID: self.threadInfoObj?.threadID ?? "")
            }
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteBtnAction(_ sender: Any) {
        self.deleteChatMessage()
    }
    
    @IBAction func sendImageAction(_ sender: Any) {
        if let isBlocked = threadInfoObj?.isBlocked {
            if chatType == .oneToOne && isBlocked {
                
                UIUtil.showAlertWithButtons(btnNo: "Cancel", btnYes: "Unblock", msg: "Unblock @\(threadInfoObj?.userName ?? "") to send a message.", title: "", vc: self) { [self] in
                    self.delegate?.unblockUser(extAppUserId: threadInfoObj?.extAppUserId ?? "")
                }
                return
            }
        }
        if let vc = UIApplication.topViewController() {
            imageMsgView.delegate = self
            self.shouldRemoveObserver = false
            imageMsgView.show(vc)
        }
    }
    
    @IBAction func showGroupAction(_ sender: Any) {
        shouldRemoveObserver = false
        shouldAddUnreadCount = true
        if self.chatType == .group {
            var isGroupAdmin = false
            if threadInfoObj?.adminExtUserId == ChatModel.sharedInstance.userId {
                isGroupAdmin = true
            }
            let vc = CreateChatGroupViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.groupName = self.threadInfoObj?.userName ?? ""
            vc.isEditGrp = true
            vc.groupMembers = self.threadInfoObj?.members ?? []
            vc.isGroupAdmin = isGroupAdmin
            vc.groupInfo = self.threadInfoObj
            vc.delegate = self
            vc.adminExtUserId = threadInfoObj?.adminExtUserId
            self.shouldMarkAsRead = false
            self.animatedPresentVC(vc)
        }
    }
    
    @IBAction func sendMsgAction(_ sender: Any) {
        if let isBlocked = threadInfoObj?.isBlocked {
            if chatType == .oneToOne && isBlocked {
                UIUtil.showAlertWithButtons(btnNo: "Cancel", btnYes: "Unblock", msg: "Unblock @\(threadInfoObj?.userName ?? "") to send a message.", title: "", vc: self) { [self] in
                    self.delegate?.unblockUser(extAppUserId: threadInfoObj?.extAppUserId ?? "")
                }
                return
            }
        }
        
        if let msgtext = messageTextfield.text {
            let msg = msgtext.trimmingCharacters(in: .whitespacesAndNewlines)
            if msg != "" {
                let chatMeta = ChatMessageMetaData(metaKey: "", metaValue: "")
                print("ChatTypeqjroiwjr---- \(chatType == .group ? "Group" : "One-O-One")")
                if chatType == .oneToOne {
                    let message = SendMessageToUserModel(toUserId: "\(threadInfoObj?.userID ?? "")", message: "\(msg)", chatId: "\(threadInfoObj?.threadID ?? "")", eMessageType: .text, chatMessageMetaDatas: [chatMeta])
                    if KeekChatBuilder.shared.isConnectionActive == .connected {
                        self.textMsgBtn.isUserInteractionEnabled = false
                        KeekChatBuilder.shared.sendMsg(msgModel: message)
                    }
                } else {
                    let message = SendMessageToGroupModel(message: "\(msg)", chatId: "\(threadInfoObj?.threadID ?? "")", eMessageType: .text, chatMessageMetaDatas: [chatMeta])
                    if KeekChatBuilder.shared.isConnectionActive == .connected {
                        self.textMsgBtn.isUserInteractionEnabled = false
                        KeekChatBuilder.shared.sendMsgToGroup(msgModel: message)
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            //self.labelTopConstraint.constant = keyboardSize.height + 46
            self.textViewBottomConstraint.constant = keyboardSize.height
            
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.textViewBottomConstraint.constant = 0
    }
    
    func hasPhysicalHomeButton() -> Bool {
        
        if #available(iOS 13.0, *), UIApplication.shared.windows[0].safeAreaInsets.bottom > 0 {
            return true
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if chatType == .oneToOne {
            self.startTypingTimer()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.unreadMsgCount = 0
        self.mainTableView.setContentOffset(self.mainTableView.contentOffset, animated: false)
        if deleteModeOn {
            deleteModeOn = false
            self.selectedIndex = []
            self.mainTableView.reloadData()
            self.mediaMsgBtn.isUserInteractionEnabled = true
            self.textMsgBtn.isUserInteractionEnabled = true
        }
    }
    
    private func startTypingTimer() {
        if !isTimerTicking {
            typingTimer?.invalidate()
            self.isTimerTicking = true
            typingTimer = Timer.scheduledTimer(withTimeInterval: typingStatusDelay, repeats: false) { [weak self] _ in
                self?.isTimerTicking = false
            }
            self.updateTypingStatus()
        } else {
            print("Timer is running")
        }
    }
}

extension ChatScreenViewController: UITableViewDelegate, UITableViewDataSource, ImageSentMsgTableViewCellDelegate, ImageReceivedTableViewCellDelegate, EditGrpForChatDelegate {
    
    func backFromGroupDetails() {
        self.shouldMarkAsRead = true
        self.markVisibleCellsAsRead()
    }
    
    func viewReceivedImage(messageNo: Int) {
        self.viewImageMsg(messageNo: messageNo)
    }
    
    func viewSentImage(messageNo: Int) {
        self.viewImageMsg(messageNo: messageNo)
    }
    
    func viewImageMsg(messageNo: Int) {
        if !self.deleteModeOn {
            let obj = self.messages[messageNo]
            if obj.mainImageUrl != "" {
                let vc = ViewImageMsgViewController()
                vc.imgUrl = self.messages[messageNo].mainImageUrl
                vc.modalPresentationStyle = .fullScreen
                shouldRemoveObserver = false
                shouldAddUnreadCount = true
                self.dismiss(animated: true)
            } else if obj.postId != "" {
                if obj.messageText.lowercased() == EMessageShareType.stream.geteMessageType().lowercased() {
                  //  openStreamPlayBack(streamId: obj.postId)
                } else {
                  //  self.getPostWithPostId(postId: obj.postId)
                }
            }
        } else {
            let indexPath = IndexPath(row: messageNo, section: 0)
            self.handleDeleteMode(indexPath: indexPath)
        }
    }
    
//    func openStreamPlayBack(streamId: String) {
//        let storyboard = UIStoryboard(name: "Streaming", bundle: nil)
//        if let vc = storyboard.instantiateViewController(withIdentifier: "JoinStreamViewControllerId") as? JoinStreamViewController {
//            let stream = Stream()
//            stream.id = Int(streamId)!
//            vc.watchStreamViewModel.stream = stream            
//            vc.modalPresentationStyle = .fullScreen
//            UIApplication.shared.isStatusBarHidden = true
//            
//            if #available(iOS 13, *) {
//                vc.isModalInPresentation = true
//            }
//            
//            self.present(vc, animated: true, completion: nil)
//        }
//    }
    
//    func getPostWithPostId(postId: String) {
//        UIUtil.indicateActivityForView(self.view, labelText: "")
//        PostConnector().lookupPost("\(postId)") { success, _, post in
//            
//            if success {
//                DispatchQueue.main.async {
//                    DispatchQueue.main.async(execute: { [self] in
//                        let vc = FullStreamViewController()
//                        vc.visiblePostId = post!.postID
//                        vc.fromScreen = .profile
//                        var userPosts: [Post] = []
//                        userPosts.append(post!)
//                        vc.userId = "\(post!.userID)"
//                        vc.userPosts = userPosts
//                        vc.visiblePostNo = 0
//                        vc.showComments = false
//                        vc.modalPresentationStyle = .fullScreen
//                        UIUtil.removeActivityViewFromView(self.view)
//                        shouldRemoveObserver = false
//                        shouldAddUnreadCount = true
//                        self.animatedPresentVC(vc)
//                    })
//                }
//            } else {
//                DispatchQueue.main.async {
//                    UIUtil.removeActivityViewFromView(self.view)
//                    let Alert = UIAlertController(title: "poorInternetConnectivity".localized, message: "", preferredStyle: .alert)
//                    Alert.addAction(UIAlertAction(title: "OK".localized, style: .cancel, handler: nil))
//                    self.present(Alert, animated: true)
//                }
//            }
//            
//        }
//    }
    
    func configureTable() {
        ReceivedMsgTableViewCell.registerNib(mainTableView)
        SentMsgTableViewCell.registerNib(mainTableView)
        ImageMsgTableViewCell.registerNib(mainTableView)
        ImageReceivedTableViewCell.registerNib(mainTableView)
        InfoTableViewCell.registerNib(mainTableView)
        
        if messages.count > 0 {
            self.apiDate =  self.messages.last?.messageTime ?? ""
            if !(messages.count > 10) {
                self.shouldMarkAsRead = true
            }
        }
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.transform = CGAffineTransformMakeScale(1, -1)
        self.updateDayLbl()
        if messages.count > 0 {
            if self.messages.count > self.unreadMsgCount {
                self.mainTableView.scrollToRow(at: IndexPath(row: self.unreadMsgCount, section: 0), at: .none, animated: false)
            } else {
                self.mainTableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: .none, animated: false)
            }
        }
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.shouldMarkAsRead = true
            self?.markVisibleCellsAsRead()
        }
    }
    
    func markVisibleCellsAsRead() {
        
        if let indexPaths = self.mainTableView.indexPathsForVisibleRows {
            for index in indexPaths {
                let obj = messages[index.row]
                if !obj.isReadByMe && obj.messageType != 3 {
                    if KeekChatBuilder.shared.isConnectionActive == .connected && obj.externalUserId != ChatModel.sharedInstance.userId {
                        KeekChatBuilder.shared.readMsg(messageId: obj.messageId)
                        obj.isReadByMe = true
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateDayLbl()
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height - 320) {
            
            if !self.isLoadingMsgs && !self.allMsgsRowsLoaded {
                self.isLoadingMsgs = true
                self.getPrivateChatMsgs(isRefresh: false)
            }
            
            if self.messages.count == self.totalMsgCount {
                self.allMsgsRowsLoaded = true
            }
            
        }
        
        if shouldMarkAsRead {
            if let indexPaths = self.mainTableView.indexPathsForVisibleRows {
                for index in indexPaths {
                    let obj = messages[index.row]
                    if !obj.isReadByMe && obj.messageType != 3 {
                        if KeekChatBuilder.shared.isConnectionActive == .connected && obj.externalUserId != ChatModel.sharedInstance.userId {
                            KeekChatBuilder.shared.readMsg(messageId: obj.messageId)
                            obj.isReadByMe = true
                        }
                    }
                }
            }
        }
    }
    
    func getPrivateChatMsgs(isRefresh: Bool) {
        
        if isRefresh {
            self.pageNo = 1
            self.apiDate = Utils.convertDateToISODate(Date())
        }
        var threadType = "oneToOne"
        if self.chatType == .group {
            threadType = "group"
        }
        ChatCacheManager.shared.getPrivateChatMessages(threadId: threadInfoObj!.threadID, isRefresh: isRefresh, messageUpto: self.apiDate, pageNo: self.pageNo, threadType: threadType) { success, error, messages, totalMsgCount  in
            if success {
                DispatchQueue.main.async {
                    if isRefresh {
                        self.messages = messages!
                    } else {
                        self.messages += messages!
                    }
                    
                    if messages!.count == 0 {
                        self.allMsgsRowsLoaded = true
                    }
                    self.mainTableView.reloadData()
                    self.totalMsgCount = totalMsgCount!
                    self.isLoadingMsgs = false
                    self.pageNo += 1
                }
            } else {
                print(error)
            }
        }
    }
    
    func deleteChatMessage() {
        if messages.count > 0 {
            var messagsIds: [String] = []
            for index in selectedIndex {
                messagsIds.append(self.messages[index].messageId)
            }
            
            ChatCacheManager.shared.deleteChatMessage(messageIds: messagsIds) { success, _ in
                if success {
                    DispatchQueue.main.async { [self] in
                        
                        let deletedDataSet = self.messages.filter { !messagsIds.contains($0.messageId) }
                        if self.selectedIndex.contains([0]) {
                            self.delegate?.lastMessageWasDeleted()
                        }
                        self.messages = deletedDataSet
                        
                        self.selectedIndex = []
                        self.deleteModeOn = false
                        self.mainTableView.reloadData()
                        for messageId in messagsIds {
                            ChatCoreDataHelper.sharedChatDBHelper.deletePrivateChatMsg(messageID: messageId)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [self] in
                        self.selectedIndex = []
                        self.mainTableView.reloadData()
                        self.deleteBtn.isHidden = true
                        self.deleteModeOn = false
                        UIUtil.apiFailure("unable_delete_message".localized, vc: self)
                    }
                }
            }
            self.mediaMsgBtn.isUserInteractionEnabled = true
            self.textMsgBtn.isUserInteractionEnabled = true
        }
    }
    
}

extension ChatScreenViewController {
    
    func manageGroupAccess() {
        if let isActive = threadInfoObj?.isActive {
            if isActive {
                self.messageView.isHidden = false
                self.chatInactiveView.isHidden = true
            } else {
                self.messageView.isHidden = true
                if self.chatType == .group {
                    self.chatInactiveView.isHidden = false
                }
            }
        }
    }
    
    func getLatestPrivateMsgs() {
        var messageFrom = ""
        if messages.count > 0 {
            messageFrom = self.messages.first?.messageTime ?? ""
        }
        ChatCacheManager.shared.getLatestPrivateChatMessages(chatId: self.threadInfoObj!.threadID, messageFrom: messageFrom) { success, error, threads in
            if success {
                if let messages = threads {
                    DispatchQueue.main.async {
                        if messages.count > 0 {
                            if self.shouldAddUnreadCount {
                                self.unreadMsgCount += messages.count
                            } else {
                                self.unreadMsgCount = messages.count
                            }
                            
                            self.messages = messages.reversed() + self.messages
                            for message in messages {
                                if KeekChatBuilder.shared.isConnectionActive == .connected && message.externalUserId != ChatModel.sharedInstance.userId && message.messageType != 3 {
                                    KeekChatBuilder.shared.readMsg(messageId: message.messageId)
                                    
                                    message.isReadByMe = true
                                    self.delegate?.markAllRead(threadId: self.threadInfoObj!.threadID)
                                }
                            }
                            self.mainTableView.reloadData()
                            if self.messages.count > 0 {
                                self.mainTableView.scrollToRow(at: IndexPath(row: self.unreadMsgCount, section: 0), at: .none, animated: false)
                            }
                        }
                    }
                }
            } else {
                print(error)
            }
        }
    }
    
    func getLatestMessagesStatus() {
        ChatCacheManager.shared.getLatestPrivateChatMessagesStatus(chatId: self.threadInfoObj!.threadID, modifiedDate: self.modifiedDate) { success, error, modifiedMessages in
            if success {
                DispatchQueue.main.async {
                    if let changedMessages = modifiedMessages {
                        for (index, obj1) in self.messages.enumerated() {
                            if let obj2 = changedMessages.first(where: { $0.messageId == obj1.messageId }) {
                                
                                let obj = self.messages[index]
                                obj.isRead = obj2.isRead
                                obj.isDeleted = obj2.isDeleted
                                self.mainTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                            }
                        }
                    }
                }
            } else {
                print(error)
            }
        }
    }
    
    func getUserStatus() {
        ChatConnector().getUserStatus(userId: self.threadInfoObj?.userID ?? "") { success, error, userObject in
            if success {
                DispatchQueue.main.async { [self] in
                    if self.threadInfoObj?.userID == userObject?.userID {
                        self.threadInfoObj?.userStatus = userObject!.userStatus
                        if !self.isTyping {
                            if userObject?.userStatus == "Online" {
                                typingStateLbl.text = "Online".localized
                            } else if userObject?.userStatus == "Offline" {
                                typingStateLbl.text = "Offline".localized
                            } else {
                                typingStateLbl.text = userObject?.userStatus
                            }
                        }
                    }
                }
            } else {
                print(error)
            }
        }
    }
    
    func getGroupDetails() {
        updatingGroup = true
        self.showGroupDetailsBtn.isUserInteractionEnabled = false
        ChatConnector().getGroupChatInfo(groupId: self.threadInfoObj!.groupId) { success, error, groupInfo in
            if success {
                DispatchQueue.main.async {
                    self.updatingGroup = false
                    if let groupInfo = groupInfo {
                        self.threadInfoObj?.members = groupInfo.members
                        self.threadInfoObj?.isActive = groupInfo.isActive
                        self.threadInfoObj?.userName = groupInfo.userName
                        self.manageGroupAccess()
                        let members = User.parseKeekChatUser(groupInfo.members)
                        self.profilePicBunchView.selectedUsers = members
                        self.profilePicBunchView.tagsMultiUserImageViewConfig(arrselectedUsers: members)
                        self.profilePicBunchView.isHidden = false
                        self.profilePicBunchView.imgWidthConstriant.constant = 21
                        self.profilePicBunchView.imgHeightConstriant.constant = 21
                        self.profilePicBunchView.imgLeadingConstraint.constant = 0
                        self.profilePicBunchView.imgview1.cornerRadius = 10.5
                        self.profilePicBunchView.imgview2.cornerRadius = 10.5
                        self.profilePicBunchView.imgview3.cornerRadius = 10.5
                        self.profilePicBunchView.imgview4.cornerRadius = 10.5
                        self.profilePicBunchView.imgview5.cornerRadius = 10.5
                        self.profilePicBunchView.imgview6.cornerRadius = 10.5
                        self.profilePicBunchView.countView.cornerRadius = 10.5
                        self.profilePicBunchView.imgTopConstraint.constant = 0
                        self.showGroupDetailsBtn.isUserInteractionEnabled = true
                        self.chatName = groupInfo.userName
                        self.chatNameLbl.text = groupInfo.userName
                        self.threadInfoObj?.userAvatarUrl = groupInfo.userAvatarUrl
                        self.loadProfilePicture()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.updatingGroup = false
                    print(error)
                }
            }
        }
    }
    
    func updateDayLbl() {
        if let topIndexPath = mainTableView.indexPathsForVisibleRows?.max(by: { $0.row < $1.row }) {
            
            let topMessage = self.messages[topIndexPath.row]
            self.dayLbl.text = UIUtil.stringDateToTopString(dateToConvert: topMessage.messageTime)
        }
        
        if self.messages.count == 0 {
            self.dayLbl.isHidden = true
        } else {
            self.dayLbl.isHidden = false
        }
    }
    
    func checkIfNextMsgIsSameType(indexNo: Int, chatUserId: String) -> Bool {
        if self.messages.count - 1 > indexNo {
            let obj = self.messages[indexNo+1]
            if obj.userId == chatUserId && obj.messageType != 3 {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func checkIfNextMsgIsSameDay(dateString1: String, dateString2: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let date1 = dateFormatter.date(from: dateString1),
              let date2 = dateFormatter.date(from: dateString2) else {
            return false
        }
        
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        
        return components1.year == components2.year &&
        components1.month == components2.month &&
        components1.day == components2.day
    }
}

extension ChatScreenViewController {
    
    @objc func updateUserStatus(_ notification: Notification) {
        if chatType == .oneToOne {
            if let object = notification.userInfo?["userStatus"] as? UserConnectedModel {
                if self.threadInfoObj?.userID == object.id {
                    self.threadInfoObj?.userStatus = object.userStatus
                    if !self.isTyping {
                        if object.userStatus == "Online" {
                            self.typingStateLbl.text = "Online".localized
                        } else if object.userStatus == "Offline" {
                            typingStateLbl.text = "Offline".localized
                        } else {
                            typingStateLbl.text = object.userStatus
                        }
                    }
                }
            }
        }
    }
    
    @objc func updateReadStatus(_ notification: Notification) {
        if let object = notification.userInfo?["message"] as? MessageReadByUserModel {
            for i in 0...self.messages.count - 1 {
                let message = self.messages[i]
                if message.messageId == object.messageId {
                    DispatchQueue.main.async {
                        message.isRead = object.isRead
                        self.mainTableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    }
                }
            }
        }
    }
    
    @objc func checkNetworkConnection(_ notification: Notification) {
        if let status = notification.userInfo?["Status"] as? String {
            if status == "Offline" {
                self.hasRefreshedData = false
                self.messageTextfield.isUserInteractionEnabled = false
                self.mediaMsgBtn.isUserInteractionEnabled = false
                self.modifiedDate = Utils.getFormattedTimeUTC(dateToFormat: Date())
                if chatType == .group {
                    self.showGroupDetailsBtn.isUserInteractionEnabled = false
                }
            } else {
                self.messageTextfield.isUserInteractionEnabled = true
                self.mediaMsgBtn.isUserInteractionEnabled = true
                if !self.hasRefreshedData {
                    self.hasRefreshedData = true
                    if messages.count > 0 {
                        self.getLatestPrivateMsgs()
                        self.getLatestMessagesStatus()
                    } else {
                        self.getPrivateChatMsgs(isRefresh: true)
                    }
                    if chatType == .group {
                        self.getGroupDetails()
                    }
                }
            }
        }
    }
    
    @objc private func updateTypingStatus() {
        if KeekChatBuilder.shared.isConnectionActive == .connected {
            KeekChatBuilder.shared.sendTypingStatus(chatId: self.threadInfoObj?.threadID ?? "")
        }
    }
    
    @objc func updateTypingLbl(_ notification: Notification) {
        if let message = notification.userInfo?["message"] as? ReceivedTypingUserModel {
            if message.chatId == self.threadInfoObj?.threadID {
                isTyping = true
                typingStateLbl.text = "typing".localized + "..."
                userTypingTimer?.invalidate()
                userTypingTimer = Timer.scheduledTimer(withTimeInterval: typingStatusDelay, repeats: false) { [weak self] _ in
                    
                    if self?.threadInfoObj?.userStatus == "Online" {
                        self?.typingStateLbl.text = "Online".localized
                    } else if self?.threadInfoObj?.userStatus == "Offline" {
                        self?.typingStateLbl.text = "Offline".localized
                    } else {
                        self?.typingStateLbl.text = self?.threadInfoObj?.userStatus
                    }
                    self?.isTyping = false
                }
            }
        }
    }
    
    @objc func socketDisconnected() {
        self.modifiedDate = Utils.getFormattedTimeUTC(dateToFormat: Date())
    }
    
    @objc func socketConnected() {
        if messages.count > 0 {
            self.getLatestPrivateMsgs()
            self.getLatestMessagesStatus()
        } else {
            self.getPrivateChatMsgs(isRefresh: true)
        }
        if chatType == .oneToOne {
            self.getUserStatus()
        }
        self.markVisibleCellsAsRead()
    }
    
    @objc func manageUserBlocked() {
        self.threadInfoObj?.isBlocked = true
    }
    
    @objc func manageUserUnBlocked() {
        self.threadInfoObj?.isBlocked = false
    }
    
    @objc func updateGroupData(_ notification: Notification) {
        if let group = notification.userInfo?["group"] as? ChatGroupModel {
            if group.chatId == self.threadInfoObj?.threadID {
                if messages.count > 0 {
                    self.getLatestPrivateMsgs()
                    self.getGroupDetails()
                } else {
                    self.getPrivateChatMsgs(isRefresh: true)
                }
            }
        }
    }
    
    @objc func messageDeleted(_ notification: Notification) {
        if let object = notification.userInfo?["message"] as? MessageDeletedModel {
            DispatchQueue.main.async {
                if object.chatId == self.threadInfoObj?.threadID {
                    for message in self.messages {
                        if object.messageIds.contains([message.messageId]) {
                          //  self.messages.removeAll([message])
                        }
                    }
                    self.mainTableView.reloadData()
                }
            }
        }
    }
    
    @objc func receivedMediaMsgUpdate(_ notification: Notification) {
        
        if let mediamessage = notification.userInfo?["message"] as? ChatMessage {
            DispatchQueue.main.async { [self] in
                if mediamessage.threadID == threadInfoObj?.threadID {
                    for i in 0...self.messages.count - 1 {
                        let message = self.messages[i]
                        if message.messageId == mediamessage.messageId {
                            message.thumbnailImageUrl = mediamessage.thumbnailImageUrl
                            message.mainImageUrl = mediamessage.mainImageUrl
                            message.imageHeight = mediamessage.imageHeight
                            message.imageWidth = mediamessage.imageWidth
                            self.mainTableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                        }
                    }
                }
            }
        }
    }
    
    @objc func unreadMsgWasDeleted(_ notification: Notification) {
        
        if let threadId = notification.userInfo?["threadId"] as? String {
            
            if threadId == self.threadInfoObj?.threadID {
                if self.unreadMsgCount > 0 {
                    DispatchQueue.main.async { [self] in
                        self.unreadMsgCount -= 1
                        self.mainTableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func receivedNewMessage(_ notification: Notification) {
        
        if let message = notification.userInfo?["message"] as? ChatMessage {
            DispatchQueue.main.async { [self] in
                if message.threadID == threadInfoObj?.threadID {
                    let messageIdToCheck = message.messageId
                    let containsMessage = self.messages.contains { $0.messageId == messageIdToCheck }
                    
                    if containsMessage {
                        return
                    }
                    self.messages.insert(message, at: 0)
                    self.mainTableView.reloadData()
                    self.textMsgBtn.isUserInteractionEnabled = true
                    if message.externalUserId == ChatModel.sharedInstance.userId {
                        self.unreadMsgCount = 0
                        shouldAddUnreadCount = false
                        self.mainTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                        if message.messageType == 1 {
                            if message.mainImageUrl == "" {
                                self.mediaMsgBtn.isUserInteractionEnabled = true
                                self.uploadMediaMsg(messageId: message.messageId)
                            }
                        } else {
                            messageTextfield.text = ""
                        }
                    } else {
                        if shouldAddUnreadCount {
                            self.unreadMsgCount += 1
                        } else {
                            if shouldMarkAsRead {
                                if let indexPathsForVisibleRows = self.mainTableView.indexPathsForVisibleRows,
                                    let firstVisibleIndexPath = indexPathsForVisibleRows.first,
                                    firstVisibleIndexPath.row == 0 {
                                    if KeekChatBuilder.shared.isConnectionActive == .connected && message.threadID == self.threadInfoObj?.threadID && message.messageType != 3 {
                                        message.isReadByMe = true
                                        KeekChatBuilder.shared.readMsg(messageId: message.messageId)
                                        self.mainTableView.reloadData()
                                    }
                                } else {
                                    self.shouldAddUnreadCount = true
                                    self.unreadMsgCount += 1
                                }
                            }
                        }
                    }
                    
                    self.updateDayLbl()
                }
            }
        }
    }
    
    func uploadMediaMsg(messageId: String) {
        if let image = self.selectedImage {
            let file_name = "\(messageId)"
            let path = self.addFile(image: image, to: file_name)
            
            if let image = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            } else {
                print("Image saved to path data error ")
            }
            if path != "" {
                ChatCoreDataHelper.sharedChatDBHelper.addMediaUploadLog(messageId: messageId, mediaUrl: path, uploadState: "Not Uploaded")
                //ChatCacheManager.shared.uploadImageMsg(path, messageId)
            }
        }
    }
}

extension ChatScreenViewController: UIImagePickerControllerDelegate, AvatarUpdateDelegate, HTTPRequesterDelegate {
    
    func addFile(image: UIImage, to filename: String) -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        
        let percentage = 100
        
        let finalPercentage = Float(percentage) / 100
        
        let imageData: Data = NSData(data: image.jpegData(compressionQuality: CGFloat(finalPercentage))!) as Data
        
        let filename = documentsDirectory.appendingPathComponent("\(filename).jpg")
        do {
            try? imageData.write(to: URL(fileURLWithPath: filename), options: [.atomic])
            return filename
        } catch let error {
            return ""
        }
    }
    
    func didUpdateAvatar(_ image: UIImage, avatarUrl: String) {
        
        self.shouldRemoveObserver = true
        if KeekChatBuilder.shared.isConnectionActive == .connected {
            self.mediaMsgBtn.isUserInteractionEnabled = false
            self.selectedImage = image
            let chatMeta = ChatMessageMetaData(metaKey: "", metaValue: "")
            if chatType == .oneToOne {
                let message = SendMessageToUserModel(toUserId: "\(threadInfoObj?.userID ?? "")", message: "IMAGE", chatId: "\(threadInfoObj?.threadID ?? "")", eMessageType: .media, chatMessageMetaDatas: [chatMeta])
                if KeekChatBuilder.shared.isConnectionActive == .connected {
                    KeekChatBuilder.shared.sendMsg(msgModel: message)
                }
            } else {
                let message = SendMessageToGroupModel(message: "IMAGE", chatId: "\(threadInfoObj?.threadID ?? "")", eMessageType: .media, chatMessageMetaDatas: [chatMeta])
                if KeekChatBuilder.shared.isConnectionActive == .connected {
                    KeekChatBuilder.shared.sendMsgToGroup(msgModel: message)
                }
            }
        } else {
            UIUtil.apiFailure("poorInternetConnectivity".localized, vc: self)
        }
        
    }
    
}

extension ChatScreenViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj = self.messages[indexPath.row]
        if obj.messageType == 1 {
            if obj.externalUserId == ChatModel.sharedInstance.userId {
                let cell = tableView.dequeueReusableCell(withIdentifier: ImageMsgTableViewCell.reuseIdentifier, for: indexPath)
                as? ImageMsgTableViewCell ?? ImageMsgTableViewCell()
                self.loadSentImageMessageCell(cell: cell, indexPath: indexPath, obj: obj)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ImageReceivedTableViewCell.reuseIdentifier, for: indexPath)
                as? ImageReceivedTableViewCell ?? ImageReceivedTableViewCell()
                self.loadReceivedImageMessageCell(cell: cell, indexPath: indexPath, obj: obj)
                return cell
            }
        } else if obj.messageType == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.reuseIdentifier, for: indexPath)
            as? InfoTableViewCell ?? InfoTableViewCell()
            self.loadInfoMsgCell(cell: cell, indexPath: indexPath, obj: obj)
            return cell
        } else {
            if obj.externalUserId == ChatModel.sharedInstance.userId {
                let cell = tableView.dequeueReusableCell(withIdentifier: SentMsgTableViewCell.reuseIdentifier, for: indexPath)
                as? SentMsgTableViewCell ?? SentMsgTableViewCell()
                self.loadSentTextMsgCell(cell: cell, indexPath: indexPath, obj: obj)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReceivedMsgTableViewCell.reuseIdentifier, for: indexPath)
                as? ReceivedMsgTableViewCell ?? ReceivedMsgTableViewCell()
                self.loadReceivedTextMsgCell(cell: cell, indexPath: indexPath, obj: obj)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.color = .MiiTV_ThemeClr()
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            if !self.allMsgsRowsLoaded {
                self.mainTableView.tableFooterView = spinner
                self.mainTableView.tableFooterView?.isHidden = false
            } else {
                self.mainTableView.tableFooterView = nil
                self.mainTableView.tableFooterView?.isHidden = true
            }
        }
        
        if shouldMarkAsRead {
            let obj = messages[indexPath.row]
            if !obj.isReadByMe && obj.messageType != 3 {
                if KeekChatBuilder.shared.isConnectionActive == .connected && obj.externalUserId != ChatModel.sharedInstance.userId {
                    KeekChatBuilder.shared.readMsg(messageId: obj.messageId)
                    
                    obj.isReadByMe = true
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if deleteModeOn {
            self.handleDeleteMode(indexPath: indexPath)
        } 
    }
    
    func handleDeleteMode(indexPath: IndexPath) {
        let obj = self.messages[indexPath.row]
        if obj.externalUserId == ChatModel.sharedInstance.userId && obj.messageType != 3 {
            if deleteModeOn {
                if !self.selectedIndex.contains([indexPath.row]) {
                    self.selectedIndex.append(indexPath.row)
                    if self.messages[indexPath.row].messageType == 0 {
                        if let cell = mainTableView.cellForRow(at: indexPath) as? SentMsgTableViewCell {
                            cell.selectionBlurView.isHidden = false
                            self.deleteModeOn = true
                        }
                    } else if self.messages[indexPath.row].messageType == 1 {
                        if let cell = mainTableView.cellForRow(at: indexPath) as? ImageMsgTableViewCell {
                            cell.selectionBlurView.isHidden = false
                            self.deleteModeOn = true
                        }
                    }
                } else {
                    selectedIndex.removeAll { $0 == indexPath.row }
                    if self.messages[indexPath.row].messageType == 0 {
                        if let cell = mainTableView.cellForRow(at: indexPath) as? SentMsgTableViewCell {
                            cell.selectionBlurView.isHidden = true
                        }
                    } else if self.messages[indexPath.row].messageType == 1 {
                        if let cell = mainTableView.cellForRow(at: indexPath) as? ImageMsgTableViewCell {
                            cell.selectionBlurView.isHidden = true
                        }
                    }
                    if selectedIndex.count == 0 {
                        self.deleteModeOn = false
                        self.mediaMsgBtn.isUserInteractionEnabled = true
                        self.textMsgBtn.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            // Handle the long press
            if !self.deleteModeOn {
                if let indexPath = mainTableView.indexPathForRow(at: sender.location(in: mainTableView)) {
                    self.messageTextfield.resignFirstResponder()
                    self.mediaMsgBtn.isUserInteractionEnabled = false
                    self.textMsgBtn.isUserInteractionEnabled = false
                    self.selectedIndex.append(indexPath.row)
                    if self.messages[indexPath.row].messageType == 0 {
                        if let cell = mainTableView.cellForRow(at: indexPath) as? SentMsgTableViewCell {
                            cell.selectionBlurView.isHidden = false
                            self.deleteModeOn = true
                        }
                    } else if self.messages[indexPath.row].messageType == 1 {
                        if let cell = mainTableView.cellForRow(at: indexPath) as? ImageMsgTableViewCell {
                            cell.selectionBlurView.isHidden = false
                            self.deleteModeOn = true
                        }
                    }
                }
            }
        }
    }
    
    func loadSentImageMessageCell(cell: ImageMsgTableViewCell, indexPath: IndexPath, obj: ChatMessage) {
        
        cell.selectionStyle = .none
        cell.messageNo = indexPath.row
        cell.delegate = self
        cell.timeLbl.text = UIUtil.dateFromMillisecondsDateString(date: obj.messageTimeSecs)
        DispatchQueue.main.async {
            cell.showLoader()
            cell.imageMsgView.image = UIImage(named: "img_placeholder")
            let url = obj.thumbnailImageUrl
            if obj.thumbnailImageUrl == "" {
                cell.imageMsgView.image = UIImage(named: "img_placeholder")
            } else {
                cell.imageMsgView.sd_setImage(with: NSURL(string: url) as URL?, completed: { (_, error, _, _) in
                    if error != nil {
                        cell.imageMsgView.image = UIImage(named: "img_placeholder")
                    }
                    cell.hideLoader()
                })
            }
        }
        let profileurl = obj.userAvatarUrl
        if profileurl != "" {
            cell.profileImgview.sd_setImage(with: NSURL(string: profileurl) as URL?, completed: { (_, error, _, _) in
                if error != nil {
                    cell.profileImgview.image = UIImage(named: "profile")
                }
            })
        } else {
            cell.profileImgview.image = UIImage(named: "profile")
        }
        if self.checkIfNextMsgIsSameType(indexNo: indexPath.row, chatUserId: obj.userId) {
            cell.shouldShowProfilePicture = false
        } else {
            cell.profileImgview.isHidden = false
            cell.shouldShowProfilePicture = true
        }
        
        if self.messages.count - 1 > indexPath.row {
            if self.checkIfNextMsgIsSameDay(dateString1: obj.messageTime, dateString2: self.messages[indexPath.row+1].messageTime) {
                cell.showDateLbl = false
            } else {
                let date = UIUtil.stringDateToTopString(dateToConvert: obj.messageTime)
                cell.showDateLbl = true
                cell.date = date
            }
        } else {
            cell.showDateLbl = false
        }
        cell.updateCellUI()
        if obj.isRead {
            cell.readStatusLbl.textColor = .MiiTV_ThemeClr()
        } else {
            cell.readStatusLbl.textColor = UIColor.gray
        }
        if obj.postId != "" {
            cell.playView.isHidden = false
        } else {
            cell.playView.isHidden = true
        }
        cell.transform = CGAffineTransformMakeScale(1, -1)
        if self.selectedIndex.contains([indexPath.row]) {
            cell.selectionBlurView.isHidden = false
        } else {
            cell.selectionBlurView.isHidden = true
        }
        if let isActive = threadInfoObj?.isActive {
            if isActive {
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
                cell.addGestureRecognizer(longPressGesture)
            }
        }
    }
    
    func loadReceivedImageMessageCell(cell: ImageReceivedTableViewCell, indexPath: IndexPath, obj: ChatMessage) {
        cell.selectionStyle = .none
        cell.messageNo = indexPath.row
        cell.delegate = self
        cell.timeLbl.text = UIUtil.dateFromMillisecondsDateString(date: obj.messageTimeSecs)
        cell.imageMsgView.image = UIImage(named: "img_placeholder")
        let url = obj.thumbnailImageUrl
        cell.imageMsgView.sd_setImage(with: NSURL(string: url) as URL?, completed: { (_, error, _, _) in
            if error != nil {
                cell.imageMsgView.image = UIImage(named: "img_placeholder")
            }
        })
        if self.checkIfNextMsgIsSameType(indexNo: indexPath.row, chatUserId: obj.userId) {
            cell.shouldShowProfilePicture = false
        } else {
            cell.profileImgview.isHidden = false
            cell.shouldShowProfilePicture = true
        }
        cell.usernameLbl.text = "@\(obj.userName)"
        if self.messages.count - 1 > indexPath.row {
            if self.checkIfNextMsgIsSameDay(dateString1: obj.messageTime, dateString2: self.messages[indexPath.row+1].messageTime) {
                cell.shouldShowDayLbl = false
            } else {
                let date = UIUtil.stringDateToTopString(dateToConvert: obj.messageTime)
                cell.shouldShowDayLbl = true
                cell.date = date
            }
        } else {
            cell.shouldShowDayLbl = false
        }
        
        if indexPath.row == self.unreadMsgCount - 1 {
            cell.shouldShowUnreadLbl = true
        } else {
            cell.shouldShowUnreadLbl = false
        }
        if self.chatType == .group {
            cell.shouldShowUsername = true
        } else {
            cell.shouldShowUsername = false
        }
        
        cell.updateCellUI()
        let profileurl = obj.userAvatarUrl
        if profileurl != "" {
            cell.profileImgview.sd_setImage(with: NSURL(string: profileurl) as URL?, completed: { (_, error, _, _) in
                if error != nil {
                    cell.profileImgview.image = UIImage(named: "profile")
                }
            })
        } else {
            cell.profileImgview.image = UIImage(named: "profile")
        }
        if obj.postId != "" {
            cell.playView.isHidden = false
        } else {
            cell.playView.isHidden = true
        }
        cell.transform = CGAffineTransformMakeScale(1, -1)
    }
  
    func loadSentTextMsgCell(cell: SentMsgTableViewCell, indexPath: IndexPath, obj: ChatMessage) {
        
        cell.selectionStyle = .none
        cell.messageLbl.text = obj.messageText
        cell.urlDelegate = self
        cell.timeLbl.text = UIUtil.dateFromMillisecondsDateString(date: obj.messageTimeSecs)
        if self.checkIfNextMsgIsSameType(indexNo: indexPath.row, chatUserId: obj.userId) {
            cell.shouldShowProfilePicture = false
        } else {
            cell.profileImgview.isHidden = false
            cell.shouldShowProfilePicture = true
        }
        
        if self.messages.count - 1 > indexPath.row {
            if self.checkIfNextMsgIsSameDay(dateString1: obj.messageTime, dateString2: self.messages[indexPath.row+1].messageTime) {
                cell.showDateLbl = false
            } else {
                let date = UIUtil.stringDateToTopString(dateToConvert: obj.messageTime)
                cell.showDateLbl = true
                cell.date = date
            }
        } else {
            cell.showDateLbl = false
        }
        cell.updateCellUI()
        if let url = ChatModel.sharedInstance.users.avatarUrl {
            cell.profileImgview.sd_setImage(with: NSURL(string: url) as URL?, completed: { (_, error, _, _) in
                if error != nil {
                    cell.profileImgview.image = UIImage(named: "profile")
                }
            })
        } else {
            cell.profileImgview.image = UIImage(named: "profile")
        }
        
        if obj.isRead {
            cell.readStatusLbl.textColor = .MiiTV_ThemeClr()
        } else {
            cell.readStatusLbl.textColor = UIColor.gray
        }
        cell.transform = CGAffineTransformMakeScale(1, -1)
        if self.selectedIndex.contains([indexPath.row]) {
            cell.selectionBlurView.isHidden = false
        } else {
            cell.selectionBlurView.isHidden = true
        }
        if let isActive = threadInfoObj?.isActive {
            if isActive {
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
                cell.addGestureRecognizer(longPressGesture)
            }
        }
    }
    
    func loadReceivedTextMsgCell(cell: ReceivedMsgTableViewCell, indexPath: IndexPath, obj: ChatMessage) {
        cell.selectionStyle = .none
        
        cell.timeLbl.text = UIUtil.dateFromMillisecondsDateString(date: obj.messageTimeSecs)
        cell.messageLbl.text = obj.messageText
        cell.urlDelegate = self
        if self.checkIfNextMsgIsSameType(indexNo: indexPath.row, chatUserId: obj.userId) {
            cell.shouldShowProfilePicture = false
        } else {
            cell.profileImgview.isHidden = false
            cell.shouldShowProfilePicture = true
        }
        if self.messages.count - 1 > indexPath.row {
            if self.checkIfNextMsgIsSameDay(dateString1: obj.messageTime, dateString2: self.messages[indexPath.row+1].messageTime) {
                cell.shouldShowDayLbl = false
            } else {
                let date = UIUtil.stringDateToTopString(dateToConvert: obj.messageTime)
                cell.shouldShowDayLbl = true
                cell.date = date
            }
        } else {
            cell.shouldShowDayLbl = false
        }
        
        if indexPath.row == self.unreadMsgCount - 1 {
            cell.shouldShowUnreadLbl = true
        } else {
            cell.shouldShowUnreadLbl = false
        }
        
        if self.chatType == .group && cell.shouldShowProfilePicture {
            cell.usernameLbl.text = "@\(obj.userName)"
            cell.usernameLbl.sizeToFit()
            cell.shouldShowUsername = true
        } else {
            cell.usernameLbl.text = ""
            cell.shouldShowUsername = false
        }
        
        cell.updateCellUI()
        cell.profileImgview.image = UIImage(named: "profile")
        let url = obj.userAvatarUrl
        if url != "" {
            cell.profileImgview.sd_setImage(with: NSURL(string: url) as URL?, completed: { (_, error, _, _) in
                if error != nil {
                    cell.profileImgview.image = UIImage(named: "profile")
                }
            })
        } else {
            cell.profileImgview.image = UIImage(named: "profile")
        }
        cell.transform = CGAffineTransformMakeScale(1, -1)
    }
    
    func loadInfoMsgCell(cell: InfoTableViewCell, indexPath: IndexPath, obj: ChatMessage) {
        cell.selectionStyle = .none
        cell.transform = CGAffineTransformMakeScale(1, -1)
        cell.infoLbl.text = obj.messageText
        if obj.messageText == GroupInfoMsgType.GroupCreated.rawValue {
            if obj.externalUserId == ChatModel.sharedInstance.userId {
                cell.infoLbl.text = "youCreatedGroup".localized + " \"\(chatName)\""
            } else {
                cell.infoLbl.text = "@\(obj.userName) " + "createdGroup".localized + " \"\(chatName)\""
            }
        } else {
            cell.infoLbl.text = "\(obj.messageText)"
        }
        cell.infoLbl.layer.cornerRadius = (cell.infoLbl.bounds.height / 2) + 4
    }
}

extension ChatScreenViewController: URLNavigationDelegate {
    func openLink(url: String) {
        if !deleteModeOn {
            var urlString = url
                if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                    urlString = "https://" + urlString
                }
            if let newurl = URL(string: urlString) {
                let vc = SFSafariViewController(url: newurl)
                vc.modalPresentationStyle = .fullScreen
                self.shouldRemoveObserver = false
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
}
