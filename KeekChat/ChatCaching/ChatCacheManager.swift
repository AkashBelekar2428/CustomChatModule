//
//  ChatCacheManager.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 30/08/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import Foundation
import Photos
import UIKit

class ChatCacheManager {
    static let shared = ChatCacheManager()
    
    func getPrivateThreads(isRefresh: Bool, timestamp: Int64, sendCachedData: Bool = false, shouldForceUpdate: Bool = false, isPullToRefresh: Bool = false, completion:@escaping (_ success: Bool, _ error: String?, _ threads: [ThreadInfo]?, _ isNewRefreshData: Bool) -> Void ) {
            
            if isRefresh && !isPullToRefresh {
                let threads =  self.getCachedPrivateThreads()
                
                if threads.count > 0 {
                    if sendCachedData {
                        completion(true, nil, threads, true)
                    } else {
                        completion(true, nil, threads, false)
                    }
                }
            }
            if sendCachedData {
                return
            }
            
            ChatConnector().getPrivateChats(isRefresh: isRefresh, timestamp: timestamp) { success, error, threads in
                if success {
                    
                    if isRefresh {
                        completion(true, nil, threads, true)
                        if let privateThreads = threads {
                            for thread in privateThreads {
                                    self.cachePrivateChatMsgs(thread: thread, shouldForceUpdate: shouldForceUpdate, threadType: "oneToOne")
                            }
                            ChatModel.sharedInstance.isUpdatingPrivateChat = false
                            NotificationCenter.default.post(name: Notification.Name("RefreshChatCacheDone"), object: nil)
                        }
                    } else {
                        completion(true, nil, threads, true)
                    }
                } else {
                    ChatModel.sharedInstance.isUpdatingPrivateChat = false
                    NotificationCenter.default.post(name: Notification.Name("RefreshChatCacheDone"), object: nil)
                    completion(false, error, nil, false)
                }
            }
            
        }
    
    func getCachedPrivateThreads() -> [ThreadInfo] {
        let threads =  ChatCoreDataHelper.sharedChatDBHelper.getPrivateThreads()
        var threadList: [ThreadInfo] = []
        
        if threads.count > 0 {
            for obj in threads {
                let thread = ThreadInfo(thread: obj)
                threadList.append(thread)
            }
        }
        
        return threadList
    }
    
    func getPrivateChatMessages(threadId: String, isRefresh: Bool, messageUpto: String, pageNo: Int, pageSize: Int = 10, threadType: String, completion:@escaping (_ success: Bool, _ error: String?, _ messages: [ChatMessage]?, _ totalMsgCount: Int?) -> Void) {
        
        var coreDataSent = false
        if isRefresh {
            let messages =  self.getCachedPrivateThreadMessages(threadID: threadId)
            
            if messages.count > 0 {
                let totalMsgCount = ChatCoreDataHelper.sharedChatDBHelper.getTotalMsgCountPrivateThreads(threadID: threadId)
                completion(true, nil, messages, totalMsgCount)
                coreDataSent = true
            }
        }
        
        ChatConnector().getChatMessages(chatId: threadId, messageUpto: messageUpto, page: pageNo, pageSize: pageSize, isRefresh: isRefresh, threadType: threadType) { success, error, messages, totalMsgCount in
                if success {
                    if !coreDataSent {
                        completion(true, nil, messages, totalMsgCount ?? 0)
                    }
                    
                } else {
                    completion(false, error, nil, nil)
                }
            }
    }
    
    func getCachedPrivateThreadMessages(threadID: String) -> [ChatMessage] {
        let messages =  ChatCoreDataHelper.sharedChatDBHelper.getChatMessages(threadID: threadID)
        var messageList: [ChatMessage] = []
        
        if messages.count > 0 {
            for obj in messages {
                let message = ChatMessage(message: obj)
                messageList.append(message)
            }
        }
        
        return messageList
    }
    
