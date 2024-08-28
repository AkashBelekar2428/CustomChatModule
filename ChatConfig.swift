//
//  ChatConfig.swift
//  ChatModule
//
//  Created by Akash Belekar on 31/07/24.
//

import Foundation


class ChatConfig{
    
    var chatURL:String
    var chatAuthURL:String
    var chatHubURL:String
    var chatToken:String
    var userID:String
    var appName:String
    var fileUploadURL:String
    var pinnedHost:String
    
    init(chatURL: String, chatAuthURL: String, chatHubURL: String, chatToken: String, appName: String,fileUploadURL:String,pinnedHost:String,userID:String) {
        self.chatURL = chatURL
        self.chatAuthURL = chatAuthURL
        self.chatHubURL = chatHubURL
        self.chatToken = chatToken
        self.appName = appName
        self.fileUploadURL = fileUploadURL
        self.pinnedHost = pinnedHost
        self.userID = userID
    }
    
}
