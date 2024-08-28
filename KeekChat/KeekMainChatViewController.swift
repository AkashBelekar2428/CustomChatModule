//
//  KeekMainChatViewController.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 19/07/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit
import SDWebImage

class KeekMainChatViewController: UIViewController {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var lblNoRecord: UILabel!
    @IBOutlet var groupsSelector: MyView!
    @IBOutlet var conversationSelector: MyView!
    @IBOutlet var groupsBtn: UIButton!
    @IBOutlet var conversationBtn: UIButton!
    @IBOutlet var messagesTableview: UITableView!
    @IBOutlet var btnCreateNewChat: UIButton!
    var showPrivateMessage = true
    var privateThreads: [ThreadInfo] = []
    var groupThreads: [ThreadInfo] = []
    var messageRefreshComp = UIRefreshControl()
    var orientations = UIInterfaceOrientationMask.portrait
    var isLoadingGroupMsgs = false
    var isLoadingPrivateMsgs = false
    var allPrivateChatsLoaded = false
    var allGroupChatsLoaded = false
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return self.orientations }
        set { self.orientations = newValue }
    }
    var hasRefreshedData: Bool = true
    var isLoadingConversation = false
    var showingLoader = false
    var privateChatTimestamp: Int64 = 0
    var hasReceivedPrivateReloadedCache = true
    var groupChatTimestamp: Int64 = 0
    var hasReceivedGroupReloadedCache = false
    
    var chatConfig:ChatConfig?
    
    private let loaderView = LoaderView()
    
    override func loadView() {
        super.loadView()
        if let chatConfig{
            ChatModel.sharedInstance.initateWithConfig(config: chatConfig)
        } else {
            fatalError("Chat configuration need to be initialized")
        }
        
        if KeekChatBuilder.shared.isConnectionActive == .disconnected {
            KeekChatBuilder.shared.initialize()
            KeekChatBuilder.shared.addNetworkObserver()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // setupLoader()        
        self.configureTable()
        conversationSelector.isHidden = false
        groupsSelector.isHidden = true
        self.getPrivateChats(isRefresh: true)
        self.getGroupChats(isRefresh: true)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePrivateThread), name: Notification.Name("ReceivedNewMessagePrivateThread"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupThread), name: Notification.Name("ReceivedNewMessageGroupThread"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getNewPrivateThreadList), name: Notification.Name("UpdatePrivateThreadList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getNewGroupThreadList), name: Notification.Name("UpdateGroupThreadList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkNetworkConnection(_:)), name: Notification.Name("ReachabilityStatusChangedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserStatus(_:)), name: Notification.Name("UpdateUserStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshGroupThreadList), name: Notification.Name("GroupWasEdited"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lastPrivateMsgDeleted), name: Notification.Name("LastPrivateMessageDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lastGroupMsgDeleted), name: Notification.Name("LastGroupMessageDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(manageUserWasBlocked(_ :)), name: Notification.Name("UserWasBlocked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(manageUserWasUnBlocked(_ :)), name: Notification.Name("UserWasUnblocked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUnreadCount(_ :)), name: Notification.Name("UpdateUnreadCount"), object: nil)
        
        Reach().monitorReachabilityChanges()
        lblNoRecord.text = "no_chat_conversation".localized
        setUpThem(msgTitle: titleLbl, convsersation: conversationBtn, group: groupsBtn, addBtn: btnCreateNewChat)
    
        ChatCacheManager.shared.uploadAllPendingMedia()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshChatCacheDone), name: Notification.Name("RefreshChatCacheDone"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshChatCacheBegin), name: Notification.Name("RefreshChatCacheBegin"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("UpdateChatNotifier"), object: nil, userInfo: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("RefreshChatCacheBegin"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("RefreshChatCacheDone"), object: nil)
        isLoadingConversation = false
    }
    
    func setUpThem(msgTitle:UILabel, convsersation:UIButton, group:UIButton, addBtn:UIButton){
        let messaageStyle = ChatStyle.shared.messageTitle
        msgTitle.setStyle(style: messaageStyle)
        
        let conversationBtnStyle = ChatStyle.shared.conversation
        convsersation.setStyle(style: conversationBtnStyle)
        
        let grpBtnStyle = ChatStyle.shared.groups
        group.setStyle(style: grpBtnStyle)
        
        
        let addBtnStyle = ChatStyle.shared.addContactBtn
        addBtn.setStyle(style: addBtnStyle)
        
    }
    
    func setupLoader() {
         loaderView.frame = view.bounds
         view.addSubview(loaderView)
       loaderView.startLoading()
       performSomeOperation()
     }

     private func performSomeOperation() {
         loaderView.startLoading()
         
         // Simulate a network request or any operation
         DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
             DispatchQueue.main.async {
                 self.loaderView.stopLoading()
             }
         }
     }
    
    @objc func appMovedToBackground() {
        isLoadingPrivateMsgs = false
        isLoadingGroupMsgs = false
        if KeekChatBuilder.shared.isConnectionActive == .connected {
            KeekChatBuilder.shared.disconnectChat()
        }
    }
    
    @objc func appMovedToForeground() {
        ChatModel.sharedInstance.isUpdatingPrivateChat = true
        ChatModel.sharedInstance.isUpdatingGroupChat = true
        NotificationCenter.default.post(name: Notification.Name("RefreshChatCacheBegin"), object: nil, userInfo: nil)
        self.getPrivateChats(isRefresh: true, shouldForceUpdate: true)
        self.getGroupChats(isRefresh: true, shouldForceUpdate: true)
        if KeekChatBuilder.shared.isConnectionActive == .disconnected {
            KeekChatBuilder.shared.initialize()
        }
        NotificationCenter.default.post(name: Notification.Name("UpdateChatNotifier"), object: nil, userInfo: nil)
        
    }
    
    @objc func refreshChatCacheDone() {
        if !ChatModel.sharedInstance.isUpdatingGroupChat && !ChatModel.sharedInstance.isUpdatingPrivateChat {
            DispatchQueue.main.async { [self] in
                UIUtil.removeActivityViewFromView(self.view)
                showingLoader = false
            }
        }
    }
    
    @objc func refreshChatCacheBegin() {
        if !showingLoader {
            DispatchQueue.main.async {
                UIUtil.indicateActivityForView(self.view, labelText: "")
            }
        }
    }
    
    @IBAction func groupsAction(_ sender: Any) {
        conversationSelector.isHidden = true
        groupsSelector.isHidden = false
        showPrivateMessage = false
        self.groupsBtn.titleLabel!.font = .Roboto18_Bold()
        self.groupsBtn.setTitleColor(UIColor.black, for: .normal)
        
        messagesTableview.reloadData()
        lblNoRecord.text = "no_group_chat".localized
    }
    
    @IBAction func conversationsAction(_ sender: Any) {
        conversationSelector.isHidden = false
        groupsSelector.isHidden = true
        showPrivateMessage = true
        messagesTableview.reloadData()
        lblNoRecord.text = "no_chat_conversation".localized
    }
    
    func configureTable() {
        MainChatTableViewCell.registerNib(messagesTableview)
        CreateChatTableViewCell.registerNib(messagesTableview)
        messagesTableview.delegate = self
        messagesTableview.dataSource = self
        messageRefreshComp.tintColor = .MiiTV_ThemeClr()
        messageRefreshComp.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        messagesTableview.addSubview(messageRefreshComp)
    }
    
    @objc func pullToRefresh() {
        if self.showPrivateMessage {
            self.getPrivateChats(isRefresh: true, isPullToRefresh: true)
        } else {
            self.getGroupChats(isRefresh: true, isPullToRefresh: true)
        }
    }
    
    @IBAction func createNewChat(_ sender: Any) {
        if self.showPrivateMessage {
            self.openContacts()
        } else {
            self.createGroup()
        }
    }
}

