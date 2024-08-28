//
//  AvatarUpdateView.swift
//  Peeks
//
//  Created by Amena Amro on 6/9/16.
//  Copyright © 2016 Riavera. All rights reserved.
//

import UIKit
import AVFoundation

protocol AvatarUpdateDelegate: class {
    func didUpdateAvatar(_ image: UIImage, avatarUrl: String)
}

class AvatarUpdateView: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HTTPRequesterDelegate {
    
    weak var delegate: AvatarUpdateDelegate?
    
    let imagePicker = UIImagePickerController()
    var progressView: UIProgressView?
    var viewController: UIViewController?
    
    func show(_ viewController: UIViewController) {
        self.viewController = viewController
        imagePicker.allowsEditing = false
        
        let cameraAction = UIAlertAction(title: "profile_userpic_camera".localized, style: .default, handler: { (_ alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .camera
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined {
                viewController.present(self.imagePicker, animated: true, completion: nil)
                self.imagePicker.delegate = self
            }
            self.checkIfCameraIsAvailable()
        })
        
        let galleryAction = UIAlertAction(title: "profile_userpic_gallery".localized, style: .default, handler: { (_ alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .photoLibrary
            viewController.present(self.imagePicker, animated: true, completion: nil)
            self.imagePicker.delegate = self
        })
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: { (_ alert: UIAlertAction!) -> Void in })
        
        self.viewController?.present(UIAlertController.avatarSelectionActionSheet(cameraAction, galleryAction: galleryAction, cancelAction: cancelAction), animated: true, completion: nil)
    }
    
    func checkIfCameraIsAvailable() {
        
        if !AVCaptureDevice.cameraIsAllowed() {
            
            let alert = UIAlertController(title: NSLocalizedString("camera_source_error_title", comment: ""),
                                          message: NSLocalizedString("camera_source_error_message",
                                            comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("no", comment: ""), style: UIAlertAction.Style.cancel) { _ in
            }
            let continueAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default) { _ in
                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
            
            // Add the actions
            alert.addAction(cancelAction)
            alert.addAction(continueAction)
            
            DispatchQueue.main.async(execute: {
                self.viewController!.present(alert, animated: true, completion: nil)
            })
            
        } else {
            viewController!.present(self.imagePicker, animated: true, completion: nil)
            imagePicker.delegate = self
        }
        
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        self.viewController!.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                self.showProgressViewForView("uploading_photo".localized, completion: {
                    UserConnector().uploadAvatar(ChatModel.sharedInstance.userId, image: image, delegate: self, completion: { (success, error, avatarUrl) in
                        if success {
                            self.uploadImageSuccess(avatarUrl!, image: image)
                        } else {
                            self.removeProgressViewForView()
                            UIUtil.apiFailure(error!, vc: self.viewController!)
                        }
                    })
                })
            }
        })
    }
    
    func HTTPRequesterFileUploadProgress(_ uploadProgress: Float, progressPercentage: Int) {
        if let progressBar = progressView {
            progressBar.progress = Float(progressPercentage) / 100
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.viewController!.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API call backs
    func uploadImageSuccess(_ avatarUrl: String, image: UIImage) {
        DispatchQueue.main.async {
            self.removeProgressViewForView()
            if let mainUser = ChatModel.sharedInstance.users {
                mainUser.avatarUrl = avatarUrl
                
                UserDefaultsUtil.addUserInfo(avatarUrl: mainUser.avatarUrl)
                self.delegate?.didUpdateAvatar(image, avatarUrl: avatarUrl)
            }
        }
    }
    
    func uploadImageFailure(_ error: NSError) {
        DispatchQueue.main.async {
            self.removeProgressViewForView()
            UIUtil.showAlert(NSLocalizedString("error", comment: ""), message: error.localizedDescription, vc: self.viewController!)
        }
    }
    
    func showProgressViewForView(_ labelText: String?, completion: () -> Void) {
        let loadView = UIView(frame: CGRect(x: 0, y: 0, width: self.viewController!.view.bounds.size.width, height: self.viewController!.view.bounds.size.height))
        loadView.tag = 1212
        loadView.backgroundColor = UIColor.black
        loadView.alpha = 0.75
        progressView = UIProgressView(progressViewStyle: UIProgressView.Style.default)
        progressView?.center = loadView.center
        
        if let labelText = labelText {
            let loadLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.viewController!.view.bounds.size.width, height: 30))
            loadLabel.center = CGPoint(x: (progressView?.center.x)!, y: (progressView?.frame.origin.y)! + 50)
            loadLabel.textAlignment = .center
            loadLabel.font = loadLabel.font.withSize(20)
            loadLabel.textColor = UIColor.white
            loadLabel.text = labelText
            loadView.addSubview(loadLabel)
        }
        
        loadView.addSubview(progressView!)
        self.viewController!.view.addSubview(loadView)
        completion()
    }
    
    func removeProgressViewForView() {
        if let subView: UIView = self.viewController!.view.viewWithTag(1212) {
            subView.removeFromSuperview()
        }
    }
}


