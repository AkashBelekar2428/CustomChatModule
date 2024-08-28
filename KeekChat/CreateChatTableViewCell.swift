//
//  CreateChatTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 20/07/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit

protocol StartConversationDelegate: class {
    func createNewChat()
}

class CreateChatTableViewCell: UITableViewCell {

    static let reuseIdentifier = "createChatTableViewCell"
    var delegate: StartConversationDelegate?
    @IBOutlet var startBtn: MyButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "CreateChatTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    @IBAction func startConversationAction(_ sender: Any) {
        self.delegate?.createNewChat()
    }
    
}
