//
//  ReceivedMsgTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 02/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit
import ActiveLabel

protocol URLNavigationDelegate: class {
    func openLink(url: String)
}


class ReceivedMsgTableViewCell: UITableViewCell {

    @IBOutlet var messageViewMinWidth: NSLayoutConstraint!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var newDayLbl: UILabel!
    @IBOutlet var messageViewWidth: NSLayoutConstraint!
    @IBOutlet var timeLbl: UILabel!
//    @IBOutlet var messageLbl: UILabel!
    @IBOutlet var profileImgview: MyImageView!
    @IBOutlet var messageView: UIView!
    static let reuseIdentifier = "receivedMsgTableViewCell"
    @IBOutlet var msgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var unreadLbl: UILabel!
    @IBOutlet var profilePictureTopConstraint: NSLayoutConstraint!
    @IBOutlet var messageLbl: ActiveLabel!
    @IBOutlet var msgLblTopConstraint: NSLayoutConstraint!
    var shouldShowProfilePicture = true
    var shouldShowDayLbl = false
    var shouldShowUnreadLbl = false
    var date = ""
    var shouldShowUsername = false
    var urlDelegate: URLNavigationDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageView.layer.cornerRadius = 16
        messageView.layer.masksToBounds = false
        messageView.layer.maskedCorners = [ .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        messageViewWidth.constant = UIScreen.main.bounds.width - 100
        messageViewMinWidth.constant = 110
        newDayLbl.isHidden = true
        newDayLbl.backgroundColor = .clear
        usernameLbl.text = ""
        messageLbl.URLColor = .MiiTV_ThemeClr()
        messageLbl.customize { detector in
            let customPattern = try! NSRegularExpression(pattern: "\\b(?:[a-z0-9-]+\\.)+[a-z]{2,}\\b", options: .caseInsensitive)
            detector.configureLinkAttribute = { (_, attributes, _) in
                var attr = attributes
                attr[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
                return attr
            }
        }
        let customType = ActiveType.custom(pattern: "\\b(?:[a-z0-9-]+\\.)+[a-z]{2,}\\b")
        messageLbl.enabledTypes = [.url, customType]
        messageLbl.customColor[customType] = .MiiTV_ThemeClr()
        messageLbl.handleCustomTap(for: customType) { url in
            self.urlDelegate?.openLink(url: url)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "ReceivedMsgTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func updateCellUI() {
        if shouldShowProfilePicture {
            messageView.layer.cornerRadius = 16
            messageView.layer.masksToBounds = false
            messageView.layer.maskedCorners = [ .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            profileImgview.isHidden = false
            msgViewTopConstraint.constant = 20.25
            profilePictureTopConstraint.constant = 10
            if shouldShowUsername {
                usernameLbl.isHidden = false
                msgLblTopConstraint.constant = 30
                
            } else {
                msgLblTopConstraint.constant = 12
                usernameLbl.isHidden = true
                
            }
           
            if shouldShowDayLbl && shouldShowUnreadLbl {
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                unreadLbl.isHidden = false
                unreadLbl.text = "Unread Messages"
                unreadLbl.layer.cornerRadius = 9
                unreadLbl.layer.masksToBounds = true
                msgViewTopConstraint.constant = 22.25
                profilePictureTopConstraint.constant = 40
            } else if shouldShowDayLbl && !shouldShowUnreadLbl {
                unreadLbl.isHidden = true
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                msgViewTopConstraint.constant = 22.25
                profilePictureTopConstraint.constant = 20
            } else if !shouldShowDayLbl && shouldShowUnreadLbl {
                unreadLbl.isHidden = false
                unreadLbl.text = "Unread Messages"
                unreadLbl.layer.cornerRadius = 9
                unreadLbl.layer.masksToBounds = true
                msgViewTopConstraint.constant = 22.25
                newDayLbl.isHidden = true
                newDayLbl.text = ""
                profilePictureTopConstraint.constant = 20
            } else {
                unreadLbl.isHidden = true
                newDayLbl.isHidden = true
                newDayLbl.text = ""
            }
            
        } else {
            messageView.layer.cornerRadius = 16
            messageView.layer.masksToBounds = false
            messageView.layer.maskedCorners = [ .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
            profileImgview.isHidden = true
            msgViewTopConstraint.constant = 0
            profilePictureTopConstraint.constant = 10
            msgLblTopConstraint.constant = 12
            usernameLbl.isHidden = true
//            messageViewMinWidth.constant = 110
            if shouldShowDayLbl && shouldShowUnreadLbl {
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                unreadLbl.isHidden = false
                unreadLbl.text = "Unread Messages"
                unreadLbl.layer.cornerRadius = 9
                unreadLbl.layer.masksToBounds = true
                msgViewTopConstraint.constant = 25.25
            } else if shouldShowDayLbl && !shouldShowUnreadLbl {
                unreadLbl.isHidden = true
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                msgViewTopConstraint.constant = 12
            } else if !shouldShowDayLbl && shouldShowUnreadLbl {
                unreadLbl.isHidden = false
                unreadLbl.text = "Unread Messages"
                unreadLbl.layer.cornerRadius = 9
                unreadLbl.layer.masksToBounds = true
                msgViewTopConstraint.constant = 16
                newDayLbl.isHidden = true
                newDayLbl.text = ""
            } else {
                unreadLbl.isHidden = true
                newDayLbl.isHidden = true
                newDayLbl.text = ""
            }
        }
        
        if shouldShowUsername {
            messageViewMinWidth.constant = max(usernameLbl.frame.width + 25, 110)
        } else {
            messageViewMinWidth.constant = 110
        }
        
        messageLbl.handleURLTap { url in
            self.urlDelegate?.openLink(url: url.absoluteString)
        }
    }
}
