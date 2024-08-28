//
//  MiiTVFollowersController.swift
//  Peeks
//
//  Created by Nishu Sharma on 26/04/22.
//  Copyright © 2022 Riavera. All rights reserved.
//

// swiftlint:disable type_body_length

import UIKit

protocol ShowBottomTabbarDelegate {
    func showTabbar()
    func goToSearchKeek()
    func refreshSearchKeek()
}
protocol FollowUserDelegate {
    func UserFollowed()
}


class MiiTVFollowersController: UIViewController {
   
    //MARK: IBAction
    @IBAction func actionBackBtn(_ sender : Any) {
        if isOtherUser {
            self.dismiss(animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    @IBAction func actionSearchBtn(_ sender : Any) {
        self.view.endEditing(true)
        UIUtil.indicateActivityForView(self.view, labelText: "")
        let searchStr = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if self.userType == .followers {
            self.getFollowersList(name: searchStr ?? "", isRefresh: true)
        }
        else if self.userType == .following {
            self.getFollowingList(name: searchStr ?? "", isRefresh: true)
        }
        if self.userType == .followers {
            self.followerSearchStr = searchStr ?? ""
        } else if self.userType == .following {
            self.followingSearchStr = searchStr ?? ""
        }
    }
    
    @IBAction func actionFollowingBtn(_ sender : Any)
    {
        self.view.endEditing(true)
        self.SelectOptions(type: .following)
        self.userType = .following
        self.refreshTableView()
        self.searchTextField.text = followingSearchStr
    }
    
    @IBAction func actionFollowerBtn(_ sender : Any)
    {
        self.view.endEditing(true)
        self.SelectOptions(type: .followers)
        self.userType = .followers
        self.refreshTableView()
        self.searchTextField.text = followerSearchStr
    }
    @IBAction func actionBlocked(_ sender : Any)
    {
        self.view.endEditing(true)
        self.SelectOptions(type: .blocked)
        self.userType = .blocked
        self.refreshTableView()
    }
    
    
    //MARK: IBOutlet
    
    @IBOutlet weak var viewHeader : UIView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnSearch : UIButton!
    @IBOutlet weak var ViewSearchbar: UIView!
    @IBOutlet weak var searchTextField: MyTextField!
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var lblTitles : UILabel!
    
    
    @IBOutlet weak var lblFollowers : UILabel!
    @IBOutlet weak var viewFollowerLine : UIView!
    @IBOutlet weak var lblFollowing : UILabel!
    @IBOutlet weak var viewFollowingLine : UIView!
    
    @IBOutlet weak var lblBlocked : UILabel!
    @IBOutlet weak var viewBlockedLine : UIView!
    
    @IBOutlet weak var lblNoRecordFound : UILabel!
    @IBOutlet weak var btnBlocked : UIButton!
    
    @IBOutlet var searchKeekButton: MyButton!
 
    
    //MARK: Variables
    
    var type: UserStatisticsType = .following
    var FollowingArray: [User] = []
    var FollowerArray: [User] = []
    var BlockedUserArray: [User] = []
    var user : User!
    var showTabDelegate : ShowBottomTabbarDelegate!
    var refreshControl = UIRefreshControl()
    var totalRowOfFollowing = 0
    var totalRowOfFollower = 0
    var followerSearchStr = ""
    var followingSearchStr = ""
    var isOtherUser = true
    var userType : UserStatisticsType = .followers
    var orientations = UIInterfaceOrientationMask.portrait
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return self.orientations }
        set { self.orientations = newValue }
        }
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userType = .followers
        self.setupTheme()
        self.lblNoRecordFound.isHidden = true
        self.setupTableview()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        var msg = ""
        if self.userType == .following {
            msg = "loadingFollowing".localized
        } else if self.userType == .followers {
            msg = "loadingFollowers".localized
        } else {
            msg = "loading".localized
        }
        
        UIUtil.indicateActivityForView(self.view, labelText: msg)
        self.getFollowersList(name: "", isRefresh: true)
        self.getFollowingList(name: "", isRefresh: true)
        self.getBlocked()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        if self.isMovingFromParent
        {
            if showTabDelegate != nil
            {
                showTabDelegate.showTabbar()
            }
        }
        
    }
    
