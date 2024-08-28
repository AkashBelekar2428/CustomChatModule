//
//  ChatStyle.swift
//  ChatModule
//
//  Created by Akash Belekar on 12/08/24.
//

import UIKit


struct UIStyle{
    var text:String
    var textColor:UIColor
    var font:UIFont
    var aligment:NSTextAlignment
    var numberOfLines:Int
    var backgroudColor:UIColor = .clear
    var profile:UIImage = UIImage(systemName: "homekit")!
    var borderColor:CGColor = CGColor(gray: 1, alpha: 1)
    var borderWidth:CGFloat = 1.0
    var cornerRadius:CGFloat = 5.0
}

func updateImageView(imageView: UIImageView){
    let size = min(imageView.bounds.width, imageView.bounds.height)
    imageView.layer.cornerRadius = size / 2
}

class ChatStyle{
    static let shared = ChatStyle()
    private init(){}
    
    //MARK: MainChatView
    var messageTitle:UIStyle = .init(text: "Messages", textColor: UIColor.black, font: .Roboto_Black_Size(size: 30), aligment: .left, numberOfLines: 0)
    
    var conversation:UIStyle = .init(text: "Conversation", textColor: .black, font: .Roboto18_Bold(), aligment: .left, numberOfLines: 0)
    var groups:UIStyle = .init(text: "Group", textColor: .black, font: .Roboto18_Bold(), aligment: .left, numberOfLines: 0)
    
    var addContactBtn:UIStyle = .init(text: "\(IconFontManager.icon_Plus)", textColor: .black, font: .MiitvIconFont(size: 20.0), aligment: .left, numberOfLines: 0)
    
    //MARK: ConversationView
    var userProfile:UIStyle = .init(text: "", textColor: .black, font: .Roboto12_Reg(), aligment: .left, numberOfLines: 0, profile: UIImage(systemName: "homekit")!, borderColor: .init(gray:1.0 , alpha: 1.0), borderWidth: 1.0, cornerRadius:10 )
    
    var userName:UIStyle = .init(text: "MF", textColor: .black, font: .Roboto14_Bold(), aligment: .left, numberOfLines: 0)
    
    var userMessage:UIStyle = .init(text: "hi MF", textColor: .gray, font: .Roboto14_Reg(), aligment: .left, numberOfLines: 0)
    
    var messageTime:UIStyle = .init(text: "01/01/2010", textColor: .black, font: .Roboto12_Reg(), aligment: .left, numberOfLines: 0)
    
    var messageCount:UIStyle = .init(text: "0", textColor: .black, font: .Roboto14_Bold(), aligment: .left, numberOfLines: 0)
    
    var messageView:UIStyle = .init(text: "", textColor: .black, font:.Roboto12_Reg(), aligment: .left, numberOfLines: 0, backgroudColor: .red, borderColor: CGColor(gray: 1.0, alpha: 1),borderWidth: 1.0, cornerRadius:5.0)
    
    //MARK: ContactViews Controller
    var searchView:UIStyle = .init(text: "", textColor: .clear, font: .Roboto12_Reg(), aligment: .left, numberOfLines: 0,borderColor: CGColor(gray: 1, alpha: 1.0), borderWidth: 1.0,cornerRadius: 5.0)
    
    var backBtn:UIStyle = .init(text: "\(IconFontManager.icon_left_arrow)", textColor: .black, font: .MiitvIconFont(size: 20.0), aligment: .left, numberOfLines: 0)
    
    var SearchBtn:UIStyle = .init(text: "\(IconFontManager.icon_search)", textColor: .black, font: .MiitvIconFont(size: 20.0), aligment: .left, numberOfLines: 0)
    
    var searchbarView:UIStyle = .init(text: "", textColor: .gray, font: .Roboto12_Reg(), aligment: .left, numberOfLines: 0,borderColor: CGColor(gray: 1, alpha: 1),borderWidth: 1.0, cornerRadius: 5.0)
    
    var txtSearch:UIStyle = .init(text: "Search Followers", textColor: .gray, font: .Roboto16_Reg(), aligment: .left, numberOfLines: 0)
    
    var recordNotFound:UIStyle = .init(text: "Not Found", textColor: .blue, font: .Roboto12_Reg(), aligment: .center, numberOfLines: 0)
    
    var selectAllBtn:UIStyle = .init(text: "", textColor: .blue, font: .Roboto12_Reg(), aligment: .center, numberOfLines: 0)
    
    var contact:UIStyle = .init(text: "Contact", textColor: .black, font: .Roboto22_Bold(), aligment: .left, numberOfLines: 0)
    
    var myContact:UIStyle = .init(text: "My Contact", textColor: .black, font: .Roboto18_Bold(), aligment: .left, numberOfLines: 0)
    
    var followersName:UIStyle = .init(text: "MF", textColor: .black, font: .Roboto14_Bold(), aligment: .left, numberOfLines: 0)
    
    var followerCount:UIStyle = .init(text: "MFF", textColor: .black, font: .Roboto18_Reg(), aligment: .left, numberOfLines: 0)
    
    var followerProfile:UIStyle = .init(text: "", textColor: .black, font: .Roboto18_Reg(), aligment: .left, numberOfLines: 0)
    
    var btnMore:UIStyle = .init(text: "", textColor: .black, font: .Roboto16_Reg(), aligment: .center, numberOfLines: 0)
    
    //MARK: CreateGroup
    var group:UIStyle = .init(text: "Groups", textColor: .black, font: .Roboto_Black_Size(size: 30), aligment: .left, numberOfLines: 0)
    
    var createGroup:UIStyle = .init(text: "Create Group", textColor: .black, font: .Roboto18_Bold(), aligment: .left, numberOfLines: 0)
    
    var groupName:UIStyle = .init(text: "Group Name", textColor: .black, font: .Roboto_Bold_Size(size: 17), aligment: .left, numberOfLines: 0)
    
    var txtGroupName:UIStyle = .init(text: "Enter Group Name", textColor: .gray, font: .Roboto16_Reg(), aligment: .left, numberOfLines: 0)
    
    var btnAddMember:UIStyle = .init(text: "Add Members", textColor: .black, font: .Roboto18_Reg(), aligment: .center, numberOfLines: 0)
    
    var member:UIStyle = .init(text: "Member", textColor: .black, font: .Roboto14_Bold(), aligment: .left, numberOfLines: 0)
    
    var memberCount:UIStyle = .init(text: "0", textColor: .red, font: .Roboto14_Bold(), aligment: .left, numberOfLines: 0)
    
    var groupImage:UIStyle = .init(text: "", textColor: .black, font: .Roboto12_Reg(), aligment: .left, numberOfLines: 0, borderColor:CGColor(gray: 1, alpha: 1), borderWidth: 1.0, cornerRadius: 5.0)
    
    var finishAndSaveBtn:UIStyle = .init(text: "Finish & Save", textColor: .white, font: .Roboto16_Bold(), aligment: .center, numberOfLines: 0,backgroudColor: .red)
    
}

extension UIView {
    func setStyle(style:UIStyle){
        if let lbl = self as? UILabel{
            lbl.text = style.text
            lbl.textColor = style.textColor
            lbl.font = style.font
            lbl.textAlignment = style.aligment
            lbl.numberOfLines = style.numberOfLines
            return
        }else
        if self as? UIButton != nil{
            if let btn = self as? UIButton{
                btn.setTitle(style.text, for: .normal)
                btn.setTitleColor(style.textColor, for: .normal)
                btn.titleLabel?.font = style.font
                btn.backgroundColor = style.backgroudColor
                return
            }
        }
    }
}
