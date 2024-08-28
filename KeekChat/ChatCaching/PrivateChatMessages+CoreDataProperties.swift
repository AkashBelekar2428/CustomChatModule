//
//  PrivateChatMessages+CoreDataProperties.swift
//  ChatModule
//
//  Created by Akash Belekar on 29/07/24.
//
//

import Foundation
import CoreData


extension PrivateChatMessages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PrivateChatMessages> {
        return NSFetchRequest<PrivateChatMessages>(entityName: "PrivateChatMessages")
    }

    @NSManaged public var externalUserId: String?
    @NSManaged public var imageHeight: Int16
    @NSManaged public var imageWidth: Int16
    @NSManaged public var isDeletedMessage: Bool
    @NSManaged public var isRead: Bool
    @NSManaged public var isReadByMe: Bool
    @NSManaged public var mainImageUrl: String?
    @NSManaged public var messageID: String?
    @NSManaged public var messageText: String?
    @NSManaged public var messageTime: String?
    @NSManaged public var messageType: Int16
    @NSManaged public var postId: String?
    @NSManaged public var sentDateTimeMilliSeconds: Int64
    @NSManaged public var threadID: String?
    @NSManaged public var threadType: String?
    @NSManaged public var thumbnailImageUrl: String?
    @NSManaged public var userAvatarUrl: String?
    @NSManaged public var userId: String?
    @NSManaged public var userName: String?

}

extension PrivateChatMessages : Identifiable {

}