    //MARK: Methods
    func setupTheme()
    {
        self.tableView.backgroundColor = .MiiTV_BGColor()
        self.view.backgroundColor = .MiiTV_BGColor()
        self.viewHeader.backgroundColor = .MiiTV_BGColor()
        self.searchTextField.font = .Roboto14_Reg()
        self.searchTextField.textColor = .MiiTV_LightBlack()
        self.searchTextField.textAlignment = .left
        self.searchTextField.delegate = self
        self.searchTextField.spellCheckingType = .no
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
    
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "intro_done".localized, style: .done, target: self, action: #selector(self.doneButtonAction))
        
        done.tintColor = .black
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        doneToolbar.isHidden = false
        searchTextField.inputAccessoryView = doneToolbar
        
        AddThemeToButton(btn: btnBack, titles: IconFontManager.icon_left_arrow, color: .MiiTV_Black(), size: 22.0)
        AddThemeToButton(btn: btnSearch, titles: IconFontManager.icon_search, color: .MiiTV_Black(), size: 20.0)
        
        self.ViewSearchbar.backgroundColor = UIColor.init(hexString: "707070", alpha: 0.07)
        self.ViewSearchbar.setCornerRadius(radius: 20.0)
        
        self.navigationController?.navigationBar.isHidden = true
        
        
        self.lblTitles.text = "Followers".localized
        self.lblTitles.font = .Roboto_Bold_Size(size: 30)
        self.lblTitles.textAlignment = .left
        self.lblTitles.textColor = .MiiTV_Black()
        
        lblFollowers.text = "Followers".localized
        lblFollowers.font = .Roboto18_Bold()
        viewFollowerLine.backgroundColor = .MiiTV_MediumPinkClr()
        viewFollowerLine.setCornerRadius(radius: 2.0)
        
        lblFollowing.text = "profile_following".localized
        lblFollowing.font = .Roboto18_Reg()
        viewFollowingLine.backgroundColor = .MiiTV_MediumPinkClr()
        viewFollowingLine.setCornerRadius(radius: 2.0)
        
        
        if isOtherUser {
            lblBlocked.isHidden = true
            viewBlockedLine.isHidden = true
            btnBlocked.isHidden = true
        }
        lblBlocked.text = "profile_blocked".localized
        lblBlocked.font = .Roboto18_Reg()
        viewBlockedLine.backgroundColor = .MiiTV_MediumPinkClr()
        viewBlockedLine.setCornerRadius(radius: 2.0)
        
        self.SelectOptions(type: .followers)
        self.lblNoRecordFound.text = "".localized
        self.lblNoRecordFound.font = .Roboto18_Reg()
        self.lblNoRecordFound.textColor = .MiiTV_Gray()
        self.lblNoRecordFound.textAlignment = .center
        self.lblNoRecordFound.isHidden = true
        self.searchKeekButton.isHidden = true
    }
    
