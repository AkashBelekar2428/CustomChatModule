//
//  ErrorCodes.swift
//  ChatModule
//
//  Created by Tushar Patil   on 26/07/24.
//

import Foundation

class ErrorCodes {

    func getErrorCode(_ code: AnyObject) -> String {

        var myCode = ""
        
        if let id = code as? Int {
            myCode = String(id)
        }

        if let path = Bundle.main.path(forResource: "ErrorCodes", ofType: "plist") {
            
            if let errorCodesList = NSDictionary(contentsOfFile: path) as NSDictionary? {
                
                if let codeContent = errorCodesList[myCode] as? String {
                    return codeContent
                }
            
            } else {
                print("ErrorCodes: The file exists but it is not a Dictionary.")
            }
        } else {
            print("ErrorCodes: ErrorCodes.plist is missing.")
        }
        
        return ""
        
    }

}
