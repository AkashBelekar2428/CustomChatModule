//
//  ThreadInfo.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 30/10/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import Foundation

class ThreadInfo: NSObject {
    var threadID: String = ""
    var userID: String = ""
    var userName: String = ""
    var userAvatarUrl: String = ""
    var unreadMsgCount: Int = 0
    var lastMsgTime: String = ""
    var lastMsgText: String = ""
    var lastMsgID: String = ""
    var isBlocked: Bool = false
    var isDeleted: Bool = false
    var lastMsgTimeSecs: Int64 = 0
    var userStatus: String = ""
    var lastMsgIsDeleted: Bool = false
    var adminUserName: String = ""
    var adminChatId: String = ""
    var adminExtUserId: String = ""
    var lastMsgType: ChatMessageType = .text
    var groupId: String = ""
    var members: [KeekChatUser] = []
    var isRemoved: Bool = false
    var recordStatus: Bool = true
    var isActive: Bool = true
    var extAppUserId: String = ""
    convenience init(params: [String: AnyObject]) {
        self.init()
        self.threadID = params["chatId"] as? String ?? ""
        self.userID = params["user"]?["id"] as? String ?? ""
        self.userName = params["user"]?["userName"] as? String ?? ""
        self.userAvatarUrl = params["user"]?["dpUrl"] as? String ?? ""
        self.unreadMsgCount = params["unreadMessageCount"] as? Int ?? 0
        if let sentTime = params["message"]?["sentDateTime"] as? String {
            self.lastMsgTime = sentTime
        }
        self.lastMsgText = params["message"]?["message"] as? String ?? ""
        self.lastMsgID = params["message"]?["id"] as? String ?? ""
        self.lastMsgTimeSecs = params["message"]?["sentDateTimeMilliSeconds"] as? Int64 ?? 0
        self.userStatus = params["user"]?["userStatus"] as? String ?? ""
        if let v = params["message"]?["recordStatus"] as? NSNumber {
            self.lastMsgIsDeleted = v.boolValue
        }
        if let v = params["isActive"] as? NSNumber {
            self.isActive = v.boolValue
        }
        if let msgType = params["message"]?["messageType"] as? Int {
            self.lastMsgType = ChatMessageType(rawValue: msgType) ?? .text
        }
        if self.lastMsgType == .media {
            if self.lastMsgText == "VIDEO" {
                self.lastMsgText = "Video"
            } else if self.lastMsgText == EMessageShareType.stream.geteMessageType() {
                self.lastMsgText = "Stream"
            } else {
                self.lastMsgText = "Photo"
            }
        }
        if let x = params["isBlockedByMe"] as? NSNumber {
            self.isBlocked = x.boolValue
        }
        self.extAppUserId = params["user"]?["externalUserId"] as? String ?? ""
    }
    
    convenience init(userData: [String: AnyObject]) {
        self.init()
        self.userStatus = userData["userStatus"] as? String ?? ""
        self.userAvatarUrl = userData["dpUrl"] as? String ?? ""
        self.userID = userData["id"] as? String ?? ""
    }
    
    convenience init(userChatData: [String: AnyObject], unreadCount: Int, chatId: String) {
        self.init()
        self.userStatus = userChatData["userStatus"] as? String ?? ""
        self.userAvatarUrl = userChatData["dpUrl"] as? String ?? ""
        self.userID = userChatData["id"] as? String ?? ""
        self.extAppUserId = userChatData["externalUserId"] as? String ?? ""
        self.userName = userChatData["userName"] as? String ?? ""
        self.unreadMsgCount = unreadCount
        self.threadID = chatId
    }
    
    convenience init(groupChatData: [String: AnyObject], unreadCount: Int) {
        self.init()
        self.unreadMsgCount = unreadCount
        self.threadID = groupChatData["chatId"] as? String ?? ""
        self.userAvatarUrl = groupChatData["dpUrl"] as? String ?? ""
        self.userName = groupChatData["groupName"] as? String ?? ""
        self.adminUserName = groupChatData["groupCreatorUser"]?["userName"] as? String ?? ""
        self.adminChatId = groupChatData["groupCreatorUser"]?["id"] as? String ?? ""
        self.adminExtUserId = groupChatData["groupCreatorUser"]?["externalUserId"] as? String ?? ""
        self.groupId = groupChatData["id"] as? String ?? ""
    }
    
    static func parsePrivateThreads(_ threads: [[String: AnyObject]]) -> [ThreadInfo] {
        var arrayOfThreads: [ThreadInfo] = []
        for thread in threads {
            let threadObj = ThreadInfo(params: thread)
            arrayOfThreads.append(threadObj)
        }
        return arrayOfThreads
    }
    
    convenience init(thread: PrivateConversation) {
        self.init()
        self.threadID = thread.threadID ?? ""
        self.userID = thread.userID ?? ""
        self.userName = thread.userName ?? ""
        self.userAvatarUrl = thread.userAvatarUrl ?? ""
        self.unreadMsgCount = Int(thread.unreadMsgCount ?? 0)
            self.lastMsgTime = thread.lastMsgTime ?? ""
        self.lastMsgText = thread.lastMsgText ?? ""
        self.lastMsgID = thread.lastMsgID ?? ""
        self.lastMsgTimeSecs = thread.sentDateTimeMilliSeconds
        self.userStatus = thread.userStatus ?? ""
        self.lastMsgIsDeleted = thread.lastMsgIsDeleted ?? false
        self.isBlocked = thread.isBlocked ?? false
    }
    
