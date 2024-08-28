//
//  MediaMessage.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 08/11/23.
//  Copyright © 2023 Riavera. All rights reserved.
//

import Foundation

class MediaMessage: NSObject {
    
    var imageUrl: String = ""
    var thumbnailUrl: String = ""
    var height: Int = 0
    var width: Int = 0
    var mimeType: String = ""
    
    convenience init(params: [String: AnyObject]) {
        self.init()
        self.imageUrl = params["url_original"] as? String ?? ""
        self.thumbnailUrl = params["url_thumbnail"] as? String ?? ""
        self.height = params["height"] as? Int ?? 0
        self.width = params["width"] as? Int ?? 0
        self.mimeType = params["mimeType"] as? String ?? ""
    }
}

class MediaUploadData: NSObject {
    
    var messageId: String = ""
    var mediaPath: String = ""
    var uploadState: String = ""
    
    convenience init(data: MediaUploadLog) {
        self.init()
        self.messageId = data.messageId ?? ""
        self.mediaPath = data.mediaPath ?? ""
        self.uploadState = data.uploadState ?? ""
    }
}

class ChatMediaMetaData: NSObject {
    var metaKey: String = ""
    var metaValue: String = ""

    convenience init(metaKey: String, metaValue: String) {
        self.init()
        self.metaKey = metaKey
        self.metaValue = metaValue
    }
    
}


