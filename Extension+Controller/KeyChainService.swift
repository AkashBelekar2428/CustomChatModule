//
//  KeyChainService.swift
//  Peeks
//
//  Created by Matheus Ruschel on 2017-05-30.
//  Copyright © 2017 Riavera. All rights reserved.
// swiftlint:disable force_try
import Foundation
import Security
import IDZSwiftCommonCrypto
import CryptoSwift
// Constant Identifiers
let userAccount = "AuthenticatedUser"
let accessGroup = "SecuritySerivice"
/**
 *  User defined keys for new entry
 *  Note: add new keys for new secure item and use them in load and save methods
 */
let passwordKey = "KeyForPassword"
let fbTokenKey = "TokenForFacebook"
let appleIdentifier = "AppleIdentifier"
let socialAuthCode = "SocialAuthCode"
let socialLoginType = "SocialLoginType"
let appleEmail = "AppleEmail"
let swipeInstructionKey = "SwipeInstructionKey"
let hasNewUploadKey = "HasNewUploadKey"
let newUploadIdsKey = "NewUploadIdsKey"
let newUploadTitlesKey = "NewUploadTitlesKey"
let apiKey = "ApiKey"
let apiSecretKey = "ApiSecretKey"
let userId = "UserId"
let keekChatUserId = "KeekChatUserId"
let keekChatToken = "KeekChatToken"
// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
public class KeychainService: NSObject {
    
    /**
     * Exposed methods to perform save and load queries.
     */
    
    static let key = "2b7e151628aed2a6abf7158809cf4f3c"
    //static let aes = try! AES(key: key)
    static let aes = try! AES(key: Array<UInt8>(key.utf8), blockMode: ECB(), padding: .pkcs5)
    
    public class func savePassword(token: String) {
        self.saveItem(token: token, service: passwordKey)
    }
    
    public class func saveFBToken(token: String) {
        self.saveItem(token: token, service: fbTokenKey)
    }
    
    public class func saveAppleIdentifier(_ identifier: String) {
        self.saveItem(token: identifier, service: appleIdentifier)
    }
    
    public class func saveSocialAuthCode(_ code: String) {
        self.saveItem(token: code, service: socialAuthCode)
    }
    
    public class func saveSocialLoginType(_ code: String) {
        self.saveItem(token: code, service: socialLoginType)
    }
    
    public class func saveSocialEmail(_ email: String) {
        self.saveItem(token: email, service: appleEmail)
    }
    
    public class func saveSwipeInstructionKey(_ disableInst: String) {
        self.saveItem(token: disableInst, service: swipeInstructionKey)
    }
    
    public class func saveHasNewUploadKey(_ hasUpload: String) {
        self.saveItem(token: hasUpload, service: hasNewUploadKey)
    }
    
    public class func saveNewUploadIdsKey(_ newUploadIds: String) {
        self.saveItem(token: newUploadIds, service: newUploadIdsKey)
    }
    
    public class func saveNewUploadTitlesKey(_ newUploadTitles: String) {
        self.saveItem(token: newUploadTitles, service: newUploadTitlesKey)
    }
    
    public class func saveApiKey(_ ApiKey: String) {
        self.saveItem(token: ApiKey, service: apiKey)
    }
    
    public class func saveApiSecretKey(_ SecretKey: String) {
        self.saveItem(token: SecretKey, service: apiSecretKey)
    }
    
    public class func saveKeekChatUserId(_ KeekChatUserId: String) {
        self.saveItem(token: KeekChatUserId, service: keekChatUserId)
    }
    
    public class func saveUserId(_ UserId: String) {
        self.saveItem(token: UserId, service: userId)
    }
    
    public class func saveKeekChatToken(_ KeekChatToken: String) {
        self.saveItem(token: KeekChatToken, service: keekChatToken)
    }
    
    public class func loadPassword() -> String? {
        return self.loadItem(service: passwordKey)
    }
    
    public class func loadFBToken() -> String? {
        return self.loadItem(service: fbTokenKey)
    }
    
    public class func loadAppleIdentifier() -> String? {
        return self.loadItem(service: appleIdentifier)
    }
    
    public class func loadSocialAuthCode() -> String? {
        return self.loadItem(service: socialAuthCode)
    }
    
    public class func loadSocialLoginType() -> String? {
        return self.loadItem(service: socialLoginType)
    }
    
    public class func loadSocialEmail() -> String? {
        return self.loadItem(service: appleEmail)
    }
    
    public class func loadSwipeInstructionKey() -> String? {
        return self.loadItem(service: swipeInstructionKey)
    }
    
    public class func loadhasNewUploadKey() -> String? {
        return self.loadItem(service: hasNewUploadKey)
    }
    
    public class func loadNewUploadIdsKey() -> String? {
        return self.loadItem(service: newUploadIdsKey)
    }
    
    public class func loadNewUploadTitlesKey() -> String? {
        return self.loadItem(service: newUploadTitlesKey)
    }
    
    public class func loadApiKey() -> String? {
        return self.loadItem(service: apiKey)
    }
    
    public class func loadSecretApiKey() -> String? {
        return self.loadItem(service: apiSecretKey)
    }
    
    public class func loadUserId() -> String? {
        return self.loadItem(service: userId)
    }
    
    public class func loadKeekChatUserId() -> String? {
        return self.loadItem(service: keekChatUserId)
    }
    
    public class func loadKeekChatToken() -> String? {
        return self.loadItem(service: keekChatToken)
    }
    
    public class func logout() {
        let secItemClasses = [kSecClassGenericPassword,
                              kSecClassInternetPassword,
                              kSecClassCertificate,
                              kSecClassKey,
                              kSecClassIdentity]
        for secItemClass in secItemClasses {
            let dictionary = [kSecClass as String: secItemClass]
            SecItemDelete(dictionary as CFDictionary)
        }
    }
    
    /**
     * Internal methods for saving and loading items
     */
    
    private class func saveItem(token: String, service: String) {
        let cypherText = try! aes.encrypt(Array(token.utf8))
        let encryptedPass = cypherText.toHexString()
        
        self.save(service: service as NSString, data: encryptedPass as NSString)
    }
    
    internal class func loadItem(service: String) -> String? {
        let encryptedPass = self.load(service: service as NSString) as String?
        guard let pass = encryptedPass else {
            return nil
        }
        
        if !pass.isValidHexNumber() {
            return nil
        }
        
        let hexPass = arrayFrom(hexString: pass)
        guard let uncrypted = try? aes.decrypt(hexPass) else {
            return nil
        }
        let string = String(bytes: uncrypted, encoding: .utf8)
        
        return string
    }
    
    /**
     * Internal methods for querying the keychain.
     */
    
    private class func save(service: NSString, data: NSString) {
        let dataFromString: NSData = data.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)! as NSData
        
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
        
        // Add the new keychain item
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    private class func load(service: NSString) -> NSString? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef: AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: NSString? = nil
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
}
