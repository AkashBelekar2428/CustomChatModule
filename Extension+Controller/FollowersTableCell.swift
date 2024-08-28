
//  FollowersTableCell.swift
//  Peeks
//
//  Created by Sara Al-Kindy on 2015-12-31.
//  Copyright © 2015 Miiscan Corp. All rights reserved.
//

import UIKit
import MGSwipeTableCell

protocol FollowersCellDelegate {
    func userAllowNotification(_ user: User?, notification: Bool)
    func chatButtonPressed(user: User)
}

class FollowersTableCell: MGSwipeTableCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var onlineOfflineIndicator: UIView!
    @IBOutlet weak var notificationIcon: UIImageView!
    @IBOutlet weak var chatButton: MyButton!
    
    var user: User?
    var followersCelldelegate: FollowersCellDelegate?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FollowersTableCell.notificationButtonTapped))
        tapGesture.delegate = self
        if self.notificationIcon != nil {
            self.notificationIcon.addGestureRecognizer(tapGesture)
            self.notificationIcon.isUserInteractionEnabled = true
        }
        
        chatButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.selectionStyle = .none
        chatButton.isHidden = !ChatModel.sharedInstance.userPermissions.canCreateChat
    }
    
    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "FollowersTableCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: "userCell")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonChatPressed(_ sender: MyButton) {
        
        if let user = user {
            followersCelldelegate?.chatButtonPressed(user: user)
        } 
    }
    
    func update(_ user: User) {
        usernameLabel.text = user.username
        self.user = user
        
        let location = user.getLocationDescription()
        locationLabel.text = location
        
        if location == "" {
            locationImageView.isHidden = true
        } else {
            locationImageView.isHidden = false
        }
        
        if user.liveId > 0 {
            // The user is Streaming
            onlineOfflineIndicator.isHidden = false
        } else {
            // The User is Not Streaming
            onlineOfflineIndicator.isHidden = true
        }

        if user.avatarUrl != nil {
            self.userImageView.sd_setImage(with: user.getAvatarImageURL(), completed: { (image, error, _ cacheType, _ imageUrl) in
                if error != nil {
                    self.userImageView.image = UIImage(named: "profile")
                }
            })
        } else {
            self.userImageView.image = UIImage(named: "profile")
        }

        //user.getProfileImageforImageView(userImageView)
        //isFollowingOn = user.isFollowed

        self.updateNotificationIcon(user.pushNotification)
    }
    
    @objc func notificationButtonTapped() {
        updateNotification()
    }
    
    func updateRecent(_ recent: Stream, isMyStream: Bool = false) {
        userImageView.contentMode = UIView.ContentMode.center
        
//        if isMyStream {
//            self.textLabel!.text = recent.title
//        } else {
//            usernameLabel.text      = recent.title
//            userImageView.image     = UIImage(named: "play")
//            userImageView.tintColor = UIColor.veryDarkGrayColor()
//        }
    }
    
    func updateNotificationIcon(_ notification: Bool) {
        if self.notificationIcon != nil {
            DispatchQueue.main.async {
                if notification {
                    self.notificationIcon.image = UIImage(named: "following_notify_on")
                } else {
                    self.notificationIcon.image = UIImage(named: "following_notify_off")
                }
            }
        }
    }
    
    func updateNotification() {
        
        if let user = user {
            
            var newNotif = true
            
            if user.pushNotification {
                newNotif = false
            }
            
//            UserActions.follow(user, pushNotifEnabled: newNotif, successBlock: {
//                user.pushNotification = newNotif
//                self.updateNotificationIcon(newNotif)
//                self.followersCelldelegate?.userAllowNotification(user, notification: newNotif)
//                }
//            )
        }
    }
}
