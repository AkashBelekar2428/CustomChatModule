//
//  UserActions.swift
//  Peeks
//
//  Created by Sara Al-Kindy on 2017-01-28.
//  Copyright © 2017 Riavera. All rights reserved.
//

import UIKit

class UserActions {
    
    
    class func favorite(_ user: User, successBlock: (() -> Void)? = nil, failureBlock: (() -> Void)? = nil) {
        UserConnector().favoriteUser(user) { (success, error) in
            if success {
                user.isFavourite = true
                successBlock?()
            } else {
                if let topVC = UIApplication.topViewController() {
                    UIUtil.apiFailure(error!, vc: topVC)
                }
                failureBlock?()
            }
        }
    }
    
    class func unFavorite(_ user: User, successBlock: (() -> Void)? = nil, failureBlock: (() -> Void)? = nil) {
        UserConnector().unFavoriteUser(user) { (success, error) in
            if success {
                user.isFavourite = false
                successBlock?()
            } else {
                if let topVC = UIApplication.topViewController() {
                    UIUtil.apiFailure(error!, vc: topVC)
                }
                failureBlock?()
            }
        }
    }
    
    class func block(_ user: User, successBlock: (() -> Void)? = nil, failureBlock: (() -> Void)? = nil) {
        UserConnector().blockUser(user) { (success, error) in
            if success {
                user.isBlocked = true
                successBlock?()
            } else {
                if let topVC = UIApplication.topViewController() {
                    UIUtil.apiFailure(error!, vc: topVC)
                }
                failureBlock?()
            }
        }
    }
    
    class func unblock(_ user: User, successBlock: (() -> Void)? = nil, failureBlock: (() -> Void)? = nil) {
        UserConnector().unblockUser(user) { (success, error) in
            if success {
                user.isBlocked = false
                successBlock?()
            } else {
                DispatchQueue.main.async {
                    if let topVC = UIApplication.topViewController() {
                        UIUtil.apiFailure(error!, vc: topVC)
                    }
                }
                failureBlock?()
            }
        }
    }
    
    class func follow(_ user: User, pushNotifEnabled: Bool? = nil, successBlock: (() -> Void)? = nil, failureBlock: (() -> Void)? = nil) {
        FollowersConnector().followerUser(user.id, pushNotification: pushNotifEnabled) { (success, error) in
            if success {
                user.isFollowingThem = true
                successBlock?()
            } else {
                if let topVC = UIApplication.topViewController() {
                    UIUtil.apiFailure(error!, vc: topVC)
                }
                failureBlock?()
            }
        }
    }
    
    class func followRequest(_ user: User, pushNotifEnabled: Bool? = nil, successBlock: (() -> Void)? = nil, failureBlock: (() -> Void)? = nil) {
        FollowersConnector().followRequestUser(user.id, pushNotification: true) { (success, error, requestId) in
            if success {
                user.followRequested = true
                user.followRequestId = Int(requestId!) ?? 0
                successBlock?()
            } else {
                if let topVC = UIApplication.topViewController() {
                    UIUtil.apiFailure(error!, vc: topVC)
                }
                user.followRequested = false
                user.followRequestId =  0
                failureBlock?()
            }
        }
    }
    
    class func deleteFollowRequest(_ user: User, pushNotifEnabled: Bool? = nil, successBlock: (() -> Void)? = nil, failureBlock: (() -> Void)? = nil) {
        
        
        FollowersConnector().updateRequestStatus(requestId: [user.followRequestId], followStatus: "delete") { (success, error) in
            if success {
                user.followRequested = false
                user.followRequestId = 0
                
                successBlock?()
            } else {
                if let topVC = UIApplication.topViewController() {
                    UIUtil.apiFailure(error!, vc: topVC)
                }
                failureBlock?()
            }
        }
    }
    
    class func removeUser(_ user: User, pushNotifEnabled: Bool? = nil, successBlock: (() -> Void)? = nil, failureBlock: (() -> Void)? = nil) {
        
        
        FollowersConnector().removefollowerUser(followId: user.id) { (success, error) in
            if success {
                user.isFollowingMe = false
                
                successBlock?()
            } else {
                if let topVC = UIApplication.topViewController() {
                    UIUtil.apiFailure(error!, vc: topVC)
                }
                failureBlock?()
            }
        }
    }
    
    class func unfollow(_ user: User, successBlock: (() -> Void)? = nil, failureBlock: (() -> Void)? = nil) {
        FollowersConnector().unfollowerUser(user.id) { (success, error) in
            if success {
                user.isFollowingThem = false
                successBlock?()
            } else {
                if let topVC = UIApplication.topViewController() {
                    UIUtil.apiFailure(error!, vc: topVC)
                }
                failureBlock?()
            }
        }
    }
    
    class func report(_ user: User, successBlock: (() -> Void)? = nil, failureBlock: (() -> Void)? = nil) {
        let storyboard = UIStoryboard(name: "Streaming", bundle: nil)
//        if let vc = storyboard.instantiateViewController(withIdentifier: "ReportViewController") as? ReportViewController {
//            let reportViewModel = ReportViewModel(withType: .user, withUserID: user.id)
//            vc.viewModel = reportViewModel
//            let nav = UINavigationController(rootViewController: vc)
//            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: vc, action: #selector(ReportViewController.dismissSelf))
//            vc.navigationItem.rightBarButtonItem = cancelButton
//            successBlock?()
//            
//            if let topVC = UIApplication.topViewController() {
//                topVC.present(nav, animated: true, completion: nil)
//            }
//        }
    }
    
    class func share(_ user: User, successBlock: (() -> Void)? = nil, failureBlock: (() -> Void)? = nil) {
        let shareURL = ChatModel.sharedInstance.shareURL + user.id
        
        let shareMessage = NSLocalizedString("profile_share_message", comment: "") + shareURL
        let activityController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {(activityType, shared: Bool, items:[Any]?, error: Error?) in
           // UINavigationBar.setCustomAppereance()
        }
        successBlock?()
        
        if let topVC = UIApplication.topViewController() {
            topVC.present(activityController, animated: true, completion: nil)
        }
    }
    
}
