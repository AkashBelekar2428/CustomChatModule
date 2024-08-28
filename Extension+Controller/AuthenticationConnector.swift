//
//  AuthenticationConnector..swift
//  Peeks
//
//  Created by Aaron Wong on 2016-04-01.
//  Copyright © 2016 Riavera. All rights reserved.
//
// swiftlint:disable type_body_length cyclomatic_complexity

import UIKit
import Foundation

enum AccountConfirmationMethod: String {
    case SMS = "sms"
    case IVR = "ivr"
    case Email = "email"
    
    init(string: String) {
        switch string {
        case "phone":
            self = .SMS
        case "sms":
            self = .SMS
        case "ivr":
            self = .IVR
        case "email":
            self = .Email
        default:
            self = .SMS
        }
    }
}

class AuthenticationConnector: Connector {
    // MARK: - REGISTRATON
    
    func lookupUser( userId: String, completion:@escaping ( _ success: Bool,  _ error: String?,  _ : User?) -> Void) {
            let ts = timestamp
            
            let queryString = "?ts=\(ts)"

            let path = "/user/\(userId)"
            
            let authToken: String = self.buildHash(RequestType.GET, uri: path,
                                                    timeStamp: ts, authentication: "",
                                                    apiSecret:ChatModel.sharedInstance.apiSecret,
                                                    sharedSecret: ChatModel.sharedInstance.sharedSecret)
            
            let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
            
            http.GET(path, queryParams: queryString, authValue: authString) { (data, error, success) in
                if success {
                    if let data = data!["data"] as? [String: AnyObject] {
                        let peeksUser = User(params: data)
                        if !userId.contains("@") {
                            peeksUser.id = userId
                        }
                        if userId == ChatModel.sharedInstance.userId {
//                            DBHelper.sharedDBHelper.deleteAllKeekUserData()
//                            DBHelper.sharedDBHelper.createUserDataObject(dict: data)
                        }
                        ChatModel.sharedInstance.users = peeksUser
                        completion(true, nil, peeksUser)
                    } else {
                        completion(false, "No data found in response", nil)
                    }
                } else {
                    completion(false, error!, nil)
                }
            }
        }
    /**
     * Register/Create User
     * POST /user/registration
     *
     * Register a new external user.
     */
    //    func registerPeeks(_ signUpData: [String: AnyObject], completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
    //        let ts = timestamp
    //        let path = "/user/registration"
    //
    //        var params: [String: AnyObject] = signUpData
    //
    //        params["ts"] = ts as AnyObject?
    //        params["terms_accepted"] = true as AnyObject?
    //        params["service"] = "miitv" as AnyObject?
    //        params["validate_only"] = false as AnyObject?
    //        let (apiSecret, sharedSecret, usernameShared) = Config.shared.peeks()
    //
    //        var authentication = getStringParamsFromDictionary(["username"], params: params) + getStringParamsFromDictionary(["password"], params: params)
    //
    //		if let uuid = DeviceService.deviceIdentifier() {
    //			params["client_id"] = uuid as AnyObject?
    //			authentication += uuid
    //		}
    //
    //        let authToken: String = self.buildHash(RequestType.POST, uri: path, timeStamp: ts, authentication: authentication, apiSecret: apiSecret, sharedSecret: sharedSecret)
    //
    //        let authString = "\(usernameShared):\(authToken)"
    //        http.POST(path, authValue: authString, parameters: params) { (data, error, success) in
    //            if success {
    //                completion(true, nil)
    //            } else {
    //                completion(false, error!)
    //            }
    //        }
    //    }
    