    func cachePrivateChatMsgs(thread: ThreadInfo, shouldForceUpdate: Bool, threadType: String) {
        if !ChatCoreDataHelper.sharedChatDBHelper.checkIfPrivateThreadIsUpdated(threadID: thread.threadID, lastMsgID: thread.lastMsgID) || shouldForceUpdate {
            let formattedDate = Utils.getFormattedTimeUTC(dateToFormat: Date())
            var pageSize = 10
            if thread.unreadMsgCount > 5 {
                pageSize = thread.unreadMsgCount + 5
            }
            ChatConnector().getChatMessages(chatId: thread.threadID, messageUpto: formattedDate, page: 1, pageSize: pageSize, isRefresh: true, threadType: threadType) { success, error, threads, totalMsgCount in
                if success {
                } else {
                }
            }
        }
    }
    
    func getLatestPrivateChatMessages(chatId: String, messageFrom: String, completion:@escaping (_ success: Bool, _ error: String?, _ threads: [ChatMessage]?) -> Void) {
        
        ChatConnector().getLatestChatMessages(chatId: chatId, messageFrom: messageFrom) { success, error, messages in
            
            if success {
                completion(success, error, messages)
            } else {
                print(error)
                completion(success, error, nil)
            }
        }
    }
    
    func getLatestPrivateChatMessagesStatus(chatId: String, modifiedDate: String, completion:@escaping (_ success: Bool, _ error: String?, _ threads: [ChatMessage]?) -> Void) {
        
        ChatConnector().getLatestChatMessagesStatus(chatId: chatId, modifiedDate: modifiedDate) { success, error, messages in
            
            if success {
                completion(success, error, messages)
            } else {
                completion(success, error, nil)
            }
        }
    }
    
    func deleteChatMessage(messageIds: [String], completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        ChatConnector().deleteChatMessage(messageIds: messageIds) { success, error in
            if success {
                    completion(true, nil)
                
            } else {
                completion(false, error)
            }
        }
    }
}

extension ChatCacheManager {
    func getGroupThreads(isRefresh: Bool, timestamp: Int64, sendCachedData: Bool = false, shouldForceUpdate: Bool = false, isPullToRefresh: Bool = false, completion:@escaping (_ success: Bool, _ error: String?, _ threads: [ThreadInfo]?, _ isNewRefreshData: Bool) -> Void ) {
        
        if isRefresh && !isPullToRefresh {
            let threads =  self.getCachedGroupThreads()
            
            if threads.count > 0 {
                if sendCachedData {
                    completion(true, nil, threads, true)
                } else {
                    completion(true, nil, threads, false)
                }
            }
        }
        if sendCachedData {
            return
        }
        
        ChatConnector().getGroupChats(isRefresh: isRefresh, timestamp: timestamp) { success, error, threads in
            if success {
                
                if isRefresh {
                    completion(true, nil, threads, true)
                    if let privateThreads = threads {
                        for thread in privateThreads {
                                self.cacheGroupChatMsgs(thread: thread, shouldForceUpdate: shouldForceUpdate, threadType: "group")
                        }
                        ChatModel.sharedInstance.isUpdatingGroupChat = false
                        NotificationCenter.default.post(name: Notification.Name("RefreshChatCacheDone"), object: nil)
                    }
                } else {
                    completion(true, nil, threads, true)
                }
            } else {
                ChatModel.sharedInstance.isUpdatingGroupChat = false
                NotificationCenter.default.post(name: Notification.Name("RefreshChatCacheDone"), object: nil)
                completion(false, error, nil, false)
            }
        }
        
    }
    
    func getCachedGroupThreads() -> [ThreadInfo] {
        let threads =  ChatCoreDataHelper.sharedChatDBHelper.getGroupThreads()
        var threadList: [ThreadInfo] = []
        
        if threads.count > 0 {
            for obj in threads {
                let thread = ThreadInfo(groupThread: obj)
                threadList.append(thread)
            }
        }
        
        return threadList
    }
    
