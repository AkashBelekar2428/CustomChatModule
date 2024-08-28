//
//  ChatEnum.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 24/10/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import Foundation

enum GroupInfoMsgType: String {
    case GroupCreated = "Group Created"
    case MemberAdded = "Member Added"
    case MemberRemoved = "Member Removed"
}

enum ChatMessageType: Int {
    case text = 0
    case media = 1
    case info = 3
}
