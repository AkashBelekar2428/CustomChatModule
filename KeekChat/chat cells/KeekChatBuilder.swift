//
//  KeekChatBuilder.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 09/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import Foundation
import SwiftSignalRClient

enum ChatConnectionStatus {
    case connected
    case connecting
    case disconnected
}

open class KeekChatBuilder {
    public static var shared = KeekChatBuilder()
    var chatHubConnection: HubConnection?
    var chatHubConnectionDelegate: HubConnectionDelegate?
    var userID = ""
    var isConnectionActive: ChatConnectionStatus = .disconnected
    
    func initialize() {
        print("==========initialize==========",ChatModel.sharedInstance.nativeChatUrl)
        self.isConnectionActive = .connecting
        chatHubConnectionDelegate = ChatHubConnectionDelegate(app: self)
        chatHubConnection = HubConnectionBuilder(url: URL(string: "\(ChatModel.sharedInstance.nativeChatUrl)/chat")!)
            .withHubConnectionDelegate(delegate: chatHubConnectionDelegate!)
            .withAutoReconnect()
            .withLogging(minLogLevel: .error)
            .withHubConnectionOptions(configureHubConnectionOptions: {options in options.keepAliveInterval = 10 })
            .withHttpConnectionOptions(configureHttpOptions: {options in options.accessTokenProvider = { return ChatModel.sharedInstance.keekChatToken}})
            .build()

        chatHubConnection!.start()
        self.userConnectionUpdates()
        self.receiveMsg()
        self.receiveGroupMsg()
        self.receiveTypingStatus()
        self.userDisConnectionUpdates()
        self.markReadByUser()
        self.messageDeleted()
        self.chatGroupCreated()
        self.chatGroupUpdated()
        self.receiveMediaMsgUpdate()
    }
    
