//
//  GroupImgRecvdTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 08/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit

protocol GroupImgRecvdTableViewCellDelegate: class {
    func viewGroupReceivedImage()
}

class GroupImgRecvdTableViewCell: UITableViewCell {

    static let reuseIdentifier = "groupImgRecvdTableViewCell"
    var delegate: GroupImgRecvdTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "GroupImgRecvdTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    @IBAction func goToImage(_ sender: Any) {
        self.delegate?.viewGroupReceivedImage()
    }
}
