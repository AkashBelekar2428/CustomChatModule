//
//  UserDefaultsUtil.swift
//  ChatModule
//
//  Created by Tushar Patil   on 26/07/24.
//

import Foundation

class UserDefaultsUtil {
    
    static let usernameKey = "username"
    static let avatarKey = "avatarUrl"
    static let riaveraGroupSuite = "group.com.riavera"
    static let deviceToken = "deviceToken"
    static let appInstalled = "app_installed"
    static let videoBitRate = "VideoBitrate"
    static let canUseApp = "CanUseApp"
    static let facebookCredentials = "FacebookCredentials"
    static let registrationPhone = "registrationPhoneTemp"
    static let eighteenPrompt = "18+Prompt"
    static let shouldSkipWalletAlert = "ShouldSkipWalletLoginAlert"
    static let shouldSkipIntro = "ShouldSkipIntro"
    static let makeFeaturedTutorialShown = "MakeFeaturedTutorialShown"
    static let categoryId = "categoryId"
    static let ratingType = "ratingType"
    static let locationAlertShown = "LocationAlertShown"
    static let regularRun = "RegularRun"
    static let killSwitchString = "KillSwitchString"
    static let ImpressionBalance = "ImpressionBalance"
    static let IsLoggedIn = "IsLoggedIn"
    static let isUploadingPost = "isUploadingPost"
    static let adMobPosition = "adMobPosition"
    static let followingAdMobPosition = "followingAdMobPosition"
    static let userPostCount = "userPostCount"
    static let IsFullScreenAllOver = "IsFullScreenAllOver"
    static let IsFullStream = "IsFullStream"
    class func addUserInfo(username: String? = nil, avatarUrl: String? = nil) {
        let defaults = UserDefaults.standard
        var groupDefaults: UserDefaults?
        
        if let riaveraDefaults = UserDefaults(suiteName: riaveraGroupSuite) {
            groupDefaults = riaveraDefaults
        } else {
            groupDefaults = UserDefaults(suiteName: riaveraGroupSuite)
        }
        
        if let username = username {
            defaults.set(username, forKey: usernameKey)
            groupDefaults?.set(username, forKey: usernameKey)
        }
        if let avatarUrl = avatarUrl {
            defaults.set(avatarUrl, forKey: avatarKey)
            groupDefaults?.set(avatarUrl, forKey: avatarKey)
        }
    }
    
    class func getUserInfo() -> (username: String?, avatarUrl: String?) {
        return (UserDefaults.standard.object(forKey: usernameKey) as? String, UserDefaults.standard.object(forKey: avatarKey) as? String)
    }
    
    class func getGroupUserInfo() -> (username: String?, avatarUrl: String?) {
        if let groupDefaults = UserDefaults(suiteName: riaveraGroupSuite) {
            return (groupDefaults.object(forKey: usernameKey) as? String, groupDefaults.object(forKey: avatarKey) as? String)
        }
        return (nil, nil)
    }
    
