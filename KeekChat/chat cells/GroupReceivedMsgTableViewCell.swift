//
//  GroupReceivedMsgTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 04/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit

class GroupReceivedMsgTableViewCell: UITableViewCell {

    @IBOutlet var messageViewWidth: NSLayoutConstraint!
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var messageLbl: UILabel!
    @IBOutlet var profileImgview: MyImageView!
    @IBOutlet var messageView: UIView!
    static let reuseIdentifier = "groupReceivedMsgTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageView.layer.cornerRadius = 16
        messageView.layer.masksToBounds = false
        messageView.layer.maskedCorners = [ .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        messageViewWidth.constant = UIScreen.main.bounds.width - 100
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "GroupReceivedMsgTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }
}
