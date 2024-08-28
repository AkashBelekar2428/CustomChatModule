//
//  ChatUser.swift
//  Peeks
//
//  Created by Inhyuck Kim on 2020-02-21.
//  Copyright © 2020 Riavera. All rights reserved.
//

import Foundation.NSString

public class ChatUser : NSObject {
    public var userName: String
    public var userID: String
    public var avatarURL: String
    var hashCode: String
	
	var chatID: String {
        var domain = "@miitv.com"
        #if SANDBOX
        domain = "@miitv.com"
        #endif
		return userID + domain
	}
	
	public override init() {
		self.userName = ""
		self.userID = ""
		self.avatarURL = ""
		self.hashCode = ""
	}
	
    public init(ID: String, username: String, avatarURL: String) {
        self.userName = username
        self.userID = ID
        self.avatarURL = avatarURL
        self.hashCode = ""
    }

}
