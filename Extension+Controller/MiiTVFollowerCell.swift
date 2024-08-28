//
//  MiiTVFollowerCell.swift
//  Peeks
//
//  Created by Nishu Sharma on 26/04/22.
//  Copyright © 2022 Riavera. All rights reserved.
//

import UIKit

protocol MiiTVSelectMoreActionProtocol {
    func PassSelectedIndex(index : Int)
}

class MiiTVFollowerCell: UITableViewCell {
    
    //MARK: IBAction
    @IBAction func actionMore(_ sender : Any) {
        delegate?.PassSelectedIndex(index: self.tag)
    }
    
    //MARK: IBOutlet
    @IBOutlet weak var lblFollowerName : UILabel!
    @IBOutlet weak var lblFollowerCount : UILabel!
    @IBOutlet weak var btnMore : UIButton!
    @IBOutlet weak var imgViewUser : UIImageView!
    
    @IBOutlet var nameLblTopConstraint: NSLayoutConstraint!
    @IBOutlet var btnHeightConstraint: NSLayoutConstraint!
    @IBOutlet var btnWidthConstraint: NSLayoutConstraint!
    //MARK: Variables
    var delegate : MiiTVSelectMoreActionProtocol?
    static let identifier = "MiiTVFollowerCell"
    
    var lblFolloName = ""
    var lblFolloCount = ""

    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "MiiTVFollowerCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: identifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupTheme()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        lblFollowerName.text = lblFolloName
        lblFollowerCount.text = lblFolloCount
    }
    
    
    //MARK: Methods
    
    func setupTheme() {
        selectionStyle = .none
        self.backgroundColor = .clear
        setUpThems(followerName: lblFollowerName, followerCount: lblFollowerCount, btnMore: btnMore, img: imgViewUser)
        self.lblFollowerName.font = .Roboto14_Bold()
        self.lblFollowerName.textColor = .MiiTV_Black()
        self.lblFollowerName.textAlignment = .left
        
        let tempColor = UIColor.init(hexString: "222B45")?.withAlphaComponent(0.42)
        self.lblFollowerCount.font = .Roboto14_Reg()
        self.lblFollowerCount.textAlignment = .left
        self.lblFollowerCount.textColor = tempColor
        
        AddThemeToButton(btn: btnMore, titles: IconFontManager.icon_3Dots, color: tempColor!, size: 22.0)
        
        self.imgViewUser.addBorder(width: 2.0, color: .MiiTV_DarkPinkClr())
        self.imgViewUser.contentMode = .scaleAspectFill
        self.imgViewUser.setCornerRadius(radius: imgViewUser.frame.size.width / 2)
    }
    
    func setUpThems(followerName:UILabel, followerCount:UILabel,btnMore:UIButton,img:UIImageView){
        let followerNameStyle = ChatStyle.shared.followersName
        followerName.setStyle(style: followerNameStyle)
        
        let followerCountStyle = ChatStyle.shared.followerCount
        followerName.setStyle(style: followerCountStyle)
        
        let followerImgStyle = ChatStyle.shared.followerProfile
        img.image = followerImgStyle.profile
        img.layer.cornerRadius = CGFloat(followerImgStyle.cornerRadius)
        img.layer.borderWidth = CGFloat(followerImgStyle.borderWidth)
        img.layer.borderColor = followerImgStyle.borderColor
        
        let btnMoreStyle = ChatStyle.shared.btnMore
        btnMore.setStyle(style: btnMoreStyle)
    }
    
    func update(_ user: User) {
        lblFolloName = "@" + user.username
        self.nameLblTopConstraint.constant = -2
        let followStr = user.followersNumber == 1 ? "Follower".localized : "Followers".localized
        lblFolloCount = "\(user.followersNumber.abbreviatedFormat()) \(followStr)"
        lblFollowerCount.isHidden = false
        if user.id == ChatModel.sharedInstance.userId {
            self.btnMore.isHidden = true
        } else {
            self.btnMore.isHidden = false
        }
        self.imgViewUser.image = UIImage(named: "profile")
        if user.avatarUrl != nil {
            self.imgViewUser.sd_setImage(with: user.getAvatarImageURL(), completed: { (image, error, _ cacheType, _ imageUrl) in
                if error != nil {
                    self.imgViewUser.image = UIImage(named: "profile")
                }
            })
        } else {
            self.imgViewUser.image = UIImage(named: "profile")
        }

    }
    
    func updateGroup(_ group: ThreadInfo) {
        lblFolloName = "@" + group.userName
        lblFollowerCount.isHidden = true
        self.imgViewUser.image = UIImage(named: "groupProfile")
        self.btnMore.isHidden = false
        self.nameLblTopConstraint.constant = 11
        if group.userAvatarUrl != nil {
            self.imgViewUser.sd_setImage(with: URL(string: group.userAvatarUrl), completed: { (image, error, _ cacheType, _ imageUrl) in
                if error != nil {
                    self.imgViewUser.image = UIImage(named: "groupProfile")
                }
            })
        } else {
            self.imgViewUser.image = UIImage(named: "groupProfile")
        }
    }
}
