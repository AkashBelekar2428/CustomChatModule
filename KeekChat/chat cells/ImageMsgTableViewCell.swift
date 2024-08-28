//
//  ImageMsgTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 07/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit

protocol ImageSentMsgTableViewCellDelegate: class {
    func viewSentImage(messageNo: Int)
}

class ImageMsgTableViewCell: UITableViewCell {

    
    @IBOutlet var playView: GradientShadowView!
    @IBOutlet var imageMsgView: MyImageView!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var profileImgview: MyImageView!
    @IBOutlet var newDayLbl: UILabel!
    @IBOutlet var msgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var selectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var profileImgTopConstraint: NSLayoutConstraint!
    @IBOutlet var selectionBlurView: UIView!
    @IBOutlet var readStatusLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    static let reuseIdentifier = "imageMsgTableViewCell"
    var delegate: ImageSentMsgTableViewCellDelegate?
    var shouldShowProfilePicture = true
    var showDateLbl = false
    var date = ""
    var messageNo: Int?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        newDayLbl.isHidden = true
        selectionBlurView.isHidden = true
        imageMsgView.image = UIImage(named: "img_placeholder")
        activityIndicator.isHidden = true
        playView.isHidden = true
        playView.layer.cornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "ImageMsgTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    @IBAction func goToImage(_ sender: Any) {
        self.delegate?.viewSentImage(messageNo: self.messageNo ?? 0)
    }
    
    func updateCellUI() {
        if shouldShowProfilePicture {
            profileImgview.isHidden = false
            msgViewTopConstraint.constant = 20.25
            
            if showDateLbl {
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                selectionViewTopConstraint.constant = 24
                profileImgTopConstraint.constant = 28
                msgViewTopConstraint.constant = 38
            } else {
                newDayLbl.isHidden = true
                newDayLbl.text = ""
                selectionViewTopConstraint.constant = 2
                profileImgTopConstraint.constant = 6
            }
        } else {
            profileImgview.isHidden = true
            msgViewTopConstraint.constant = 10
            if showDateLbl {
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                msgViewTopConstraint.constant = 32
                selectionViewTopConstraint.constant = 22
            } else {
                newDayLbl.isHidden = true
                newDayLbl.text = ""
                selectionViewTopConstraint.constant = 6
            }
        }
    }
    
    func showLoader() {
        activityIndicator.startAnimating()
                activityIndicator.isHidden = false
    }
    
    func hideLoader() {
        activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
    }
}
