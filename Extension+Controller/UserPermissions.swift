//
//  UserPermissions.swift
//  Peeks
//
//  Created by Vineet Mrug on 2017-05-03.
//  Copyright © 2017 Riavera. All rights reserved.
//

import UIKit

class UserPermissions: NSObject {

    var canCreateStreamLiveG: Bool
    var canCreateStreamLivePlus14: Bool
    var canCreateStreamLivePlus18: Bool
    var canCreateStreamUploadG: Bool
    var canCreateStreamUploadPlus14: Bool
    var canCreateStreamUploadPlus18: Bool
    var canCreatePost: Bool
    var canCreatePostG: Bool
    var canCreatePost14: Bool
    var canCreatePost18: Bool
    var canCreateSubscription: Bool
    var canCreateSubscriptionPlan: Bool
    var canCreateGoal: Bool
    var canCreateStreamGoal: Bool
    var canCreateOffer: Bool
    var canCreateChat: Bool
    var canCreateStreamChat: Bool
    var canCreateStreamShare: Bool
    var canDeleteStream: Bool  = false
    var canUpdateStream: Bool = false
    var canDisableStreamingUploadPermission = false
    var canAccessOfferBox: Bool = false
    var canGetSponsored: Bool = false
    var canCreateComment: Bool = false
    var canUpdateUser: Bool = false
    var isAdmin: Bool {
        return canDeleteStream || canUpdateStream || canDisableStreamingUploadPermission
    }
    
    override init() {
        self.canCreateStreamLiveG = false
        self.canCreateStreamLivePlus14 = false
        self.canCreateStreamLivePlus18 = false
        self.canCreateStreamUploadG = false
        self.canCreateStreamUploadPlus14 = false
        self.canCreateStreamUploadPlus18 = false
        self.canCreatePost = false
        self.canCreatePostG = false
        self.canCreatePost14 = false
        self.canCreatePost18 = false
        self.canCreateSubscription = false
        self.canCreateSubscriptionPlan = false
        self.canCreateGoal = false
        self.canCreateStreamGoal = false
        self.canCreateOffer = false
        self.canCreateChat = false
        self.canCreateStreamChat = false
        self.canCreateStreamShare = false
        self.canCreateComment = false
        self.canUpdateUser = false
    }
    
    convenience init(params: [String]) {
        self.init()
        self.parseParams(params: params)
    }
    
    func parseParams(params: [String]) {
        self.canCreateStreamLiveG = params.contains("CREATE STREAM_LIVE_G")
        self.canCreateStreamLivePlus14 = params.contains("CREATE STREAM_LIVE_PLUS14")
        self.canCreateStreamLivePlus18 = params.contains("CREATE STREAM_LIVE_PLUS18")
        self.canCreateStreamUploadG = params.contains("CREATE STREAM_UPLOAD_G")
        self.canCreateStreamUploadPlus14 = params.contains("CREATE STREAM_UPLOAD_PLUS14")
        self.canCreateStreamUploadPlus18 = params.contains("CREATE STREAM_UPLOAD_PLUS18")
        self.canCreatePost = params.contains("CREATE POST")
        self.canCreatePostG = self.canCreatePost && params.contains("CREATE POST_G")
        self.canCreatePost14 = self.canCreatePost && params.contains("CREATE POST_14")
        self.canCreatePost18 = self.canCreatePost && params.contains("CREATE POST_18")
        self.canCreateSubscription = params.contains("CREATE SUBSCRIPTION")
        self.canCreateSubscriptionPlan = params.contains("CREATE SUBSCRIPTION_PLAN")
        self.canCreateGoal = params.contains("CREATE GOAL")
        self.canCreateStreamGoal = params.contains("CREATE STREAM_GOAL")
        self.canCreateOffer = params.contains("CREATE OFFER")
        self.canCreateChat = params.contains("CREATE CHAT")
        self.canCreateStreamChat = params.contains("CREATE STREAM_CHAT")
        self.canCreateStreamShare = params.contains("CREATE STREAM_SHARE")
        self.canDeleteStream = params.contains("ALLOW REPORT_STREAM_HIDE")
        self.canUpdateStream = params.contains("UPDATE STREAM_ANY")
        self.canDisableStreamingUploadPermission = params.contains("GRANT PERMISSION")
        self.canAccessOfferBox = params.contains("ALLOW OFFERBOX_ACCESS")
        self.canGetSponsored = params.contains("ALLOW GET_SPONSORED")
        self.canCreateComment = params.contains("CREATE COMMENT")
        self.canUpdateUser = params.contains("UPDATE USER")
    }
    
}