    convenience init(groupParams: [String: AnyObject]) {
        self.init()
        self.threadID = groupParams["chatId"] as? String ?? ""
        self.groupId = groupParams["id"] as? String ?? ""
        self.userName = groupParams["groupName"] as? String ?? ""
        self.userAvatarUrl = groupParams["dpUrl"] as? String ?? ""
        self.unreadMsgCount = groupParams["unreadMessageCount"] as? Int ?? 0
        if let sentTime = groupParams["message"]?["sentDateTime"] as? String {
            self.lastMsgTime = sentTime
        }
        self.lastMsgText = groupParams["message"]?["message"] as? String ?? ""
        self.lastMsgID = groupParams["message"]?["id"] as? String ?? ""
        self.lastMsgTimeSecs = groupParams["message"]?["sentDateTimeMilliSeconds"] as? Int64 ?? 0
        self.adminUserName = groupParams["groupCreatedBy"]?["userName"] as? String ?? ""
        self.adminChatId = groupParams["groupCreatedBy"]?["id"] as? String ?? ""
        self.adminExtUserId = groupParams["groupCreatedBy"]?["externalUserId"] as? String ?? ""
        if let msgType = groupParams["message"]?["messageType"] as? Int {
            self.lastMsgType = ChatMessageType(rawValue: msgType) ?? .text
        }
        self.members = KeekChatUser.parseKeekChatUsers(groupParams["members"] as? [[String: AnyObject]] ?? [])
        if self.lastMsgType == .info && self.lastMsgText == GroupInfoMsgType.MemberAdded.rawValue {
            if let user = groupParams["message"]?["toUser"] as? [String: AnyObject] {
                let memberUsername = user["userName"] as? String ?? ""
                if memberUsername == ChatModel.sharedInstance.users.username {
                    self.lastMsgText = "@\(self.adminUserName ?? "") " + "addedYou".localized
                } else if self.adminUserName == ChatModel.sharedInstance.users.username {
                    self.lastMsgText = "youAdded".localized + " @\(memberUsername)"
                } else {
                    self.lastMsgText = "@\(self.adminUserName) " + "added".localized + " @\(memberUsername)" 
                }
            }
            
        } else if self.lastMsgType == .info && self.lastMsgText == GroupInfoMsgType.MemberRemoved.rawValue {
            if let user = groupParams["message"]?["toUser"] as? [String: AnyObject] {
                let memberUsername = user["userName"] as? String ?? ""
                if memberUsername == ChatModel.sharedInstance.users.username {
                    self.lastMsgText = "@\(self.adminUserName) " + "removedYou".localized
                } else if self.adminUserName == ChatModel.sharedInstance.users.username {
                    self.lastMsgText = "youRemoved".localized + " @\(memberUsername)"
                } else {
                    self.lastMsgText = "@\(self.adminUserName) " + "removed".localized + " @\(memberUsername)" 
                }
            }
        } else if self.lastMsgType == .media {
            if self.lastMsgText == "VIDEO" {
                self.lastMsgText = "Video"
            } else if self.lastMsgText == EMessageShareType.stream.geteMessageType() {
                self.lastMsgText = "Stream"
            } else {
                self.lastMsgText = "Photo"
            }
        }
        if self.lastMsgType != .info {
            if let user = groupParams["message"]?["user"] as? [String: AnyObject] {
            let memberUsername = user["userName"] as? String ?? ""
            if memberUsername == ChatModel.sharedInstance.users.username {
                self.lastMsgText = "You: \(self.lastMsgText)"
            } else {
                self.lastMsgText = "@\(memberUsername): \(self.lastMsgText)"
            }
        }
    }
        if let v = groupParams["isActive"] as? NSNumber {
            self.isActive = v.boolValue
        }
    }
    
    static func parseGroupThreads(_ threads: [[String: AnyObject]]) -> [ThreadInfo] {
        var arrayOfThreads: [ThreadInfo] = []
        for thread in threads {
            let threadObj = ThreadInfo(groupParams: thread)
            arrayOfThreads.append(threadObj)
        }
        return arrayOfThreads
    }
    
    static func parseShareGroupThreads(_ threads: [[String: AnyObject]]) -> [ThreadInfo] {
        var arrayOfThreads: [ThreadInfo] = []
        for thread in threads {
            let threadObj = ThreadInfo(groupParams: thread)
            if threadObj.isActive {
                arrayOfThreads.append(threadObj)
            }
        }
        return arrayOfThreads
    }
    
    convenience init(groupThread: GroupConversation) {
        self.init()
        self.threadID = groupThread.threadID ?? ""
        self.groupId = groupThread.groupID ?? ""
        self.userName = groupThread.groupName ?? ""
        self.userAvatarUrl = groupThread.groupAvatarUrl ?? ""
        self.unreadMsgCount = Int(groupThread.unreadMsgCount ?? 0)
        self.lastMsgTime = groupThread.lastMsgTime ?? ""
        self.lastMsgText = groupThread.lastMsgText ?? ""
        self.lastMsgID = groupThread.lastMsgID ?? ""
        self.lastMsgTimeSecs = groupThread.sentDateTimeMilliSeconds
        self.recordStatus = groupThread.recordStatus
        self.adminUserName = groupThread.adminUserName ?? ""
        self.adminChatId = groupThread.adminChatId ?? ""
        self.adminExtUserId = groupThread.adminExtUserId ?? ""
        self.lastMsgType = ChatMessageType(rawValue: Int(groupThread.lastMsgType ?? 0)) ?? .text
        self.isActive = groupThread.isActive
    }
}
