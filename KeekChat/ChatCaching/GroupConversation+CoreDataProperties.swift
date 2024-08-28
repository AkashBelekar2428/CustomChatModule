//
//  GroupConversation+CoreDataProperties.swift
//  ChatModule
//
//  Created by Akash Belekar on 29/07/24.
//
//

import Foundation
import CoreData


extension GroupConversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupConversation> {
        return NSFetchRequest<GroupConversation>(entityName: "GroupConversation")
    }

    @NSManaged public var adminChatId: String?
    @NSManaged public var adminExtUserId: String?
    @NSManaged public var adminUserName: String?
    @NSManaged public var groupAvatarUrl: String?
    @NSManaged public var groupID: String?
    @NSManaged public var groupName: String?
    @NSManaged public var groupThreadID: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var isBlocked: Bool
    @NSManaged public var isDeletedChat: Bool
    @NSManaged public var lastMsgID: String?
    @NSManaged public var lastMsgText: String?
    @NSManaged public var lastMsgTime: String?
    @NSManaged public var lastMsgType: Int16
    @NSManaged public var recordStatus: Bool
    @NSManaged public var sentDateTimeMilliSeconds: Int64
    @NSManaged public var threadID: String?
    @NSManaged public var unreadMsgCount: Int16

}

extension GroupConversation : Identifiable {

}
