//
//  MainChatTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 20/07/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit

class MainChatTableViewCell: UITableViewCell {
    static let reuseIdentifier = "mainChatTableViewCell"
    
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var profileImgview: MyImageView!
    
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var messageLbl: UILabel!
    
    @IBOutlet var messageCountView: MyView!
    @IBOutlet var messageCountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageLbl.text = ""
        setUpThem(userProfile: profileImgview, userName: usernameLbl, userMessage: messageLbl, usermessageTime: timeLbl, messageCount: messageCountLbl, countView: messageCountView)
    }

    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "MainChatTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    public func setUpThem(userProfile:MyImageView,userName:UILabel, userMessage:UILabel, usermessageTime:UILabel,messageCount:UILabel,countView:UIView){
        
        let profileStyle = ChatStyle.shared.userProfile
        userProfile.image = profileStyle.profile
        userProfile.setCornerRadius(radius: userProfile.cornerRadius)
        userProfile.addBorder(width: CGFloat(profileStyle.borderWidth ), color: profileStyle.textColor)
        
        let usernameStyle = ChatStyle.shared.userName
        userName.setStyle(style: usernameStyle)
        
        let userMessageStyle = ChatStyle.shared.userMessage
        userMessage.setStyle(style: userMessageStyle)
        
        let userMessageTimeStyle = ChatStyle.shared.messageTime
        usermessageTime.setStyle(style: userMessageTimeStyle)
        
        let userMessageCountStyle = ChatStyle.shared.messageCount
        messageCount.setStyle(style: userMessageCountStyle)
        
        let messageCountViewStyle = ChatStyle.shared.messageView
        countView.layer.cornerRadius = CGFloat(userMessageCountStyle.cornerRadius)
        countView.layer.borderColor = userMessageCountStyle.borderColor
        countView.layer.borderWidth = CGFloat(userMessageCountStyle.borderWidth)
    }
}
