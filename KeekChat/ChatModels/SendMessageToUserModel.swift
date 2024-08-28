//
//  SendMessageToUserModel.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 12/09/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import Foundation
import SwiftSignalRClient

enum EMessageType {
    case text
    case media
    func geteMessageType() -> Int {
        switch self {
        case .text:
            return 0
        case .media:
            return 1
        }
    }
}

enum EMessageShareType {
    case stream
    case video
    case image
    func geteMessageType() -> String {
        switch self {
        case .stream:
            return "STREAM"
        case .video:
            return  "VIDEO"
        case .image:
            return  "IMAGE"
        }
    }
}

struct SendMessageToUserModel: Encodable {
    var toUserId: String = ""
    var message: String = ""
    var chatId: String = ""
    var eMessageType: EMessageType = .text
    var chatMessageMetaDatas: [ChatMessageMetaData]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        try container.encode(toUserId, forKey: .toUserId)
        try container.encode(chatId, forKey: .chatId)
        try container.encode(eMessageType.geteMessageType(), forKey: .eMessageType)
        try container.encode(chatMessageMetaDatas, forKey: .chatMessageMetaDatas)
    }
    
    private enum CodingKeys: String, CodingKey {
        case message
        case toUserId
        case chatId
        case eMessageType
        case chatMessageMetaDatas
    }
}

struct RequestModel: Encodable {
    var chatMessageMetaDatas: [ChatMessageMetaData]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(chatMessageMetaDatas, forKey: .chatMessageMetaDatas)
    }
    
    private enum CodingKeys: String, CodingKey {
        case chatMessageMetaDatas
    }
}

struct SendMessageToGroupModel: Encodable {
    
    var message: String = ""
    var chatId: String = ""
    var eMessageType: EMessageType = .text
    var chatMessageMetaDatas: [ChatMessageMetaData]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        try container.encode(chatId, forKey: .chatId)
        try container.encode(eMessageType.geteMessageType(), forKey: .eMessageType)
        try container.encode(chatMessageMetaDatas, forKey: .chatMessageMetaDatas)
    }
    
    private enum CodingKeys: String, CodingKey {
        case message
        case chatId
        case eMessageType
        case chatMessageMetaDatas
    }
}

struct ChatMessageMetaData: Encodable {
    var metaKey: String = ""
    var metaValue: String = ""
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metaKey, forKey: .metaKey)
        try container.encode(metaValue, forKey: .metaValue)
    }
    
    private enum CodingKeys: String, CodingKey {
        case metaKey
        case metaValue
    }
}

struct ChatMediaMessageMetaData: Encodable {
    var metaKey: String = ""
    var metaValue: String = ""
    
    init(metaKey: String, metaValue: String) {
          self.metaKey = metaKey
          self.metaValue = metaValue
      }
}

class ReceivedChatMessageMetaData: Decodable {
    var metaKey: String = ""
    var metaValue: String = ""
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.metaKey = try container.decode(String.self, forKey: .metaKey)
        self.metaValue = try container.decode(String.self, forKey: .metaValue)
    }
    
     enum CodingKeys: String, CodingKey {
        case metaKey
        case metaValue
    }
}

class ReceivedMessageModel: Decodable {
    var id: String = ""
    var message: String = ""
    var sentDateTime: String = ""
    var recordStatus: Int = 0
    var user: MessageUserModel?
    var chatSrNo: Int64 = 0
    var chatId: String = ""
    var messageType: Int = 0
    var isRead: Bool = false
    var isReadByMe: Bool = false
    var metaDatas: [ReceivedChatMessageMetaData] = []
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try container.decode(String.self, forKey: .message)
        self.id = try container.decode(String.self, forKey: .id)
        self.recordStatus = try container.decode(Int.self, forKey: .recordStatus)
        self.chatSrNo = try container.decode(Int64.self, forKey: .chatSrNo)
        self.chatId = try container.decode(String.self, forKey: .chatId)
        self.messageType = try container.decode(Int.self, forKey: .messageType)
        self.user = try container.decode(MessageUserModel.self, forKey: .user)
        self.sentDateTime = try container.decode(String.self, forKey: .sentDateTime)
        self.isRead = try container.decode(Bool.self, forKey: .isRead)
        self.isReadByMe = try container.decode(Bool.self, forKey: .isReadByMe)
        if self.messageType == 1 {
            self.metaDatas = try container.decode([ReceivedChatMessageMetaData].self, forKey: .metaDatas)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case id
        case sentDateTime
        case recordStatus
        case chatSrNo
        case messageType
        case chatId
        case user
        case isRead
        case isReadByMe
        case metaDatas
    }
}

