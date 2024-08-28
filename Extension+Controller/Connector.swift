//
//  Connector.swift
//  Test
//
//  Created by Vasily Evreinov on 1/27/15.
//  Copyright (c) 2015 Direct Invent. All rights reserved.
// swiftlint:disable variable_name

import UIKit

class Connector: NSObject {
    
    let http =  HTTPRequester.sharedInstance
    
    var timestamp: String {
        let time = "\(Date().timeIntervalSince1970)" as NSString
        
        return time.substring(with: NSRange(location: 0, length: 10))
    }
    
    class func oldBaseUrl() -> URL {
        let (host) = Config.shared.oldApi()
        return URL(string: host)!
    }
    
    class func baseUrl() -> URL {
        let (host) = Config.shared.api()
        return URL(string: host)!
    }
    
    override init () {
        super.init()
    }
    
//    func sessionParams() -> [NSObject : AnyObject]? {
//        if let session = A0SimpleKeychain().stringForKey("PHPSESSID") {
//            let params: [NSObject: AnyObject] = [ "PHPSESSID" : session ]
//            return params
//        } else {
//            return nil
//        }
//    }
    
    func buildHash(_ request: RequestType, uri: String, timeStamp: String, authentication: String, apiSecret: String, sharedSecret: String) -> String {
        var hashString = request.rawValue + uri + timeStamp + authentication + apiSecret + sharedSecret
        
        
        hashString = hashString.sha1()
        
        return hashString
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        
        return documentsDirectory as NSString
    }
    
    func getParams(_ keyArray: [String], params: NSMutableDictionary) -> String {
        var paramString = ""
        
        for key: String in keyArray {
            if let paramKey = params[key] as? String {
                paramString += paramKey
            }
        }
        
        return paramString
    }
    
    func getStringParamsFromDictionary(_ keyArray: [String], params: [String : AnyObject]) -> String {
        var paramString = ""
        
        for key in keyArray {
            if let value =  params[key] as? String {
                paramString = value
            } else {
                print("Connector getStringParamsFromDictionary ERROR: \(key) did not return value of string")
            }
        }
        
        return paramString
    }
    
    func parseErrorFromAPIResponse(_ response: AnyObject) -> String {
        if let error = response as? String {
            return error
        } else {
            return "No error response provided"
        }
    }
}
