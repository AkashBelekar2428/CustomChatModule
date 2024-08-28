//
//  GroupSentMsgTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 04/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit

class GroupSentMsgTableViewCell: UITableViewCell {

    @IBOutlet var messageMaxWidth: NSLayoutConstraint!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var messageLbl: UILabel!
    @IBOutlet var profileImgview: MyImageView!
    @IBOutlet var messageView: UIView!
    static let reuseIdentifier = "groupSentMsgTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageView.layer.cornerRadius = 16
        messageView.layer.masksToBounds = false
        messageView.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        messageMaxWidth.constant = UIScreen.main.bounds.width - 100
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "GroupSentMsgTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }
}
