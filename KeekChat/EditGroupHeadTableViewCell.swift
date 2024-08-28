//
//  EditGroupHeadTableViewCell.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 01/08/22.
//  Copyright © 2022 Riavera. All rights reserved.
//

import UIKit

protocol EditGroupHeadTableViewCellDelegate: class {
    func addMembers()
    func groupNameChanged(groupName: String)
    func changeGroupIcon()
}

class EditGroupHeadTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var membersLblTopConstraint: NSLayoutConstraint!
    @IBOutlet var dashedView: RectangularDashedView!
    @IBOutlet var addMembersBtn: MyButton!
    @IBOutlet var memberCountLbl: UILabel!
    @IBOutlet var groupNameTextfield: MyTextField!
    @IBOutlet var groupImageview: MyImageView!
    static let reuseIdentifier = "editGroupHeadTableViewCell"
    var cellDelegate: EditGroupHeadTableViewCellDelegate?
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var membersLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: groupNameTextfield.frame.height + 8, width: groupNameTextfield.frame.width - 28, height: 0.5)
        bottomLine.backgroundColor = #colorLiteral(red: 0.8077717423, green: 0.8078888059, blue: 0.8077461123, alpha: 1)
        groupNameTextfield.borderStyle = UITextField.BorderStyle.none
        groupNameTextfield.layer.addSublayer(bottomLine)
        groupNameTextfield.delegate = self

        setUpThem(groupName: titleLbl, txtGroupName: groupNameTextfield, members: membersLbl, addMember: addMembersBtn, memberCount: memberCountLbl, groupImg: groupImageview)
        titleLbl.text = NSLocalizedString("group_name", comment: "")
        
        addMembersBtn.setTitle(NSLocalizedString("add_members", comment: ""), for: UIControl.State())
        
        groupNameTextfield.placeholder = NSLocalizedString("my_group_name", comment: "")
        
        membersLbl.text = "members".localized
        groupNameTextfield.inputAccessoryView = createDoneToolbar()
    }
    
    func setUpThem(groupName:UILabel,txtGroupName:UITextField, members:UILabel,addMember:UIButton,memberCount:UILabel,groupImg:MyImageView){
        let groupNameStyle = ChatStyle.shared.groupName
        groupName.setStyle(style: groupNameStyle)
        
        let txtGroupNameStyle = ChatStyle.shared.txtGroupName
        txtGroupName.placeholder = txtGroupNameStyle.text
        txtGroupName.textColor = txtGroupNameStyle.textColor
        txtGroupName.font = txtGroupNameStyle.font
        
        let membersStyle = ChatStyle.shared.member
        members.setStyle(style: membersStyle)
        
        let addMembersStyle = ChatStyle.shared.btnAddMember
        addMember.setStyle(style: addMembersStyle)
        
        let memberCountStyle = ChatStyle.shared.memberCount
        memberCount.setStyle(style: memberCountStyle)
        
        let groupImageStyle = ChatStyle.shared.groupImage
        groupImg.image = groupImageStyle.profile
        groupImg.layer.cornerRadius = groupImageview.cornerRadius
        groupImg.layer.borderWidth = CGFloat(groupImageStyle.borderWidth)
        groupImg.layer.borderColor = groupImageStyle.borderColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static func registerNib(_ tableView: UITableView) {
        let textNib = UINib(nibName: "EditGroupHeadTableViewCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    @IBAction func addMembersAction(_ sender: Any) {
        cellDelegate?.addMembers()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        cellDelegate?.groupNameChanged(groupName: groupNameTextfield.text!)
    }
    
    @IBAction func changeGroupIcon(_ sender: Any) {
        cellDelegate?.changeGroupIcon()
    }

    
    func createDoneToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        toolbar.items = [flexSpace, doneButton]
        
        return toolbar
    }
    
    @objc func doneButtonTapped() {
        self.groupNameTextfield.resignFirstResponder()
    }
    
}