    func cacheGroupChatMsgs(thread: ThreadInfo, shouldForceUpdate: Bool, threadType: String) {
        if !ChatCoreDataHelper.sharedChatDBHelper.checkIfPrivateThreadIsUpdated(threadID: thread.threadID, lastMsgID: thread.lastMsgID) || shouldForceUpdate {
            let formattedDate = Utils.getFormattedTimeUTC(dateToFormat: Date())
            var pageSize = 10
            if thread.unreadMsgCount > 5 {
                pageSize = thread.unreadMsgCount + 5
            }
            ChatConnector().getChatMessages(chatId: thread.threadID, messageUpto: formattedDate, page: 1, pageSize: pageSize, isRefresh: true, threadType: threadType) { success, error, threads, totalMsgCount in
                if success {
                } else {
                }
            }
        }
    }
}

extension ChatCacheManager: HTTPRequesterDelegate {
    
    func uploadPendingMedia() {
       let mediaData = ChatCoreDataHelper.sharedChatDBHelper.getMediaUploadLog()
        var pendingMediaData: [MediaUploadData] = []
        for data in mediaData {
            if data.uploadState == "Not Uploaded" {
                pendingMediaData.append(MediaUploadData(data: data))
            }
        }
        
        for data in pendingMediaData {
            self.uploadImageMsg(data.mediaPath, data.messageId)
          
        }
    }
    
    func uploadAllPendingMedia() {
       let mediaData = ChatCoreDataHelper.sharedChatDBHelper.getMediaUploadLog()
        var pendingMediaData: [MediaUploadData] = []
        for data in mediaData {
                pendingMediaData.append(MediaUploadData(data: data))
        }
        
        for data in pendingMediaData {
            self.uploadImageMsg(data.mediaPath, data.messageId)
        }
    }
    
    func uploadImageMsg(_ mediaPath: String, _ messageID: String) {
        ChatCoreDataHelper.sharedChatDBHelper.updateMediaLogState(MsgId: messageID, uploadState: "In Progress")
        GroupConnector().uploadChatMessageMedia("chat-media", mediaPath: mediaPath, delegate: self) { success, _, media in
            if success {
                DispatchQueue.main.async {
                    let mediaData = media
                    let chatMeta1 = ChatMediaMessageMetaData(metaKey: "url_original", metaValue: mediaData?.imageUrl ?? "")
                    let chatMeta2 = ChatMediaMessageMetaData(metaKey: "url_thumbnail", metaValue: mediaData?.thumbnailUrl ?? "")
                    let chatMeta3 = ChatMediaMessageMetaData(metaKey: "height", metaValue: "\(mediaData?.height ?? 0)")
                    let chatMeta4 = ChatMediaMessageMetaData(metaKey: "width", metaValue: "\(mediaData?.width ?? 0)")
                    let chatMeta5 = ChatMediaMessageMetaData(metaKey: "mimeType", metaValue: mediaData?.mimeType ?? "")
                var chatMetaData: [ChatMediaMessageMetaData] = [chatMeta1, chatMeta2, chatMeta3, chatMeta4, chatMeta5]
                        ChatConnector().updateMediaMetadata(messageID, chatMetaData) { success, _ in
                            if success {
                                self.deleteFile(atPath: mediaPath)
                                ChatCoreDataHelper.sharedChatDBHelper.deleteMediaUploadLog(messageID: messageID)
                            } else {
                                ChatCoreDataHelper.sharedChatDBHelper.updateMediaLogState(MsgId: messageID, uploadState: "Not Uploaded")
                            }
                        }
                }
            } else {
                DispatchQueue.main.async {
                    ChatCoreDataHelper.sharedChatDBHelper.updateMediaLogState(MsgId: messageID, uploadState: "Not Uploaded")
                }
            }
        }
    }
    
    func deleteFile(atPath path: String) {
        let fileManager = FileManager.default

        do {
            try fileManager.removeItem(atPath: path)
            print("File deleted successfully")
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }

    func downloadImageAndSaveToGallery(from imageURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        // Download the image
        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                completion(false, error)
                return
            }

            if let data = data, let image = UIImage(data: data) {
                // Save the image to the gallery
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { (success, error) in
                    completion(success, error)
                }
            } else {
                completion(false, NSError(domain: "YourAppDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to download or convert image"]))
            }
        }.resume()
    }
}


