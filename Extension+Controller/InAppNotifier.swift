//
//  InAppNotifier.swift
//  Peeks
//
//  Created by Aaron Wong on 2016-06-06.
//  Copyright © 2016 Riavera. All rights reserved.
//

import UIKit
import JFMinimalNotifications

enum NotificationType {
    case `default`
    case error
    case success
    case info
    case warning
    
    func getNotificationType() -> JFMinimalNotificationStyle {
        switch self {
        case .default:
            return JFMinimalNotificationStyle.default
        case .error:
            return JFMinimalNotificationStyle.error
        case .success:
            return JFMinimalNotificationStyle.success
        case .info:
            return JFMinimalNotificationStyle.info
        case .warning:
            return JFMinimalNotificationStyle.warning
        }
    }
}

enum NotificationObjectType {
    case user
    case stream
    case streamUserId
    case chat
    case url
    case alert (UIAlertController)
    case postComment
    case miitvNewFollower
    case newFollowerRequest
    case followUserRequestAccepted
    case followUserRequestDeclined
    case post
    case postLike
    case userVerification
    case postViolation
    case userChatMsg
    case groupChatMsg
    case other
}

class NotificationObject: NSObject {
    var objectId: String?
    var objectType: NotificationObjectType = .user //by default
    var optObject: String?  //fall back objectId, incase of objectType is stream and stream is deleted, optObject will be userId to open user profile as a fallback
    var objectValue: String?
    var authRequired: Bool? = true
    
}

@objc protocol InAppNotifierDelegate {
    func didTapInAppNotification(_ notifObject: NotificationObject?)
}

class InAppNotifier: NSObject, JFMinimalNotificationDelegate {
    
    static let sharedInstance = InAppNotifier()
    
    var inAppNotification: JFMinimalNotification?
    
    var delegate: InAppNotifierDelegate?
    
    var notifObject: NotificationObject?
   
    func showLocalNotification(_ vc: UIViewController, title: String, subTitle: String, notificationType: NotificationType) {

        /*if (self.inAppNotification == nil) {
            self.inAppNotification = JFMinimalNotification(style: notificationType.getNotificationType(), title: title, subTitle: subTitle, dismissalDelay: 3.0, touchHandler: inAppNotificationTapped)
            self.inAppNotification!.delegate = self
            self.inAppNotification!.edgePadding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        } else {
            self.inAppNotification!.setStyle(notificationType.getNotificationType(), animated: true)
        }*/
        
        self.inAppNotification = JFMinimalNotification(style: notificationType.getNotificationType(), title: title, subTitle: subTitle, dismissalDelay: 5.0, touchHandler: inAppNotificationTapped)
        self.inAppNotification!.delegate = self
        self.inAppNotification!.edgePadding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)

        if !self.inAppNotification!.isDescendant(of: vc.view) {
            vc.view.addSubview(self.inAppNotification!)
        }
        
        self.inAppNotification!.show()
    }
    
    func inAppNotificationTapped() {
        print("Did tap noitification")
        
        if let del = self.delegate {
            
            del.didTapInAppNotification(notifObject)
        }
        
    }
    
    func minimalNotificationWillShow(_ notification: JFMinimalNotification) {
        print("minimalNotificationWillShowNotification: \(notification)")
    }
    
    func minimalNotificationDidShow(_ notification: JFMinimalNotification) {
        print("minimalNotificationDidShowNotification: \(notification)")
    }
    
    func minimalNotificationWillDisimissNotification(_ notification: JFMinimalNotification) {
        print("minimalNotificationWillDisimissNotification: \(notification)")
    }
    
    func minimalNotificationDidDismiss(_ notification: JFMinimalNotification) {
        print("minimalNotificationDidDismissNotification: \(notification)")
    }

}