class ReceivedGroupMessageModel: Decodable {
    var id: String = ""
    var message: String = ""
    var sentDateTime: String = ""
    var recordStatus: Int = 0
    var user: MessageUserModel?
    var chatSrNo: Int64 = 0
    var chatId: String = ""
    var messageType: Int = 0
    var isRead: Bool = false
    var isReadByMe: Bool = false
    var metaDatas: [ReceivedChatMessageMetaData] = []
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try container.decode(String.self, forKey: .message)
        self.id = try container.decode(String.self, forKey: .id)
        self.recordStatus = try container.decode(Int.self, forKey: .recordStatus)
        self.chatSrNo = try container.decode(Int64.self, forKey: .chatSrNo)
        self.chatId = try container.decode(String.self, forKey: .chatId)
        self.messageType = try container.decode(Int.self, forKey: .messageType)
        self.user = try container.decode(MessageUserModel.self, forKey: .user)
        self.sentDateTime = try container.decode(String.self, forKey: .sentDateTime)
        self.isRead = try container.decode(Bool.self, forKey: .isRead)
        self.isReadByMe = try container.decode(Bool.self, forKey: .isReadByMe)
        if self.messageType == 1 {
            self.metaDatas = try container.decode([ReceivedChatMessageMetaData].self, forKey: .metaDatas)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case id
        case sentDateTime
        case recordStatus
        case chatSrNo
        case messageType
        case chatId
        case user
        case isRead
        case isReadByMe
        case metaDatas
    }
}

class MessageUserModel: Decodable {
    
    var id: String = ""
    var userName: String = ""
    var externalUserId: String = ""
    var dpUrl: String = ""
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.externalUserId = try container.decode(String.self, forKey: .externalUserId)
        self.dpUrl = try container.decode(String.self, forKey: .dpUrl)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userName
        case externalUserId
        case dpUrl
    }
}

struct MarkMessageAsRead: Encodable {
    var messageId: String = ""
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
    }
    
    private enum CodingKeys: String, CodingKey {
        case messageId
    }
}

class MessageReadByUserModel: Decodable {
    var messageId: String = ""
    var chatId: String = ""
    var isRead: Bool = false
    var user: MessageUserModel?
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.messageId = try container.decode(String.self, forKey: .messageId)
            self.chatId = try container.decode(String.self, forKey: .chatId)
            self.isRead = try container.decode(Bool.self, forKey: .isRead)
            self.user = try container.decode(MessageUserModel.self, forKey: .user)
        
    }
    
    enum CodingKeys: String, CodingKey {
        case messageId
        case chatId
        case isRead
        case user
    }
}

struct InformTypingStatus: Encodable {
    var chatId: String = ""
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(chatId, forKey: .chatId)
    }
    
    private enum CodingKeys: String, CodingKey {
        case chatId
    }
}

struct TypingUserModel: Encodable {
    var Id: String = ""
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Id, forKey: .Id)
    }
    
    private enum CodingKeys: String, CodingKey {
        case Id
    }
}

class ReceivedTypingUserModel: Decodable {
    
    var chatId: String = ""
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chatId = try container.decode(String.self, forKey: .chatId)
    }
    
    enum CodingKeys: String, CodingKey {
        case chatId
    }
}

class UserConnectedModel: Decodable {
    var id: String = ""
    var externalUserId: String = ""
    var userStatus: String = ""
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.externalUserId = try container.decode(String.self, forKey: .externalUserId)
        self.userStatus = try container.decode(String.self, forKey: .userStatus)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case externalUserId
        case userStatus
    }
}

class MessageDeletedModel: Decodable {
    var chatId: String = ""
    var messageIds: [String] = []
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chatId = try container.decode(String.self, forKey: .chatId)
        self.messageIds = try container.decode([String].self, forKey: .messageIds)
    }
    
    private enum CodingKeys: String, CodingKey {
        case chatId
        case messageIds
    }
}

class ChatGroupModel: Decodable {
    var chatId: String = ""
    var id: String = ""
    var groupName: String = ""
    var dpUrl: String = ""
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chatId = try container.decode(String.self, forKey: .chatId)
        self.id = try container.decode(String.self, forKey: .id)
        self.groupName = try container.decode(String.self, forKey: .groupName)
        self.dpUrl = try container.decode(String.self, forKey: .dpUrl)
    }
    
    private enum CodingKeys: String, CodingKey {
        case chatId
        case id
        case groupName
        case dpUrl
    }
}