    @IBAction func searchKeekBtnAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true, completion: {
            if self.showTabDelegate != nil
            {
                self.showTabDelegate.goToSearchKeek()
            }
        })
        
    }
    
    func SelectOptions(type: UserStatisticsType) {
        let bold = UIFont.Roboto18_Bold()
        let regular = UIFont.Roboto18_Reg()
        let selcolor = UIColor.MiiTV_Black()
        let deselcolor = UIColor.init(hexString: "8F9BB3")?.withAlphaComponent(0.80)
        
        if type == .followers {
            self.ViewSearchbar.isHidden = false
            
            self.viewFollowerLine.isHidden = false
            self.viewFollowingLine.isHidden = true
            self.viewBlockedLine.isHidden = true
            
            self.lblFollowers.font = bold
            self.lblFollowing.font = regular
            self.lblBlocked.font = regular
            
            self.lblFollowers.textColor = selcolor
            self.lblFollowing.textColor = deselcolor
            self.lblBlocked.textColor = deselcolor
            
            self.lblTitles.text = "Followers".localized
            self.searchTextField.placeholder = "searchFollower".localized
            if FollowerArray.count == 0 {
                self.lblNoRecordFound.isHidden = false
                if self.followerSearchStr == "" && !isOtherUser {
                    self.lblNoRecordFound.text = "No_followers".localized
                } else {
                    if isOtherUser && self.followerSearchStr.count == 0 {
                        self.lblNoRecordFound.text = "No_followers_OtherUser".localized
                    } else {
                        self.lblNoRecordFound.text = "noResultFound".localized
                    }
                }
            } else {
                self.lblNoRecordFound.isHidden = true
            }
            self.searchKeekButton.isHidden = true
        } else if type == .following {
            self.ViewSearchbar.isHidden = false
            self.viewFollowerLine.isHidden = true
            self.viewFollowingLine.isHidden = false
            self.viewBlockedLine.isHidden = true
            
            self.lblFollowers.font = regular
            self.lblFollowing.font = bold
            self.lblBlocked.font = regular
            
            self.lblFollowers.textColor = deselcolor
            self.lblFollowing.textColor = selcolor
            self.lblBlocked.textColor = deselcolor
            
            self.lblTitles.text = "profile_following".localized
            self.searchTextField.placeholder = "searchFollowing".localized
            if FollowingArray.count == 0 {
                self.lblNoRecordFound.isHidden = false
                if self.followingSearchStr == "" && !isOtherUser {
                    self.lblNoRecordFound.text = "No_following".localized
                    self.searchKeekButton.isHidden = false
                } else {
                    if isOtherUser && self.followingSearchStr.count == 0 {
                        self.lblNoRecordFound.text = "No_followingUser_OtherUser".localized
                        self.searchKeekButton.isHidden = true
                    } else {
                        self.lblNoRecordFound.text = "noResultFound".localized
                        self.searchKeekButton.isHidden = true
                    }
                }
                
            } else {
                self.lblNoRecordFound.isHidden = true
                self.searchKeekButton.isHidden = true
            }
        } else {
            self.ViewSearchbar.isHidden = true
            self.viewFollowerLine.isHidden = true
            self.viewFollowingLine.isHidden = true
            self.viewBlockedLine.isHidden = false
            
            self.lblFollowers.font = regular
            self.lblFollowing.font = regular
            self.lblBlocked.font = bold
            
            self.lblFollowers.textColor = deselcolor
            self.lblFollowing.textColor = deselcolor
            self.lblBlocked.textColor = selcolor
            
            self.lblTitles.text = "Blocked".localized
            self.searchTextField.placeholder = "searchBlocked".localized
            self.lblNoRecordFound.text = "No_blocked".localized
            if BlockedUserArray.count == 0 {
                self.lblNoRecordFound.isHidden = false
            } else {
                self.lblNoRecordFound.isHidden = true
            }
            self.searchKeekButton.isHidden = true
        }
        
    }

    func setupTableview() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MiiTVFollowerCell", bundle: nil), forCellReuseIdentifier: MiiTVFollowerCell.identifier)
        
        refreshControl.tintColor = .MiiTV_ThemeClr()
        refreshControl.addTarget(self, action: #selector(self.ReloadList), for: .valueChanged)
        tableView.addSubview(refreshControl)
        self.lblNoRecordFound.isHidden = true
    }
    
    @objc func ReloadList() {
        let searchStr = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if self.userType == .followers {
            if searchStr.count > 0 {
                self.getFollowersList(name: searchStr, isRefresh: false)
            } else {
                self.getFollowersList(name: "", isRefresh: true)
            }
        } else if self.userType == .following {
            if searchStr.count > 0 {
                self.getFollowingList(name: searchStr, isRefresh: false)
            } else {
                self.getFollowingList(name: "", isRefresh: true)
            }
        } else if self.userType == .blocked {
            self.getBlocked()
        }
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func refreshTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            UIUtil.removeActivityViewFromView(self.view)
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK:- Api calls
    
    func getFollowingList(name : String, isRefresh : Bool) {
        var offSet = 0
        if isRefresh == false {
            offSet = FollowingArray.count
        }
        let userId = (user != nil) ? user!.id : ChatModel.sharedInstance.userId
        FollowersConnector().getListOfFollowing(userId, name: name, order: "username", offset: offSet, limit: 20) { (success, error, followings, totalRows, _ offset, _ limit) in
            
            if success {
                DispatchQueue.main.async {
                    if let followingsArray = followings, let totalRows = totalRows {
                        self.totalRowOfFollowing = totalRows
                        if isRefresh == true {
                            self.FollowingArray.removeAll()
                            self.FollowingArray += followingsArray
                        } else {
                            self.FollowingArray += followingsArray
                        }
                        if self.userType == .following {
                            self.refreshTableView()
                            self.SelectOptions(type: .following)
                        }
                    }
                }
            } else {
                
                DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                    UIUtil.removeActivityViewFromView(self.view)
                    UIUtil.apiFailure(error!, vc: self)
                }
            }
        }
    }
    
    func getFollowersList(name : String, isRefresh : Bool) {
        let userId = (user != nil) ? user!.id : ChatModel.sharedInstance.userId
        
        var offSet = 0
        
        if !isRefresh {
            offSet = FollowerArray.count
        } else {
            if userType == .followers {
                self.lblNoRecordFound.isHidden = true
                self.lblNoRecordFound.text = "No_followers".localized
            }
        }
        
        FollowersConnector().getListOfFollowers(userId, name: name, order: "username", offset: offSet, limit: 20) { (success, error, followers, totalRows, _ offset, _ limit) in
           
            if success {
                DispatchQueue.main.async {
                    if let followersArray = followers, let totalRows = totalRows {
                        self.totalRowOfFollower = totalRows
                        if isRefresh == true {
                            self.FollowerArray.removeAll()
                            self.FollowerArray += followersArray
                        } else {
                            self.FollowerArray += followersArray
                        }
                        self.refreshTableView()
                        if self.userType == .followers {
                            
                            self.SelectOptions(type: .followers)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                    UIUtil.removeActivityViewFromView(self.view)
                    UIUtil.apiFailure(error!, vc: self)
                }
            }
        }
    }
    
    func getBlocked() {
//        UserConnector().listOfBlockedUsers { (success, error, users) in
//            if success {
//                if let blockedArray = users {
//                    self.BlockedUserArray.removeAll()
//                    self.BlockedUserArray = blockedArray
//                    if self.userType == .blocked
//                    {
//                        self.refreshTableView()
//                    }
//                }
//            } else {
//                UIUtil.apiFailure(error!, vc: self)
//            }
//        }
    }
    
    // MARK: - User actions
    func presentBlockActions(_ fUser: User, indexPath: IndexPath) {
        let yesAction = UIAlertAction(title: "yes".localized, style: .default, handler: {(_ alert: UIAlertAction!) -> Void in
            self.blockUser(fUser, indexPath: indexPath)
        })
        let cancelAction = UIAlertAction(title: "no".localized, style: .cancel, handler: nil)
        present(UIAlertController.createBasicActionSheet("stream_block_alert".localized, yesAction: yesAction, cancelAction: cancelAction), animated: true, completion: nil)
    }
    
    
    func Followuser(_ fUser: User) {
        UIUtil.indicateActivityForView(self.view, labelText: "folowingLoader".localized)
        UserActions.follow(fUser, successBlock: {
            
            DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                if self.showTabDelegate != nil {
                    self.showTabDelegate.refreshSearchKeek()
                }
                UIUtil.removeActivityViewFromView(self.view)
                if self.userType == .followers {
                    self.followingSearchStr = ""
                    self.followerSearchStr = ""
                    self.searchTextField.text = ""
                    UIUtil.indicateActivityForView(self.view, labelText: "loadingFollowers".localized)
                    self.getFollowersList(name: "", isRefresh: true)
                    self.getFollowingList(name: "", isRefresh: true)
                }
            }
        })
    }
    
    func sendFollowRequest(_ fUser: User) {
        UIUtil.indicateActivityForView(self.view, labelText: "folowingLoader".localized)
        UserActions.followRequest(fUser, successBlock: {

            DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                UIUtil.removeActivityViewFromView(self.view)
                if self.showTabDelegate != nil {
                    self.showTabDelegate.refreshSearchKeek()
                }
                if self.userType == .followers {
                    self.followingSearchStr = ""
                    self.followerSearchStr = ""
                    self.searchTextField.text = ""
                    UIUtil.indicateActivityForView(self.view, labelText: "loadingFollowers".localized)
                    self.getFollowersList(name: "", isRefresh: true)
                    self.getFollowingList(name: "", isRefresh: true)
                }
            }

        })
    }
    
    func cancelFollowRequest(_ fUser: User) {
        UIUtil.indicateActivityForView(self.view, labelText: "cancelRequestLoader".localized)
        UserActions.deleteFollowRequest(fUser, successBlock: {

            DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                if self.showTabDelegate != nil {
                    self.showTabDelegate.refreshSearchKeek()
                }
                UIUtil.removeActivityViewFromView(self.view)
                if self.userType == .followers {
                    self.followingSearchStr = ""
                    self.followerSearchStr = ""
                    self.searchTextField.text = ""
                    UIUtil.indicateActivityForView(self.view, labelText: "loadingFollowers".localized)
                    self.getFollowersList(name: "", isRefresh: true)
                    self.getFollowingList(name: "", isRefresh: true)
                }
            }

        })
    }
    func removeUser(_ fUser: User) {
        UIUtil.indicateActivityForView(self.view, labelText: "Removing User")
        UserActions.removeUser(fUser, successBlock: {
                DispatchQueue.main.async{ [weak self] in guard let self = self else { return }
                    self.followingSearchStr = ""
                    self.searchTextField.text = ""
                    if self.showTabDelegate != nil {
                        self.showTabDelegate.refreshSearchKeek()
                    }
                    var msg = ""
                    if self.userType == .following {
                        msg = "loadingFollowing".localized
                    }
                    else
                    if self.userType == .followers {
                        msg = "loadingFollowers".localized
                    }
                    else {
                        msg = "loading".localized
                    }
                    
                    UIUtil.indicateActivityForView(self.view, labelText: msg)
                    self.getFollowingList(name: "", isRefresh: true)
                    self.getFollowersList(name: "", isRefresh: true)
                    self.getBlocked()
                }
            

        })
    }
    
