//
//  CreateChatGroupViewController.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 30/10/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit

protocol CreateGrpForChatControllerDelegate: AnyObject {
    func groupCreated(groupId: String, groupName: String, groupChatId: String, groupDpUrl: String)
}

protocol EditGrpForChatDelegate: AnyObject {
    func backFromGroupDetails()
}

class CreateChatGroupViewController: UIViewController, HTTPRequesterDelegate {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var subtitleLbl: UILabel!
    var lineView: UIView?
    var groupMembers: [KeekChatUser] = []
    var groupName: String = ""
    @IBOutlet var createTableView: UITableView!
    @IBOutlet var backAction: UIButton!
    var groupIcon: UIImage?
    var clubID: Int64? = 0
    var groupImgUrl: String? = ""
    var isEditGrp = false
    var groupIconChanged = false
    var fromNoGroups = false
    var createTitle = "createGroup".localized
    var chatCreateGrpDelegate: CreateGrpForChatControllerDelegate?
    var delegate: EditGrpForChatDelegate?
    let avatarUpdateView = GroupAvatarUpdateView()
    @IBOutlet var saveBtn: MyButton!
    var orientations = UIInterfaceOrientationMask.portrait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return self.orientations }
        set { self.orientations = newValue }
    }
    var groupInfo: ThreadInfo?
    var isGroupAdmin = true
    var mediaData: MediaMessage?
    var adminExtUserId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        if !self.isEditGrp {
           setUpThemForCreateGroup(createGroup: subtitleLbl)
        } else {
            if isGroupAdmin {
                subtitleLbl.text = "editGroup".localized
                self.lineView?.isHidden = false
            } else {
                subtitleLbl.text = self.groupInfo?.userName
                self.lineView?.isHidden = true
            }
            self.groupImgUrl = self.groupInfo?.userAvatarUrl ?? ""
        }
        self.sortGroupMembers()
        self.configureTable()
        setUpThemForSaveBtn(saveBtn: saveBtn)
       // saveBtn.setTitle(NSLocalizedString("finish_n_save", comment: ""), for: UIControl.State())
        
      setUpThemForGroup(group: titleLbl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addLineView()
        if isEditGrp {
            if !self.isGroupAdmin {
                self.saveBtn.isHidden = true
            }
        }
    }
    
    func setUpThemForGroup(group:UILabel){
        let groupStyle = ChatStyle.shared.group
        group.setStyle(style: groupStyle)
    }
    
    func setUpThemForCreateGroup(createGroup:UILabel){
        let createGroupStyle = ChatStyle.shared.createGroup
        createGroup.setStyle(style: createGroupStyle)
    }
    
    func setUpThemForSaveBtn(saveBtn:UIButton){
        let saveBtnStyle = ChatStyle.shared.finishAndSaveBtn
        saveBtn.setStyle(style: saveBtnStyle)
        
    }
    
    func configureTable() {
        EditGroupHeadTableViewCell.registerNib(createTableView)
        GroupMemberTableViewCell.registerNib(createTableView)
        createTableView.delegate = self
        createTableView.dataSource = self
    }
    
    func addLineView() {
        self.lineView = UIView(frame: CGRect(x: self.subtitleLbl.frame.minX + 6, y: self.subtitleLbl.frame.minY + self.subtitleLbl.frame.height, width: 25, height: 4))
        self.lineView!.backgroundColor =  #colorLiteral(red: 1, green: 0, blue: 0.3617234826, alpha: 1)
        lineView?.setCornerRadius(radius: 2)
        self.view.addSubview(self.lineView!)
        self.view.bringSubviewToFront(self.lineView!)
        self.lineView?.layoutIfNeeded()
    }
    
    @IBAction func backAction(_ sender: Any) {
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false) {
            if self.isEditGrp {
                self.delegate?.backFromGroupDetails()
            }
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.groupName = self.groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        if self.groupName == "" {
            UIUtil.showAlert("alert".localized, message: "pleaseEnterGroupName".localized, vc: self)
        } else if self.groupMembers.count == 0 {
            UIUtil.showAlert("alert".localized, message: "addGroupMembers".localized, vc: self)
        } else {
            if groupIconChanged {
                self.uploadGroupIcon()
            } else {
                if !isEditGrp {
                    UIUtil.indicateActivityForView(self.view, labelText: "creatingGroup".localized)
                    self.createChatGroup()
                } else {
                    UIUtil.indicateActivityForView(self.view, labelText: "Updating Group".localized)
                    self.editChatGroup()
                }
            }
        }
    }
    
    func createChatGroup(groupDpUrl: String = "") {
        var audience: [String] = []
        for obj in self.groupMembers {
            audience.append(obj.externalUserId)
        }
        ChatConnector().createGroupChat(self.groupName, groupDpUrl, audience) { success, error, groupId, groupName, groupChatId, groupDpUrl in
            if success {
                DispatchQueue.main.async {
                    UIUtil.removeActivityViewFromView(self.view)
                    self.dismiss(animated: false) {
                        self.chatCreateGrpDelegate!.groupCreated(groupId: groupId!, groupName: groupName!, groupChatId: groupChatId!, groupDpUrl: groupDpUrl!)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    UIUtil.removeActivityViewFromView(self.view)
                    UIUtil.apiFailure("Could not create the group at the moment", vc: self)
                }
            }
        }
    }
    
    func editChatGroup(groupDpUrl: String = "") {
        if self.isGroupAdmin {
            var removedGrpMembers: [KeekChatUser] = []
            for member in groupInfo!.members {
                if !self.groupMembers.contains(where: { $0.externalUserId == member.externalUserId }) {
                    removedGrpMembers.append(member)
                }
            }
            var removedAudience: [String] = []
            for obj in removedGrpMembers {
                removedAudience.append(obj.id)
            }
            
            var addedGrpMembers: [KeekChatUser] = []
            for member in groupMembers {
                if !self.groupInfo!.members.contains(where: { $0.externalUserId == member.externalUserId }) {
                    addedGrpMembers.append(member)
                }
            }
            var addedAudience: [String] = []
            for obj in addedGrpMembers {
                addedAudience.append(obj.externalUserId)
            }
            var grpUrl = groupDpUrl
            if groupDpUrl == "" {
                grpUrl = self.groupInfo?.userAvatarUrl ?? ""
            }
            ChatConnector().editChatGroup(self.groupInfo?.groupId ?? "", self.groupName, grpUrl, addedAudience, removedAudience) { success, error in
                if success {
                    DispatchQueue.main.async {
                        UIUtil.removeActivityViewFromView(self.view)
                        self.dismiss(animated: false) {
                            self.delegate?.backFromGroupDetails()
                        }
                    }
                } else {
                    print(error)
                    print("Could not update group")
                    DispatchQueue.main.async {
                        UIUtil.removeActivityViewFromView(self.view)
                        UIUtil.apiFailure("Could not update the group at the moment", vc: self)
                    }
                }
            }
        }
    }
    
    func uploadGroupIcon() {
        if let icon = groupIcon {
            print("selected image to upload")
            if self.isEditGrp {
                UIUtil.indicateActivityForView(self.view, labelText: "Updating Group".localized)
            } else {
                UIUtil.indicateActivityForView(self.view, labelText: "creatingGroup".localized)
            }
            
            GroupConnector().uploadGroupProfileImage("chat-group", image: icon, delegate: self) {
                success, error, media in
                if success {
                    DispatchQueue.main.async { [self] in
                        self.mediaData = media
                        if self.isEditGrp {
                            self.editChatGroup(groupDpUrl: mediaData?.imageUrl ?? "")
                        } else {
                            self.createChatGroup(groupDpUrl: mediaData?.imageUrl ?? "")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        if self.isEditGrp {
                            UIUtil.apiFailure("Could not update the group at the moment", vc: self)
                        } else {
                            UIUtil.apiFailure("Could not create the group at the moment", vc: self)
                        }
                    }
                }
            }
        } else {
            print("no image to upload")
        }
    }
}

extension CreateChatGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.groupMembers.count != 0 {
            return self.groupMembers.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: EditGroupHeadTableViewCell.reuseIdentifier,
                                                     for: indexPath)
            as? EditGroupHeadTableViewCell ?? EditGroupHeadTableViewCell()
            cell.memberCountLbl.text = "\(self.groupMembers.count)"
            cell.groupNameTextfield.text = self.groupName
            cell.cellDelegate = self
            if !isEditGrp {
                if let image = self.groupIcon {
                    cell.groupImageview.image = image
                    cell.groupImageview.bordercolor = #colorLiteral(red: 0.7703962326, green: 0.8077660203, blue: 0.8770630956, alpha: 1)
                } else {
                    cell.groupImageview.image = UIImage(named: "group_camera")
                    cell.groupImageview.bordercolor = #colorLiteral(red: 0.7703962326, green: 0.8077660203, blue: 0.8770630956, alpha: 1)
                }
            } else {
                if let image = self.groupIcon {
                    cell.groupImageview.image = image
                    cell.groupImageview.bordercolor = #colorLiteral(red: 0.7703962326, green: 0.8077660203, blue: 0.8770630956, alpha: 1)
                } else if groupImgUrl != "" {
                    cell.groupImageview.bordercolor = #colorLiteral(red: 0.7703962326, green: 0.8077660203, blue: 0.8770630956, alpha: 1)
                    cell.groupImageview.sd_setImage(with: NSURL(string: groupImgUrl!) as URL?, completed: { (img, error, type, urls) in
                        if error != nil {
                            cell.groupImageview.image = UIImage(named: "group_camera")
                            cell.groupImageview.bordercolor = #colorLiteral(red: 0.7703962326, green: 0.8077660203, blue: 0.8770630956, alpha: 1)
                        }
                    })
                    
                } else {
                    cell.groupImageview.image = UIImage(named: "group_camera")
                    cell.groupImageview.bordercolor = #colorLiteral(red: 0.7703962326, green: 0.8077660203, blue: 0.8770630956, alpha: 1)
                }
              
            }
            
            if self.isGroupAdmin {
                cell.groupNameTextfield.isUserInteractionEnabled = true
                cell.addMembersBtn.isHidden = false
                cell.dashedView.isHidden = false
                cell.membersLblTopConstraint.constant = 105
            } else {
                cell.groupNameTextfield.isUserInteractionEnabled = false
                cell.addMembersBtn.isHidden = true
                cell.dashedView.isHidden = true
                cell.membersLblTopConstraint.constant = 16
            }
            if isEditGrp {
                if self.isGroupAdmin {
                    cell.groupNameTextfield.isHidden = false
                    cell.titleLbl.isHidden = false
                    cell.membersLblTopConstraint.constant = 105
                } else {
                    cell.groupNameTextfield.isHidden = true
                    cell.titleLbl.isHidden = true
                    cell.membersLblTopConstraint.constant = -50
                }
            }
            cell.groupNameTextfield.placeholder = NSLocalizedString("enterGrpName", comment: "")
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupMemberTableViewCell.reuseIdentifier,
                                                     for: indexPath)
            as? GroupMemberTableViewCell ?? GroupMemberTableViewCell()
            cell.contentView.backgroundColor = UIColor.white
            let obj = self.groupMembers[indexPath.row-1]
            
            if obj.externalUserId == self.adminExtUserId {
                cell.adminLbl.isHidden = false
                cell.adminLbl.text = "Admin"
            } else {
                cell.adminLbl.isHidden = true
            }
            if obj.externalUserId == ChatModel.sharedInstance.userId {
                cell.usernameLbl.text = "You"
            } else {
                cell.usernameLbl.text = "@\(obj.userName)"
            }
            let url = obj.dpUrl
            cell.profileImageview.sd_setImage(with: NSURL(string: url) as URL?, completed: { (img, error, type, urls) in
                if error != nil {
                    cell.profileImageview.image = UIImage(named: "groupProfile")
                }
            })
            if obj.externalUserId == ChatModel.sharedInstance.userId || !self.isGroupAdmin {
                cell.removeMemberBtn.isHidden = true
            } else {
                cell.removeMemberBtn.isHidden = false
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            if isEditGrp {
                if isGroupAdmin {
                    let obj = self.groupMembers[indexPath.row-1]
                    if obj.externalUserId != ChatModel.sharedInstance.userId {
                        if self.groupMembers.count < 2 {
                            UIUtil.showAlert("Error", message: "The group needs atleast one member", vc: self)
                        } else {
                            //                            self.removedGrpMembers.append(self.groupMembers[indexPath.row-1])
                            self.groupMembers.remove(at: indexPath.row-1)
                            self.createTableView.reloadData()
                        }
                    }
                }
            } else {
                self.groupMembers.remove(at: indexPath.row-1)
                self.createTableView.reloadData()
            }
        }
    }
}

