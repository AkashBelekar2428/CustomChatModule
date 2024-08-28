//
//  GroupMemberTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 01/08/22.
//  Copyright © 2022 Riavera. All rights reserved.
//

import UIKit

protocol SearchUserDelegate: AnyObject {
    func updateFollowUser(indexPath: Int)
}

class GroupMemberTableViewCell: UITableViewCell {

    static let reuseIdentifier = "groupMemberTableViewCell"
    @IBOutlet var adminLbl: MyLabel!
    @IBOutlet var profileImageview: MyImageView!
    @IBOutlet var removeMemberBtn: UIButton!
    @IBOutlet var usernameLbl: UILabel!
    var indexPath: Int = -1
    var delegate: SearchUserDelegate?
    
    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "GroupMemberTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        adminLbl.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeBtnAction(_ sender: Any) {
        self.delegate?.updateFollowUser(indexPath: indexPath)
    }
    
}
