//
//  InfoTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 25/10/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet var lblWidth: NSLayoutConstraint!
    @IBOutlet var infoLbl: MyLabel!
    static let reuseIdentifier = "infoTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        infoLbl.text = ""
        
        infoLbl.layer.masksToBounds = true
        lblWidth.constant = UIScreen.main.bounds.width - 50
//        infoLbl.layer.cornerRadius = infoLbl.layer.frame.height / 2
    }
    
    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "InfoTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