    class func clearUserInfo() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: usernameKey)
        defaults.removeObject(forKey: avatarKey)
        
        if let groupDefaults = UserDefaults(suiteName: riaveraGroupSuite) {
            groupDefaults.removeObject(forKey: usernameKey)
            groupDefaults.removeObject(forKey: avatarKey)
        }
    }
    
    class func addAppIsInstalled() {
        UserDefaults.standard.set(true, forKey: appInstalled)
    }
    
    class func getAppIsInstalled () -> Bool {
        return UserDefaults.standard.bool(forKey: appInstalled)
    }
    
    class func addKillSwitchMessage(message: String?) {
        UserDefaults.standard.set(message, forKey: killSwitchString)
    }
    
    class func getKillSwitchMessage() -> String? {
        return UserDefaults.standard.object(forKey: killSwitchString) as? String
    }
    
    class func addVideoBitRate(bitRate: Int) {
        UserDefaults.standard.set(bitRate, forKey: videoBitRate)
    }
    
    class func getVideoBitRate() -> Int {
        return UserDefaults.standard.integer(forKey: videoBitRate)
    }
    
    class func followingAddAdmobPosition(position: Int) {
        UserDefaults.standard.set(position, forKey: followingAdMobPosition)
    }
    
    class func getFollowingAddAdmobPosition() -> Int {
        return UserDefaults.standard.integer(forKey: followingAdMobPosition)
    }
    
    class func addAdmobPosition(position: Int) {
        UserDefaults.standard.set(position, forKey: adMobPosition)
    }
    
    class func getAdmobPosition() -> Int {
        return UserDefaults.standard.integer(forKey: adMobPosition)
    }
    
    class func addUserPostCount(count: Int) {
        UserDefaults.standard.set(count, forKey: userPostCount)
    }
    
    class func getUserPostCount() -> Int {
        return UserDefaults.standard.integer(forKey: userPostCount)
    }
    
    class func addDeviceToken(token: String) {
        UserDefaults.standard.set(token, forKey: deviceToken)
    }
    
    class func getDeviceToken() -> String? {
        return UserDefaults.standard.object(forKey: deviceToken) as? String ?? nil
    }
    
    class func addCanUseApp(canUse: Bool) {
        UserDefaults.standard.set(canUse, forKey: canUseApp)
    }
    
    class func getCanUseApp() -> Bool {
        return UserDefaults.standard.bool(forKey: canUseApp)
    }
    
    class func getIsUploadingPost() -> Bool {
        return UserDefaults.standard.bool(forKey: isUploadingPost)
    }
    
    class func addIsUploadingPost(isUploading: Bool) {
        UserDefaults.standard.set(isUploading, forKey: isUploadingPost)
    }
    
    class func addRegistrationPhone(phone: String?) {
        UserDefaults.standard.set(phone, forKey: registrationPhone)
    }
    
    class func getRegistrationPhone() -> String? {
        return UserDefaults.standard.object(forKey: registrationPhone) as? String
    }
    
    class func addEighteenPrompt(seen: Bool) {
        UserDefaults.standard.set(seen, forKey: eighteenPrompt)
    }
    
    class func getEighteenPrompt() -> Bool {
        return UserDefaults.standard.bool(forKey: eighteenPrompt)
    }
    
    class func addShouldSkipWalletAlert(shouldSkip: Bool) {
        UserDefaults.standard.set(shouldSkip, forKey: shouldSkipWalletAlert)
    }
    
    class func getShouldSkipWalletAlert() -> Bool {
        return UserDefaults.standard.bool(forKey: shouldSkipWalletAlert)
    }
    
    class func addShouldSkipIntro(skip: Bool) {
        UserDefaults.standard.set(skip, forKey: shouldSkipIntro)
    }
    
    class func getShouldSkipIntro() -> Bool {
        return UserDefaults.standard.bool(forKey: shouldSkipIntro)
    }
    
    class func addMakeFeaturedTutorialShown(shown: Bool) {
        UserDefaults.standard.set(shown, forKey: makeFeaturedTutorialShown)
    }
    
    class func getMakeFeauturedTutorialShown() -> Bool {
        return UserDefaults.standard.bool(forKey: makeFeaturedTutorialShown)
    }
    
    class func addUserStreamSettings(category: Int, rating: Int) {
        UserDefaults.standard.set(category, forKey: categoryId)
        UserDefaults.standard.set(rating, forKey: ratingType)
    }
    
    class func getUserStreamSettings() -> (category: Int?, rating: Int?) {
        return (UserDefaults.standard.integer(forKey: categoryId), UserDefaults.standard.integer(forKey: ratingType))
    }
    
    class func addLocationAlertShown(shown: Bool) {
        UserDefaults.standard.set(shown, forKey: locationAlertShown)
    }
    
    class func getLocationAlertShown() -> Bool {
        return UserDefaults.standard.bool(forKey: locationAlertShown)
    }
    
    class func addRegularRun(run: Bool) {
        UserDefaults.standard.set(run, forKey: regularRun)
    }
    
    class func getRegularRun() -> Bool {
        return UserDefaults.standard.bool(forKey: regularRun)
        UserDefaults.standard.synchronize()
    }
    
    class func getImpressionBalance() -> Int? {
        return (UserDefaults.standard.value(forKey: ImpressionBalance) as? Int) ?? 0
    }
    
    class func setImpressionBalance(impBalance: Int) {
        UserDefaults.standard.set(impBalance, forKey: ImpressionBalance)
    }
    
    class func setIsloggedIn(isloggedIn: Bool) {
        UserDefaults.standard.set(isloggedIn, forKey: IsLoggedIn)
    }
    
    class func getIsloggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: IsLoggedIn)
    }
    
    class func setIsFullAllOver(isfull: Bool) {
        UserDefaults.standard.set(isfull, forKey: IsFullScreenAllOver)
        UserDefaults.standard.synchronize()
    }
    
    class func getIsFullScreenAllOver() -> Bool {
        return UserDefaults.standard.bool(forKey: IsFullScreenAllOver)
    }
    
    class func setIsFullStreamStrechAllOver(isfull: Bool) {
        UserDefaults.standard.set(isfull, forKey: IsFullStream)
        UserDefaults.standard.synchronize()
    }
    
    class func getIsFullStreamStrechAllOver() -> Bool {
        return UserDefaults.standard.bool(forKey: IsFullStream)
    }
}
