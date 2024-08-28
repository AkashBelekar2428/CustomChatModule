//
//  ChatMessage.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 25/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Foundation

class ChatMessage: NSObject {
    
    var messageId: String = ""
    var messageTime: String = ""
    var messageType: Int = 0
    var messageText: String = ""
    var thumbnailImageUrl: String = ""
    var mainImageUrl: String = ""
    var userAvatarUrl: String = ""
    var userName: String = ""
    var userId: String = ""
    var imageHeight: Int = 0
    var imageWidth: Int = 0
    var isDeleted: Bool = false
    var isRead: Bool = false
    var threadID: String = ""
    var messageTimeSecs: Int64 = 0
    var externalUserId: String = ""
    var threadType: String = ""
    var isReadByMe: Bool = false
    var postId: String = ""
    convenience init(params: [String: AnyObject]) {
        self.init()
        self.messageId = params["id"] as? String ?? ""
        if let sentTime = params["sentDateTime"] as? String {
            self.messageTime = sentTime //Utils.formatDateFromISODate(sentTime)//Utils.formatDateFromString(date: sentTime, format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'")
            self.messageTimeSecs = Int64(UIUtil.convertDateStringToMilliseconds(dateString: sentTime) ?? 0)
        }
        self.messageText = params["message"] as? String ?? ""
        self.userAvatarUrl = params["user"]?["dpUrl"] as? String ?? ""
        self.userName = params["user"]?["userName"] as? String ?? ""
        self.userId = params["user"]?["id"] as? String ?? ""
        self.threadID = params["chatId"] as? String ?? ""
        if let v = params["isRead"] as? NSNumber {
            self.isRead = v.boolValue
        }
        if let v = params["isReadByMe"] as? NSNumber {
            self.isReadByMe = v.boolValue
        }
        if let v = params["recordStatus"] as? NSNumber {
            self.isDeleted = v.boolValue
        }
        self.messageType = params["messageType"] as? Int ?? 0
        self.externalUserId = params["user"]?["externalUserId"] as? String ?? ""
        
        if self.messageType == 3 && self.messageText == GroupInfoMsgType.MemberAdded.rawValue {
            if let user = params["toUser"] as? [String: AnyObject] {
                let memberUsername = user["userName"] as? String ?? ""
                if memberUsername == ChatModel.sharedInstance.users.username {
                    self.messageText = "@\(self.userName ?? "") " + "addedYou"
                } else if self.userName == ChatModel.sharedInstance.users.username {
                    self.messageText = "youAdded" + " @\(memberUsername)"
                } else {
                    self.messageText = "@\(self.userName) " + "added" + " @\(memberUsername)"
                }
            }
        } else if self.messageType == 3 && self.messageText == GroupInfoMsgType.MemberRemoved.rawValue {
            if let user = params["toUser"] as? [String: AnyObject] {
                let memberUsername = user["userName"] as? String ?? ""
                if memberUsername == ChatModel.sharedInstance.users.username {
                    self.messageText = "@\(self.userName) " + "removedYou"
                } else if self.userName == ChatModel.sharedInstance.users.username {
                    self.messageText = "youRemoved" + " @\(memberUsername)"
                } else {
                    self.messageText = "@\(self.userName) " + "removed" + " @\(memberUsername)"
                }
            }
        }
        
        if self.messageType == 1 {
            if let metaDatas = params["metaDatas"] as? [[String: AnyObject]] {
                for metaData in metaDatas {
                if let metaKey = metaData["metaKey"] as? String,
                   let metaValue = metaData["metaValue"] {
                    
                    switch metaKey {
                    case "url_original":
                        self.mainImageUrl = metaValue as? String ?? ""
                    case "url_thumbnail":
                        self.thumbnailImageUrl = metaValue as? String ?? ""
                    case "height":
                        self.imageHeight = metaValue as? Int ?? 0
                    case "width":
                        self.imageWidth = metaValue as? Int ?? 0
                    case "post_id":
                        self.postId = metaValue as? String ?? ""
                    default:
                        break
                    }
                }
            }
            }
        }
    }
    
