//
//  NotificationExtension.swift
//  Peeks
//
//  Created by Sara Al-Kindy on 2017-07-18.
//  Copyright © 2017 Riavera. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let disableTabBar = Notification.Name("DisableTabBar")
    static let enableTabBar = Notification.Name("EnableTabBar")
    static let addToBlockedUserStats = Notification.Name("AddToBlockedUserStats")
    static let addToFollowingUserStats = Notification.Name("AddToFollowingUserStats")
    static let refreshUserStats = Notification.Name("RefreshUserStats")
    static let killSwitchMessage = Notification.Name("KillSwitchMessage")
    static let gotNewDeviceToken = NSNotification.Name("new_device_token")
    static let keekBackVideo = NSNotification.Name("KeekBackVideo")
    static let banubaDismiss = NSNotification.Name("BanubaDismiss")
    static let uploadDismiss = NSNotification.Name("DissmissFromUploadController")
    static let updateProfile = NSNotification.Name("UpdateProfile")
    static let pausePlayerFromReKeek = NSNotification.Name("pausePlayerFromReKeek")
    static let restartPlayerFromReKeek = NSNotification.Name("restartPlayerFromReKeek")
    static let showReKeekMenu = NSNotification.Name("showReKeekMenu")
    public static let userSelectedCustomContacts = Notification.Name("ChatHelper.UserSelectedFromCustomContacts")
    func post(userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: self, object: nil, userInfo: userInfo)
    }
}
