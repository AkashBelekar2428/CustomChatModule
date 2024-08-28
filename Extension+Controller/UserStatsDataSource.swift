//
//  UserStatsDataSource.swift
//  Peeks
//
//  Created by Sara Al-kindy on 2016-05-16.
//  Copyright © 2016 Riavera. All rights reserved.
//

import UIKit
import MGSwipeTableCell

@objc protocol UserStatsDelegate: class {
    
    @objc optional func didFollowUser(_ user: User, indexPath: IndexPath)
    @objc optional func didUnblockUser(_ user: User, indexPath: IndexPath)
    @objc optional func presentUnfollowActions(_ user: User, indexPath: IndexPath)
    @objc optional func presentBlockActions(_ user: User, indexPath: IndexPath)
    @objc optional func goToUserProfile(_ user: User)
    @objc optional func goToUserChat(fromCell: Bool, _ user: User)
}

class UserStatsDataSource: NSObject, NSCopying {
    
    var fromChat = false
    var fromProfile = false
    var user: User?
    var tableView: UITableView?
    weak var delegate: UserStatsDelegate?
    var tblDelegate : MiiTVSelectMoreActionProtocol?
    internal var userStatsArray: [User] = []
    internal var channel: Channel?
    internal var allRowsLoaded: Bool = false
    fileprivate var isLoadingStreams = false
    fileprivate var userStatsType: UserStatisticsType?
    fileprivate var footerView: LoadMoreFooterView?
    fileprivate var searchedName: String?
    
    init(userStatsType: UserStatisticsType, delegate: UserStatsDelegate?, user: User?) {
        super.init()
        self.userStatsType = userStatsType
        self.delegate = delegate
        self.user = user
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = UserStatsDataSource(userStatsType: userStatsType!, delegate: delegate, user: user)
        copy.userStatsArray = userStatsArray
        copy.channel = channel
        copy.tableView = tableView
        copy.fromChat = fromChat
        copy.fromProfile = fromProfile
        copy.searchedName = searchedName
        copy.allRowsLoaded = allRowsLoaded
        copy.footerView = footerView
        return copy
    }
    
    func setupFooterView() {
        footerView = LoadMoreFooterView(frame: CGRect(x: 0, y: 0, width: tableView!.frame.size.width, height: 97), isLight: true)
        self.tableView!.tableFooterView = footerView
    }
    
    // MARK: - API Calls
    func refresh() {
        self.getUsers(true) { (_) in
            DispatchQueue.main.async {
                if self.tableView != nil {
                    UIUtil.removeActivityViewFromView(self.tableView!)
                }
                //self.tableView?.pullToRefreshView.stopAnimating()
                self.tableView?.reloadData()
                if self.userStatsArray.count == 0 {
                    //self.tableView?.setEmptyState()
                }
                self.setupFooterView()
            }
        }
    }
    
    func searchedName(name: String) {
        searchedName = name
        refresh()
    }
    
    fileprivate func getUsers(_ refresh: Bool, completion: ((_ success: Bool) -> Void)? = nil) {
//        if self.tableView != nil {
//            UIUtil.indicateActivityForView(self.tableView!, labelText: "loading".localized)
//        }
        
        switch userStatsType! as UserStatisticsType {
        case .following:
            getFollowings(refresh, name: searchedName, completion: {
                completion?(true)
            })
        case .followers:
            getFollowers(refresh, name: searchedName, completion: {
                completion?(true)
            })
        case .blocked:
            getBlocked(refresh, name: searchedName, completion: {
                completion?(true)
            })
        case .people:
            getListOfPeople(refresh, name: searchedName, completion: {
                completion?(true)
            })
        case .none:
            getTrendingUsers({
                completion?(true)
            })
        }
    }
    
    internal func loadMoreStreams() {
        getUsers(false) { (_ success) in
            self.isLoadingStreams = false
            self.footerView?.stopAnimating()
            DispatchQueue.main.async {
//                self.tableView?.reloadData()
            }            
        }
    }
    
    internal func endOfListProcess() {
        if allRowsLoaded {
            DispatchQueue.main.async {
                self.tableView?.tableFooterView = UIView()
                self.tableView?.reloadData()
            }
        }
    }
    