//    func reportUser(_ fUser: User) {
//        let vc = ReportSheetViewController()
//                   vc.reportObj = .user
//       //            vc.userId = ChatModel.sharedInstance.userId
//    vc.reportObjID = fUser.id
//                   vc.modalPresentationStyle = .overCurrentContext
//                   self.present(vc, animated: false)
//    }
    
    func blockUser(_ fUser: User, indexPath: IndexPath) {
        UIUtil.indicateActivityForView(self.view, labelText: "blockingLoader".localized)
        UserConnector().blockUser(fUser) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    if self.showTabDelegate != nil {
                        self.showTabDelegate.refreshSearchKeek()
                    }
                }
                if self.userType == .following || self.userType == .followers {
                    DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                        self.followingSearchStr = ""
                        self.searchTextField.text = ""
                        
                        var msg = ""
                        if self.userType == .following {
                            msg = "loadingFollowing".localized
                        }
                        else
                        if self.userType == .followers {
                            msg = "loadingFollowers".localized
                        }
                        else {
                            msg = "loading".localized
                        }
                        
                        UIUtil.indicateActivityForView(self.view, labelText: msg)
                        self.getFollowingList(name: "", isRefresh: true)
                        self.getFollowersList(name: "", isRefresh: true)
                        self.getBlocked()
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                    UIUtil.removeActivityViewFromView(self.view)
                    UIUtil.apiFailure(error!, vc: self)
                }
            }
        }
    }
    
    func didUnblockUser(_ fUser: User, indexPath: IndexPath) {
//        dataSource?.userStatsArray.remove(at: indexPath.row)
        refreshTableView()
    }
    
    func didFollowUser(_ user: User, indexPath: IndexPath) {
        refreshTableView()
        Notification.Name.addToFollowingUserStats.post(userInfo: ["user": user])
    }
    
    func unfollowUser(_ fUser: User, indexPath: IndexPath) {
        UIUtil.indicateActivityForView(self.view, labelText: "Unfollowing...".localized)
        UserActions.unfollow(fUser, successBlock: {
            DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                if self.showTabDelegate != nil {
                    self.showTabDelegate.refreshSearchKeek()
                }
                UIUtil.removeActivityViewFromView(self.view)
                if self.userType == .following || self.userType == .followers {
                    self.followingSearchStr = ""
                    self.followerSearchStr = ""
                    self.searchTextField.text = ""
                    
                    var msg = ""
                    if self.userType == .following {
                        msg = "loading".localized
                    }
                    else
                    if self.userType == .followers {
                        msg = "loading".localized
                    }
                    else {
                        msg = "loading".localized
                    }
                    
                    UIUtil.indicateActivityForView(self.view, labelText: msg)
                    self.getFollowersList(name: "", isRefresh: true)
                    self.getFollowingList(name: "", isRefresh: true)
                }
            }
        })
    }
    
    func UnBlockuser(_ fUser: User, indexPath: IndexPath) {
        UIUtil.indicateActivityForView(self.view, labelText: "unblockingLoader".localized)
        UserActions.unblock(fUser) {
            DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                if self.showTabDelegate != nil {
                    self.showTabDelegate.refreshSearchKeek()
                }
                UIUtil.indicateActivityForView(self.view, labelText: "blockedLoader".localized)
                self.getBlocked()
            }
        } failureBlock: {
            DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                UIUtil.removeActivityViewFromView(self.view)
            }
        }
    }
    
    func goToUserProfile(_ user: User) {
        DispatchQueue.main.async(execute: {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let vc = storyboard.instantiateViewController(withIdentifier: "ProfileView") as? ProfileViewController {
//                vc.userId = user.id
//                vc.followUserDelegate = self
//                if self.isOtherUser {
//                    vc.fromFeed = true
//                    vc.fromFollowers = true
//                    vc.modalPresentationStyle = .fullScreen
//                    self.present(vc, animated: true)
//                } else {
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//                
//            }
        })
    }
    
    func goToUserChat(fromCell: Bool, _ user: User) {
        if fromCell {
            let group = DispatchGroup()
            group.enter()

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .userSelectedCustomContacts, object: nil, userInfo: ["username": user.chatID])
                group.leave()
            }

            group.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            self.showFirebaseChatUI(userId: user.chatID)
        }
    }

}
extension MiiTVFollowersController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table View Stuff
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userType == .followers {
            if FollowerArray.count > 0 {
                lblNoRecordFound.isHidden = true
                tableView.isHidden = false
                return FollowerArray.count
            } else {
                lblNoRecordFound.isHidden = false
                tableView.isHidden = true
                return 0
            }
        } else if self.userType == .following {
            if FollowingArray.count > 0 {
                lblNoRecordFound.isHidden = true
                tableView.isHidden = false
                return FollowingArray.count
            } else {
                lblNoRecordFound.isHidden = false
                tableView.isHidden = true
                return 0
            }
        } else if self.userType == .blocked {
            if BlockedUserArray.count > 0 {
                lblNoRecordFound.isHidden = true
                tableView.isHidden = false
                return BlockedUserArray.count
            } else {
                lblNoRecordFound.isHidden = false
                tableView.isHidden = true
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MiiTVFollowerCell.identifier, for: indexPath)
            as? MiiTVFollowerCell ?? MiiTVFollowerCell()
        
        var user = User.init()
        if self.userType == .followers {
            user = FollowerArray[indexPath.row]
            
            if indexPath.row == FollowerArray.count - 1 {
                if totalRowOfFollower != FollowerArray.count && FollowerArray.count < totalRowOfFollower {
                    let searchStr = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    self.getFollowersList(name: searchStr, isRefresh: false)
                }
            }
        } else if self.userType == .following {
            user = FollowingArray[indexPath.row]
            if indexPath.row == FollowingArray.count - 1 {
                if totalRowOfFollowing != FollowingArray.count && FollowingArray.count < totalRowOfFollowing {
                    UIUtil.indicateActivityForView(self.view, labelText: "loadingFollowing".localized)
                    let searchStr = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    self.getFollowingList(name: searchStr, isRefresh: false)
                }
            }
        } else if self.userType == .blocked {
            user = BlockedUserArray[indexPath.row]
        }
        cell.delegate = self
        cell.update(user)
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if userType != .blocked {
            let user: User = {
                if self.userType == .followers {
                    return self.FollowerArray[indexPath.row]
                } else {
                    return self.FollowingArray[indexPath.row]
                }
            }()
            
            if ChatModel.sharedInstance.userId != user.id {
                self.goToUserProfile(user)
            }
        }
    }

}