extension CreateChatGroupViewController: EditGroupHeadTableViewCellDelegate, MiitvPrivateAudienceDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AvatarUpdateDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                
                self.groupIcon = image
                self.groupIconChanged = true
                self.createTableView.reloadData()
//                if self.isEditGrp {
//                    self.uploadGroupIcon()
//                }
            })
        }
    }
    
    func didUpdateAvatar(_ image: UIImage, avatarUrl: String) {
        self.groupIcon = image
        self.groupIconChanged = true
        self.createTableView.reloadData()
//        if self.isEditGrp {
//            self.uploadGroupIcon()
//        }
    }
    
    func changeGroupIcon() {
        if self.isEditGrp && !self.isGroupAdmin {
            return
        }
            if let vc = UIApplication.topViewController() {
                avatarUpdateView.delegate = self
                avatarUpdateView.show(vc)
            }
        
    }
    
    func groupNameChanged(groupName: String) {
        self.groupName = groupName
    }
    
    func addMembers() {
        let vc = ContactsViewController()
        vc.delegate = self
        vc.fromScreen = .groupChat
        var users: [User] = []
        users = User.parseKeekChatUser(self.groupMembers)
        vc.streamSelectedFollowers = users
        vc.modalPresentationStyle = .fullScreen
        let parentVC = self.presentingViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(vc, animated: false, completion: nil)
    }
    
    func audienceSelected(streamSelectedFollowers: [User], allFollowers: Bool) {
        var keekChatUsers: [KeekChatUser] = []
        keekChatUsers = KeekChatUser.parseNativeUsers(streamSelectedFollowers)
        
        if isEditGrp {
            if groupMembers.count == 0 {
                UIUtil.showAlert("Error", message: "The group needs atleast one member", vc: self)
            } else {
                self.groupMembers = keekChatUsers
                self.sortGroupMembers()
                self.createTableView.reloadData()
            }
        } else {
            self.groupMembers = keekChatUsers
            self.sortGroupMembers()
            self.createTableView.reloadData()
        }
    }
    
    func audienceNotSelected() {
        
    }
    
    func groupMembersSelected(selectedMembers: [String]) {
        
    }
    
    func sortGroupMembers() {
        var tempMembers: [KeekChatUser] = []
        
        for (index, member) in self.groupMembers.enumerated() {
            if member.externalUserId == ChatModel.sharedInstance.userId {
                tempMembers.append(member)
                self.groupMembers.remove(at: index)
                break
            }
        }
        
        for (index, member) in self.groupMembers.enumerated() {
            if member.externalUserId == self.adminExtUserId {
                tempMembers.append(member)
                self.groupMembers.remove(at: index)
                break
            }
        }
        
        self.groupMembers.sort { $0.userName < $1.userName }
        
        for member in self.groupMembers {
            tempMembers.append(member)
        }
        
        self.groupMembers = []
        for member in tempMembers {
            self.groupMembers.append(member)
        }
        
    }
}
