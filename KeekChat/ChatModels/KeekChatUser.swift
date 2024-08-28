//
//  KeekChatUser.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 30/10/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import Foundation

class KeekChatUser: NSObject {
    var id: String = ""
    var groupMemberId: String = ""
    var dpUrl: String = ""
    var email: String = ""
    var externalUserId: String = ""
    var userName: String = ""
    var userStatus: String = ""
    
    convenience init(params: [String: AnyObject]) {
        self.init()
        self.groupMemberId = params["id"] as? String ?? ""
        self.id = params["user"]?["id"] as? String ?? ""
        self.dpUrl = params["user"]?["dpUrl"] as? String ?? ""
        self.email = params["user"]?["email"] as? String ?? ""
        self.externalUserId = params["user"]?["externalUserId"] as? String ?? ""
        self.userName = params["user"]?["userName"] as? String ?? ""
    }
    
    static func parseKeekChatUsers(_ users: [[String: AnyObject]]) -> [KeekChatUser] {
        var arrayOfUsers: [KeekChatUser] = []
        for user in users {
            let userObj = KeekChatUser(params: user)
            arrayOfUsers.append(userObj)
        }
        return arrayOfUsers
    }
    
    static func parseNativeUsers(_ users: [User]) -> [KeekChatUser] {
        var arrayOfUsers: [KeekChatUser] = []
        for user in users {
            let userObj = KeekChatUser(user: user)
            arrayOfUsers.append(userObj)
        }
        return arrayOfUsers
    }
    
    convenience init(user: User) {
        self.init()
        self.externalUserId = user.id
        self.userName = user.username
        self.dpUrl = user.avatarUrl ?? ""
    }
}
