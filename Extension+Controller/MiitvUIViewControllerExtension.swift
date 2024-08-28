//
//  MiitvUIViewControllerExtension.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 23/11/22.
//  Copyright © 2022 Riavera. All rights reserved.
//

import Firebase
import FirebaseAnalytics
import UIKit

extension UIViewController {
    
    func setScreeName(_ name: String) {
        self.title = name
    }
    
    func analyticsTrackEvent(_ category: String, action: String, label: String, value: NSNumber?) {
        Analytics.logEvent(category, parameters: [
        "action" : action as NSObject,
        "label" : label as NSObject,
        "value" : value as Any])
    }
    
    @objc func dismissVc() {
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func animatedDismissVc() {
        DispatchQueue.main.async(execute: {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    //EZSE: Presents a view controller modally.
    @objc func presentVC(_ vc: UIViewController) {
        DispatchQueue.main.async(execute: {
            self.present(vc, animated: true, completion: nil)
        })
    }
    
    @objc func animatedPresentVC(_ vc: UIViewController) {
        DispatchQueue.main.async(execute: {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.present(vc, animated: false, completion: nil)
        })
    }
    
    @objc func blur(_ shouldBlur: Bool, belowView: UIView?, withDuration: TimeInterval, completion: (() -> Void)? = nil) {
        if shouldBlur {
            let blurEffect = UIBlurEffect(style: .dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = self.view.bounds
            
            if let belowView = belowView {
                self.view.insertSubview(blurView, belowSubview: belowView)
            } else {
                self.view.addSubview(blurView)
            }
            self.viewDidLayoutSubviews()
            completion?()
        } else {
            for subview in self.view.subviews {
                if subview is UIVisualEffectView {
                    UIView.animate(withDuration: withDuration, animations: {
                        subview.alpha = 0
                        }, completion: { (_ completed) in
                            subview.removeFromSuperview()
                            self.viewDidLayoutSubviews()
                            completion?()
                    })
                }
            }
        }
    }
    
}

//extension UIViewController : ViewDirection {
//    func direction() -> UIUserInterfaceLayoutDirection {
//        return self.view.direction()
//    }
//}

//RattleSnake Chat stuff
extension UIViewController {
    func showFirebaseChatUI(userId: String, fromMessages: Bool = false) {
//        ChatHelper.startConversation(id: userId, searchIndex: "email") { result in
//            switch result {
//            case .success(let vc):
//
//                let navController = UINavigationController(rootViewController: vc)
//                navController.modalPresentationStyle = .fullScreen
//
//                if #available(iOS 13, *) {
//                    navController.isModalInPresentation = true
//                }
//
//                DispatchQueue.main.async {
//                    self.present(navController, animated: true, completion: nil)
//                }
//
//            case .failure(let error):
//
//                print("Firebase - \(error)")
//                let alert = UIAlertController(title: "Sorry", message: "Unable to message the user at this current time.", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
//                alert.addAction(okAction)
//
//                DispatchQueue.main.async {
//                    self.present(alert, animated: true, completion: nil)
//                }
//
//            }
//        }
    }
    
   
}

extension UIViewController {
    func performNotifObject() {
        
    }
}
