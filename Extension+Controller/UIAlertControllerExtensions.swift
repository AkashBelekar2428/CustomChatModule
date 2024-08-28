//
//  UIAlertControllerExtensions.swift
//  Streamini
//
//  Created by Vasily Evreinov on 24/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    open override var shouldAutorotate: Bool {
        return false
    }

    class func sendMailErrorAlert() -> UIAlertController {
        let alertTitle      = NSLocalizedString("feddback_error_alert_title", comment: "")
        let alertMessage    = NSLocalizedString("feddback_error_alert_message", comment: "")
        let ok              = NSLocalizedString("ok", comment: "")
        
        let alertView = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        let yesAction = UIAlertAction(title: ok, style: UIAlertAction.Style.default) { (_ result: UIAlertAction) -> Void in
            print(ok)
        }
        alertView.addAction(yesAction)
        alertView.view.tintColor = .MiiTV_ThemeClr()
        return alertView
    }

    class func mailUnavailableErrorAlert() -> UIAlertController {
        let alertTitle      = NSLocalizedString("mail_unavailable_error_alert_title", comment: "")
        let alertMessage    = NSLocalizedString("mail_unavailable_error_alert_message", comment: "")
        let ok              = NSLocalizedString("ok", comment: "")
        
        let alertView = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        let yesAction = UIAlertAction(title: ok, style: UIAlertAction.Style.default) { (_ result: UIAlertAction) -> Void in
            print(ok)
        }
        alertView.addAction(yesAction)
        alertView.view.tintColor = .MiiTV_ThemeClr()
        return alertView
    }
    
    class func confirmLogoutActionSheet(_ yesAction: UIAlertAction, cancelAction: UIAlertAction) -> UIAlertController {
        let actionSheetTitle = NSLocalizedString("profile_logout_actionsheet_title", comment: "")
        let actionSheet = UIAlertController(title: actionSheetTitle, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionSheet.addAction(yesAction)
        actionSheet.addAction(cancelAction)
        actionSheet.view.tintColor = .MiiTV_ThemeClr()
        return actionSheet
    }
    
    class func deletePostActionSheet(_ yesAction: UIAlertAction, cancelAction: UIAlertAction) -> UIAlertController {
        let actionSheetTitle = NSLocalizedString("DeletePostActionSheetTitle", comment: "")
        let actionSheet = UIAlertController(title: actionSheetTitle, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionSheet.addAction(yesAction)
        actionSheet.addAction(cancelAction)
        actionSheet.view.tintColor = .MiiTV_ThemeClr()
        return actionSheet
    }
    
    class func confirmBankAccountDeleteActionSheet(_ yesAction: UIAlertAction, cancelAction: UIAlertAction) -> UIAlertController {
        let actionSheetTitle = NSLocalizedString("bank_account_delete_actionsheet_title", comment: "")
        
        let actionSheet = UIAlertController(title: actionSheetTitle, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.addAction(yesAction)
        actionSheet.addAction(cancelAction)
        actionSheet.view.tintColor = .MiiTV_ThemeClr()
        return actionSheet
    }
    
    class func deleteOfferActionSheet(_ yesAction: UIAlertAction, cancelAction: UIAlertAction) -> UIAlertController {
        let actionSheetTitle = NSLocalizedString("AreYouSureYouWantToDeleteThisOffer?".localized, comment: "")
        
        let actionSheet = UIAlertController(title: actionSheetTitle, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.addAction(yesAction)
        actionSheet.addAction(cancelAction)
        actionSheet.view.tintColor = .MiiTV_ThemeClr()
        return actionSheet
    }
    
    
    class func reportOfferActionSheet(_ yesAction: UIAlertAction, cancelAction: UIAlertAction) -> UIAlertController {
        let actionSheetTitle = NSLocalizedString("AreYouSureYouWantToReportThisOffer?".localized, comment: "")
        
        let actionSheet = UIAlertController(title: actionSheetTitle, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.addAction(yesAction)
        actionSheet.addAction(cancelAction)
        actionSheet.view.tintColor = .MiiTV_ThemeClr()
        return actionSheet
    }
    
    class func otherUserProfileActionSheet(_ blockAction: UIAlertAction, reportAction: UIAlertAction, unfollowAction: UIAlertAction?, cancelAction: UIAlertAction, shareAction: UIAlertAction) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(blockAction)
        actionSheet.addAction(reportAction)
        if let unfollowAction = unfollowAction {
            actionSheet.addAction(unfollowAction)
        }
        actionSheet.addAction(shareAction)
        actionSheet.addAction(cancelAction)
        actionSheet.view.tintColor = .MiiTV_ThemeClr()
        return actionSheet
    }
    
    class func postMenuActionSheet(_ deleteAction: UIAlertAction, reportAction: UIAlertAction, cancelAction: UIAlertAction, shareAction: UIAlertAction, isMyProfile: Bool, canShare: Bool) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if isMyProfile {
            actionSheet.addAction(deleteAction)
        } else {
            actionSheet.addAction(reportAction)
            
        }
        
        if canShare {
        actionSheet.addAction(shareAction)
        }
        actionSheet.addAction(cancelAction)
        actionSheet.view.tintColor = .MiiTV_ThemeClr()
        return actionSheet
    }
    
    class func streamShareActionSheet(_ internalShareAction: UIAlertAction, externalShareAction: UIAlertAction, cancelAction: UIAlertAction) -> UIAlertController {
        let actionSheetTitle = "stream_share_option_title".localized
        let actionSheetMessage = "stream_share_option_message".localized
        let actionSheet = UIAlertController(title: actionSheetTitle, message: actionSheetMessage, preferredStyle: .actionSheet)
        actionSheet.addAction(internalShareAction)
        actionSheet.addAction(externalShareAction)
        actionSheet.addAction(cancelAction)
        actionSheet.view.tintColor = .MiiTV_ThemeClr()
        return actionSheet
    }
    
    class func avatarSelectionActionSheet(_ cameraAction: UIAlertAction, galleryAction: UIAlertAction, cancelAction: UIAlertAction, title: String = "choose_picture".localized) -> UIAlertController {
        let actionSheetTitle = title
        let actionSheet = UIAlertController(title: actionSheetTitle, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(cancelAction)
        actionSheet.view.tintColor = .MiiTV_ThemeClr()
        return actionSheet
    }
    
    class func createBasicActionSheet(_ actionSheetTitle: String, yesAction: UIAlertAction, cancelAction: UIAlertAction) -> UIAlertController {
        let actionSheet = UIAlertController(title: actionSheetTitle, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(yesAction)
        actionSheet.addAction(cancelAction)
        actionSheet.view.tintColor = .MiiTV_ThemeClr()
        return actionSheet
    }
    
    class func createBasicAlert(_ alertTitle: String?, alertMessage: String?, yesAction: UIAlertAction, cancelAction: UIAlertAction) -> UIAlertController {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .MiiTV_ThemeClr()
        return alert
    }
}