    fileprivate func getListOfPeople(_ isRefresh: Bool, name: String?, completion:@escaping () -> Void) {
        
        isLoadingStreams = true
        
        if isRefresh {
            userStatsArray.removeAll()
        }
        
        UserConnector().listOfUsers(nil,
                                    username: name,
                                    city: nil, country: nil,
                                    live: nil, order: "username",
                                    offset: userStatsArray.count,
                                    limit: 20) {(_ success, error, users, _ offset, _ limit, totalRows) in
                                        self.isLoadingStreams = false
                                        if success {
                                            if let peopleArray = users, let totalRows = totalRows {
                                                if peopleArray.count > 0 {
                                                    self.userStatsArray += peopleArray
                                                    self.allRowsLoaded = totalRows == self.userStatsArray.count || self.userStatsArray.count > totalRows
                                                }
                                            }
                                        } else {
                                            if let delegate = self.delegate as? UIViewController {
                                                UIUtil.apiFailure(error!, vc: delegate)
                                            }
                                        }
                                        completion()
        }
    }
    
    fileprivate func getFollowers(_ isRefresh: Bool, name: String?, completion:@escaping () -> Void) {
        
        isLoadingStreams = true
        
        if isRefresh {
            userStatsArray.removeAll()
        }
        
        let userId = (user != nil) ? user!.id : ChatModel.sharedInstance.userId
        FollowersConnector().getListOfFollowers(userId, name: name, order: "username", offset: userStatsArray.count, limit: 20) { (success, error, followers, totalRows, _ offset, _ limit) in
            self.isLoadingStreams = false
            if success {
                if let followersArray = followers, let totalRows = totalRows {
                    self.userStatsArray += followersArray
                    self.allRowsLoaded = totalRows == self.userStatsArray.count || self.userStatsArray.count > totalRows
                    self.endOfListProcess()
                }
            } else {
                if let delegate = self.delegate as? UIViewController {
                    UIUtil.apiFailure(error!, vc: delegate)
                }
            }
            completion()
        }
    }
    
    fileprivate func getFollowings(_ isRefresh: Bool, name: String?, completion: @escaping () -> Void) {
        
        isLoadingStreams = true
        
        if isRefresh {
            userStatsArray.removeAll()
        }
        
        let userId = (user != nil) ? user!.id : ChatModel.sharedInstance.userId
        FollowersConnector().getListOfFollowing(userId, name: name, order: "username", offset: userStatsArray.count, limit: 20) { (success, error, followings, totalRows, _ offset, _ limit) in
            self.isLoadingStreams = false
            if success {
                if let followingsArray = followings, let totalRows = totalRows {
                    self.userStatsArray += followingsArray
                    self.allRowsLoaded = totalRows == self.userStatsArray.count || self.userStatsArray.count > totalRows
                    self.endOfListProcess()
                }
            } else {
                if let delegate = self.delegate as? UIViewController {
                    UIUtil.apiFailure(error!, vc: delegate)
                }
            }
            completion()
        }
    }
    
    fileprivate func getBlocked(_ isRefresh: Bool, name: String?, completion:@escaping () -> Void) {
        
        isLoadingStreams = true
        
        if isRefresh {
            userStatsArray = []
        }
//        UserConnector().listOfBlockedUsers { (success, error, users) in
//            self.isLoadingStreams = false
//            if success {
//                if let blockedArray = users {
//                    self.userStatsArray += blockedArray
//                    self.allRowsLoaded = true
//                    self.endOfListProcess()
//                }
//            } else {
//                if let delegate = self.delegate as? UIViewController {
//                    UIUtil.apiFailure(error!, vc: delegate)
//                }
//            }
//            completion()
//        }
    }
    
    fileprivate func getTrendingUsers(_ completion:@escaping () -> Void) {
        if let channel = self.channel {
            
            channel.loadUsers({ result in
                
                switch result {
                case .success:
                    self.userStatsArray = channel.users
                case .failure(let error):
                    print(error)
                }
                completion()
            })
        }
    }
}

