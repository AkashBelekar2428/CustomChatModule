//
//  Config.swift
//  Peeks
//
//  Created by Vasily Evreinov on 22/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//swiftlint:disable large_tuple

import UIKit

class Config: NSObject {
    fileprivate var config: Config?
    fileprivate var data: NSDictionary?
    var apiSecret: String!
    var sharedSecret: String!
    var usernameShared: String!
    
    var termsOfService: String!
    var privacyPolicy: String!
    
    var email: String!
    
    var publishKeyPubNub: String!
    var subscribeKeyPubNub: String!
    var secretKeyPubNub: String!
    
    var hostWowza: String!
    var portWowza: String!
    var applicationWowza: String!
    var usernameWowza: String!
    var passwordWowza: String!
    
    var hostOld: String!
    var host: String!
    var hostXmpp: String!
    var kountDataMerchantID: Int!
   // var kountDataEnvironment: KEnvironment!
    var emailSupportLink: String!
    var certificateURL: String!
    var contentKeyContextURL: String!
    // MARK: - Init
    
    class var shared: Config {
        struct Static {
            static let instance: Config = Config()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        #if USE_DEV_SERVER
            
            setPublicDevConfig()
            
        #elseif USE_PROD_SERVER
        
            setProdConfig()
            
        #else
            
            setDebugConfig()
            
        #endif
    }
    
    func setPublicDevConfig() {
        print("Using DevConfig file.")
        setDebugConfig()
        host = "https://dev.api.keek.com/peeks/2"
    }
    
    func setProdConfig() {
        apiSecret = "8rX4GPUcDH7IxdytvhTt1lYPKyoXR8DJ" //"mQXmNemG8OcSN8DTDmlaSLoIO9Z3QvW9"
        sharedSecret = "8840bR5YxoSJ"
        usernameShared = "miitv|jzMwYzqdux5rcBtvYiLfndvZTEdnq7GM" // "yPyEwCQKaH3hG5QUvQZgbXI9YQgkoyl9"
        
        termsOfService = "http://54.173.80.27/terms"
        privacyPolicy  = "http://54.173.80.27/privacy"
        
        email = "support@mii.tv" //"support@peeks.com"
        
        publishKeyPubNub = "pub-c-7e865260-2f8c-4534-8f4f-80d87d6efaf3"
        subscribeKeyPubNub = "sub-c-7482b8da-fb65-11e5-a492-02ee2ddab7fe"
        secretKeyPubNub = "sec-c-ZDE4Y2EyYTEtNDBkMy00Mjc0LWI5ZDYtZWE4OTk4YWU1YmRh"
        
        hostWowza = "52.90.142.255"
        portWowza = "1935"
        applicationWowza = "live"
        usernameWowza = "streamer"
        passwordWowza = "streamer"
        
        hostOld = "http://54.173.80.27/api"
        host = "https://main.api.keek.com/peeks/2"

        hostXmpp = "chat.peeks.com"
        kountDataMerchantID = 171361
       // kountDataEnvironment = KEnvironment.production
        emailSupportLink = "https://info.mii.tv/contact-dynamic/?" //"https://peeks.social/contact-dynamic/"
        
        certificateURL = "https://fp-keyos.licensekeyserver.com/cert/a0ae9dd5b9401f55976c7bb1f5ebd97f.der"
        contentKeyContextURL = "https://fp-keyos.licensekeyserver.com/getkey"
    }
    
    func setDebugConfig() {
        
        apiSecret = "rREfLM7jMgUWCnSf0ujPo1Qg06ehLbaU" //"0b7438f75a575b5442e917de42fa503e"
        sharedSecret = "8840bR5YxoSJ"
        usernameShared = "miitv|gMdMJFHoFWSXOtuQfsdd6ISN4QlB4cdm" //"3e7958a835cdcd3f3e2cac65794d6ae3"
        
        termsOfService = "http://54.173.80.27/terms"
        privacyPolicy  = "http://54.173.80.27/privacy"
        
        email = "davidk@riavera.com"
        
        publishKeyPubNub = "pub-c-9360eaf0-0f6a-4218-8590-f37b0d714e6c"
        subscribeKeyPubNub = "sub-c-55f3f592-b4b0-11e5-8622-0619f8945a4f"
        secretKeyPubNub = "sec-c-ZmRjMThjZGEtNWJiYS00ZGJlLTk5ODEtMzU1OWI0ZGVhZGY1"
        
        hostWowza = "52.90.142.255"
        portWowza = "1935"
        applicationWowza = "live"
        usernameWowza = "streamer"
        passwordWowza = "streamer"
        
        hostOld = "http://54.173.80.27/api"
        #if DEBUG
            let serverDefaultUrl = "https://dev.api.keek.com/peeks/2"
            if let url = ChatModel.sharedInstance.serverURLString {
                host = url.isEmpty ? serverDefaultUrl : url
            } else {
                host = serverDefaultUrl
            }
        #else
            host = "https://dev.api.keek.com/peeks/2"
        #endif
        hostXmpp = "dev-chat.peeks.com"
        kountDataMerchantID = 171361
        //kountDataEnvironment = KEnvironment.test
        emailSupportLink = "http://peeks.dev.onpressidium.com/contact-dynamic/"
        certificateURL = "https://fp-keyos.licensekeyserver.com/cert/a0ae9dd5b9401f55976c7bb1f5ebd97f.der"
        contentKeyContextURL = "https://fp-keyos.licensekeyserver.com/getkey"
    }
   
    func xmpp() -> (String) {
        return (hostXmpp)
    }
    
    func api() -> (String) {
        return (host)
    }
    
    func oldApi() -> (String) {
        return (hostOld)
    }
    
    func wowza() -> (host: String, port: String, application: String, username: String, password: String) {
        return (hostWowza, portWowza, applicationWowza, usernameWowza, passwordWowza)
    }
    
    func pubNub() -> (publishKey: String, subscribeKey: String, secretKey: String) {
        
        return (publishKeyPubNub, subscribeKeyPubNub, secretKeyPubNub)
    }
    
    func feedback() -> String {
        return email
    }
    
    func legal() -> (termsOfService: String, privacyPolicy: String) {
        return (termsOfService, privacyPolicy)
    }
    
    func peeks() -> (apiKey: String, apiSecret: String, usernameShared: String) {
        return (apiSecret, sharedSecret, usernameShared)
    }
}
