//
//  ChatConnector.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 06/09/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import Foundation

class ChatConnector: NSObject {
    
    let http =  ChatHTTPRequestor.sharedInstance
    
    /// To create or get chat details for the user
    /// - Parameters:
    ///   - userID: The external app user id of the other user
    ///   - completion: chat/thread details
    func getChatTokenForUser(_ userID: String, completion:@escaping (_ success: Bool, _ error: String?, _ toUserID: String?, _ chatID: String?, _ userStatus: String?, _ dpUrl: String?) -> Void) {
        let path = "/api/v1/chatmessage/getchatidbyexternalappuserid"
        var params: [String: AnyObject] = ["externalAppUserId": userID as AnyObject]
        
        params["externalUserAppName"] = "miitv" as AnyObject // appname key define in ChatModel
        
        http.POST(path, parameters: params) { data, error, success in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    if let toUserID = data["toUserId"] as? String {
                        if let chatID = data["chatId"] as? String {
                            let userStatus = data["user"]?["userStatus"] as? String
                            let dpUrl = data["user"]?["dpUrl"] as? String
                            completion(true, nil, toUserID, chatID, userStatus, dpUrl)
                        }
                    }
                } else {
                    completion(false, "Cannot connect to chat at the moment", nil, nil, nil, nil)
                }
                
            } else {
                completion(false, error!, nil, nil, nil, nil)
            }
        }
    }
    
    /// To get the list of 1 to 1 chat
    /// - Parameters:
    ///   - isRefresh: Flag to indicate if it is loading new list. If it is true it will save the response in coredata
    ///   - timestamp: It is the timestamp of the last object from the thread list that is loaded
    ///   - completion: If success, it will return the list of 1 to 1 chats
    func getPrivateChats(isRefresh: Bool, timestamp: Int64, completion:@escaping (_ success: Bool, _ error: String?, _ threads: [ThreadInfo]?) -> Void) {
        let path = "/api/v1/chatuser/getchatusers"
        let params = "?lastUpdatedMessageMilliSeconds=\(timestamp)&pageSize=10"
        http.GET(path, queryParams: params, parameters: [:]) { data, error, success in
            if success {
                if let threads = data!["data"] as? [[String: AnyObject]] {
                    let threadList = ThreadInfo.parsePrivateThreads(threads)
                    if isRefresh {
                        ChatCoreDataHelper.sharedChatDBHelper.deleteAllPrivateThread()
                        ChatCoreDataHelper.sharedChatDBHelper.parsePrivateThreads(threads)
                    }
                    completion(true, nil, threadList)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                print(error)
                completion(false, error, nil)
            }
        }
    }
    
    /// To get the list of chat messages
    /// - Parameters:
    ///   - chatId: chatId of the thread
    ///   - messageUpto: timestamp of the last message that is loaded
    ///   - page: Page number
    ///   - pageSize: Number of messages
    ///   - isRefresh: If its reloaded , store the response in core data
    ///   - threadType: If it is "oneToOne" or "group"
    ///   - completion: The list of chat messages
    func getChatMessages(chatId: String, messageUpto: String, page: Int, pageSize: Int, isRefresh: Bool, threadType: String, completion:@escaping (_ success: Bool, _ error: String?, _ threads: [ChatMessage]?, _ totalMsgCount: Int?) -> Void) {
        
        let path = "/api/v1/chatmessage/getuserchatmessages"
        
        let params = "?chatId=\(chatId)&messagesUpto=\(messageUpto)"
        var paramsHeader: [String: AnyObject] = ["Page": page as AnyObject]
        
        paramsHeader["PageSize"] = pageSize as AnyObject
        http.GET(path, queryParams: params, parameters: paramsHeader) { data, error, success in
            if success {
                if let messages = data!["data"]?["data"] as? [[String: AnyObject]] {
                    let messageList = ChatMessage.parsePrivateThreadMessages(messages)
                    let msgCount = data!["data"]?["totalItems"] as? Int
                    if isRefresh {
                        ChatCoreDataHelper.sharedChatDBHelper.deleteAllPrivateChatMsg(threadID: chatId)
                        ChatCoreDataHelper.sharedChatDBHelper.parsePrivateThreadMessages(messages, threadType: threadType)
                    }
                    completion(true, nil, messageList, msgCount)
                } else {
                    completion(false, "No data found in response", nil, nil)
                }
            } else {
                completion(false, error, nil, nil)
            }
        }
    }
    
    /// It is used to get the missed messages when socket/network is reconnected
    /// - Parameters:
    ///   - chatId: chatId for the thread
    ///   - messageFrom: The timestamp of the last message that is loaded
    ///   - completion: The list of messages that were missed due to network issue
    func getLatestChatMessages(chatId: String, messageFrom: String, completion:@escaping (_ success: Bool, _ error: String?, _ threads: [ChatMessage]?) -> Void) {
        let path = "/api/v1/chatmessage/getchatmessagesfromdate"
        
        let params = "?chatId=\(chatId)&messageDate=\(messageFrom)"
        
        http.GET(path, queryParams: params, parameters: [:]) { data, error, success in
            if success {
                if let messages = data!["data"] as? [[String: AnyObject]] {
                    
                    let messageList = ChatMessage.parsePrivateThreadMessages(messages)
                    completion(true, nil, messageList)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                completion(false, error, nil)
            }
        }
    }
    
    /// It is used to get the missed actions on the messages when socket/network is reconnected
    /// - Parameters:
    ///   - chatId: chatId for the thread
    ///   - modifiedDate:The timestamp when the socket/network was disconnected
    ///   - completion: The list messages whose state where changed since the network issue
    func getLatestChatMessagesStatus(chatId: String, modifiedDate: String, completion:@escaping (_ success: Bool, _ error: String?, _ threads: [ChatMessage]?) -> Void) {
      
        let path = "/api/v1/chatmessage/getmessagesbymodifieddate"
        
        let params = "?chatId=\(chatId)&modifiedDate=\(modifiedDate)"
        
        http.GET(path, queryParams: params, parameters: [:]) { data, error, success in
            if success {
                if let messages = data!["data"] as? [[String: AnyObject]] {
                    
                    let messageList = ChatMessage.parsePrivateThreadMessages(messages)
                    completion(true, nil, messageList)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                completion(false, error, nil)
            }
        }
    }
    
    /// To delete the chat message
    /// - Parameters:
    ///   - messageIds: Array of messageIds to be deleted
    ///   - completion: It indicates if messages were deleted succesfully or not
    func deleteChatMessage(messageIds: [String], completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
      
        let path = "/api/v1/chatmessage/delete"
        
        var paramsHeader: [String: AnyObject] = ["messageIds": messageIds as AnyObject]
        
        http.DELETE(path, queryParams: "", parameters: paramsHeader) { data, error, success in
            if success {
                    completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    /// To delete the chat thread
    /// - Parameters:
    ///   - threadId: thread id to be deleted
    func deleteChatThread(threadId: String, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
      
        let path = "/api/v1/chatmessage/deletethreadforme"
        
        var paramsHeader: [String: AnyObject] = ["chatId": threadId as AnyObject]
        
        http.DELETE(path, queryParams: "", parameters: paramsHeader) { data, error, success in
            if success {
                    completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    /// To get user details when socket is reconnected
    /// - Parameters:
    ///   - userId: userId of the user
    ///   - completion: The response has
    func getUserStatus(userId: String, completion:@escaping (_ success: Bool, _ error: String?, _ userStatus: ThreadInfo?) -> Void ) {
        
        let path = "/api/v1/chatuser/getbyid"
        let params = "?userId=\(userId)"
       
        http.GET(path, queryParams: params, parameters: [:]) { data, error, success in
            if success {
                if let user = data!["data"] as? [String: AnyObject] {
                    let user = ThreadInfo(userData: user)
                    completion(true, nil, user)
                } else {
                    completion(false, error, nil)
                }
            } else {
                completion(false, error, nil)
            }
        }
    }
    
    /// To get if the user has any unread threads to show the notifier of unread state
    /// - Parameter completion: It returns number of threads with unread messages
    func getUnreadMsgsStatus(completion:@escaping (_ success: Bool, _ error: String?, _ unreadCount: Int?) -> Void ) {
        
        let path = "/api/v1/chatmessage/getallmessagesunreadcount"
        
        http.GET(path, queryParams: "", parameters: [:]) { data, error, success in
            if success {
                if let unreadCount = data!["data"] as? Int {
                    completion(true, nil, unreadCount)
                } else {
                    completion(false, error, nil)
                }
            } else {
                completion(false, error, nil)
            }
        }
    }
    
    /// To create chat group
    /// - Parameters:
    ///   - groupName: The name of the group
    ///   - dpUrl: Url of the group profile picture uploaded
    ///   - externalUserIds: External user ids of the members to be added to the group
    ///   - completion: It returns group details when group is created successfully
    func createGroupChat(_ groupName: String, _ dpUrl: String, _ externalUserIds: [String], completion:@escaping (_ success: Bool, _ error: String?, _ groupId: String?, _ groupName: String?, _ groupChatId: String?, _ groupDpUrl: String?) -> Void) {
        let path = "/api/v1/chatgroup/createchatgroupbyexternalappuserid"
        var params: [String: AnyObject] = ["groupName": groupName as AnyObject]
        params["dpUrl"] = dpUrl as AnyObject
        params["externalUserIds"] = externalUserIds as AnyObject
        params["externalApplicationName"] = "miitv" as AnyObject
        
        http.POST(path, parameters: params) { data, error, success in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    if let groupId = data["id"] as? String {
                        if let chatID = data["chatId"] as? String {
                            let groupName = data["groupName"] as? String
                            completion(true, nil, groupId, groupName, chatID, "")
                        }
                    }
                } else {
                    completion(false, "Cannot connect to chat at the moment", nil, nil, nil, nil)
                }
                
            } else {
                completion(false, error!, nil, nil, nil, nil)
            }
        }
    }
    
    /// To get the list of group chats/threads
    /// - Parameters:
    ///   - isRefresh: Flag to indicate if it is loading new list. If it is true it will save the response in coredata
    ///   - timestamp: It is the timestamp of the last object from the thread list that is loaded
    ///   - completion: If success, it will return the list of group chats
    func getGroupChats(isRefresh: Bool, timestamp: Int64, completion:@escaping (_ success: Bool, _ error: String?, _ threads: [ThreadInfo]?) -> Void) {
        let path = "/api/v1/chatgroup/getchatgrouplist"
        let params = "?lastUpdatedMessageMilliSeconds=\(timestamp)&pageSize=10"
        http.GET(path, queryParams: params, parameters: [:]) { data, error, success in
          
            if success {
                if let threads = data!["data"] as? [[String: AnyObject]] {
                    let threadList = ThreadInfo.parseGroupThreads(threads)
                    if isRefresh {
                        ChatCoreDataHelper.sharedChatDBHelper.deleteAllGroupThread()
                        ChatCoreDataHelper.sharedChatDBHelper.parseGroupThreads(threads)
                    }
                    completion(true, nil, threadList)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                print(error)
                completion(false, error, nil)
            }
        }
    }
    
    /// To get the list of group chats/threads
    /// - Parameters:
    ///   - isRefresh: Flag to indicate if it is loading new list. If it is true it will save the response in coredata
    ///   - timestamp: It is the timestamp of the last object from the thread list that is loaded
    ///   - completion: If success, it will return the list of group chats
    func getGroupChatsForShare(isRefresh: Bool, timestamp: Int64, completion:@escaping (_ success: Bool, _ error: String?, _ threads: [ThreadInfo]?) -> Void) {
        let path = "/api/v1/chatgroup/getchatgrouplist"
        let params = "?lastUpdatedMessageMilliSeconds=\(timestamp)&pageSize=100"
        http.GET(path, queryParams: params, parameters: [:]) { data, error, success in
          
            if success {
                if let threads = data!["data"] as? [[String: AnyObject]] {
                    let threadList = ThreadInfo.parseShareGroupThreads(threads)
                    completion(true, nil, threadList)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                print(error)
                completion(false, error, nil)
            }
        }
    }
    
    /// To get chat group information
    /// - Parameters:
    ///   - groupId: Thread's groupId
    ///   - completion: Details of the specified group
    func getGroupChatInfo(groupId: String,completion:@escaping (_ success: Bool, _ error: String?, _ groupDetails: ThreadInfo?) -> Void) {
        let path = "/api/v1/chatgroup/getbyid"
        let params = "?id=\(groupId)"
        http.GET(path, queryParams: params, parameters: [:]) { data, error, success in
            if success {
                if let group = data!["data"] as? [String: AnyObject] {
                     let groupDetails = ThreadInfo(groupParams: group)
                        completion(true, nil, groupDetails)
                }
            } else {
                print(error)
                completion(false, error, nil)
            }
        }
    }
    
    /// To edit chat group
    /// - Parameters:
    ///   - id: group id to be edited
    ///   - groupName: Group name to be set
    ///   - dpUrl: Url of the group profile picture
    ///   - externalUserIds: External userids of the new members added to the group
    ///   - removedGroupMembers: ChatIds of the members that are removed from the group
    ///   - completion: It indicates if the group was edited successfully or not
    func editChatGroup(_ id: String, _ groupName: String, _ dpUrl: String, _ externalUserIds: [String], _ removedGroupMembers: [String], completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let path = "/api/v1/chatgroup/edit"
        var params: [String: AnyObject] = ["groupName": groupName as AnyObject]
        params["id"] = id as AnyObject
        params["dpUrl"] = dpUrl as AnyObject
        params["addExternalUserIds"] = externalUserIds as AnyObject
        params["externalApplicationName"] = "miitv" as AnyObject
        params["removedGroupMembers"] = removedGroupMembers as AnyObject
        
        http.PUT(path, parameters: params) { _, error, success in
            if success {
                completion(true, nil)
            } else {
                completion(false, "Cannot not update the group at the moment")
            }
        }
    }
    
    func updateMediaMetadata(_ messageId: String, _ metaDatas: [ChatMediaMessageMetaData], completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let path = "/api/v1/chatmessage/updatemetadata"
        
        var params: [String: AnyObject] = ["chatMessageId": messageId as AnyObject]
        var metaDataArrayConverted: [[String: String]] = []

        for metaData in metaDatas {
            let metaDataDict = [
                "metaKey": metaData.metaKey,
                "metaValue": metaData.metaValue
            ]
            metaDataArrayConverted.append(metaDataDict)
        }
                params["metaDatas"] = metaDataArrayConverted as AnyObject
    
        http.PUT(path, parameters: params) { _, error, success in
            if success {
                completion(true, nil)
            } else {
                completion(false, "Cannot not update the media message at the moment")
            }
        }
    }
    
    func blockUserForChat(_ userID: String, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let path = "/api/v1/chatuser/blockbyexternalappuserid"
        var params: [String: AnyObject] = ["externalAppUserId": userID as AnyObject]
        
        params["externalAppName"] = "miitv" as AnyObject
        
        http.POST(path, parameters: params) { data, error, success in
            if success {
                completion(true, nil)
                
            } else {
                completion(false, error!)
            }
        }
    }
    
    func unblockUserForChat(_ userID: String, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let path = "/api/v1/chatuser/unblockbyexternalappuserid"
        var params: [String: AnyObject] = ["externalAppUserId": userID as AnyObject]
        
        params["externalAppName"] = "miitv" as AnyObject
        
        http.POST(path, parameters: params) { data, error, success in
            if success {
                completion(true, nil)
                
            } else {
                completion(false, error!)
            }
        }
    }
    
    func updateDeviceTokenForChat(_ deviceToken: String, _ deviceType: Int, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let path = "/api/v1/userdeviceinfo/update"
        var params: [String: AnyObject] = ["deviceToken": deviceToken as AnyObject]
        params["deviceType"] = deviceType as AnyObject
        
        http.PUT(path, parameters: params) { _, error, success in
            if success {
                completion(true, nil)
            } else {
                completion(false, "Cannot not register for chat push notification at the moment")
            }
        }
    }
    
    func getChatInfo(chatId: String,completion:@escaping (_ success: Bool, _ error: String?, _ thread: ThreadInfo?) -> Void ) {
        let path = "/api/v1/chat/getchatinfo"
        let params = "?id=\(chatId)"
        http.GET(path, queryParams: params, parameters: [:]) { data, error, success in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    let unreadCount = data["unreadCount"] as? Int
                    if let data = data["chatGroup"] as? [String: AnyObject] {
                        
                        let thread = ThreadInfo(groupChatData: data, unreadCount: unreadCount ?? 0)
                        completion(true, nil, thread)
                    } else if let data = data["chatUser"] as? [String: AnyObject] {
                        let thread = ThreadInfo(userChatData: data, unreadCount: unreadCount ?? 0, chatId: chatId)
                        completion(true, nil, thread)
                    }
                    
                } else {
                    completion(false, error, nil)
                }
            } else {
                completion(false, error, nil)
            }
        }
    }
    
    func getChatNotificationSetting(completion:@escaping (_ success: Bool, _ error: String?, _ thread: ThreadInfo?) -> Void) {
        let path = "/api/v1/chatsettings/getuserchatsettings"
        http.GET(path, queryParams: "", parameters: [:]) { data, error, success in
            if success {
               
                completion(true, error, nil)
                
            } else {
                completion(false, error, nil)
            }
        }
    }
    
    func updateChatNotificationSetting(settingType: String, isEnabled: Bool, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let path = "/api/v1/chatsettings/update"
        var params: [String: AnyObject] = ["settingType": settingType as AnyObject]
        params["isEnabled"] = isEnabled as AnyObject
     
        
        http.PUT(path, parameters: params) { _, error, success in
            if success {
                completion(true, nil)
            } else {
                completion(false, "Cannot not update the chat setting at the moment")
            }
        }
    }
    
    func updateUserProfilePicture(profilePicUrl: String, externalUserID: String, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let path = "/api/v1/user/updateprofileurlexternaluser"
        var params: [String: AnyObject] = ["profileUrl": profilePicUrl as AnyObject]
        params["externalUserAppName"] = "miitv" as AnyObject
        params["externalUserId"] = externalUserID as AnyObject
        http.PUT(path, parameters: params, isAuth: true) { data, error, success in
            if success {
                completion(true, nil)
            } else {
                completion(false, "Cannot not update the chat setting at the moment")
            }
        }
        
    }
    
}

struct ChatMessageRequest: Codable {
    let chatMessageId: String
    let metaDatas: [MetaData]

    struct MetaData: Codable {
        let metaKey: String
        let metaValue: String
    }
}