    static func parsePrivateThreadMessages(_ messages: [[String: AnyObject]]) -> [ChatMessage] {
        var arrayOfMessages: [ChatMessage] = []
        for message in messages {
            let messageObj = ChatMessage(params: message)
            arrayOfMessages.append(messageObj)
        }
        return arrayOfMessages
    }
    
    convenience init(message: PrivateChatMessages) {
        self.init()
        self.messageId = message.messageID ?? ""
        self.messageTime = message.messageTime ?? ""
        self.messageText = message.messageText ?? ""
        self.userAvatarUrl = message.userAvatarUrl ?? ""
        self.userName = message.userName ?? ""
        self.userId = message.userId ?? ""
        self.threadID = message.threadID ?? ""
        self.isRead = message.isRead ?? false
        self.messageTimeSecs = message.sentDateTimeMilliSeconds ?? 0
        self.externalUserId = message.externalUserId ?? ""
        self.isDeleted = message.isDeletedMessage ?? false
        self.messageType = Int(message.messageType ?? 0)
        self.threadType = message.threadType ?? ""
        self.isReadByMe = message.isReadByMe ?? false
        self.thumbnailImageUrl = message.thumbnailImageUrl ?? ""
        self.mainImageUrl = message.mainImageUrl ?? ""
        self.imageHeight = Int(message.imageHeight ?? 0)
        self.imageWidth = Int(message.imageWidth ?? 0)
        self.postId = message.postId ?? ""
    }
    
    convenience init(message: ReceivedMessageModel) {
        self.init()
        self.messageId = message.id
        self.messageTime = message.sentDateTime
        self.messageTimeSecs = Int64(UIUtil.convertDateStringToMilliseconds(dateString: message.sentDateTime) ?? 0)
        self.messageText = message.message
        self.userAvatarUrl = message.user?.dpUrl ?? ""
        self.userName = message.user?.userName ?? ""
        self.userId = message.user?.id ?? ""
        self.threadID = message.chatId
        self.externalUserId = message.user?.externalUserId ?? ""
        self.isRead = message.isRead
        self.isDeleted = (message.recordStatus != 0)
        self.isReadByMe = message.isReadByMe
        self.messageType = message.messageType
        
        for metaData in message.metaDatas {
           let metaKey = metaData.metaKey
               let metaValue = metaData.metaValue
                
                switch metaKey {
                case "url_original":
                    self.mainImageUrl = metaValue
                case "url_thumbnail":
                    self.thumbnailImageUrl = metaValue
                case "height":
                    self.imageHeight = Int(metaValue) ?? 0
                case "width":
                    self.imageWidth = Int(metaValue) ?? 0
                case "post_id":
                    self.postId = metaValue as? String ?? ""
                default:
                    break
                }
        }
    }
    
    convenience init(message: ReceivedGroupMessageModel) {
        self.init()
        self.messageId = message.id
        self.messageTime = message.sentDateTime
        self.messageTimeSecs = Int64(UIUtil.convertDateStringToMilliseconds(dateString: message.sentDateTime) ?? 0)
        self.messageText = message.message
        self.userName = message.user?.userName ?? ""
        self.userId = message.user?.id ?? ""
        self.threadID = message.chatId
        self.userAvatarUrl = message.user?.dpUrl ?? ""
        self.externalUserId = message.user?.externalUserId ?? ""
        self.isRead = message.isRead
        self.isDeleted = (message.recordStatus != 0)
        self.isReadByMe = message.isReadByMe
        self.messageType = message.messageType
        for metaData in message.metaDatas {
            let metaKey = metaData.metaKey
            let metaValue = metaData.metaValue
            
            switch metaKey {
            case "url_original":
                self.mainImageUrl = metaValue
            case "url_thumbnail":
                self.thumbnailImageUrl = metaValue
            case "height":
                self.imageHeight = Int(metaValue) ?? 0
            case "width":
                self.imageWidth = Int(metaValue) ?? 0
            case "post_id":
                self.postId = metaValue as? String ?? ""
            default:
                break
            }
        }
    }
}
