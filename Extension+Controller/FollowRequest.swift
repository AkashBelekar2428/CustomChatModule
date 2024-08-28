//
//  FollowRequest.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 15/11/22.
//  Copyright © 2022 Riavera. All rights reserved.
//

import Foundation

class FollowRequest: NSObject {
    
    var entryDate: Date?
    var followRequestID: Int = 0
    var followStatus = ""
    var followers: Int = 0
    var following: Int = 0
    var receiverAvatar = ""
    var receiverGuserId: Int64 = 0
    var receiverSname = ""
    var receiverUserId: Int64 = 0
    var senderAvatar = ""
    var senderGuserId: Int64 = 0
    var senderSname = ""
    var senderUserId: Int64 = 0
    var updatedDate: Date?
    
    convenience init(params: [String: AnyObject]) {
        self.init()
        if let read = params["entry_date"] as? String {
            self.entryDate = Utils.formatDateFromString(date: read, format: "yyyy-MM-dd HH:mm:ssZ")
        }
        self.followRequestID = params["follow_request_id"] as? Int ?? 0
        self.followStatus = params["follow_status"] as? String ?? ""
        self.followers = params["followers"] as? Int ?? 0
        self.following = params["following"] as? Int ?? 0
        self.receiverAvatar = params["receiver_avatar"] as? String ?? ""
        self.receiverGuserId = params["receiver_guser_id"] as? Int64 ?? 0
        self.receiverSname = params["receiver_sname"] as? String ?? ""
        self.receiverUserId = params["receiver_user_id"] as? Int64 ?? 0
        self.senderAvatar = params["sender_avatar"] as? String ?? ""
        self.senderGuserId = params["sender_guser_id"] as? Int64 ?? 0
        self.senderSname = params["sender_sname"] as? String ?? ""
        self.senderUserId = params["sender_user_id"] as? Int64 ?? 0
        if let update = params["updated_date"] as? String {
            self.entryDate = Utils.formatDateFromString(date: update, format: "yyyy-MM-dd HH:mm:ssZ")
        }
    }
    
    static func parseRequestList(_ requests: [[String: AnyObject]]) -> [FollowRequest]{
        var arrayOfRequest: [FollowRequest] = []
        for request in requests {
            let requestObj = FollowRequest(params: request)
            arrayOfRequest.append(requestObj)
        }
        return arrayOfRequest
        
    }
}
