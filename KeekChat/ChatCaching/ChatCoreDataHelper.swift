//
//  ChatCoreDataHelper.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 31/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Foundation
import CoreData
import UIKit

class ChatCoreDataHelper: NSObject {
    
    static let sharedChatDBHelper = ChatCoreDataHelper()
    var mainMOC: NSManagedObjectContext!
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "ChatDataModel")
        container.persistentStoreDescriptions.append(storeDescription)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            self.mainMOC = container.viewContext
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var storeDescription: NSPersistentStoreDescription = {
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true
        return storeDescription
    }()
    
    // MARK: - Core Data Saving support
    func saveContext (context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                do {
                    try self.mainMOC.save()
                } catch {
                    print(error.localizedDescription)
                }
            } catch {
                let nserror = error as NSError
                print(nserror.localizedDescription)
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func clearAllData() {
        
        // Create a fetch request for each entity in the Core Data model
        let entityNames = persistentContainer.managedObjectModel.entities.map { $0.name! }
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            // Create a batch delete request to delete all objects for the current entity
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            // Perform the batch delete request
            do {
                try persistentContainer.viewContext.execute(batchDeleteRequest)
            } catch {
                print("Error deleting objects for entity '\(entityName)': \(error)")
            }
        }
        
        // Save the changes to the persistent store
        do {
            try persistentContainer.viewContext.save()
            
        } catch {
            print("Error saving changes: \(error)")
        }
        
    }
    
    func saveAll() {
        do {
            try self.mainMOC.save()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}

extension ChatCoreDataHelper {
    // MARK: - Manage Private Conversations
    
    // Get private chat list
    
    func getPrivateThreads() -> [PrivateConversation] {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sentDateTimeMilliSeconds", ascending: false)]
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            return objects
        } catch {
            print("Failed to fetch PrivateConversation")
            return []
        }
    }
    
    // Get list of private chat messages
    
    func getChatMessages(threadID: String) -> [PrivateChatMessages] {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateChatMessages>.init(entityName: "PrivateChatMessages")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "messageTime", ascending: false)]
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            return objects
        } catch {
            print("Failed to fetch PrivateChatMessages")
            return []
        }
    }
    
    func addMediaUploadLog(messageId: String, mediaUrl: String, uploadState: String) {
        let log = MediaUploadLog(context: self.mainMOC)
        log.messageId = messageId
        log.mediaPath = mediaUrl
        log.uploadState = uploadState
        do {
            try mainMOC.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateMediaLogState(MsgId: String, uploadState: String) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<MediaUploadLog>.init(entityName: "MediaUploadLog")
        fetchRequest.predicate = NSPredicate(format: "messageId == %@", MsgId)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let media = objects[0]
            media.uploadState = uploadState
            do {
                try self.mainMOC.save()
            } catch {
                print("\(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteMediaUploadLog(messageID: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MediaUploadLog")
        fetchRequest.predicate = NSPredicate(format: "messageId == %@", messageID)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.mainMOC.execute(batchDeleteRequest)
            
        } catch {
            print("Failed to delete Chat message")
            
        }
    }
    
    func getMediaUploadLog() -> [MediaUploadLog] {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest<MediaUploadLog>.init(entityName: "MediaUploadLog")
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            return objects
        } catch {
            print("Failed to fetch PrivateChatMessages")
            return []
        }
    }
    
    // Add private chat message
    
    func addChatMsg(chatMessage: ChatMessage, atBeginning: Bool = false) {
        let message = PrivateChatMessages(context: self.mainMOC)
        message.threadID = chatMessage.threadID
        message.messageID = chatMessage.messageId
        message.messageTime = chatMessage.messageTime
        message.messageText = chatMessage.messageText
        message.thumbnailImageUrl = chatMessage.thumbnailImageUrl
        message.mainImageUrl = chatMessage.mainImageUrl
        message.userAvatarUrl = chatMessage.userAvatarUrl
        message.userName = chatMessage.userName
        message.userId = chatMessage.userId
        message.imageHeight = Int16(chatMessage.imageHeight)
        message.imageWidth = Int16(chatMessage.imageWidth)
        message.isDeletedMessage = chatMessage.isDeleted
        message.isRead = chatMessage.isRead
        message.sentDateTimeMilliSeconds = chatMessage.messageTimeSecs
        message.externalUserId = chatMessage.externalUserId
        message.isDeletedMessage = chatMessage.isDeleted
        message.threadType = chatMessage.threadType
        message.isReadByMe = chatMessage.isReadByMe
        message.messageType = Int16(chatMessage.messageType)
        message.postId = chatMessage.postId
        do {
            try mainMOC.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func parsePrivateThreadMessages(_ messages: [[String: AnyObject]], threadType: String) {
        mainMOC.perform { [self] in
            for params in messages {
                let message = PrivateChatMessages(context: self.mainMOC)
                message.messageID = params["id"] as? String ?? ""
                if let sentTime = params["sentDateTime"] as? String {
                    message.messageTime = sentTime
                    message.sentDateTimeMilliSeconds = Int64(UIUtil.convertDateStringToMilliseconds(dateString: sentTime) ?? 0)
                }
                message.messageText = params["message"] as? String ?? ""
                message.userAvatarUrl = params["user"]?["dpUrl"] as? String ?? ""
                message.userName = params["user"]?["userName"] as? String ?? ""
                message.userId = params["user"]?["id"] as? String ?? ""
                message.threadID = params["chatId"] as? String ?? ""
                if let v = params["isRead"] as? NSNumber {
                    message.isRead = v.boolValue
                }
                if let v = params["isReadByMe"] as? NSNumber {
                    message.isReadByMe = v.boolValue
                }
                message.externalUserId = params["user"]?["externalUserId"] as? String ?? ""
                if let v = params["recordStatus"] as? NSNumber {
                    message.isDeletedMessage = v.boolValue
                }
                message.messageType = params["messageType"] as? Int16 ?? 0
                message.threadType = threadType
                if message.messageType == 3 && message.messageText == GroupInfoMsgType.MemberAdded.rawValue {
                    if let user = params["toUser"] as? [String: AnyObject] {
                        var memberUsername = user["userName"] as? String ?? ""
                        if memberUsername == ChatModel.sharedInstance.users.username {
                            message.messageText = "@\(message.userName ?? "") " + "addedYou".localized
                        } else if message.userName == ChatModel.sharedInstance.users.username {
                            message.messageText = "youAdded".localized + " @\(memberUsername)"
                        } else {
                            message.messageText = "@\(message.userName ?? "") " + "added".localized + " @\(memberUsername)"
                        }
                    }
                    
                } else if message.messageType == 3 && message.messageText == GroupInfoMsgType.MemberRemoved.rawValue{
                    if let user = params["toUser"] as? [String: AnyObject] {
                        var memberUsername = user["userName"] as? String ?? ""
                        if memberUsername == ChatModel.sharedInstance.users.username {
                            message.messageText = "@\(message.userName ?? "") " + "removedYou".localized
                        } else if message.userName == ChatModel.sharedInstance.users.username {
                            message.messageText = "youRemoved".localized + " @\(memberUsername)"
                        } else {
                            message.messageText = "@\(message.userName ?? "") " + "removed".localized + " @\(memberUsername)"
                        }
                    }
                }
                
                if message.messageType == 1 {
               
                    if let metaDatas = params["metaDatas"] as? [[String: AnyObject]] {
                        for metaData in metaDatas {
                        if let metaKey = metaData["metaKey"] as? String,
                           let metaValue = metaData["metaValue"] {
                            
                            switch metaKey {
                            case "url_original":
                                message.mainImageUrl = metaValue as? String
                                
                            case "url_thumbnail":
                                message.thumbnailImageUrl = metaValue as? String
                            case "height":
                                message.imageHeight = metaValue as? Int16 ?? 0
                            case "width":
                                message.imageWidth = metaValue as? Int16 ?? 0
                            case "post_id":
                                message.postId = metaValue as? String
                            default:
                                break
                            }
                        }
                    }
                    }
                }
                self.saveContext()
                
            }
        }
    }
    
    func saveContext() {
        do {
            try mainMOC.save()
        } catch {
            print("Core Data save error: \(error)")
        }
    }
    
    func updateChatMsgReadStatus(MsgId: String, isRead: Bool = true, isReadByMe: Bool) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateChatMessages>.init(entityName: "PrivateChatMessages")
        fetchRequest.predicate = NSPredicate(format: "messageID == %@", MsgId)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let msg = objects[0]
            if isRead && msg.isRead != isRead && msg.threadType == "oneToOne" {
                self.updatePrivateThreadUnreadCount(threadId: msg.threadID ?? "", lastMsgID: MsgId, isRead: true)
            } else if isReadByMe && msg.isReadByMe != isReadByMe && msg.threadType == "group" {
                self.updateGroupThreadUnreadCount(threadId: msg.threadID ?? "", lastMsgID: MsgId, isRead: true)
            }
            msg.isRead = isRead
            msg.isReadByMe = isReadByMe
            do {
                try self.mainMOC.save()
            } catch {
                print("\(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateChatMsgMedia(MsgId: String, message: ChatMessage) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateChatMessages>.init(entityName: "PrivateChatMessages")
        fetchRequest.predicate = NSPredicate(format: "messageID == %@", MsgId)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let msg = objects[0]
            msg.thumbnailImageUrl = message.thumbnailImageUrl
            msg.mainImageUrl = message.mainImageUrl
            msg.imageHeight = Int16(message.imageHeight)
            msg.imageWidth = Int16(message.imageWidth)
            do {
                try self.mainMOC.save()
            } catch {
                print("\(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Add Private thread
    
    func addPrivateThread(params: [String: AnyObject]) {
        let threadID = params["chatId"] as? String ?? ""
        if !self.checkIfPrivateThreadExists(threadID: threadID) {
            let thread = PrivateConversation(context: self.mainMOC)
            thread.threadID = params["chatId"] as? String ?? ""
            thread.userID = params["user"]?["id"] as? String ?? ""
            thread.userName = params["user"]?["userName"] as? String ?? ""
            thread.userAvatarUrl = params["user"]?["dpUrl"] as? String ?? ""
            thread.unreadMsgCount = params["unreadMessageCount"] as? Int16 ?? 0
            if let sentTime = params["message"]?["sentDateTime"] as? String {
                thread.lastMsgTime = sentTime
            }
            thread.lastMsgText = params["message"]?["message"] as? String ?? ""
            thread.lastMsgID = params["message"]?["id"] as? String ?? ""
            thread.sentDateTimeMilliSeconds = params["message"]?["sentDateTimeMilliSeconds"] as? Int64 ?? 0
            thread.userStatus = params["user"]?["userStatus"] as? String ?? ""
            if let v = params["message"]?["recordStatus"] as? NSNumber {
                thread.lastMsgIsDeleted = v.boolValue
            }
            thread.lastMsgType = params["message"]?["messageType"] as? Int16 ?? 0
            if thread.lastMsgType == 1 {
                if thread.lastMsgText == "VIDEO" {
                    thread.lastMsgText = "Video"
                } else if thread.lastMsgText == EMessageShareType.stream.geteMessageType() {
                    thread.lastMsgText = "Stream"
                } else {
                    thread.lastMsgText = "Photo"
                }
            }
            thread.extAppUserId = params["user"]?["externalUserId"] as? String ?? ""
            do {
                try mainMOC.save()
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addPrivateThread(tempThread: ThreadInfo) {
        let thread = PrivateConversation(context: self.mainMOC)
        thread.threadID = tempThread.threadID
        thread.userID = tempThread.userID
        thread.userName = tempThread.userName
        thread.userStatus = tempThread.userStatus
        thread.isBlocked = tempThread.isBlocked
        thread.userAvatarUrl = tempThread.userAvatarUrl
        do {
            try mainMOC.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func parsePrivateThreads(_ threads: [[String: AnyObject]]) {
        mainMOC.perform { [self] in
            for params in threads {
                let threadID = params["chatId"] as? String ?? ""
                if !self.checkIfPrivateThreadExists(threadID: threadID) {
                    let thread = PrivateConversation(context: self.mainMOC)
                    
                    thread.threadID = params["chatId"] as? String ?? ""
                    thread.userID = params["user"]?["id"] as? String ?? ""
                    thread.userName = params["user"]?["userName"] as? String ?? ""
                    thread.userAvatarUrl = params["user"]?["dpUrl"] as? String ?? ""
                    thread.unreadMsgCount = params["unreadMessageCount"] as? Int16 ?? 0
                    if let sentTime = params["message"]?["sentDateTime"] as? String {
                        thread.lastMsgTime = sentTime
                    }
                    thread.lastMsgText = params["message"]?["message"] as? String ?? ""
                    thread.lastMsgID = params["message"]?["id"] as? String ?? ""
                    thread.sentDateTimeMilliSeconds = params["message"]?["sentDateTimeMilliSeconds"] as? Int64 ?? 0
                    thread.userStatus = params["user"]?["userStatus"] as? String ?? ""
                    if let v = params["message"]?["recordStatus"] as? NSNumber {
                        thread.lastMsgIsDeleted = v.boolValue
                    }
                    thread.lastMsgType = params["message"]?["messageType"] as? Int16 ?? 0
                    if thread.lastMsgType == 1 {
                        if thread.lastMsgText == "VIDEO" {
                            thread.lastMsgText = "Video"
                        } else if thread.lastMsgText == EMessageShareType.stream.geteMessageType() {
                            thread.lastMsgText = "Stream"
                        } else {
                            thread.lastMsgText = "Photo"
                        }
                    }
                    
                    if let x = params["isBlockedByMe"] as? NSNumber {
                        thread.isBlocked = x.boolValue
                    }
                    thread.extAppUserId = params["user"]?["externalUserId"] as? String ?? ""
                    self.saveContext()
            }
            }
        }
    }
    
    func checkIfPrivateThreadExists(threadID: String) -> Bool {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return false
            } else {
                return true
            }
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    func markUserBlocked(extAppUserId: String) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "extAppUserId == %@", extAppUserId)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            thread.isBlocked = true
            do {
                try self.mainMOC.save()
                NotificationCenter.default.post(name: Notification.Name("UserWasBlocked"), object: nil, userInfo: ["threadID": thread.threadID])
            } catch {
                print("\(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func markUserUnBlocked(extAppUserId: String) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "extAppUserId == %@", extAppUserId)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            thread.isBlocked = false
            do {
                try self.mainMOC.save()
                NotificationCenter.default.post(name: Notification.Name("UserWasUnblocked"), object: nil, userInfo: ["threadID": thread.threadID])
            } catch {
                print("\(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func addTotalMsgCountPrivateThreads(threadID: String, totalMsgCount: Int) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            thread.totalMsgCount = Int16(totalMsgCount)
            do {
                try self.mainMOC.save()
            } catch {
                print("\(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateUnreadMsgCountPrivateThreads(threadID: String) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            if thread.unreadMsgCount > 0 {
                thread.unreadMsgCount -= 1
            }
            do {
                try self.mainMOC.save()
            } catch {
                print("\(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getUnreadMsgCountPrivateThreads(threadID: String) -> Int {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return 0
            }
            let thread = objects[0]
            return Int(thread.unreadMsgCount)
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
    
    func getUnreadMsgCountGroupThreads(threadID: String) -> Int {
        let fetchRequest: NSFetchRequest = NSFetchRequest<GroupConversation>.init(entityName: "GroupConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return 0
            }
            let thread = objects[0]
            return Int(thread.unreadMsgCount)
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
    
    func checkIfLastMsgDeleted(threadID: String, messageIds: [String]) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                self.checkIfLastMsgDeletedGroup(threadID: threadID, messageIds: messageIds)
                return
            }
            let thread = objects[0]
            if let lastMsgID = thread.lastMsgID, messageIds.contains(lastMsgID) {
                // The last message ID is in the array
                NotificationCenter.default.post(name: Notification.Name("LastPrivateMessageDeleted"), object: nil, userInfo: nil)
            } else {
                self.checkIfChatHasMoreMessages(threadID: threadID, threadType: "oneToOne")
            }
           
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateUnreadMsgCountGroupThreads(threadID: String) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<GroupConversation>.init(entityName: "GroupConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            if thread.unreadMsgCount > 0 {
                thread.unreadMsgCount -= 1
            }
            do {
                try self.mainMOC.save()
            } catch {
                print("\(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateUserStatusPrivateThreads(userID: String, userStatus: String) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            thread.userStatus = userStatus
            do {
                try self.mainMOC.save()
            } catch {
                print("\(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func markAllReadPrivateThreads(threadID: String) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            
            thread.unreadMsgCount = 0
            
            do {
                try self.mainMOC.save()
            } catch {
                print("\(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getTotalMsgCountPrivateThreads(threadID: String) -> Int {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return 0
            }
            let thread = objects[0]
            return Int(thread.totalMsgCount)
        } catch {
            print(error.localizedDescription)
        }
        return 0
    }
    
    // Delete private chat message
    
    func checkIfChatHasMessages(threadID: String, threadType: String) -> Bool {
        var unreadMsgCount = 0
        if threadType == "oneToOne" {
            unreadMsgCount = self.getTotalMsgCountPrivateThreads(threadID: threadID)
        } else {
            unreadMsgCount = self.getUnreadMsgCountGroupThreads(threadID: threadID)
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PrivateChatMessages")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count < unreadMsgCount + 5 {
                return false
            }
           return true
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    func checkIfChatHasMoreMessages(threadID: String, threadType: String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PrivateChatMessages")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count < 10 {
                self.getChatMessages(threadID: threadID, threadType: threadType)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getChatMessages(threadID: String, threadType: String) {
        let currentDate = Utils.convertDateToISODate(Date())
        
        ChatCacheManager.shared.getPrivateChatMessages(threadId: threadID, isRefresh: true, messageUpto: currentDate, pageNo: 1, pageSize: 10, threadType: threadType) { success, error, messages, totalMsgCount in
            
        }
    }
    
    func deletePrivateChatMsg(messageID: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PrivateChatMessages")
        fetchRequest.predicate = NSPredicate(format: "messageID == %@", messageID)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.mainMOC.execute(batchDeleteRequest)
            
        } catch {
            print("Failed to delete Chat message")
            
        }
    }
    
    func updateUnreadCountOnDelete(messageID: String) {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateChatMessages>.init(entityName: "PrivateChatMessages")
        fetchRequest.predicate = NSPredicate(format: "messageID == %@", messageID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let msg = objects[0]
            
            if !msg.isReadByMe {
                if msg.threadType == "oneToOne" {
                    self.updatePrivateThreadUnreadCount(threadId: msg.threadID ?? "", lastMsgID: messageID, isRead: true)
                    
                } else {
                    self.updateGroupThreadUnreadCount(threadId: msg.threadID ?? "", lastMsgID: messageID, isRead: true)
                }
                NotificationCenter.default.post(name: Notification.Name("UnreadMsgWasDeleted"), object: nil, userInfo: ["threadId": msg.threadID ?? ""])
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteAllPrivateChatMsg(threadID: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PrivateChatMessages")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.mainMOC.execute(batchDeleteRequest)
            
        } catch {
            print("Failed to delete Chat message")
            
        }
    }
    // Delete oldest private chat message
    
    func deleteOldestPrivateChatMsg(threadID: String, threadType: String) {
        if self.checkIfChatHasMessages(threadID: threadID, threadType: threadType) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PrivateChatMessages")
            fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "messageTime", ascending: true)]
            fetchRequest.fetchLimit = 1
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try self.mainMOC.execute(batchDeleteRequest)
            } catch {
                print("Failed to fetch PrivateChatMessages")
                
            }
        }
    }
    
    // Delete private conversation thread
    
    func deletePrivateThread(threadID: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.mainMOC.execute(batchDeleteRequest)
            
        } catch {
            print("Failed to delete Chat message")
            
        }
    }
    
    func deleteAllPrivateThread() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PrivateConversation")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try mainMOC.execute(batchDeleteRequest)
            
            // Save the changes to the managed object context
            try mainMOC.save()
            
        } catch {
            print("Failed")
        }
    }
    
    // Manage Cached messages on receiveing new message
    
    func managePrivateChatMessages(chatMessage: ChatMessage) {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", chatMessage.threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count > 0 {
                let thread = objects[0]
                if thread.unreadMsgCount > 0 {
                    // Store all unread messages
                    self.addChatMsg(chatMessage: chatMessage)
                } else {
                    // Delete the oldest message
                    self.deleteOldestPrivateChatMsg(threadID: thread.threadID ?? "", threadType: chatMessage.threadType)
                    // Add the new received message
                    self.addChatMsg(chatMessage: chatMessage, atBeginning: true)
                }
                if chatMessage.threadType == "oneToOne" {
                    self.updatePrivateThread(msg: chatMessage)
                }
            } else {
                NotificationCenter.default.post(name: Notification.Name("UpdatePrivateThreadList"), object: nil)
            }
        } catch {
            print("Failed to fetch PrivateConversation")
        }
    }
    
    func manageGroupChatMessages(chatMessage: ChatMessage) {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest<GroupConversation>.init(entityName: "GroupConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", chatMessage.threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count > 0 {
                let thread = objects[0]
                if thread.unreadMsgCount > 0 {
                    // Store all unread messages
                    self.addChatMsg(chatMessage: chatMessage)
                } else {
                    // Delete the oldest message
                    self.deleteOldestPrivateChatMsg(threadID: thread.threadID ?? "", threadType: chatMessage.threadType)
                    // Add the new received message
                    self.addChatMsg(chatMessage: chatMessage, atBeginning: true)
                }
                if chatMessage.threadType == "group" {
                    self.updateGroupThread(msg: chatMessage)
                }
            } else {
                NotificationCenter.default.post(name: Notification.Name("UpdateGroupThreadList"), object: nil)
            }
        } catch {
            print("Failed to fetch PrivateConversation")
        }
    }
    
    // Update private thread
    
    func updatePrivateThread(msg: ChatMessage) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", msg.threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            thread.lastMsgText = msg.messageText
            thread.lastMsgTime = msg.messageTime
            thread.lastMsgID = msg.messageId
            thread.sentDateTimeMilliSeconds = Int64(UIUtil.convertDateStringToMilliseconds(dateString: msg.messageTime) ?? 0)
            if msg.externalUserId != ChatModel.sharedInstance.userId {
                thread.unreadMsgCount += 1
            }
            thread.lastMsgType = Int16(msg.messageType)
            if thread.lastMsgType == 1 {
                if msg.postId != "" {
                    if thread.lastMsgText == EMessageShareType.stream.geteMessageType() {
                        thread.lastMsgText = "Stream"
                    } else {
                        thread.lastMsgText = "Video"
                    }
                } else {
                    thread.lastMsgText = "Photo"
                }
            }
            do {
                try self.mainMOC.save()
                NotificationCenter.default.post(name: Notification.Name("ReceivedNewMessagePrivateThread"), object: nil)
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updatePrivateThreadUnreadCount(threadId: String, lastMsgID: String, isRead: Bool) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateConversation>.init(entityName: "PrivateConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadId)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            if thread.lastMsgID == lastMsgID && isRead {
                thread.unreadMsgCount = 0
            } else {
                if thread.unreadMsgCount != 0 {
                    thread.unreadMsgCount -= 1
                }
            }
            
            do {
                try self.mainMOC.save()
                NotificationCenter.default.post(name: Notification.Name("UpdateUnreadCount"), object: nil, userInfo: ["threadId": threadId])
//                NotificationCenter.default.post(name: Notification.Name("ReceivedNewMessagePrivateThread"), object: nil)
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateGroupThreadUnreadCount(threadId: String, lastMsgID: String, isRead: Bool) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<GroupConversation>.init(entityName: "GroupConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadId)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            if thread.lastMsgID == lastMsgID && isRead {
                thread.unreadMsgCount = 0
            } else {
                if thread.unreadMsgCount != 0 {
                    thread.unreadMsgCount -= 1
                }
            }
            
            do {
                try self.mainMOC.save()
                NotificationCenter.default.post(name: Notification.Name("UpdateUnreadCount"), object: nil, userInfo: ["threadId": threadId])
//                NotificationCenter.default.post(name: Notification.Name("ReceivedNewMessagePrivateThread"), object: nil)
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func checkIfPrivateThreadIsUpdated(threadID: String, lastMsgID: String) -> Bool {
        let fetchRequest: NSFetchRequest = NSFetchRequest<PrivateChatMessages>.init(entityName: "PrivateChatMessages")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            
            let msg = objects.first
            if msg?.messageID == lastMsgID {
                return true
            } else {
                return false
            }
        } catch {
            print("Failed to fetch PrivateChatMessages")
            return false
        }
    }
    
    // MARK: - Manage Group Conversations
    
    // Get group chat list
    
    func getGroupThreads() -> [GroupConversation] {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest<GroupConversation>.init(entityName: "GroupConversation")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sentDateTimeMilliSeconds", ascending: false)]
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            return objects
        } catch {
            print("Failed to fetch GroupConversation")
            return []
        }
    }
    
    // Add Group thread
    
    func addGroupThread(params: [String: AnyObject]) {
        let threadID = params["chatId"] as? String ?? ""
        if !self.checkIfPrivateThreadExists(threadID: threadID) {
            let thread = GroupConversation(context: self.mainMOC)
            
            thread.threadID = params["chatId"] as? String ?? ""
            thread.groupID = params["id"] as? String ?? ""
            thread.groupName = params["groupName"] as? String ?? ""
            thread.groupAvatarUrl = params["dpUrl"] as? String ?? ""
            thread.unreadMsgCount = params["unreadMessageCount"] as? Int16 ?? 0
            if let sentTime = params["message"]?["sentDateTime"] as? String {
                thread.lastMsgTime = sentTime
            }
            
            thread.lastMsgID = params["message"]?["id"] as? String ?? ""
            thread.sentDateTimeMilliSeconds = params["message"]?["sentDateTimeMilliSeconds"] as? Int64 ?? 0
            thread.lastMsgText = params["message"]?["message"] as? String ?? ""
            
            thread.adminUserName = params["groupCreatedBy"]?["userName"] as? String ?? ""
            thread.adminChatId = params["groupCreatedBy"]?["id"] as? String ?? ""
            thread.adminExtUserId = params["groupCreatedBy"]?["externalUserId"] as? String ?? ""
            thread.lastMsgType = params["message"]?["messageType"] as? Int16 ?? 0
            if thread.lastMsgType == 3 && thread.lastMsgText == GroupInfoMsgType.MemberAdded.rawValue {
                if let user = params["message"]?["toUser"] as? [String: AnyObject] {
                    var memberUsername = user["userName"] as? String ?? ""
                    thread.lastMsgText = "@\(memberUsername) was Added"
                }
            } else if thread.lastMsgType == 3 && thread.lastMsgText == GroupInfoMsgType.MemberRemoved.rawValue{
                if let user = params["message"]?["toUser"] as? [String: AnyObject] {
                    var memberUsername = user["userName"] as? String ?? ""
                    thread.lastMsgText = "@\(memberUsername) was Removed"
                }
            }
            if let v = params["isActive"] as? NSNumber {
                thread.isActive = v.boolValue
            }
            self.saveContext()
        }
    }
    
    func parseGroupThreads(_ threads: [[String: AnyObject]]) {
        mainMOC.perform { [self] in
            for params in threads {
                let threadID = params["chatId"] as? String ?? ""
                if !self.checkIfPrivateThreadExists(threadID: threadID) {
                let thread = GroupConversation(context: self.mainMOC)
                
                thread.threadID = params["chatId"] as? String ?? ""
                thread.groupID = params["id"] as? String ?? ""
                thread.groupName = params["groupName"] as? String ?? ""
                thread.groupAvatarUrl = params["dpUrl"] as? String ?? ""
                thread.unreadMsgCount = params["unreadMessageCount"] as? Int16 ?? 0
                if let sentTime = params["message"]?["sentDateTime"] as? String {
                    thread.lastMsgTime = sentTime
                }
                thread.lastMsgID = params["message"]?["id"] as? String ?? ""
                thread.sentDateTimeMilliSeconds = params["message"]?["sentDateTimeMilliSeconds"] as? Int64 ?? 0
                thread.lastMsgText = params["message"]?["message"] as? String ?? ""
                thread.adminUserName = params["groupCreatedBy"]?["userName"] as? String ?? ""
                thread.adminChatId = params["groupCreatedBy"]?["id"] as? String ?? ""
                thread.adminExtUserId = params["groupCreatedBy"]?["externalUserId"] as? String ?? ""
                thread.lastMsgType = params["message"]?["messageType"] as? Int16 ?? 0
                if thread.lastMsgType == 3 && thread.lastMsgText == GroupInfoMsgType.MemberAdded.rawValue {
                    if let user = params["message"]?["toUser"] as? [String: AnyObject] {
                        let memberUsername = user["userName"] as? String ?? ""
                        if memberUsername == ChatModel.sharedInstance.users.username {
                            thread.lastMsgText = "@\(thread.adminUserName ?? "") " + "addedYou".localized
                        } else if thread.adminUserName == ChatModel.sharedInstance.users.username {
                            thread.lastMsgText = "youAdded".localized + " @\(memberUsername)"
                        } else {
                            thread.lastMsgText = "@\(thread.adminUserName ?? "") " + "added".localized + " @\(memberUsername)" 
                        }
                    }
                } else if thread.lastMsgType == 3 && thread.lastMsgText == GroupInfoMsgType.MemberRemoved.rawValue {
                    if let user = params["message"]?["toUser"] as? [String: AnyObject] {
                        let memberUsername = user["userName"] as? String ?? ""
                        if memberUsername == ChatModel.sharedInstance.users.username {
                            thread.lastMsgText = "@\(thread.adminUserName ?? "") " + "removedYou".localized
                        } else if thread.adminUserName == ChatModel.sharedInstance.users.username {
                            thread.lastMsgText = "youRemoved".localized + " @\(memberUsername)"
                        } else {
                            thread.lastMsgText = "@\(thread.adminUserName ?? "") " + "removed".localized + " @\(memberUsername)" 
                        }
                    }
                } else if thread.lastMsgType == 1 {
                    if thread.lastMsgText == "VIDEO" {
                        thread.lastMsgText = "Video"
                    } else if thread.lastMsgText == EMessageShareType.stream.geteMessageType() {
                        thread.lastMsgText = "Stream"
                    } else {
                        thread.lastMsgText = "Photo"
                    }
                }
                if thread.lastMsgType != 3 {
                    if let user = params["message"]?["user"] as? [String: AnyObject] {
                        let memberUsername = user["userName"] as? String ?? ""
                        if memberUsername == ChatModel.sharedInstance.users.username {
                            thread.lastMsgText = "You: \(thread.lastMsgText ?? "")"
                        } else {
                            thread.lastMsgText = "@\(memberUsername): \(thread.lastMsgText ?? "")"
                        }
                    }
                }
                if let v = params["isActive"] as? NSNumber {
                    thread.isActive = v.boolValue
                }
                self.saveContext()
            }
            }
        }
    }
    
    func checkIfGroupThreadExists(threadID: String) -> Bool {
        let fetchRequest: NSFetchRequest = NSFetchRequest<GroupConversation>.init(entityName: "GroupConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return false
            } else {
                return true
            }
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    func markAllReadGroupThreads(threadID: String) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<GroupConversation>.init(entityName: "GroupConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            
            thread.unreadMsgCount = 0
            
            do {
                try self.mainMOC.save()
            } catch {
                print("\(error.localizedDescription)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addGroupThread(groupThread: ThreadInfo) {
        let thread = GroupConversation(context: self.mainMOC)
        thread.isBlocked = groupThread.isRemoved
        thread.isDeletedChat = groupThread.isDeleted
        thread.lastMsgText = groupThread.lastMsgText
        thread.lastMsgTime = groupThread.lastMsgTime
        thread.threadID = groupThread.threadID
        thread.unreadMsgCount = Int16(groupThread.unreadMsgCount)
        thread.groupAvatarUrl = groupThread.userAvatarUrl
        thread.groupID = groupThread.groupId
        thread.groupName = groupThread.userName
        thread.lastMsgID = groupThread.lastMsgID
        thread.isActive = groupThread.isActive
        do {
            try mainMOC.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteAllGroupThread() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupConversation")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try mainMOC.execute(batchDeleteRequest)
            
            // Save the changes to the managed object context
            try mainMOC.save()
            
        } catch {
            print("Failed")
        }
    }
    
    // Delete group conversation thread
    
    func deleteGroupThread(threadID: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.mainMOC.execute(batchDeleteRequest)
            
        } catch {
            print("Failed to delete Chat message")
        }
    }
    
    // Update group thread
    
    func updateGroupThread(msg: ChatMessage) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<GroupConversation>.init(entityName: "GroupConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", msg.threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            thread.lastMsgText = msg.messageText
            thread.lastMsgTime = msg.messageTime
            thread.lastMsgID = msg.messageId
            thread.sentDateTimeMilliSeconds = Int64(UIUtil.convertDateStringToMilliseconds(dateString: msg.messageTime) ?? 0)
            if msg.externalUserId != ChatModel.sharedInstance.userId {
                thread.unreadMsgCount += 1
            }
            thread.lastMsgType = Int16(msg.messageType)
            if thread.lastMsgType == 1 {
                if thread.lastMsgText == "VIDEO" {
                    thread.lastMsgText = "Video"
                } else if thread.lastMsgText == EMessageShareType.stream.geteMessageType() {
                    thread.lastMsgText = "Stream"
                } else {
                    thread.lastMsgText = "Photo"
                }
            }
            if thread.lastMsgType != 3 {
                let memberUsername = msg.userName
                if memberUsername == ChatModel.sharedInstance.users.username {
                    thread.lastMsgText = "You: \(thread.lastMsgText ?? "")"
                } else {
                    thread.lastMsgText = "@\(memberUsername): \(thread.lastMsgText ?? "")"
                }
            
        }
            do {
                try self.mainMOC.save()
                NotificationCenter.default.post(name: Notification.Name("ReceivedNewMessageGroupThread"), object: nil)
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateGroupThread(threadId: String, groupName: String, dpUrl: String) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<GroupConversation>.init(entityName: "GroupConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadId)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                
                NotificationCenter.default.post(name: Notification.Name("GroupWasEdited"), object: nil)
                return
            }
            let thread = objects[0]
            thread.groupName = groupName
            thread.groupAvatarUrl = dpUrl
            
            do {
                try self.mainMOC.save()
                NotificationCenter.default.post(name: Notification.Name("GroupWasEdited"), object: nil)
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            NotificationCenter.default.post(name: Notification.Name("GroupWasEdited"), object: nil)
            print(error.localizedDescription)
        }
    }
    
    func checkIfLastMsgDeletedGroup(threadID: String, messageIds: [String]) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<GroupConversation>.init(entityName: "GroupConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            if let lastMsgID = thread.lastMsgID, messageIds.contains(lastMsgID) {
                // The last message ID is in the array
                NotificationCenter.default.post(name: Notification.Name("LastGroupMessageDeleted"), object: nil, userInfo: nil)
            } else {
                self.checkIfChatHasMoreMessages(threadID: threadID, threadType: "group")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateGroupThread(groupThread: ThreadInfo) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<GroupConversation>.init(entityName: "GroupConversation")
        fetchRequest.predicate = NSPredicate(format: "threadID == %@", groupThread.threadID)
        do {
            let objects = try self.mainMOC.fetch(fetchRequest)
            if objects.count == 0 {
                return
            }
            let thread = objects[0]
            thread.isBlocked = groupThread.isRemoved
            thread.isDeletedChat = groupThread.isDeleted
            thread.lastMsgText = groupThread.lastMsgText
            thread.lastMsgTime = groupThread.lastMsgTime
            thread.threadID = groupThread.threadID
            thread.unreadMsgCount = Int16(groupThread.unreadMsgCount)
            thread.groupAvatarUrl = groupThread.userAvatarUrl
            thread.groupID = groupThread.groupId
            thread.groupName = groupThread.userName
            thread.lastMsgID = groupThread.lastMsgID
            do {
                try self.mainMOC.save()
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