extension UserStatsDataSource: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table View Stuff
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userStatsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 97.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //There appears to be a bug with the pull to refresh handler
        //As soon as a user pulls down this method is called even before reloadData is called
        //So you get instances where it thinks it has rows to load but userStatsArray is empty
        //I added the following to combat that
        if userStatsArray.count == 0 || indexPath.row >= userStatsArray.count {
            return UITableViewCell()
        }
        let user = userStatsArray[indexPath.row]
        return getTableCellWithPeeksUser(user, tableView: tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if userStatsArray.count > 0 {
            if userStatsType != .blocked {
                if fromChat {
                    delegate?.goToUserChat?(fromCell: true, userStatsArray[(indexPath as NSIndexPath).row])
                } else {
                    self.delegate?.goToUserProfile?(userStatsArray[(indexPath as NSIndexPath).row])
                }
            }
        }
    }
    
    fileprivate func getTableCellWithPeeksUser(_ user: User, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MiiTVFollowerCell.identifier, for: indexPath)
            as? MiiTVFollowerCell ?? MiiTVFollowerCell()
        cell.lblFollowerName.textColor = .MiiTV_Black()
        cell.lblFollowerCount.textColor = .lightGray
        cell.btnMore.isHidden = true
//        cell.update(user)
//        cell.followersCelldelegate = self
//        cell.chatButton.isHidden = fromChat || (userStatsType == .blocked) || !PeeksModel.sharedInstance.userPermissions.canCreateChat
        
//        let followButton = SwipeCellButton.followButton(otherUser: user, pushNotifEnabled: true) {
//            self.delegate?.didFollowUser?(user, indexPath: indexPath)
//        }
//
//        let unfollowButton = SwipeCellButton.unfollowAlertButton(otherUser: user) {
//            self.delegate?.presentUnfollowActions?(user, indexPath: indexPath)
//        }
//
//        let blockButton = SwipeCellButton.blockAlertButton(otherUser: user) {
//            self.delegate?.presentBlockActions?(user, indexPath: indexPath)
//        }
//
//        let unblockButton = SwipeCellButton.unblockButton(otherUser: user) {
//            self.delegate?.didUnblockUser?(user, indexPath: indexPath)
//        }
//
//        let reportButton = SwipeCellButton.reportButton(otherUser: user)
        
//        if !fromChat {
//            switch userStatsType! as UserStatisticsType {
//
//            case .following:
//                cell.rightButtons = [reportButton, unfollowButton, blockButton]
//
//            case .followers:
//                cell.notificationIcon.isHidden = true
//                if user.isFollowingThem {
//                    cell.rightButtons = [reportButton, unfollowButton]
//                } else {
//                    cell.rightButtons = [reportButton, followButton]
//                }
//
//            case .blocked:
//                cell.notificationIcon.isHidden = true
//                cell.rightButtons = [unblockButton]
//
//            case .people:
//                cell.rightButtons = user.isFollowingThem ? [reportButton, unfollowButton] : [reportButton, followButton]
//
//            case .none:
//                if user.isFollowingThem {
//                    cell.rightButtons = [reportButton, unfollowButton, blockButton]
//                } else {
//                    cell.rightButtons = [reportButton, followButton, blockButton]
//                }
//            }
//        }
        
//        if cell.notificationIcon != nil {
//            if userStatsType == .followers || userStatsType == .blocked || userStatsType == .people || fromChat || fromProfile {
//                cell.notificationIcon.isHidden = true
//            } else {
//                cell.notificationIcon.isHidden = false
//            }
//        }
        
        cell.delegate = self
        cell.update(user)
        if fromChat {
            cell.lblFollowerCount.text = user.city == "" ? "\(user.country)": "\(user.city), \(user.country)"
        }
        cell.tag = indexPath.row
        return cell
    }
}

extension UserStatsDataSource: MiiTVSelectMoreActionProtocol {
    
    // MARK: - FollowersCellDelegate
    internal func userAllowNotification(_ user: User?, notification: Bool) {
        //update user info in array
        if user != nil {
            if let i: Int = (userStatsArray.index(of: user!)) {
                let updatedUser: User = userStatsArray[i]
                updatedUser.pushNotification = notification
                self.userStatsArray.remove(at: i)
                self.userStatsArray.insert(updatedUser, at: i)
            }
        }
    }
    
    internal func chatButtonPressed (user: User) {
        // go straight to chat window not passing by the users list
        delegate?.goToUserChat?(fromCell: false, user)
    }
    
    func PassSelectedIndex(index : Int)
    {
        self.tblDelegate?.PassSelectedIndex(index: index)
    }
}

extension UserStatsDataSource: UIScrollViewDelegate {
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            if !isLoadingStreams && !allRowsLoaded {
                isLoadingStreams = true
                footerView?.startAnimating()
                loadMoreStreams()
            }
        }
    }
}
