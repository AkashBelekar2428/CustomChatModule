//
//  MediaUploadLog+CoreDataProperties.swift
//  ChatModule
//
//  Created by Akash Belekar on 29/07/24.
//
//

import Foundation
import CoreData


extension MediaUploadLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaUploadLog> {
        return NSFetchRequest<MediaUploadLog>(entityName: "MediaUploadLog")
    }

    @NSManaged public var mediaPath: String?
    @NSManaged public var messageId: String?
    @NSManaged public var uploadState: String?

}

extension MediaUploadLog : Identifiable {

}
