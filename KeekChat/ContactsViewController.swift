//
//  ContactsViewController.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 08/12/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit
enum ToFollowersFrom {
    case group
    case messages
    case groupChat
}

protocol MiitvPrivateAudienceDelegate: class {
    func audienceSelected(streamSelectedFollowers: [User], allFollowers: Bool)
    func groupMembersSelected(selectedMembers: [String])
    func audienceNotSelected()
}

protocol CreateChatDelegate: class {
    func openChat(toUserID: String, chatID: String, username: String, userStatus: String, dpUrl: String)
    func failToOpenChat()
}

class ContactsViewController: UIViewController {

    @IBOutlet var viewHeader: UILabel!
    //    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var ViewSearchbar: UIView!
    @IBOutlet weak var searchTextField: MyTextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblNoRecordFound: UILabel!
    @IBOutlet var selectAllView: UIView!
    var lineView: UIView?
    @IBOutlet var selectAllBtn: UIButton!
    @IBOutlet var subtitleLbl: UILabel!
    
    @IBOutlet var doneBtn: MyButton!
    
    @IBOutlet var doneBtnHeight: NSLayoutConstraint!
    var type: UserStatisticsType = .following
    var FollowingArray: [User] = []
    var FollowerArray: [User] = []
    var BlockedUserArray: [User] = []
    var user: User!
    var showTabDelegate: ShowBottomTabbarDelegate!
    var refreshControl = UIRefreshControl()
    var totalRowOfFollowing = 0
    var totalRowOfFollower = 0
    var followerSearchStr = ""
    var followingSearchStr = ""
    var userType: UserStatisticsType = .followers
    var streamAudienceIDs: String = ""
    var streamSelectedFollowers: [User] = []
    var selectedAll = false
    var delegate: MiitvPrivateAudienceDelegate?
    var chatDelegate: CreateChatDelegate?
    var originalFollowerCount = 0
    var orientations = UIInterfaceOrientationMask.portrait
        override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        get { return self.orientations }
        set { self.orientations = newValue }
        }
    
    var selectedFollowers: [String] = []
    var isDataLoaded = false
    var fromScreen: ToFollowersFrom = .group
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableview()
        UIUtil.indicateActivityForView(self.view, labelText: "Loading...")
        self.lblNoRecordFound.isHidden = true
        self.getFollowersList(name: "", isRefresh: true)
        self.selectAllBtn.isHidden = true
        setupThem(contact: viewHeader, myContact: subtitleLbl, backBtn: btnBack, searchBtn: btnSearch, txtSearchFollowers: searchTextField, searchView: ViewSearchbar)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:
                                                                                       )))
        selectAllView.addGestureRecognizer(tap)
        if fromScreen == .group {
            viewHeader.text = "Followers".localized
            subtitleLbl.text = "Followers".localized
            doneBtn.setTitle("intro_done".localized, for: .normal)
            searchTextField.placeholder = "private_broadcast_search_followers".localized
            lblNoRecordFound.text = "No_followers".localized
           
        } else if fromScreen == .messages || fromScreen == .groupChat {
            viewHeader.text = "My Contacts".localized
            
            subtitleLbl.text = "Contacts".localized
            
            doneBtn.setTitle("intro_done".localized, for: .normal)
            
            searchTextField.placeholder = "Search Contacts".localized
            lblNoRecordFound.text = "NoContactsResult".localized
            
        }
        if fromScreen == .messages {
            doneBtn.isHidden = true
            doneBtnHeight.constant = 0
        } else {
            doneBtnHeight.constant = 48
        }
        searchTextField.delegate = self
    }
    
    func setupTableview() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MiiTVFollowerCell", bundle: nil), forCellReuseIdentifier: MiiTVFollowerCell.identifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {

    }
    
    func updateSelectAll() {
        // handling code
        
        if self.selectedAll {
            self.selectAllBtn.isHidden = false
        self.streamSelectedFollowers = []
        for obj in self.FollowerArray {
            self.streamSelectedFollowers.append(obj)
        }
        } else {
            self.selectAllBtn.isHidden = true
            self.streamSelectedFollowers = []
        }
        self.tableView.reloadData()
    }