extension MiiTVFollowersController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.actionSearchBtn(self)
        
        return true
    }
}
   
extension MiiTVFollowersController : MiiTVSelectMoreActionProtocol,FollowUserDelegate
{
    func UserFollowed()
    {
        DispatchQueue.main.async
        { [weak self] in guard let self = self else { return }
            self.followingSearchStr = ""
            self.followerSearchStr = ""
            self.searchTextField.text = ""
            UIUtil.indicateActivityForView(self.view, labelText: "loadingFollowers".localized)
            self.getFollowersList(name: "", isRefresh: true)
            self.getFollowingList(name: "", isRefresh: true)
        }
    }
    
    func PassSelectedIndex(index: Int)
    {
        let TempPeekuser : User = {
            if self.userType == .followers {
                return self.FollowerArray[index]
            } else if self.userType == .following {
                return self.FollowingArray[index]
            } else if self.userType == .blocked {
                return self.BlockedUserArray[index]
            } else { return User.init() }
        }()
        let indexpath = IndexPath.init(row: index, section: 0)
                                
        if self.userType == .following || self.userType == .followers {
            let controller = UIAlertController(title: "alert".localized, message: "ChooseAction".localized, preferredStyle: .actionSheet)
            var follow = UIAlertAction()
            let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (_ ) in }
            let unfollow = UIAlertAction(title: "user_options_unfollow".localized, style: .default) { (_ ) in
                self.unfollowUser(TempPeekuser, indexPath: indexpath)
            }
            
            let cancelRequest = UIAlertAction(title: "CancelRequest".localized, style: .default) { (_ ) in
                self.cancelFollowRequest(TempPeekuser)
            }

            let followBack = UIAlertAction(title: "Follow Back".localized, style: .default) { (_ ) in
                if TempPeekuser.isPrivate {
                    self.sendFollowRequest(TempPeekuser)
                } else {
                    self.Followuser(TempPeekuser)
                }
               
           }
            
            follow = UIAlertAction(title: "Follow".localized, style: .default) { (_ ) in
                if !TempPeekuser.isPrivate {
                    self.Followuser(TempPeekuser)
                } else {
                    self.sendFollowRequest(TempPeekuser)
                }
           }
            
            let remove = UIAlertAction(title: "Remove", style: .default) { (_ ) in
                self.removeUser(TempPeekuser)
            }
            
            let block = UIAlertAction(title: "user_card_block".localized, style: .default) { (_ ) in
                self.presentBlockActions(TempPeekuser, indexPath: indexpath)
            }
            
            let report = UIAlertAction(title: "user_options_report".localized, style: .default) { (_ ) in
               // self.reportUser(TempPeekuser)
            }

            if TempPeekuser.isFollowingThem {
                controller.addAction(unfollow)
            } else {
                if TempPeekuser.isPrivate && TempPeekuser.followRequested {
                    controller.addAction(cancelRequest)
                } else {
                    if TempPeekuser.isFollowingMe {
                        controller.addAction(followBack)
                    } else {
                        controller.addAction(follow)
                    }
                }
            }
            if TempPeekuser.isFollowingMe {
                controller.addAction(remove)
            }
            
            controller.addAction(block)
            controller.addAction(report)
            controller.addAction(cancel)
            controller.view.tintColor = .MiiTV_ThemeClr()
            self.present(controller, animated: true, completion: nil)
        } else if self.userType == .blocked {
            let controller = UIAlertController(title: "alert".localized, message: "ChooseAction".localized, preferredStyle: .actionSheet)
            let Unblock = UIAlertAction(title: "user_options_unblock".localized, style: .default) { (_ ) in
                self.UnBlockuser(TempPeekuser, indexPath: IndexPath.init(row: index, section: 0))
            }
            
            let report = UIAlertAction(title: "user_options_report".localized, style: .default) { (_ ) in
               // self.reportUser(TempPeekuser)
                
            }
            
            let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (_ ) in }
            controller.addAction(Unblock)
            controller.addAction(report)
            controller.addAction(cancel)
            controller.view.tintColor = .MiiTV_ThemeClr()
            self.present(controller, animated: true, completion: nil)
        }
    }
}