    /**
     * Register/Create User (Validation Only)
     * POST /user/registration
     *
     * It will run only the validation
     */
    //    func validateRegistrationPeeks(_ signUpData: [String: AnyObject], completion: @escaping (_ success: Bool,  _ error: AnyObject?) -> Void) {
    //        let ts = timestamp
    //        let path = "/user/registration"
    //
    //        var params: [String: AnyObject] = signUpData
    //
    //        params["ts"] = ts as AnyObject?
    //        params["validate_only"] = true as AnyObject?
    //        params["service"] = "miitv" as AnyObject?
    //        let (apiSecret, sharedSecret, usernameShared) = Config.shared.peeks()
    //
    //        let authentication = getStringParamsFromDictionary(["username"], params: params) + getStringParamsFromDictionary(["password"], params: params)
    //
    //        let authToken: String = self.buildHash(RequestType.POST, uri: path, timeStamp: ts, authentication: authentication, apiSecret: apiSecret, sharedSecret: sharedSecret)
    //
    //        let authString = "\(usernameShared):\(authToken)"
    //
    //        http.POST(path, authValue: authString, parameters: params, rawData: true) { (data, error, success) in
    //            if success {
    //                completion(true, data! as AnyObject?)
    //            } else {
    //                completion(false, error! as AnyObject?)
    //            }
    //        }
    //    }
    
    /**
     * Send Confirmation code via SMS
     * POST /user/{id}/sendconfirmation
     *
     * It will send a confirmation code to the user's phone number. It could be called as many times as require.
     */
//    func sendAccountConfirmation(_ userId: String, method: AccountConfirmationMethod, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
//        let ts = timestamp
//        let path = "/user/\(userId)/sendconfirmation"
//        
//        let params: [String: AnyObject] = ["ts": ts as AnyObject, "id": userId as AnyObject, "method": method.rawValue as AnyObject]
//        
//        let authToken = self.buildHash(RequestType.POST,
//                                       uri: path,
//                                       timeStamp: ts,
//                                       authentication: "",
//                                       apiSecret: ChatModel.sharedInstance.apiSecret,
//                                       sharedSecret: ChatModel.sharedInstance.sharedSecret)
//        
//        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
//        
//        http.POST(path, authValue: authString, parameters: params) { (_, error, success) in
//            if success {
//                completion(true, nil)
//            } else {
//                completion(false, error)
//            }
//        }
//    }
    
    /**
     * Validate Confirmation code
     * POST /user/{id}/validateconfirmation
     *
     * It verifies if the code the client is passing matches with the code on the database, and if so it updates the confirmation status to 'received'.
     */
//    func validateAccountConfirmation(_ userId: String, confirmationCode: String, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
//        let ts = timestamp
//        let path = "/user/\(userId)/validateconfirmation"
//        
//        let params: [String: AnyObject] = ["ts": ts as AnyObject, "id": userId as AnyObject, "confirmation_code": confirmationCode as AnyObject]
//        
//        let authToken = self.buildHash(RequestType.POST,
//                                       uri: path,
//                                       timeStamp: ts,
//                                       authentication: confirmationCode,
//                                       apiSecret: ChatModel.sharedInstance.apiSecret,
//                                       sharedSecret: ChatModel.sharedInstance.sharedSecret)
//        
//        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
//        
//        http.POST(path, authValue: authString, parameters: params) { (data, error, success) in
//            if success {
//                if let data = data!["data"] as? [String: AnyObject] {
//                    if let state = data["state"] as? String {
//                        if state == "confirmed" {
//                            completion(true, nil)
//                        } else if state == "already confirmed" {
//                            completion(true, nil)
//                            //                            completion(false, "The account is already verified")
//                        } else {
//                            completion(false, "Validation state returned \(state)")
//                        }
//                    } else {
//                        print("response state did not return as String")
//                    }
//                } else {
//                    completion(false, "There was no data parameter returned")
//                }
//            } else {
//                completion(false, error)
//            }
//        }
//    }
    
    // MARK: - AUTHENTICATION
    
    /**
     * Login
     * POST /user/login
     *
     * Perform login based on username and password.
     */
    func loginPeeks(_ username: String, password: String, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let path = "/user/login"
        let authentication = "\(username)\(password)"
        let params = ["username": username, "password": password]
        
        performLogin(path: path, authentication: authentication, params: params, isSocialMedia: false) { (success, error) in
            completion(success, error)
        }
        
    }
    
//    func sessionLogin(_ userId: String, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
//        let path = "/user/verify/session"
//        let authentication = "\(userId)"
//        let params = ["user_id": userId]
//        
//        performSessionLogin(path: path, authentication: authentication, params: params, isSocialMedia: true) { (success, error) in
//            completion(success, error)
//        }
//        
//    }
    
//    func verifyPassword(_ username: String, password: String, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
//        let path = "/user/login"
//        let authentication = "\(username)\(password)"
//        let params = ["username": username, "password": password]
//        
//        performLogin(path: path, authentication: authentication, params: params, isSocialMedia: false, onlyCheckPassword: true) { (success, error) in
//            completion(success, error)
//        }
//    }
    