func setupThem(contact:UILabel,myContact:UILabel,backBtn:UIButton,searchBtn:UIButton,txtSearchFollowers:UITextField,searchView:UIView){
        
        let contactStyle = ChatStyle.shared.contact
        contact.setStyle(style: contactStyle)
    
        let myContactStyle = ChatStyle.shared.myContact
        myContact.setStyle(style: myContactStyle)
        
        let backBtnStyle = ChatStyle.shared.backBtn
        backBtn.setStyle(style: backBtnStyle)
        
        let searchBtnStyle = ChatStyle.shared.SearchBtn
        searchBtn.setStyle(style: searchBtnStyle)
        
        let txtSearchStyle = ChatStyle.shared.txtSearch
        txtSearchFollowers.placeholder = txtSearchStyle.text
        txtSearchFollowers.textColor = txtSearchStyle.textColor
        txtSearchFollowers.font = txtSearchStyle.font
        
        let searchViewStyle = ChatStyle.shared.searchView
        searchView.layer.borderColor = searchViewStyle.borderColor
        searchView.layer.borderWidth = CGFloat(searchViewStyle.borderWidth)
        searchView.layer.cornerRadius = CGFloat(searchViewStyle.cornerRadius)
        
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false) {
            self.delegate?.groupMembersSelected(selectedMembers: self.selectedFollowers)
            if self.streamSelectedFollowers.count == self.originalFollowerCount {
            self.delegate?.audienceSelected(streamSelectedFollowers: self.streamSelectedFollowers, allFollowers: true)
            } else {
                self.delegate?.audienceSelected(streamSelectedFollowers: self.streamSelectedFollowers, allFollowers: false)
            }
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false) {
            self.delegate?.audienceNotSelected()
        }
    }
    
    @IBAction func actionSearchBtn(_ sender : Any) {
        self.view.endEditing(true)
        UIUtil.indicateActivityForView(self.view, labelText: "")
        let searchStr = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.getFollowersList(name: searchStr ?? "", isRefresh: true)
    }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource, MiiTVSelectMoreActionProtocol {
    func PassSelectedIndex(index: Int) {

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if fromScreen == .messages {
            UIUtil.indicateActivityForView(self.view, labelText: "Loading...")
            
                let user = self.FollowerArray[indexPath.row]
               
                ChatConnector().getChatTokenForUser(user.id) { success, error, toUserId, chatId, userStatus, dpUrl in
                    
                    if success {
                        DispatchQueue.main.async {
                            UIUtil.removeActivityViewFromView(self.view)
                            self.dismiss(animated: false) {
                                self.chatDelegate?.openChat(toUserID: toUserId ?? "", chatID: chatId ?? "", username: user.username, userStatus: userStatus ?? "Offline", dpUrl: dpUrl ?? "")
                            }
                        }
                    } else {
                        print("Could not connect to chat at the moment \(error)")
                        DispatchQueue.main.async {
                            UIUtil.removeActivityViewFromView(self.view)
                            self.dismiss(animated: false) {
                                self.chatDelegate?.failToOpenChat()
                            }
                        }
                    }
                }
            
        } else {
            let user = FollowerArray[indexPath.row]
            var userRemoved = false
            if self.streamSelectedFollowers.count != 0 {
                for i in 0...self.streamSelectedFollowers.count-1 {
                    let selecteduser = self.streamSelectedFollowers[i]
                    if selecteduser == user {
                        self.streamSelectedFollowers.remove(at: i)
                        userRemoved = true
                        break
                    }
                }
            }
            
            if !userRemoved {
                self.streamSelectedFollowers.append(user)
            }
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FollowerArray.count > 0 {
            lblNoRecordFound.isHidden = true
            tableView.isHidden = false
            return FollowerArray.count
        } else {
            if isDataLoaded {
                lblNoRecordFound.isHidden = false
                
            }
            tableView.isHidden = true
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MiiTVFollowerCell.identifier, for: indexPath)
        as? MiiTVFollowerCell ?? MiiTVFollowerCell()
        
        var user = User.init()
        
        user = FollowerArray[indexPath.row]
        
        if indexPath.row == FollowerArray.count - 1 {
            if totalRowOfFollower != FollowerArray.count && FollowerArray.count < totalRowOfFollower {
                let searchStr = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                self.getFollowersList(name: searchStr, isRefresh: false)
            }
        }
        cell.delegate = self
        cell.update(user)
        if self.fromScreen == .messages {
            cell.btnMore.setTitle("", for: .normal)
            cell.btnMore.isUserInteractionEnabled = false
            cell.btnMore.layer.cornerRadius = 0
            cell.btnMore.layer.borderWidth = 0
            cell.btnMore.setTitleColor(#colorLiteral(red: 1, green: 0.2404623032, blue: 0.4438095093, alpha: 1), for: .normal)
        } else {
            if self.streamSelectedFollowers.contains(user) {
                cell.btnMore.setTitle("", for: .normal)
                cell.btnMore.isUserInteractionEnabled = false
                cell.btnMore.layer.cornerRadius = 0
                cell.btnMore.layer.borderWidth = 0
                cell.btnMore.setTitleColor(#colorLiteral(red: 1, green: 0.2404623032, blue: 0.4438095093, alpha: 1), for: .normal)
            } else {
                cell.btnMore.setTitle("", for: .normal)
                cell.btnMore.isUserInteractionEnabled = false
                cell.btnMore.layer.cornerRadius = 10
                cell.btnMore.layer.borderWidth = 2
                cell.btnMore.layer.borderColor = UIColor.black.cgColor
                cell.btnMore.setTitleColor(UIColor.black, for: .normal)
            }
        }
//        if self.streamSelectedFollowers.contains(user) {
//            cell.btnMore.isHidden = false
//        } else {
//            cell.btnMore.isHidden = true
//        }
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 68
    }
    
    func getFollowersList(name: String, isRefresh: Bool) {
       
        if self.fromScreen == .messages || self.fromScreen == .groupChat {
           
            self.getFollowingList(name: name, isRefresh: isRefresh)
        } else {
            let userId = (user != nil) ? user!.id : ChatModel.sharedInstance.userId
            
            var offSet = 0
            
            if isRefresh == false {
                offSet = FollowerArray.count
            }
            
            FollowersConnector().getListOfFollowers(userId, name: name, order: "username", offset: offSet, limit: 20) { (success, error, followers, totalRows, _ offset, _ limit) in
                self.isDataLoaded = true
                if success {
                    if let followersArray = followers, let totalRows = totalRows {
                        self.totalRowOfFollower = totalRows
                        
                        if isRefresh == true {
                            if name == "" {
                                self.originalFollowerCount = totalRows
                            }
                            self.FollowerArray.removeAll()
                            self.FollowerArray += followersArray
                        } else {
                            self.FollowerArray += followersArray
                            self.originalFollowerCount = self.FollowerArray.count
                        }
                        self.refreshTableView()
                    }
                } else {
                    DispatchQueue.main.async {
                        [weak self] in guard let self = self else { return }
                        UIUtil.removeActivityViewFromView(self.view)
                        
                        UIUtil.showAlertWithButtons(btnNo: "", btnYes: "OK", msg: error!, vc: self) {
                            self.animatedDismissVc()
                        }
                    }
                }
            }
        }
    }
    
    func getFollowingList(name: String, isRefresh: Bool) {
        let userId = (user != nil) ? user!.id : ChatModel.sharedInstance.userId
        
        var offSet = 0
        
        if isRefresh == false {
            offSet = FollowerArray.count
        }
        
        FollowersConnector().getListOfFollowing(userId, name: name, order: "username", offset: offSet, limit: 20) { (success, error, followers, totalRows, _ offset, _ limit) in
            self.isDataLoaded = true
            if success {
                DispatchQueue.main.async {
                    if let followersArray = followers, let totalRows = totalRows {
                        self.totalRowOfFollower = totalRows
                        
                        if isRefresh == true {
                            if name == "" {
                                self.originalFollowerCount = totalRows
                            }
                            self.FollowerArray.removeAll()
                            self.FollowerArray += followersArray
                        } else {
                            self.FollowerArray += followersArray
                            self.originalFollowerCount = self.FollowerArray.count
                        }
                        if name == "" {
                            self.lblNoRecordFound.text = "Your chat list is waiting to come alive! Start following users and engaging in vibrant conversations."
                        } else {
                            self.lblNoRecordFound.text = "We couldn’t find what you were looking for. Please try a different search term.".localized
                        }
                        self.refreshTableView()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    [weak self] in guard let self = self else { return }
                    UIUtil.removeActivityViewFromView(self.view)
                    
                    UIUtil.showAlertWithButtons(btnNo: "", btnYes: "OK", msg: error!, vc: self) {
                        self.animatedDismissVc()
                    }
                }
            }
        }
    }
    func refreshTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
//            self.updateSelectAll()
            UIUtil.removeActivityViewFromView(self.view)
            self.refreshControl.endRefreshing()
        }
    }
}

extension ContactsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.actionSearchBtn(self)
//        if self.userType == .followers {
            self.followerSearchStr = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
//        } else if self.userType == .following {
//            self.followingSearchStr = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
//        }
        return true
    }
}
