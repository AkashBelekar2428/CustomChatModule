//
//  BunchProfilePicView.swift
//  MiiTV
//
//  Created by Yogesh Dalavi on 31/10/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import UIKit
// swiftlint:disable cyclomatic_complexity

protocol BunchProfilePicViewDelegate: class {
    func callViewTagsList(selectedUsers: [User])
}

@IBDesignable class BunchProfilePicView: UIView {
    
    // MARK: - Properties
    @IBOutlet var imgview2: MyImageView!
    @IBOutlet var imgview3: MyImageView!
    @IBOutlet var imgview1: MyImageView!
    @IBOutlet var imgview4: MyImageView!
    @IBOutlet var imgview5: MyImageView!
    @IBOutlet var imgview6: MyImageView!
    @IBOutlet var countLbl: UILabel!
    @IBOutlet var countView: MyView!
    @IBOutlet var btnTaggsClick: UIButton!
    @IBOutlet var imgHeightConstriant: NSLayoutConstraint!
    @IBOutlet var imgWidthConstriant: NSLayoutConstraint!
    @IBOutlet var imgLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var imgTopConstraint: NSLayoutConstraint!
    var delegate: BunchProfilePicViewDelegate!
    var selectedUsers: [User] = []
        
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        tagsMultiUserImageViewConfig(arrselectedUsers: [])
    }
    
    // MARK: - Private Helper Methods
    
    // Performs the initial setup.
    fileprivate func setupView() {
        let view = viewFromNibForClass()
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
    }
    
    // Loads a XIB file into a view and returns this view.
    fileprivate func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    @IBAction func callViewTagList() {
        guard self.delegate != nil else { return }
        if selectedUsers.count > 0 {
            self.delegate.callViewTagsList(selectedUsers: selectedUsers)
        }        
    }
    
    func tagsMultiUserImageViewConfig(arrselectedUsers: [User]) {
        selectedUsers = arrselectedUsers
        imgview1.isHidden = true
        imgview2.isHidden = true
        imgview3.isHidden = true
        imgview4.isHidden = true
        imgview5.isHidden = true
        imgview6.isHidden = true
        countView.isHidden = true
        imgview1.image = UIImage(named: "profile")
        imgview2.image = UIImage(named: "profile")
        imgview3.image = UIImage(named: "profile")
        imgview4.image = UIImage(named: "profile")
        imgview5.image = UIImage(named: "profile")
        imgview6.image = UIImage(named: "profile")
        
        if selectedUsers.count > 0 {
            imgview1.isHidden = false
            if let url = selectedUsers[0].avatarUrl {
                imgview1.sd_setImage(with: NSURL(string: url) as URL?, completed: { [self] (_, error, _, _) in
                    if error != nil {
                        imgview1.image = UIImage(named: "profile")
                    }
                })
            } else {
                imgview1.image = UIImage(named: "profile")
            }
        }
        
        if selectedUsers.count > 1 {
            imgview2.isHidden = false
            if let url = selectedUsers[1].avatarUrl {
                imgview2.sd_setImage(with: NSURL(string: url) as URL?, completed: { [self] (_, error, _, _) in
                    if error != nil {
                        imgview2.image = UIImage(named: "profile")
                    }
                })
            } else {
                imgview2.image = UIImage(named: "profile")
            }
        }
        
        if selectedUsers.count > 2 {
            imgview3.isHidden = false
            if let url = selectedUsers[2].avatarUrl {
                imgview3.sd_setImage(with: NSURL(string: url) as URL?, completed: { [self] (_, error, _, _) in
                    if error != nil {
                        imgview3.image = UIImage(named: "profile")
                    }
                })
            } else {
                imgview3.image = UIImage(named: "profile")
            }
        }
        
        if selectedUsers.count > 3 {
            imgview4.isHidden = false
            if let url = selectedUsers[3].avatarUrl {
                imgview4.sd_setImage(with: NSURL(string: url) as URL?, completed: { [self] (_, error, _, _) in
                    if error != nil {
                        imgview4.image = UIImage(named: "profile")
                    }
                })
            } else {
                imgview4.image = UIImage(named: "profile")
            }
        }
        
        if selectedUsers.count > 4 {
            imgview5.isHidden = false
            if let url = selectedUsers[4].avatarUrl {
                imgview5.sd_setImage(with: NSURL(string: url) as URL?, completed: { [self] (_, error, _, _) in
                    if error != nil {
                        imgview5.image = UIImage(named: "profile")
                    }
                })
            } else {
                imgview5.image = UIImage(named: "profile")
            }
        }
        
        if selectedUsers.count > 5 {
            imgview6.isHidden = false
            if let url = selectedUsers[5].avatarUrl {
                imgview6.sd_setImage(with: NSURL(string: url) as URL?, completed: { [self] (_, error, _, _) in
                    if error != nil {
                        imgview6.image = UIImage(named: "profile")
                    }
                })
            } else {
                imgview6.image = UIImage(named: "profile")
            }
        }
        
        if selectedUsers.count > 6 {
            countView.isHidden = false
            countLbl.text = "+\(selectedUsers.count - 6)"
        }
        
    }
}


