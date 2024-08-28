//
//  ChatModel.swift
//  MFChatModuleKeek
//
//  Created by Akash Belekar on 19/07/24.
//

import Foundation

class ChatModel{
    static let sharedInstance = ChatModel()
    
    var appName:String?
    var users:User!
    var isUpdatingPrivateChat = false
    var isUpdatingGroupChat = false
    var userId = ""
    var chatUserID = ""
    var isLoadingKeekChatToken = false
    var nativeChatUrl = ""
    var nativeChatAuthUrl = ""
    var apiSecret = ""
    var sharedSecret = ""
    var apiKey = ""
    var currentChatId = ""
    var serverURLString: String?
    var eighteenPlusPopupTextContent: String = ""
    var streamViewUrl = ""
    var tipStream18plus = false
    var channelViewUrl = ""
    var walletUrl = ""
    var walletPurchaseUrl = ""
    var subscriptionManageUrl = ""
    var fcmToken = ""
    var privacyURL = "https://peeks.social/privacy-policy/"
    var termsURL = "https://peeks.social/terms-of-service/"
    var shareURL = ""
    var postShareURL = ""
    var networkID: String = "3"
    var impressionToCoinRatio: Double?
    var deviceToken: String?
    var password = ""
    var adEndPoint: String = ""
    var giftingEndPoint: String = ""
    var commonObjectsEndPoint: String = ""
    var pinnedHost: String = ""
    var contentUploadUrl: String = ""
    var userPermissions = UserPermissions()
    var accountConfirmed = false
    
    var notifObject: NotificationObject?
    var publisherAdunitID: String?
    var urlStreamId: String?
    var streamViewerLikeLimit: Int = 0
    var streamShareUrl = ""
    var isEighteenPlusRedirect = false
    var streamPrivateMaxTipAmount: Int = 0
    var streamPrivateMinTipAmount: Int = 0
    var streamFollowersMinTipAmount: Int = 0
    var streamFollowersMaxTipAmount: Int = 0
    var subscribeUserUrl = ""
    
    var streamPaidG = true
    var streamPaid14plus = true
    var streamPaid18plus = true
    
    var streamPlay18plus = false
    
    var tipStreamG = false
    var tipStream14plus = false
    var reKeekPostId: String = ""
    var reKeekVideoMediaUrl: String = ""
    var reKeekVideoDownloadUrl: String = ""
    var reKeekVideoDescription: String = ""
    var keekChatToken = ""
    var keekChatUserID = ""
    
    func setDeviceToken(_ deviceToken: String) {
        self.deviceToken = deviceToken
    }
    
    func initateWithConfig(config:ChatConfig){
        nativeChatUrl = config.chatURL
        nativeChatAuthUrl = config.chatAuthURL
        pinnedHost = config.pinnedHost
        contentUploadUrl = config.fileUploadURL
        keekChatUserID = config.userID
        keekChatToken = config.chatToken
    }
    private init(){}
//    fileprivate init(){
//        nativeChatUrl = "https://keekchat-dev.api.keek.com/chat"
//        nativeChatAuthUrl = "https://keekchat-dev.api.keek.com/auth"
//        adEndPoint = "https://dev.api.keek.com/ad/2"
//        giftingEndPoint = "https://dev.api.keek.com/gifting/2"
//        commonObjectsEndPoint = "https://dev.api.keek.com/common/1"
//        pinnedHost = "dev.api.keek.com"
//        contentUploadUrl = "https://upload-dev.api.keek.com/files"
//        
//        if let chatUserId = KeychainService.loadKeekChatUserId() {
//            self.keekChatUserID = chatUserId
//        }
//        
//        if let chatToken = KeychainService.loadKeekChatToken() {
//            self.keekChatToken = chatToken
//        }
//    }
}
