//
//  PrivateConversation+CoreDataProperties.swift
//  ChatModule
//
//  Created by Akash Belekar on 29/07/24.
//
//

import Foundation
import CoreData


extension PrivateConversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PrivateConversation> {
        return NSFetchRequest<PrivateConversation>(entityName: "PrivateConversation")
    }

    @NSManaged public var extAppUserId: String?
    @NSManaged public var isBlocked: Bool
    @NSManaged public var isDeletedChat: Bool
    @NSManaged public var lastMsgID: String?
    @NSManaged public var lastMsgIsDeleted: Bool
    @NSManaged public var lastMsgText: String?
    @NSManaged public var lastMsgTime: String?
    @NSManaged public var lastMsgType: Int16
    @NSManaged public var sentDateTimeMilliSeconds: Int64
    @NSManaged public var threadID: String?
    @NSManaged public var totalMsgCount: Int16
    @NSManaged public var unreadMsgCount: Int16
    @NSManaged public var userAvatarUrl: String?
    @NSManaged public var userID: String?
    @NSManaged public var userName: String?
    @NSManaged public var userStatus: String?

}

extension PrivateConversation : Identifiable {

}
