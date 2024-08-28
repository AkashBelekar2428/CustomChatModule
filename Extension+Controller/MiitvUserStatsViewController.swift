//
//  MiitvUserStatsViewController.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 23/11/22.
//  Copyright © 2022 Riavera. All rights reserved.
//

enum UserStatisticsType: Int {
    case following = 0
    case followers
    case blocked
    case people
    case none
}

import UIKit

protocol UserChatSelectedProtocol {
    func userSelectedForChat(user: ChatUser)
}

class MiitvUserStatsViewController: UIViewController, UITextFieldDelegate, UserStatsDelegate, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    var chatDelegate: UserChatSelectedProtocol?
    var fromChat = false
    
    var dataSource: UserStatsDataSource?
    var prevDataSource: UserStatsDataSource?
    var type: UserStatisticsType = .following
    var viewSetup = false
    var closeButtonEnabled = false
    var orientations = UIInterfaceOrientationMask.portrait
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return self.orientations }
        set { self.orientations = newValue }
        }
    // MARK: - Configuration
    class func instantiate() -> MiitvUserStatsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserStatsViewController") as? MiitvUserStatsViewController ?? MiitvUserStatsViewController()
        return vc
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            search(name: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    lazy var searchBar: UISearchBar = UISearchBar()
    func configure(refresh: Bool) {
        edgesForExtendedLayout = []
        
        dataSource?.tableView = tableView
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
//        tableView.addPullToRefresh(actionHandler: {
//            DispatchQueue.main.async {
//                self.dataSource?.refresh()
//            }
//        })
        
        if chatDelegate != nil || fromChat == true {
            
            dataSource?.fromChat = true
//            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(UserStatsViewController.dismissSelf))
//            navigationItem.rightBarButtonItem?.tintColor = .darkGray
            navigationItem.setRightBarButton(nil, animated: true)
            self.navigationController?.navigationBar.tintColor = .darkGray
            searchBar.searchBarStyle = UISearchBar.Style.prominent
            searchBar.placeholder = " Search..."
            searchBar.sizeToFit()
            searchBar.isTranslucent = false
            searchBar.backgroundImage = UIImage()
            searchBar.delegate = self
            self.view.addSubview(searchBar)
            let headerView = UIView(frame: searchBar.frame)
            self.tableView.tableHeaderView = headerView
        }
            
        if refresh {
            dataSource?.refresh()
        }
        
        switch type {
        case .following:
            NotificationCenter.default.addObserver(self, selector: #selector(MiitvUserStatsViewController.addUserToFollowing(_:)), name: .addToFollowingUserStats, object: nil)
        case .followers:
            NotificationCenter.default.addObserver(self, selector: #selector(MiitvUserStatsViewController.refreshTableView), name: .refreshUserStats, object: nil)
        case .blocked:
            NotificationCenter.default.addObserver(self, selector: #selector(MiitvUserStatsViewController.addUserToBlocked(_:)), name: .addToBlockedUserStats, object: nil)
        default:
            break
        }
    }
    
    @objc func refreshTableView() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if fromChat {
            self.tableView.register(UINib(nibName: "MiiTVFollowerCell", bundle: nil), forCellReuseIdentifier: MiiTVFollowerCell.identifier)
        }
        FollowersTableCell.registerNib(self.tableView)
        if dataSource == nil {
            dataSource = UserStatsDataSource(userStatsType: type, delegate: self, user: ChatModel.sharedInstance.users)
            configure(refresh: true)
        } else {
            configure(refresh: false)
        }
    }
    
    // MARK: - Notifications handling
    @objc fileprivate func addUserToFollowing(_ notification: NSNotification) {
        if let user = notification.userInfo?["user"] as? User {
            addUserToArray(user: user)
        }
    }
    
    @objc fileprivate func addUserToBlocked(_ notification: NSNotification) {
        if let user = notification.userInfo?["user"] as? User {
            addUserToArray(user: user)
        }
    }
    
    fileprivate func addUserToArray(user: User) {
        if let userStatsArray  = dataSource?.userStatsArray {
            if let index = userStatsArray.index(where: { $0.username > user.username }) {
                dataSource?.userStatsArray.insert(user, at: index)
            } else {
                dataSource?.userStatsArray.append(user)
            }
            refreshTableView()
        }
    }
    
    // MARK: - User actions
    func presentBlockActions(_ fUser: User, indexPath: IndexPath) {
        let yesAction = UIAlertAction(title: "yes".localized, style: .default, handler: {(_ alert: UIAlertAction!) -> Void in
         //   self.blockUser(fUser, indexPath: indexPath)
        })
        let cancelAction = UIAlertAction(title: "no".localized, style: .cancel, handler: nil)
        present(UIAlertController.createBasicActionSheet("stream_block_alert".localized, yesAction: yesAction, cancelAction: cancelAction), animated: true, completion: nil)
    }
    
    func presentUnfollowActions(_ fUser: User, indexPath: IndexPath) {
        let yesAction = UIAlertAction(title: "yes".localized, style: .default, handler: {(_ alert: UIAlertAction!) -> Void in
          //  self.unfollowUser(fUser, indexPath: indexPath)
        })
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        present(UIAlertController.createBasicActionSheet("stream_unfollow_alert".localized, yesAction: yesAction, cancelAction: cancelAction), animated: true, completion: nil)
    }
    
//    func blockUser(_ fUser: User, indexPath: IndexPath) {
//        UserConnector().blockUser(fUser) { (success, error) in
//            if success {
//                self.dataSource?.userStatsArray.remove(at: indexPath.row)
//                self.refreshTableView()
//                Notification.Name.addToBlockedUserStats.post(userInfo: ["user": fUser])
//                Notification.Name.refreshUserStats.post()
//            } else {
//                UIUtil.apiFailure(error!, vc: self)
//            }
//        }
//    }
    
//    func didUnblockUser(_ fUser: User, indexPath: IndexPath) {
//        dataSource?.userStatsArray.remove(at: indexPath.row)
//        refreshTableView()
//    }
    
    func didFollowUser(_ user: User, indexPath: IndexPath) {
        refreshTableView()
        Notification.Name.addToFollowingUserStats.post(userInfo: ["user": user])
    }
    
//    func unfollowUser(_ fUser: User, indexPath: IndexPath) {
//        UserActions.unfollow(fUser, successBlock: {
//            if self.type == .following {
//                self.dataSource?.userStatsArray.remove(at: indexPath.row)
//            }
//            self.refreshTableView()
//            Notification.Name.refreshUserStats.post()
//        })
//    }
    
//    func goToUserProfile(_ user: User) {
//        DispatchQueue.main.async(execute: {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let vc = storyboard.instantiateViewController(withIdentifier: "ProfileView") as? ProfileViewController {
//                vc.userId = user.id
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        })
//    }
    
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
                    self.dismissSelf()
                }
            }
        } else {
         //   self.showFirebaseChatUI(userId: user.chatID, fromMessages: true)
        }
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Search list
    func search(name: String) {
        prevDataSource = dataSource?.copy() as? UserStatsDataSource
        dataSource?.searchedName(name: name)
    }
    
    func endSearch() {
        if let prev = prevDataSource {
            dataSource = prev.copy() as? UserStatsDataSource
            tableView.dataSource = dataSource
            tableView.delegate = dataSource
            prevDataSource = nil
        }
       refreshTableView()
    }
    
    // MARK: - disabling interaction
    
    func enableUserInteractionOnView() {
        tableView.isUserInteractionEnabled = true
    }
    
    func disableUserInteractionOnView() {
        tableView.isUserInteractionEnabled = false
    }
}

