//
//  ViewImageMsgViewController.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 07/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit

class ViewImageMsgViewController: UIViewController {
    var orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return self.orientations }
        set { self.orientations = newValue }
    }

    @IBOutlet var mainImgView: MyImageView!
    @IBOutlet var downloadBtn: MyButton!
    var imgUrl: String = ""
    
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            UIUtil.indicateActivityForView(self.view, labelText: "Loading...")
            
        }
        self.mainImgView.sd_setImage(with: NSURL(string: imgUrl) as URL?, completed: { (img, error, _, _) in
            if let img = self.mainImgView.image {
                let aspectFitHeight = self.mainImgView.bounds.width / img.size.width * img.size.height
                var screenHeight = UIScreen.main.bounds.height - 200
                print("chat Image height \(aspectFitHeight)")
                if screenHeight < aspectFitHeight {
                    self.imageViewHeightConstraint.constant = screenHeight
                } else {
                    self.imageViewHeightConstraint.constant = aspectFitHeight
                }
                // Update the bottom anchor based on the adjusted height
                if img.size.width > img.size.height {
                    self.mainImgView.contentMode = .scaleAspectFill
                } else {
                    self.mainImgView.contentMode = .scaleAspectFit
                }
                self.view.layoutIfNeeded()
            }
                 if error != nil {
                     self.mainImgView.image = UIImage(named: "img_placeholder")
                 }
            DispatchQueue.main.async {
                UIUtil.removeActivityViewFromView(self.view)
            }
             })
    }

    @IBAction func backButtonAction(_ sender: Any) {
        DispatchQueue.main.async {
            UIUtil.removeActivityViewFromView(self.view)
        }
        self.animatedDismissVc()
    }

    @IBAction func downloadImage(_ sender: Any) {
        if let url = URL(string: self.imgUrl) {
            self.downloadBtn.isUserInteractionEnabled = false
            ChatCacheManager.shared.downloadImageAndSaveToGallery(from: url) { success, error in
                if success {
                    DispatchQueue.main.async { [self] in
                        UIUtil.showAlert("Download success", message: "Image downloaded to gallery", vc: self)
                        self.downloadBtn.isUserInteractionEnabled = true
                    }
                } else {
                    DispatchQueue.main.async { [self] in
                        UIUtil.showAlert("Download failure", message: "Failed to download image to gallery", vc: self)
                        self.downloadBtn.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
}