    fileprivate func performLogin(path: String, authentication: String, params: [String: Any], isSocialMedia: Bool,onlyCheckPassword: Bool = false, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        print("login params \(params)")
        var params = params
        let ts = timestamp
        var version: String
        var token = ""
        
        if let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            version = "iOS-\(UIDevice.current.systemVersion)/\(versionString)"
        } else {
            version = "iOS-\(UIDevice.current.systemVersion)"
        }
        
        if let deviceToken = ChatModel.sharedInstance.deviceToken {
            token = deviceToken
            print("Push Notification token is : \(token)")
        } else {
            //                    if let t = UserDefaultsUtil.getDeviceToken() {
            //                        token = t
            //                        print("Push Notification token (from NSUserDefaults) is : \(token))")
            //                    }
        }
        
        params["ts"] = ts
        params["client_version"] = version
        params["push_notification_id"] = token
        params["platform"] = "IOS"
        params["service"] = "miitv"
        let (apiSecret, sharedSecret, usernameShared) = Config.shared.peeks()
        
        let authToken: String = self.buildHash(RequestType.POST, uri: path, timeStamp: ts, authentication: authentication, apiSecret: apiSecret, sharedSecret: sharedSecret)
        
        let authString = "\(usernameShared):\(authToken)"
        
        http.POST(path, authValue: authString, parameters: params as [String: AnyObject]) { (data, error, success) in
            print("Keek chat login \(data)")
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    // this will hold:  user, admin, etc. Only 'user' can use the app.
                    if let userType = data["type"] as? String, userType != "user" {
                        completion(false, "login_invalid_credentails".localized)
                        return
                    }
                    if onlyCheckPassword {
                        completion(true, nil)
                        return
                    } else {
                        self.loginSuccess(data, username: params["username"] as? String, password: params["password"] as? String, isSocialMedia: isSocialMedia, completionBlock: {
                            completion(true, nil)
                        })
                    }
                } else {
                    completion(false, "No data found in response")
                }
            } else {
                completion(false, error!)
            }
        }
        
    }
    
    fileprivate func performSessionLogin(path: String, authentication: String, params: [String: Any], isSocialMedia: Bool,onlyCheckPassword: Bool = false, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        var params = params
        let ts = timestamp
        var version: String
        var token = ""
        
        if let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            version = "iOS-\(UIDevice.current.systemVersion)/\(versionString)"
        } else {
            version = "iOS-\(UIDevice.current.systemVersion)"
        }
        
        if let deviceToken = ChatModel.sharedInstance.deviceToken {
            token = deviceToken
            print("Push Notification token is : \(token)")
        } else {
            //                    if let t = UserDefaultsUtil.getDeviceToken() {
            //                        token = t
            //                        print("Push Notification token (from NSUserDefaults) is : \(token))")
            //                    }
        }
        
        params["ts"] = ts
        params["client_version"] = version
        params["push_notification_id"] = token
        params["platform"] = "IOS"
        params["service"] = "miitv"
        var apiSecret = ChatModel.sharedInstance.apiSecret
        var sharedSecret = ChatModel.sharedInstance.sharedSecret
        var usernameShared = ""
        if let key = KeychainService.loadApiKey() {
            usernameShared = key
        }
        let authToken: String = self.buildHash(RequestType.POST, uri: path, timeStamp: ts, authentication: authentication, apiSecret: apiSecret, sharedSecret: sharedSecret)
        
        let authString = "\(usernameShared):\(authToken)"
        
        http.POST(path, authValue: authString, parameters: params as [String: AnyObject], userId: ChatModel.sharedInstance.userId) { (data, error, success) in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    // this will hold:  user, admin, etc. Only 'user' can use the app.
                    if let userType = data["type"] as? String, userType != "user" {
                        completion(false, "login_invalid_credentails".localized)
                        return
                    }
                    if onlyCheckPassword {
                        completion(true, nil)
                        return
                    } else {
                        self.loginSuccess(data, username: params["username"] as? String, password: params["password"] as? String, isSocialMedia: isSocialMedia, completionBlock: {
                            completion(true, nil)
                        })
                    }
                } else {
                    completion(false, "No data found in response")
                }
            } else {
                completion(false, error!)
            }
        }
        
    }
    
    fileprivate func registerForChatNotification(_ deviceToken: String, _ deviceType: Int) {
        ChatConnector().updateDeviceTokenForChat(deviceToken, deviceType) { success, error in
            if success {
                print("Registered successfully for chat notification")
            } else {
                print("Could not register for chat token")
            }
        }
    }
    
    fileprivate func loginSuccess(_ data: [String: AnyObject], username: String?, password: String?, isSocialMedia: Bool, completionBlock: () -> Void) {
        
        if let username = username, let password = password {
            KeychainService.savePassword(token: password)
            UserDefaultsUtil.addUserInfo(username: username)
        } else if isSocialMedia {
            UserDefaultsUtil.clearUserInfo()
        }
        UserDefaultsUtil.setIsloggedIn(isloggedIn: true)
        
        let (_, sharedSecret, _) = Config.shared.peeks()
        ChatModel.sharedInstance.sharedSecret = sharedSecret
        ChatModel.sharedInstance.apiKey = "miitv|" + (data["api_key"] as? String ?? "")
        KeychainService.saveApiKey(ChatModel.sharedInstance.apiKey)
        ChatModel.sharedInstance.apiSecret = data["api_secret"] as? String ?? ""
        KeychainService.saveApiSecretKey(ChatModel.sharedInstance.apiSecret)
        ChatModel.sharedInstance.userId = data["user_id"] as? String ?? ""
        KeychainService.saveUserId(ChatModel.sharedInstance.userId)
        
        if let enviroment = data["environment"] as? [String: AnyObject] {
            if let privacyURL = enviroment["privacy_url"] as? String {
                ChatModel.sharedInstance.privacyURL = privacyURL
            }
            
            if let termsURL = enviroment["terms_url"] as? String {
                ChatModel.sharedInstance.termsURL = termsURL
            }
            
            if let shareURL = enviroment["profile_share_url"] as? String {
                ChatModel.sharedInstance.shareURL = shareURL
            }
            
            if let postShareURL = enviroment["post_share_url"] as? String {
                ChatModel.sharedInstance.postShareURL = postShareURL
            }
            
            if let streamShareUrl = enviroment["stream_share_url"] as? String {
                ChatModel.sharedInstance.streamShareUrl = streamShareUrl
            }
            
            if let subscribeUrl = enviroment["subscribe_user_url"] as? String {
                ChatModel.sharedInstance.subscribeUserUrl = subscribeUrl
            }
            
            if let subscriptionPackagesUrl = enviroment["subscription_manage_url"] as? String {
//                PeeksModel.sharedInstance.subscriptionPackagesUrl = subscriptionPackagesUrl
            }
            
            if let impToCoin = enviroment["imp_to_con"] as? String {
                ChatModel.sharedInstance.impressionToCoinRatio = Double(impToCoin)
            }
            
            if let pubAdunitId = enviroment["publisher_adunit_id"] as? String {
                ChatModel.sharedInstance.publisherAdunitID = pubAdunitId
            }
            
            if let eighteenPlusRedirect = enviroment["plus_18_redirect_enabled"] as? String {
                ChatModel.sharedInstance.isEighteenPlusRedirect = eighteenPlusRedirect == "N" ? false : true
            }
            
            if let eighteenPlusText = enviroment["plus_18_popup_content"] as? String {
                ChatModel.sharedInstance.eighteenPlusPopupTextContent = eighteenPlusText
            }
            
            if let pubAdunitId = enviroment["network_id"] as? String {
                ChatModel.sharedInstance.networkID = pubAdunitId
            } else if let pubAdunitId = enviroment["network_id"] as? Int {
                ChatModel.sharedInstance.networkID = pubAdunitId.toString
            }
            
            ChatModel.sharedInstance.streamViewerLikeLimit = (enviroment["stream_viewer_like_limit"] as? NSNumber)?.intValue ?? 0
        }
        
        if let permissions = data["permissions"] as? [String] {
            ChatModel.sharedInstance.userPermissions = UserPermissions(params: permissions)
        }
        
        if let confirm = data["account_confirmed"] as? Bool {
            ChatModel.sharedInstance.accountConfirmed = confirm
        }
        
        if let canUse = data["can_use_app"] as? Bool {
            UserDefaultsUtil.addCanUseApp(canUse: canUse)
        }
        
        if let message = data["login_welcome_message_ios"] as? String, message.length > 0 {
            UserDefaultsUtil.addKillSwitchMessage(message: message)
        }
        self.getKeekChatToken()
        
        completionBlock()
        
    }
    
    func loginPeeksUsingSocialAccount(token: String, socialMediaType: String, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        let path = "/user/loginsocialmedia"
        let authentication = "\(token)"
        let params = ["token" : token, "social_media_type" : socialMediaType]
        
        performLogin(path: path, authentication: authentication, params: params, isSocialMedia: true) { (success, error) in
            completion(success, error)
        }
    }
    
    func parseStreamEnvironment(environment: [String: AnyObject]) {
        if let privateMaxTip = environment["stream_private_max_tip_amount"] as? Int {
            ChatModel.sharedInstance.streamPrivateMaxTipAmount = privateMaxTip
        }
        
        if let privateMinTip = environment["stream_private_min_tip_amount"] as? Int {
            ChatModel.sharedInstance.streamPrivateMinTipAmount = privateMinTip
        }
        
        if let followerMaxTip = environment["stream_followers_max_tip_amount"] as? Int {
            ChatModel.sharedInstance.streamFollowersMaxTipAmount = followerMaxTip
        }
        
        if let followerMinTip = environment["stream_followers_min_tip_amount"] as? Int {
            ChatModel.sharedInstance.streamFollowersMinTipAmount = followerMinTip
        }
        
        if let shouldAllowPaidG = environment["stream_paid_g"] as? String {
            ChatModel.sharedInstance.streamPaidG = shouldAllowPaidG == "Y"
        }
        
        if let shouldAllowPaid14 = environment["stream_paid_14plus"] as? String {
            ChatModel.sharedInstance.streamPaid14plus = shouldAllowPaid14 == "Y"
        }
        
        if let shouldAllowPaid18 = environment["stream_paid_18plus"] as? String {
            ChatModel.sharedInstance.streamPaid18plus = shouldAllowPaid18 == "Y"
        }
        
        if let shouldAllowPlay18 = environment["stream_play_18plus"] as? String {
            ChatModel.sharedInstance.streamPlay18plus = shouldAllowPlay18 == "Y"
        }
        
        if let shouldAllowTipG = environment["tip_stream_g"] as? String {
            ChatModel.sharedInstance.tipStreamG = shouldAllowTipG == "Y"
        }
        
        if let shouldAllowTip14 = environment["tip_stream_14plus"] as? String {
            ChatModel.sharedInstance.tipStream14plus = shouldAllowTip14 == "Y"
        }
        
        if let shouldAllowTip18 = environment["tip_stream_18plus"] as? String {
            ChatModel.sharedInstance.tipStream18plus = shouldAllowTip18 == "Y"
        }
    }
    
    func parseEnvironment(environment: [String: AnyObject]) {
        if let privacyURL = environment["privacy_url"] as? String {
            ChatModel.sharedInstance.privacyURL = privacyURL
        }
        
        if let termsURL = environment["terms_url"] as? String {
            ChatModel.sharedInstance.termsURL = termsURL
        }
        
        if let shareURL = environment["profile_share_url"] as? String {
            ChatModel.sharedInstance.shareURL = shareURL
        }
        
        if let streamShareUrl = environment["stream_share_url"] as? String {
            ChatModel.sharedInstance.streamShareUrl = streamShareUrl
        }
        
        if let streamViewUrl = environment["stream_view_url"] as? String {
            ChatModel.sharedInstance.streamViewUrl = streamViewUrl
        }
        
        if let channelViewUrl = environment["channel_view_url"] as? String {
            ChatModel.sharedInstance.channelViewUrl = channelViewUrl
        }
        
        if let walletUrl = environment["wallet_url"] as? String {
            ChatModel.sharedInstance.walletUrl = walletUrl
        }
        
        if let walletPurchaseUrl = environment["wallet_purchase_url"] as? String {
            ChatModel.sharedInstance.walletPurchaseUrl = walletPurchaseUrl
        }
        
        if let subscribeUserUrl = environment["subscribe_user_url"] as? String {
            ChatModel.sharedInstance.subscribeUserUrl = subscribeUserUrl
        }
        
        if let subscriptionManageUrl = environment["subscribe_manage_url"] as? String {
            ChatModel.sharedInstance.subscriptionManageUrl = subscriptionManageUrl
        }
        
        if let impToCoin = environment["imp_to_con"] as? String {
            ChatModel.sharedInstance.impressionToCoinRatio = Double(impToCoin)
        }
        
        if let pubAdunitId = environment["publisher_adunit_id"] as? String {
            ChatModel.sharedInstance.publisherAdunitID = pubAdunitId
        }
        
        if let eighteenPlusRedirect = environment["plus_18_redirect_enabled"] as? String {
            ChatModel.sharedInstance.isEighteenPlusRedirect = eighteenPlusRedirect == "N" ? false : true
        }
        
        if let eighteenPlusText = environment["plus_18_popup_content"] as? String {
            ChatModel.sharedInstance.eighteenPlusPopupTextContent = eighteenPlusText
        }
        
        if let pubAdunitId = environment["network_id"] as? String {
            ChatModel.sharedInstance.networkID = pubAdunitId
        } else if let pubAdunitId = environment["network_id"] as? Int {
            ChatModel.sharedInstance.networkID = pubAdunitId.toString
        }
        
        ChatModel.sharedInstance.streamViewerLikeLimit = (environment["stream_viewer_like_limit"] as? NSNumber)?.intValue ?? 0
    }
    
    /**
     * Get Keek Chat Token
     * POST /chat/get-token
     *
     *
     */
    func getKeekChatToken() { //login
        let ts = timestamp
        let path = "/chat/get-token"
        
        var params: [String: AnyObject] = ["ts": ts as AnyObject]
        params["user_id"] = ChatModel.sharedInstance.userId as AnyObject?
        
        let authToken: String = self.buildHash(RequestType.POST,
                                               uri: path, timeStamp: ts,
                                               authentication: "",
                                               apiSecret: ChatModel.sharedInstance.apiSecret,
                                               sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        ChatModel.sharedInstance.isLoadingKeekChatToken = true
        http.POST(path, authValue: authString, parameters: params) { (data, error, success) in
            print("Keek chat token data \(data)")
            ChatModel.sharedInstance.isLoadingKeekChatToken = false
            if success {
                if let token = data!["data"]?["token"] as? String {
                    ChatModel.sharedInstance.keekChatToken = token
                    KeychainService.saveKeekChatToken(token)
                    let fcmtoken = ChatModel.sharedInstance.fcmToken
                    self.registerForChatNotification(fcmtoken, 2)
                }
                
            } else {
                let token = KeychainService.loadKeekChatToken() ?? ""
                if token != "" {
                    ChatModel.sharedInstance.keekChatToken = token
                    if KeekChatBuilder.shared.isConnectionActive == .disconnected {
                        KeekChatBuilder.shared.initialize()
                        KeekChatBuilder.shared.addNetworkObserver()
                    }
                    let fcmtoken = ChatModel.sharedInstance.fcmToken
                    self.registerForChatNotification(fcmtoken, 2)
                }
                print("Keek chat token error \(error)")
            }
        }
    }
    
    func getKeekChatId() {
        ChatConnector().getChatTokenForUser(ChatModel.sharedInstance.userId) { success, error, toUserID, _, _,_  in
            if success {
                ChatModel.sharedInstance.userId = toUserID ?? ""
                KeychainService.saveKeekChatUserId(toUserID ?? "")
                print("My chat id is \(toUserID)")
            } else {
                print("my chat id error \(error)")
            }
        }
    }
}
