//
//  ImageReceivedTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 07/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit

protocol ImageReceivedTableViewCellDelegate: class {
    func viewReceivedImage(messageNo: Int)
}

class ImageReceivedTableViewCell: UITableViewCell {

    @IBOutlet var playView: GradientShadowView!
    @IBOutlet var usernameLblTopConstraint: NSLayoutConstraint!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var newDayLbl: UILabel!
    @IBOutlet var unreadLbl: UILabel!
    @IBOutlet var imageMsgView: MyImageView!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var profileImgview: MyImageView!
    @IBOutlet var msgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var profilePictureTopConstraint: NSLayoutConstraint!
    static let reuseIdentifier = "imageReceivedTableViewCell"
    var delegate: ImageReceivedTableViewCellDelegate?
    var shouldShowProfilePicture = true
    var shouldShowDayLbl = false
    var shouldShowUnreadLbl = false
    var shouldShowUsername = false
    var date = ""
    var messageNo: Int?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        newDayLbl.isHidden = true
        newDayLbl.backgroundColor = .clear
        imageMsgView.image = UIImage(named: "img_placeholder")
        usernameLbl.isHidden = true
        playView.isHidden = true
        usernameLblTopConstraint.constant = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "ImageReceivedTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    @IBAction func goToImage(_ sender: Any) {
        self.delegate?.viewReceivedImage(messageNo: self.messageNo ?? 0)
    }
    
    func updateCellUI() {
        if shouldShowProfilePicture {
            
            profileImgview.isHidden = false
            if shouldShowUsername {
                msgViewTopConstraint.constant = 32
                usernameLbl.isHidden = false
                usernameLblTopConstraint.constant = 10
            } else {
                msgViewTopConstraint.constant = 20.25
                usernameLbl.isHidden = true
            }
            profilePictureTopConstraint.constant = 10
            if shouldShowDayLbl && shouldShowUnreadLbl {
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                unreadLbl.isHidden = false
                unreadLbl.text = "Unread Messages".localized
                unreadLbl.layer.cornerRadius = 9
                unreadLbl.layer.masksToBounds = true
                if shouldShowUsername {
                    msgViewTopConstraint.constant = 75
                    usernameLblTopConstraint.constant = 53
                } else {
                    msgViewTopConstraint.constant = 44
                }
                profilePictureTopConstraint.constant = 62
            } else if shouldShowDayLbl && !shouldShowUnreadLbl {
                unreadLbl.isHidden = true
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                if shouldShowUsername {
                    msgViewTopConstraint.constant = 46
                    usernameLblTopConstraint.constant = 24
                } else {
                    msgViewTopConstraint.constant = 32
                }
                profilePictureTopConstraint.constant = 30
            } else if !shouldShowDayLbl && shouldShowUnreadLbl {
                unreadLbl.isHidden = false
                unreadLbl.text = "Unread Messages".localized
                unreadLbl.layer.cornerRadius = 9
                unreadLbl.layer.masksToBounds = true
                if shouldShowUsername {
                    msgViewTopConstraint.constant = 46
                    usernameLblTopConstraint.constant = 24
                } else {
                    msgViewTopConstraint.constant = 32
                }
                newDayLbl.isHidden = true
                newDayLbl.text = ""
                profilePictureTopConstraint.constant = 30
            } else {
                unreadLbl.isHidden = true
                newDayLbl.isHidden = true
                newDayLbl.text = ""
            }
            
        } else {
            
            profileImgview.isHidden = true
            msgViewTopConstraint.constant = 0
            usernameLbl.isHidden = true
            if shouldShowDayLbl && shouldShowUnreadLbl {
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                unreadLbl.isHidden = false
                unreadLbl.text = "Unread Messages".localized
                unreadLbl.layer.cornerRadius = 9
                unreadLbl.layer.masksToBounds = true
                msgViewTopConstraint.constant = 44
            } else if shouldShowDayLbl && !shouldShowUnreadLbl {
                unreadLbl.isHidden = true
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                msgViewTopConstraint.constant = 26
            } else if !shouldShowDayLbl && shouldShowUnreadLbl {
                unreadLbl.isHidden = false
                unreadLbl.text = "Unread Messages".localized
                unreadLbl.layer.cornerRadius = 9
                unreadLbl.layer.masksToBounds = true
                msgViewTopConstraint.constant = 26
                newDayLbl.isHidden = true
                newDayLbl.text = ""
            } else {
                unreadLbl.isHidden = true
                newDayLbl.isHidden = true
                newDayLbl.text = ""
            }
        }
    }
}