// MARK: - Methods to load data into table

extension KeekMainChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showPrivateMessage {
            if self.privateThreads.count == 0 {
                self.lblNoRecord.isHidden = false
            } else {
                self.lblNoRecord.isHidden = true
            }
            return privateThreads.count
        } else {
            if self.groupThreads.count == 0 {
                self.lblNoRecord.isHidden = false
            } else {
                self.lblNoRecord.isHidden = true
            }
            return groupThreads.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainChatTableViewCell.reuseIdentifier, for: indexPath)
        as? MainChatTableViewCell ?? MainChatTableViewCell()
        cell.selectionStyle = .none
        cell.messageLbl.text = ""
        if self.showPrivateMessage {
            let obj = self.privateThreads[indexPath.row]
            cell.usernameLbl.text = "@\(obj.userName)"
            if obj.unreadMsgCount > 0 {
                cell.messageCountView.isHidden = false
                cell.messageCountLbl.text = "\(obj.unreadMsgCount)"
            } else {
                cell.messageCountView.isHidden = true
            }
            
            if obj.userStatus == "Online" {
                
                cell.profileImgview.borderwidth = 2
            } else {
                
                cell.profileImgview.borderwidth = 0
            }
            cell.messageLbl.text = obj.lastMsgText
            cell.timeLbl.text = UIUtil.dayDateFromMilliseconds(milliseconds: obj.lastMsgTimeSecs)
            cell.profileImgview.image = UIImage(named: "profile")
            var url = obj.userAvatarUrl
            if url != "" {
                cell.profileImgview.sd_setImage(with: NSURL(string: url) as URL?, completed: { (_, error, _, _) in
                    if error != nil {
                        cell.profileImgview.image = UIImage(named: "profile")
                    }
                })
            } else {
                cell.profileImgview.image = UIImage(named: "profile")
            }
        } else {
            let obj = self.groupThreads[indexPath.row]
            cell.usernameLbl.text = "@\(obj.userName)"
            if obj.unreadMsgCount > 0 {
                cell.messageCountView.isHidden = false
                cell.messageCountLbl.text = "\(obj.unreadMsgCount)"
                cell.profileImgview.borderwidth = 2
            } else {
                cell.messageCountView.isHidden = true
                cell.profileImgview.borderwidth = 0
            }
            
            if obj.lastMsgType == .text {
                cell.messageLbl.text = obj.lastMsgText
            } else if obj.lastMsgType == .info {
                if obj.lastMsgText == GroupInfoMsgType.GroupCreated.rawValue {
                    if obj.adminExtUserId == ChatModel.sharedInstance.userId {
                        cell.messageLbl.text = "youCreatedGroup".localized + " \"\(obj.userName)\""
                    } else {
                        cell.messageLbl.text = "@\(obj.adminUserName) " + "createdGroup".localized + " \"\(obj.userName)\""
                    }
                } else {
                    cell.messageLbl.text = obj.lastMsgText
                }
            } else if obj.lastMsgType == .media {
                cell.messageLbl.text = obj.lastMsgText
            }
            cell.timeLbl.text = UIUtil.dayDateFromMilliseconds(milliseconds: obj.lastMsgTimeSecs)
            cell.profileImgview.image = UIImage(named: "groupProfile")
            var url = obj.userAvatarUrl
            if url != "" {
                cell.profileImgview.sd_setImage(with: NSURL(string: url) as URL?, completed: { (_, error, _, _) in
                    if error != nil {
                        cell.profileImgview.image = UIImage(named: "groupProfile")
                    }
                })
            } else {
                cell.profileImgview.image = UIImage(named: "groupProfile")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoadingConversation {
            isLoadingConversation = true
            if self.showPrivateMessage {
                let obj = self.privateThreads[indexPath.row]
                self.getPrivateChatMessages(obj: obj)
            } else {
                let obj = self.groupThreads[indexPath.row]
                self.getGroupChatMessages(obj: obj)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
                let deleteAction = UIContextualAction(style: .destructive, title: "Delete".localized, handler: {
                    (action, sourceView, completionHandler) in
                    self.deleteThread(indexPath: indexPath)
                    completionHandler(true)
                }
                )
                deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                deleteAction.image = UIImage(named: "close")
                let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
                
                return swipeConfiguration
            
    }
    
    func deleteThread(indexPath: IndexPath) {
        UIUtil.showAlertWithButtons(btnNo: "cancel".localized, btnYes: "Delete".localized, msg: "deleteThreadConfirmation".localized, title: "", vc: self) { [self] in
            if showPrivateMessage {
                let obj = self.privateThreads[indexPath.row]
                self.deleteChatThread(threadID: obj.threadID)
            } else {
                let obj = self.groupThreads[indexPath.row]
                self.deleteChatThread(threadID: obj.threadID)
            }
        }
       
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var secondLastIndexPath = IndexPath(row: messagesTableview.numberOfRows(inSection: 0) - 2, section: 0)
        secondLastIndexPath = secondLastIndexPath.row == -2 ? IndexPath(row: 0, section: 0) : secondLastIndexPath
        if let secondLastCellRect = messagesTableview.rectForRow(at: secondLastIndexPath) as CGRect?, messagesTableview.bounds.contains(secondLastCellRect) {
            
            if !isLoadingPrivateMsgs && !allPrivateChatsLoaded && self.showPrivateMessage {
                self.getPrivateChats(isRefresh: false)
            } else if !isLoadingGroupMsgs && !allGroupChatsLoaded && !self.showPrivateMessage {
                self.getGroupChats(isRefresh: false)
            }
        }
    }

}

// MARK: - Methods to create or navigate to chat from contacts

extension KeekMainChatViewController: CreateChatDelegate, StartConversationDelegate, CreateGrpForChatControllerDelegate {
    
    func groupCreated(groupId: String, groupName: String, groupChatId: String, groupDpUrl: String) {
        let thread = ThreadInfo()
        thread.groupId = groupId
        thread.threadID = groupChatId
        thread.userName = groupName
        thread.userAvatarUrl = groupDpUrl
        thread.adminUserName = ChatModel.sharedInstance.users.username
        thread.adminExtUserId = ChatModel.sharedInstance.userId
        thread.adminChatId = ChatModel.sharedInstance.chatUserID
        ChatCoreDataHelper.sharedChatDBHelper.addGroupThread(groupThread: thread)
        self.getGroupChatMessages(obj: thread)
        self.getGroupChats(isRefresh: true)
    }
    
    func failToOpenChat() {
        UIUtil.apiFailure("user_not_available".localized, vc: self)
    }
    
    func createNewChat() {
        if self.showPrivateMessage {
            self.openContacts()
        } else {
            self.createGroup()
        }
    }
    
    func openChat(toUserID: String, chatID: String, username: String, userStatus: String, dpUrl: String) {
        isLoadingConversation = true
        if let desiredThread = self.privateThreads.first(where: { $0.threadID == chatID }) {
            self.getPrivateChatMessages(obj: desiredThread)
        } else {
            let thread = ThreadInfo()
            thread.threadID = chatID
            thread.userID = toUserID
            thread.userName = username
            thread.userStatus = userStatus
            thread.userAvatarUrl = dpUrl
            thread.isBlocked = false
            ChatCoreDataHelper.sharedChatDBHelper.addPrivateThread(tempThread: thread)
            self.getPrivateChatMessages(obj: thread)
        }
    }
    
    func createGroup() {
        let vc = CreateChatGroupViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.chatCreateGrpDelegate = self
        self.animatedPresentVC(vc)
    }
    
    func goToChat(chatMessages: [ChatMessage], userName: String, threadObj: ThreadInfo, totalMsgCount: Int, chatType: ChatType) {
        DispatchQueue.main.async {
            let vc = ChatScreenViewController()
            vc.messages = chatMessages
            vc.chatName = userName
            vc.chatType = chatType
            vc.threadInfoObj = threadObj
            vc.totalMsgCount = totalMsgCount
            vc.delegate = self
            vc.unreadMsgCount = threadObj.unreadMsgCount
            if vc.unreadMsgCount > 0 {
                vc.shouldAddUnreadCount = true
            }
            if chatMessages.count < 10 {
                vc.allMsgsRowsLoaded = true
            }
            vc.modalPresentationStyle = .fullScreen
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.view.window?.layer.add(transition, forKey: kCATransition)
            self.present(vc, animated: false) { [self] in
                isLoadingConversation = false
            }
        }
    }
    
    func openContacts() {
        let vc = ContactsViewController()
        vc.chatDelegate = self
        vc.fromScreen = .messages
        vc.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(vc, animated: false, completion: nil)
    }
}

// MARK: - API stuff of 1 to 1 and group thread list

extension KeekMainChatViewController {
    func getGroupChats(isRefresh: Bool, sendCacheData: Bool = false, shouldForceUpdate: Bool = false, isPullToRefresh: Bool = false) {
        
        if !isRefresh {
            if groupChatTimestamp != self.groupThreads.last?.lastMsgTimeSecs {
                groupChatTimestamp = self.groupThreads.last?.lastMsgTimeSecs ?? 0
            } else {
                return
            }
        } else {
            self.allGroupChatsLoaded = false
            groupChatTimestamp = 0
            self.hasReceivedGroupReloadedCache = false
        }
        if !isLoadingGroupMsgs {
            self.isLoadingGroupMsgs = true
            ChatCacheManager.shared.getGroupThreads(isRefresh: isRefresh, timestamp: groupChatTimestamp, sendCachedData: sendCacheData, shouldForceUpdate: shouldForceUpdate, completion: { success, error, threads, isNewRefreshData in
                if success {
                    DispatchQueue.main.async {
                        
                        if threads!.count == 0 {
                            self.allGroupChatsLoaded = true
                        }
                        if isRefresh {
                            self.groupChatTimestamp = 0
                            self.groupThreads = threads!
                        } else {
                            self.groupThreads += threads!
                        }
                       
                        if !self.showPrivateMessage {
                            
                            self.messagesTableview.reloadData()
                            self.messageRefreshComp.endRefreshing()
                        }
                        if isNewRefreshData {
                            self.isLoadingGroupMsgs = false
                        }
                    }
                } else {
                    if !self.showPrivateMessage {
                        
                            self.messageRefreshComp.endRefreshing()
                            self.isLoadingPrivateMsgs = false
                        
                        UIUtil.apiFailure(error!, vc: self)
                    }
                }
            })
        } else {
            DispatchQueue.main.async { [self] in
                if !self.showPrivateMessage {
                    
                        self.messageRefreshComp.endRefreshing()
                    
                }
            }
        }
    }
    
    func getPrivateChats(isRefresh: Bool, sendCacheData: Bool = false, shouldForceUpdate: Bool = false, isPullToRefresh: Bool = false) {
        if !isRefresh {
            if privateChatTimestamp != self.privateThreads.last?.lastMsgTimeSecs {
                privateChatTimestamp = self.privateThreads.last?.lastMsgTimeSecs ?? 0
            } else {
                return
            }
        } else {
                self.allPrivateChatsLoaded = false
                privateChatTimestamp = 0
                self.hasReceivedPrivateReloadedCache = false
        }
        
        
        if !isLoadingPrivateMsgs {
            self.isLoadingPrivateMsgs = true
            ChatCacheManager.shared.getPrivateThreads(isRefresh: isRefresh, timestamp: privateChatTimestamp, sendCachedData: sendCacheData, shouldForceUpdate: shouldForceUpdate, isPullToRefresh: isPullToRefresh, completion: { success, error, threads, isNewRefreshData in
                if success {
                    DispatchQueue.main.async { [self] in
                        
                        if threads!.count == 0 {
                            self.allPrivateChatsLoaded = true
                        }
                        if isRefresh {
                            self.privateChatTimestamp = 0
                            self.privateThreads = threads!
                        } else {
                            self.privateThreads += threads!
                        }
                        
                        if self.showPrivateMessage {
                            
                            self.messagesTableview.reloadData()
                            self.messageRefreshComp.endRefreshing()
                        }
                        if isNewRefreshData {
                            self.isLoadingPrivateMsgs = false
                        }
                    }
                } else {
                    DispatchQueue.main.async { [self] in
                        if self.showPrivateMessage {
                                self.messageRefreshComp.endRefreshing()
                            self.isLoadingPrivateMsgs = false
                            UIUtil.apiFailure(error!, vc: self)
                        }
                    }
                }
            })
        } else {
            DispatchQueue.main.async { [self] in
                if self.showPrivateMessage {
                        self.messageRefreshComp.endRefreshing()
                }
            }
        }
    }
        

    
    func updateUnreadCount(threadID: String) {
//        if self.showPrivateMessage {
            if !self.privateThreads.isEmpty {
                for i in 0...self.privateThreads.count - 1 {
                    let obj = self.privateThreads[i]
                    if obj.threadID == threadID {
                        if obj.unreadMsgCount > 0 {
                            obj.unreadMsgCount -= 1
                            if self.showPrivateMessage {
                                self.messagesTableview.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                            }
                            return
                        }
                        
                    }
                }
            }
//        } else {
            if !self.groupThreads.isEmpty {
                for i in 0...self.groupThreads.count - 1 {
                    let obj = self.groupThreads[i]
                    if obj.threadID == threadID {
                        if obj.unreadMsgCount > 0 {
                            obj.unreadMsgCount -= 1
                            if !self.showPrivateMessage {
                                self.messagesTableview.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                            }
                            return
                        }
                        
                    }
                }
            }
//        }
    }
    
    func getPrivateChatMessages(obj: ThreadInfo) {
        let currentDate = Utils.convertDateToISODate(Date())
        var pageSize = 10
        if obj.unreadMsgCount > 5 {
            pageSize = obj.unreadMsgCount + 5
        }
        ChatCacheManager.shared.getPrivateChatMessages(threadId: obj.threadID, isRefresh: true, messageUpto: currentDate, pageNo: 1, pageSize: pageSize, threadType: "oneToOne") { success, error, messages, totalMsgCount in
            if success {
                self.goToChat(chatMessages: messages ?? [], userName: obj.userName, threadObj: obj, totalMsgCount: totalMsgCount ?? 0, chatType: .oneToOne)
            } else {
                self.isLoadingConversation = false
                print(error)
            }
        }
    }
    
    func getGroupChatMessages(obj: ThreadInfo) {
        let currentDate = Utils.convertDateToISODate(Date())
        var pageSize = 10
        if obj.unreadMsgCount > 5 {
            pageSize = obj.unreadMsgCount + 5
        }
        ChatCacheManager.shared.getPrivateChatMessages(threadId: obj.threadID, isRefresh: true, messageUpto: currentDate, pageNo: 1, pageSize: pageSize, threadType: "group") { success, error, messages, totalMsgCount in
            if success {
                self.goToChat(chatMessages: messages ?? [], userName: obj.userName, threadObj: obj, totalMsgCount: totalMsgCount ?? 0, chatType: .group)
            } else {
                self.isLoadingConversation = false
                print(error)
            }
        }
    }
    
    func deleteChatThread(threadID: String) {
         showingLoader = true
            UIUtil.indicateActivityForView(self.view, labelText: "Deleting...")
        
        ChatConnector().deleteChatThread(threadId: threadID) { success, error in
            if success {
                DispatchQueue.main.async { [self] in
                    self.appMovedToForeground()
                }
            } else {
                DispatchQueue.main.async {
                    self.showingLoader = false
                    UIUtil.removeActivityViewFromView(self.view)
                    UIUtil.apiFailure("deleteThreadError".localized, vc: self)
                }
            }
        }
        
        
    }
    
    @objc func getNewPrivateThreadList() {
        self.getPrivateChats(isRefresh: true)
    }
    
    @objc func getNewGroupThreadList() {
        self.getGroupChats(isRefresh: true)
    }
    
    @objc func updatePrivateThread() {
        self.getPrivateChats(isRefresh: true, sendCacheData: true)
    }
    
    @objc func updateGroupThread() {
        self.getGroupChats(isRefresh: true, sendCacheData: true)
    }
    
    @objc func refreshGroupThreadList() {
        self.getGroupChats(isRefresh: true, sendCacheData: false)
    }
    
    @objc func updateUnreadCount(_ notification: Notification) {
        
        if let threadID = notification.userInfo?["threadId"] as? String {
            self.updateUnreadCount(threadID: threadID)
        }
    }
}

// MARK: - Methods to handle updates from chat screen

extension KeekMainChatViewController: ChatScreenViewControllerDelegate {
    
    @objc func lastPrivateMsgDeleted() {
        self.getPrivateChats(isRefresh: true)
    }
    
    @objc func lastGroupMsgDeleted() {
        self.getGroupChats(isRefresh: true)
    }
    
    func lastMessageWasDeleted() {
        if self.showPrivateMessage {
            self.getPrivateChats(isRefresh: true)
        } else {
            self.getGroupChats(isRefresh: true)
        }
    }
    
    func unblockUser(extAppUserId: String) {
        let user = User()
        user.id = extAppUserId
//        UserActions.unblock(user) {
//            DispatchQueue.main.async {
//              //  (self.tabBarController as! PeeksTabBarController).refreshSearchKeek()
//            }
//        } failureBlock: {
            
    //    }
    }
    
    func markAllRead(threadId: String) {
        if self.showPrivateMessage {
            if !self.privateThreads.isEmpty {
                for i in 0...self.privateThreads.count - 1 {
                    let obj = self.privateThreads[i]
                    if obj.threadID == threadId {
                        DispatchQueue.main.async {
                            obj.unreadMsgCount = 0
                            self.messagesTableview.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                        }
                    }
                }
            }
        } else {
            if !self.groupThreads.isEmpty {
                for i in 0...self.groupThreads.count - 1 {
                    let obj = self.groupThreads[i]
                    if obj.threadID == threadId {
                        DispatchQueue.main.async {
                            obj.unreadMsgCount = 0
                            self.messagesTableview.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Network stability handling

extension KeekMainChatViewController {
    
    @objc func manageUserWasBlocked(_ notification: Notification) {
        if let threadID = notification.userInfo?["threadID"] as? String {
            DispatchQueue.main.async {
                if !self.privateThreads.isEmpty {
                    for i in 0...self.privateThreads.count - 1 {
                        let obj = self.privateThreads[i]
                        if obj.threadID == threadID {
                            obj.isBlocked = true
                            self.messagesTableview.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                            NotificationCenter.default.post(name: Notification.Name("UserBlockedChatScreen"), object: nil, userInfo: nil)
                        }
                    }
                }
            }
        }
    }

    @objc func manageUserWasUnBlocked(_ notification: Notification) {
        if let threadID = notification.userInfo?["threadID"] as? String {
            DispatchQueue.main.async {
                if !self.privateThreads.isEmpty {
                    for i in 0...self.privateThreads.count - 1 {
                        let obj = self.privateThreads[i]
                        if obj.threadID == threadID {
                            obj.isBlocked = false
                            self.messagesTableview.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                            NotificationCenter.default.post(name: Notification.Name("UserUnBlockedChatScreen"), object: nil, userInfo: nil)
                        }
                    }
                }
            }
        }

    }

    @objc func checkNetworkConnection(_ notification: Notification) {
       
        if let status = notification.userInfo?["Status"] as? String {
            if status == "Offline" {
                self.hasRefreshedData = false
            } else {
                if !self.hasRefreshedData {
                    self.hasRefreshedData = true
                    
                    if self.showPrivateMessage {
                        if self.privateThreads.count > 0 {
                            self.messagesTableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                    } else {
                        if self.groupThreads.count > 0 {
                            self.messagesTableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                    }
                    self.getPrivateChats(isRefresh: true)
                    self.getGroupChats(isRefresh: true)
                }
               // ChatCacheManager.shared.uploadPendingMedia()
                NotificationCenter.default.post(name: Notification.Name("UpdateChatNotifier"), object: nil, userInfo: nil)
            }
        }
    }
    
    @objc func updateUserStatus(_ notification: Notification) {
        if self.showPrivateMessage {
            if let object = notification.userInfo?["userStatus"] as? UserConnectedModel {
                if !self.privateThreads.isEmpty {
                    for i in 0...self.privateThreads.count - 1 {
                        let obj = self.privateThreads[i]
                        if obj.userID == object.id {
                            obj.userStatus = object.userStatus
                            self.messagesTableview.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                        }
                    }
                }
            }
        }
    }
    
    func checkTokenStatus() {
        if ChatModel.sharedInstance.keekChatToken == "" && !ChatModel.sharedInstance.isLoadingKeekChatToken && ChatModel.sharedInstance.userId != "" {
            AuthenticationConnector().getKeekChatToken()
            print("Keek chat token not available")
        }
    }
}
