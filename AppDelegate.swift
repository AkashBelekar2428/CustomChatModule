//
//  AppDelegate.swift
//  ChatModule
//
//  Created by Akash Belekar on 23/07/24.
//

import UIKit
import TrustKit
import FirebaseMessaging
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate, UNUserNotificationCenterDelegate {
    
    
    let keekChat = KeekChatBuilder.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // Register for remote notifications
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in
            
        }
        application.registerForRemoteNotifications()
        
        // Get FCM token
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error)")
            } else if let token = token {
                print("FCM token: \(token)")
                // Save or use the FCM token as needed
            }
        }
        
        //Clear keychain on first run in case of reinstallation: also used to check if app has been just installed or opened (code in the begining of this function)
        if !UserDefaultsUtil.getRegularRun() {
            UserDefaultsUtil.addRegularRun(run: true)
        }
        
        if !UserDefaults.standard.bool(forKey: "OneTime") {
            UserDefaults.standard.set(true, forKey: "OneTime")
            UserDefaultsUtil.setIsFullAllOver(isfull: true)
        }
        UIApplication.shared.isIdleTimerDisabled = true
        
        let trustKitConfig = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                "dev.api.keek.com": [
                    kTSKEnforcePinning: false,
                    kTSKIncludeSubdomains: true,
                    kTSKPublicKeyHashes: [
                        "7Iq+Ng+8aSPBQAuMa59Ylk052o4JG/py2dGqB31j8JE="
                    ]],
                "main.api.keek.com": [
                    kTSKEnforcePinning: false,
                    kTSKIncludeSubdomains: true,
                    kTSKPublicKeyHashes: [
                        "7Iq+Ng+8aSPBQAuMa59Ylk052o4JG/py2dGqB31j8JE="
                    ]], ]] as [String: Any]
        
        TrustKit.initSharedInstance(withConfiguration: trustKitConfig)
        
        let _ = ChatCoreDataHelper.sharedChatDBHelper.persistentContainer
        
        UserDefaultsUtil.addIsUploadingPost(isUploading: false)
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken)")
        ChatModel.sharedInstance.fcmToken = fcmToken ?? ""
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for index in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[index]])
        }
        
        print("Device token is: \(tokenString)")
        ChatModel.sharedInstance.setDeviceToken(tokenString)
        UserDefaultsUtil.addDeviceToken(token: tokenString)
        if !self.hasReset {
            Notification.Name.gotNewDeviceToken.post()
            //            textChat.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
            Messaging.messaging().apnsToken = deviceToken
        }
    }
    // MARK: UISceneSession Lifecycle
    func registerForNotification(_ application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound,.alert,.badge], completionHandler: { (granted, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            })
        } else {
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            application.registerUserNotificationSettings(pushNotificationSettings)
            application.registerForRemoteNotifications()
        }
    }
    var hasReset = false
    func resetRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.unregisterForRemoteNotifications()
            UIApplication.shared.registerForRemoteNotifications()
            self.hasReset = true//logged out
        }
        
        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            // Called when a new scene session is being created.
            // Use this method to select a configuration to create the new scene with.
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
        
        func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
            // Called when the user discards a scene session.
            // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
            // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        }
        func applicationWillTerminate(_ application: UIApplication) {
            keekChat.disconnectChat()
        }
        
    }
}
    
//    @available(iOS 10, *)
//    extension AppDelegate: UNUserNotificationCenterDelegate {
//        // Receive displayed notifications for iOS 10 devices.
//        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//            let userInfo = notification.request.content.userInfo
//            // Handle the notification content here
//            completionHandler([.alert, .sound, .badge])
//        }
//        
//        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//            let userInfo = response.notification.request.content.userInfo
//            // Handle the notification content here
//            completionHandler()
//        }
//    }