    func addNetworkObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(checkNetworkConnection(_:)), name: Notification.Name("ReachabilityStatusChangedNotification"), object: nil)
    }
    
    func userConnectionUpdates() {
        chatHubConnection!.on(method: "UserConnected", callback: { user in
            
            do {
                  let object = try user.getArgument(type: UserConnectedModel.self)
                ChatCoreDataHelper.sharedChatDBHelper.updateUserStatusPrivateThreads(userID: object.id, userStatus: "Online")
                NotificationCenter.default.post(name: Notification.Name("UpdateUserStatus"), object: nil, userInfo: ["userStatus": object])
                NotificationCenter.default.post(name: Notification.Name("UpdateChatScreenUserStatus"), object: nil, userInfo: ["userStatus": object])
                
            } catch {
                print(error)
            }
        })
    }
    
    func userDisConnectionUpdates() {
        chatHubConnection!.on(method: "UserDisconnected", callback: { user in
           
            do {
                  let object = try user.getArgument(type: UserConnectedModel.self)
                ChatCoreDataHelper.sharedChatDBHelper.updateUserStatusPrivateThreads(userID: object.id, userStatus: "Offline")
                NotificationCenter.default.post(name: Notification.Name("UpdateUserStatus"), object: nil, userInfo: ["userStatus": object])
                NotificationCenter.default.post(name: Notification.Name("UpdateChatScreenUserStatus"), object: nil, userInfo: ["userStatus": object])
            } catch {
                print(error)
            }
        })
    }
    
    func receiveMsg() {
        chatHubConnection!.on(method: "ReceiveUserMessage", callback: { message in
            do {
                  let object = try message.getArgument(type: ReceivedMessageModel.self)
                let msgObj = ChatMessage(message: object)
                msgObj.threadType = "oneToOne"
                ChatCoreDataHelper.sharedChatDBHelper.managePrivateChatMessages(chatMessage: msgObj)
                NotificationCenter.default.post(name: Notification.Name("ReceivedNewMessage"), object: nil, userInfo: ["message": msgObj])
                NotificationCenter.default.post(name: Notification.Name("UpdateChatNotifier"), object: nil, userInfo: nil)
            } catch {
                print(error)
            }
        })
    }
    
    func sendMsg(msgModel: SendMessageToUserModel) {
        chatHubConnection?.send(method: "SendMessageToUser", msgModel) {error in
            if let e = error {
                print("Send message Error: \(e)")
            }
        }
    }
    
    func sendMsgToGroup(msgModel: SendMessageToGroupModel) {
        chatHubConnection?.send(method: "SendMessageToGroup", msgModel) {error in
            if let e = error {
                print("Send message Error: \(e)")
            }
        }
    }
    
    func receiveGroupMsg() {
        chatHubConnection!.on(method: "ReceiveGroupMessage", callback: { message in
             
            do {
                  let object = try message.getArgument(type: ReceivedGroupMessageModel.self)
                let msgObj = ChatMessage(message: object)
                msgObj.threadType = "group"
                ChatCoreDataHelper.sharedChatDBHelper.manageGroupChatMessages(chatMessage: msgObj)
                NotificationCenter.default.post(name: Notification.Name("ReceivedNewMessage"), object: nil, userInfo: ["message": msgObj])
                NotificationCenter.default.post(name: Notification.Name("UpdateChatNotifier"), object: nil, userInfo: nil)
            } catch {
                print(error)
            }
        })
    }
    
    func receiveMediaMsgUpdate() {
        chatHubConnection!.on(method: "MessageMetaDataUpdated", callback: { message in
             
            do {
                  let object = try message.getArgument(type: ReceivedMessageModel.self)
                let msgObj = ChatMessage(message: object)
                ChatCoreDataHelper.sharedChatDBHelper.updateChatMsgMedia(MsgId: msgObj.messageId, message: msgObj)
                NotificationCenter.default.post(name: Notification.Name("MediaMsgUpdated"), object: nil, userInfo: ["message": msgObj])
            } catch {
                print(error)
            }
        })
    }
    
    func readMsg(messageId: String) {
        chatHubConnection?.send(method: "ReadMessage", messageId) {error in
            if let e = error {
                print("Mark as read message Error: \(e)")
            }
        }
    }
    
    func markReadByUser() {
        chatHubConnection!.on(method: "MessageReadByUser", callback: { message in
            do {
                  let objects = try message.getArgument(type: [MessageReadByUserModel].self)
                let object2 = try message.getArgument(type: Bool.self)
                var selfUser: MessageReadByUserModel
                for obj in objects {
                    if obj.user?.externalUserId == ChatModel.sharedInstance.userId {
                        ChatCoreDataHelper.sharedChatDBHelper.updateChatMsgReadStatus(MsgId: obj.messageId, isRead: object2, isReadByMe: obj.isRead)
                        obj.isRead = object2
                        NotificationCenter.default.post(name: Notification.Name("UpdateMessageReadStatus"), object: nil, userInfo: ["message": obj])
                        NotificationCenter.default.post(name: Notification.Name("UpdateChatNotifier"), object: nil, userInfo: nil)
                        break
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    func sendTypingStatus(chatId: String) {
        chatHubConnection?.send(method: "InformTypingStatus", chatId) { error in
            if let e = error {
                print("Send typing status Error: \(e)")
            }
        }
    }
    
    func receiveTypingStatus() {
        chatHubConnection!.on(method: "UserIsTyping", callback: { argumentExtractor in
            do {
                  let object = try argumentExtractor.getArgument(type: ReceivedTypingUserModel.self)
                NotificationCenter.default.post(name: Notification.Name("UpdateTypingStatus"), object: nil, userInfo: ["message": object])
                
            } catch {
                print(error)
            }
        })
    }
    
    func messageDeleted() {
        chatHubConnection!.on(method: "MessageDeleted", callback: { message in
             
            do {
                  let object = try message.getArgument(type: MessageDeletedModel.self)
                NotificationCenter.default.post(name: Notification.Name("InformMessageDeleted"), object: nil, userInfo: ["message": object])
                for messageId in object.messageIds {
                    ChatCoreDataHelper.sharedChatDBHelper.updateUnreadCountOnDelete(messageID: messageId)
                    ChatCoreDataHelper.sharedChatDBHelper.deletePrivateChatMsg(messageID: messageId)
                }
                ChatCoreDataHelper.sharedChatDBHelper.checkIfLastMsgDeleted(threadID: object.chatId, messageIds: object.messageIds)
                NotificationCenter.default.post(name: Notification.Name("UpdateChatNotifier"), object: nil, userInfo: nil)
            } catch {
                print(error)
            }
        })
    }
    
    func chatGroupUpdated() {
        chatHubConnection!.on(method: "ChatGroupUpdated", callback: { message in
             
            do {
                  let object = try message.getArgument(type: ChatGroupModel.self)
                ChatCoreDataHelper.sharedChatDBHelper.updateGroupThread(threadId: object.chatId, groupName: object.groupName, dpUrl: object.dpUrl)
                NotificationCenter.default.post(name: Notification.Name("GroupWasUpdated"), object: nil, userInfo: ["group": object])
            } catch {
                print(error)
            }
        })
    }
    
    func chatGroupCreated() {
        chatHubConnection!.on(method: "ChatGroupCreated", callback: { message in
            do {
                  let object = try message.getArgument(type: ChatGroupModel.self)
                ChatCoreDataHelper.sharedChatDBHelper.updateGroupThread(threadId: object.chatId, groupName: object.groupName, dpUrl: object.dpUrl)
            } catch {
                print(error)
            }
        })
    }
    
    func disconnectChat() {
        chatHubConnection!.stop()
    }
    
    func connectionDidStart() {
        print("connectionDidStart")
        self.isConnectionActive = .connected
        NotificationCenter.default.post(name: Notification.Name("InformChatScreenSocketConnected"), object: nil, userInfo: nil)
    }

    func connectionDidFailToOpen(error: Error) {
        print("connectionDidFailToOpen \(error)")
        self.isConnectionActive = .disconnected
    }

    func connectionDidClose(error: Error?) {
        print("connectionDidClose \(error)")
        self.isConnectionActive = .disconnected
        NotificationCenter.default.post(name: Notification.Name("InformChatScreenSocketDisconnected"), object: nil, userInfo: nil)
    }

     func connectionWillReconnect(error: Error?) {
        print("connectionWillReconnect \(error)")
         self.isConnectionActive = .disconnected
    }

     func connectionDidReconnect() {
        print("connectionDidReconnect")
         self.isConnectionActive = .connected
    }
    
    @objc func checkNetworkConnection(_ notification: Notification) {
        if let status = notification.userInfo?["Status"] as? String {
            if status == "Offline" {
                if self.isConnectionActive == .connected {
                    print("Keek csocket diosconnected")
                    self.disconnectChat()
                } else {
                    print("Keek csocket diosconnected not")
                }
            } else {
                if self.isConnectionActive == .disconnected {
                    print("keek socket connected")
                    self.initialize()
                }
            }
        }
    }
    
}

class ChatHubConnectionDelegate: HubConnectionDelegate {
    weak var app: KeekChatBuilder?

    init(app: KeekChatBuilder) {
        self.app = app
    }

    func connectionDidOpen(hubConnection: HubConnection) {
        app?.connectionDidStart()
    }

    func connectionDidFailToOpen(error: Error) {
        app?.connectionDidFailToOpen(error: error)
    }

    func connectionDidClose(error: Error?) {
        app?.connectionDidClose(error: error)
    }

    func connectionWillReconnect(error: Error) {
        app?.connectionWillReconnect(error: error)
    }

    func connectionDidReconnect() {
        app?.connectionDidReconnect()
    }
}