class GroupAvatarUpdateView: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HTTPRequesterDelegate {
    
    weak var delegate: AvatarUpdateDelegate?
    
    let imagePicker = UIImagePickerController()
    var progressView: UIProgressView?
    var viewController: UIViewController?
    
    func show(_ viewController: UIViewController) {
        self.viewController = viewController
        imagePicker.allowsEditing = false
        
        let cameraAction = UIAlertAction(title: "profile_userpic_camera".localized, style: .default, handler: { (_ alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .camera
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined {
                viewController.present(self.imagePicker, animated: true, completion: nil)
                self.imagePicker.delegate = self
            }
            self.checkIfCameraIsAvailable()
        })
        
        let galleryAction = UIAlertAction(title: "profile_userpic_gallery".localized, style: .default, handler: { (_ alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .photoLibrary
            viewController.present(self.imagePicker, animated: true, completion: nil)
            self.imagePicker.delegate = self
        })
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: { (_ alert: UIAlertAction!) -> Void in })
        
        self.viewController?.present(UIAlertController.avatarSelectionActionSheet(cameraAction, galleryAction: galleryAction, cancelAction: cancelAction), animated: true, completion: nil)
    }
    
    func checkIfCameraIsAvailable() {
        
        if !AVCaptureDevice.cameraIsAllowed() {
            
            let alert = UIAlertController(title: NSLocalizedString("camera_source_error_title", comment: ""),
                                          message: NSLocalizedString("camera_source_error_message",
                                            comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("no", comment: ""), style: UIAlertAction.Style.cancel) { _ in
            }
            let continueAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default) { _ in
                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
            
            // Add the actions
            alert.addAction(cancelAction)
            alert.addAction(continueAction)
            
            DispatchQueue.main.async(execute: {
                self.viewController!.present(alert, animated: true, completion: nil)
            })
            
        } else {
            viewController!.present(self.imagePicker, animated: true, completion: nil)
            imagePicker.delegate = self
        }
        
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        self.viewController!.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                self.uploadImageSuccess("", image: image)
//                self.showProgressViewForView("uploading_photo".localized, completion: {
//                    UserConnector().uploadAvatar(ChatModel.sharedInstance.userId, image: image, delegate: self, completion: { (success, error, avatarUrl) in
//                        if success {
//                            self.uploadImageSuccess(avatarUrl!, image: image)
//                        } else {
//                            self.removeProgressViewForView()
//                            UIUtil.apiFailure(error!, vc: self.viewController!)
//                        }
//                    })
//                })
            }
        })
    }
    
    func HTTPRequesterFileUploadProgress(_ uploadProgress: Float, progressPercentage: Int) {
        if let progressBar = progressView {
            progressBar.progress = Float(progressPercentage) / 100
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.viewController!.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API call backs
    func uploadImageSuccess(_ avatarUrl: String, image: UIImage) {
        DispatchQueue.main.async {
            self.removeProgressViewForView()
            if let mainUser = ChatModel.sharedInstance.users {
                mainUser.avatarUrl = avatarUrl
                
                UserDefaultsUtil.addUserInfo(avatarUrl: mainUser.avatarUrl)
                self.delegate?.didUpdateAvatar(image, avatarUrl: avatarUrl)
            }
        }
    }
    
    func uploadImageFailure(_ error: NSError) {
        DispatchQueue.main.async {
            self.removeProgressViewForView()
            UIUtil.showAlert(NSLocalizedString("error", comment: ""), message: error.localizedDescription, vc: self.viewController!)
        }
    }
    
    func showProgressViewForView(_ labelText: String?, completion: () -> Void) {
        let loadView = UIView(frame: CGRect(x: 0, y: 0, width: self.viewController!.view.bounds.size.width, height: self.viewController!.view.bounds.size.height))
        loadView.tag = 1212
        loadView.backgroundColor = UIColor.black
        loadView.alpha = 0.75
        progressView = UIProgressView(progressViewStyle: UIProgressView.Style.default)
        progressView?.center = loadView.center
        
        if let labelText = labelText {
            let loadLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.viewController!.view.bounds.size.width, height: 30))
            loadLabel.center = CGPoint(x: (progressView?.center.x)!, y: (progressView?.frame.origin.y)! + 50)
            loadLabel.textAlignment = .center
            loadLabel.font = loadLabel.font.withSize(20)
            loadLabel.textColor = UIColor.white
            loadLabel.text = labelText
            loadView.addSubview(loadLabel)
        }
        
        loadView.addSubview(progressView!)
        self.viewController!.view.addSubview(loadView)
        completion()
    }
    
    func removeProgressViewForView() {
        if let subView: UIView = self.viewController!.view.viewWithTag(1212) {
            subView.removeFromSuperview()
        }
    }
}
