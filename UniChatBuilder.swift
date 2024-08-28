//
//  UniChatBuilder.swift
//  ChatModule
//
//  Created by Akash Belekar on 22/08/24.
//

import Foundation

public class UniChatBuilder {
    
    static var shared = UniChatBuilder()
    internal init() {}
    
    public func setToken() -> String{
        return KeychainService.loadItem(service: keekChatToken) ?? ""
    }
}
