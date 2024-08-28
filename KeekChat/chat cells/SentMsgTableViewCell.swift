//
//  SentMsgTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 02/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit
import ActiveLabel

class SentMsgTableViewCell: UITableViewCell {

    @IBOutlet var newDayLbl: UILabel!
    @IBOutlet var messageMaxWidth: NSLayoutConstraint!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var profileImgview: MyImageView!
    @IBOutlet var messageView: UIView!
    static let reuseIdentifier = "sentMsgTableViewCell"
    @IBOutlet var msgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var selectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var profileImgTopConstraint: NSLayoutConstraint!
    @IBOutlet var messageLbl: ActiveLabel!
    @IBOutlet var selectionBlurView: UIView!
    @IBOutlet var backgroundSelectionView: UIView!
    @IBOutlet var readStatusLbl: UILabel!
    var shouldShowProfilePicture = true
    var showDateLbl = false
    var date = ""
    var urlDelegate: URLNavigationDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageView.layer.cornerRadius = 16
        messageView.layer.masksToBounds = false
        messageView.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        messageMaxWidth.constant = UIScreen.main.bounds.width - 100
        newDayLbl.isHidden = true
        selectionBlurView.isHidden = true
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
        let textNib = UINib(nibName: "SentMsgTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func updateCellUI() {
        messageView.layer.cornerRadius = 16
        messageView.layer.masksToBounds = false
        if shouldShowProfilePicture {
            messageView.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            profileImgview.isHidden = false
            msgViewTopConstraint.constant = 20.25
            
            if showDateLbl {
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                selectionViewTopConstraint.constant = -2
                profileImgTopConstraint.constant = 22
            } else {
                newDayLbl.isHidden = true
                newDayLbl.text = ""
                selectionViewTopConstraint.constant = -4
                profileImgTopConstraint.constant = 2
            }
        } else {
            messageView.layer.maskedCorners = [ .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
            profileImgview.isHidden = true
            msgViewTopConstraint.constant = 0
            profileImgTopConstraint.constant = 12
            if showDateLbl {
                newDayLbl.isHidden = false
                newDayLbl.text = date
                newDayLbl.textColor = .MiiTV_BlackClr()
                msgViewTopConstraint.constant = 14.25
                selectionViewTopConstraint.constant = 10
            } else {
                newDayLbl.isHidden = true
                newDayLbl.text = ""
                selectionViewTopConstraint.constant = -4
            }
        }
        messageLbl.handleURLTap { url in
            self.urlDelegate?.openLink(url: url.absoluteString)
        }
    }
}
