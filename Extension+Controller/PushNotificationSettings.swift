//
//  PushNotificationSettings.swift
//  Peeks
//
//  Created by Vineet Mrug on 2016-08-12.
//  Copyright © 2016 Riavera. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import UIKit

enum UserPreferenceType {
    case dailyStats
    case newFollower
    case chat
    case startAnyStream
    case shareStream
    case show18Plus
    case communicationEmail
    case communicationText
    case communicationPhone
    case newPost
    case likes
    case comment
    case newPostPrivate
    case followRequest
    case none
    
    func getKeyString() -> String {
        switch self {
        case .dailyStats:
            return "notify_daily_stats"
        case .newFollower:
            return "notify_new_follower"
        case .startAnyStream:
            return "notify_stream_start"
        case .shareStream:
            return "notify_stream_share"
        case .show18Plus:
            return "stream_show_18plus"
        case .communicationText:
            return "notify_via_text"
        case .communicationEmail:
            return "notify_via_email"
        case .communicationPhone:
            return "notify_via_phone"
        case .chat:
            return "notify_chat"
        case .newPost:
            return "post_create_follower"
        case .likes:
            return "notify_post_like"
        case .comment:
            return "notify_post_comment"
        case .newPostPrivate:
            return "post_create_private"
        case .followRequest:
            return "notify_follow_request"
        case .none:
            return ""
        }
    }
    
    static func getTypeForKeyString(_ keyString: String) -> UserPreferenceType? {
        switch keyString {
        case "notify_daily_stats":
            return .dailyStats
        case "notify_new_follower":
            return .newFollower
        case "notify_stream_start":
            return .startAnyStream
        case "notify_stream_share":
            return .shareStream
        case "stream_show_18plus":
            return .show18Plus
        case "notify_via_text":
            return .communicationText
        case "notify_via_email":
            return .communicationEmail
        case "notify_via_phone":
            return .communicationPhone
        case "notify_chat":
            return .chat
        case "notify_post_like":
            return .likes
        case "notify_post_comment":
            return .comment
        case "post_create_follower":
            return .newPost
        case "post_create_private":
            return .newPostPrivate
        case "notify_follow_request":
            return .followRequest
        default:
            return nil
        }
    }
}

class UserPreferences: NSObject {

//    var dailyStatsNotifications: Bool?
//    var newFollowerNotifications: Bool?
//    var startAnyStreamNotifications: Bool?
    
    static var sharedInstance: UserPreferences?
    var userSettings: [UserPreferenceType: Bool] = [:]
    
    init(params: [String: AnyObject]) {
        super.init()
        self.parsUserPreferences(params)
    }
    
    func parsUserPreferences(_ params: [String: AnyObject]) {
        
        for (key, value) in params {
            if let preferenceType = UserPreferenceType.getTypeForKeyString(key) {
                if let valueBool = value as? Bool {
                    self.userSettings[preferenceType] = valueBool
                }
            }
        }
    }
}

enum PushNotificationType {
    case streamStart
    case streamShare
    case broadcastStart
    case newFollower
    case dailyStat
    case message
    case url
    case any
    case postCommentThread
    case postComment
    case mentionUser
    case miitvNewFollower
    case newFollowerRequest
    case followUserRequestAccepted
    case followUserRequestDeclined
    case postLike
    case postCreatePrivate
    case postCreateFollower
    case postViolation
    case clubAddMember
    case post_tag_user
    case userChatMessage
    case groupChatMessage
    
    func getKeyString() -> String {
        switch self {
        case .streamStart:
            return "stream-start"
        case .streamShare:
            return "broadcast_share"
        case .broadcastStart:
            return "broadcast_start"
        case .newFollower:
            return "new-follower"
        case .dailyStat:
            return "daily-stat"
        case .message:
            return "chat-message"
        case .url:
            return "url-redirect"
        case .any:
            return "any"
        case .postCommentThread:
            return "post_comment_thread"
        case .postComment:
            return "post_comment"
        case .miitvNewFollower:
            return "new-follower"
        case .newFollowerRequest:
            return "new-follower-request"
        case.followUserRequestAccepted:
            return "follow_user_request_accepted"
        case .followUserRequestDeclined:
            return "follow_user_request_declined"
        case .postLike:
            return "post_like"
        case .postCreatePrivate:
            return "post_create_private"
        case .postCreateFollower:
            return "post_create_follower"
        case .postViolation:
            return "post_appeal"
        case .clubAddMember:
            return "club_add_member"
        case .post_tag_user:
            return "post_tag_user"
        case .mentionUser:
            return "comment_mention_user"
        case .userChatMessage:
            return "USER_CHAT_MESSAGE"
        case .groupChatMessage:
            return "GROUP_CHAT_MESSAGE"
        }
    }
}
