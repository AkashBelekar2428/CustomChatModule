//
//  User.swift
//  MFChatModuleKeek
//
//  Created by Akash Belekar on 19/07/24.
//

enum IDReviewState: String {
    case Null = ""
    case None = "none"
    case Pending = "pending"
    case Approved = "approved"
    case Rejected = "rejected"
}

import UIKit

class User: NSObject{
    var socialNetworkId: String
    var socialNetworkType: String
    var username: String
    var fullname: String
    var avatarUrl: String?
    var avatarImage: UIImage?
    var gender: String
    var email: String
    var phone: String
    var birthday: String
    var birthYear: String?
    var userDescription: String
    var likes: Int64
    var followers: Int
    var following: Int
    var liveId: Int
    var isFeatured: Bool
    var isBanned: Bool
    var role: String
    var city: String
    var country: String
    var creationTime: Date?
    var lastUpdate: Date?
    var prefix: String
    var id: String
    var gUserId: String?
    var isFollowingMe: Bool
    var isFollowingThem: Bool
    var pushNotification: Bool
    var statusLevelId: Float
   // var statusLevel: StatusLevel?
    var idReviewState = IDReviewState.Null
    var peeksUser: Bool
    var isWatching: Bool
    var age: Int
    var viewerRating: Float
    var overallRating: Float
    var isBlocked: Bool
    var termsAccepted = false
    var canSubscribe = false
    var subscribed = false
    var post_count : Int = 0
    var followersNumber : Int = 0
    var hasGroups = false
    var isFavourite: Bool
    var isPrivate = false
    var followRequested = false
    var followRequestId: Int
    var accountConfirmed = false
    var statusLevel: StatusLevel?
    
    override init () {
        self.socialNetworkId = ""
        self.socialNetworkType = ""
        self.username = ""
        self.fullname = ""
        self.avatarUrl = nil
        self.avatarImage = nil
        self.gender = ""
        self.email = ""
        self.phone = ""
        self.birthday = ""
        self.userDescription = ""
        self.likes = 0
        self.followers = 0
        self.following = 0
        self.liveId = 0
        self.isFeatured = false
        self.isBanned = false
        self.role = ""
        self.city = ""
        self.country = ""
        self.gUserId = ""
        self.creationTime = nil
        self.lastUpdate = nil
        self.prefix = ""
        self.id = ""
        self.isFollowingMe = false
        self.isFollowingThem = false
        self.pushNotification = false
      //  self.statusLevel = StatusLevel()
        self.statusLevelId = 0
        self.idReviewState = IDReviewState.Null
        self.peeksUser = true
        self.isWatching = false
        self.age = 0
        self.viewerRating = 0.0
        self.overallRating = 3.0
        self.isBlocked = false
        self.canSubscribe = false
        self.subscribed = false
        self.post_count = 0
        self.isFavourite = false
        self.isPrivate = false
        self.followRequested = false
        self.followRequestId = 0
        self.accountConfirmed = false
    }
    
    override func validateValue(_ ioValue: AutoreleasingUnsafeMutablePointer<AnyObject?>, forKeyPath inKeyPath: String) throws {
        if let _: AnyObject = ioValue.pointee {
            if (inKeyPath == "avatar" || inKeyPath == "desc") && ioValue.pointee is NSNull {
                ioValue.pointee = nil
                return
            }
        }
        try super.validateValue(ioValue, forKeyPath: inKeyPath)
    }
    
    convenience init(params: [String: AnyObject]) {
        self.init()
        self.parsePeeksUser(params)
    }
    
    convenience init(messengerParams: [String: AnyObject]) {
        self.init()
        self.parsePeeksUserfromMessage(messengerParams)
    }
    
    convenience init(clubParams: [String: AnyObject]) {
        self.init()
        self.parseClubAudienceUser(clubParams)
    }
    func updateUserStatusLevel() {
        if StatusLevel.statusLevels.count > 0 && self.statusLevelId != 0 {
            self.statusLevel = StatusLevel.getStatusLevelFromId(self.statusLevelId)
        }
    }
       
//    convenience init(searchUser: SearchUserList) {
//        self.init()
//        self.isFollowingThem = searchUser.am_following
//        self.avatarUrl = searchUser.avatar
//        self.followRequested = searchUser.follow_requested
//        
//        self.followers = Int(searchUser.followers)
//        self.followersNumber = Int(searchUser.followers)
//        self.following = Int(searchUser.following)
//        self.isFollowingMe = searchUser.following_me
//        self.isPrivate = searchUser.is_private
//        self.id = searchUser.user_id ?? ""
//        self.username = searchUser.username ?? "username"
//    }
    
    var chatID: String {
        var domain = "@miitv.com"
        #if SANDBOX
        domain = "@miitv.com"
        #endif
        return id + domain
    }
    
    func parsePeeksUser(_ dict: [String: AnyObject]) {
        
        if let guserId = dict["guser_id"] as? String {
            self.gUserId = guserId
        }
        
        if let socialNetworkId = dict["social_network_id"] as? String {
            self.socialNetworkId = socialNetworkId
        }
        
        if let socialNetworkType = dict["social_network_type"] as? String {
            self.socialNetworkType = socialNetworkType
        }
        
        if let username = dict["username"] as? String {
            self.username = username
        } else if let userName = dict["user_name"] as? String {
            self.username = userName
        }
        
        if let fullname = dict["fullname"] as? String {
            self.fullname = fullname
        } else if let fullname = dict["full_name"] as? String {
            self.fullname = fullname
        } else if let fullname = dict["name"] as? String {
            self.fullname = fullname
        }
        
        if let avatar = dict["avatar"] as? String {
            self.avatarUrl = avatar
        } else if let avatarURL = dict["user_avatar"] as? String {
            self.avatarUrl = avatarURL
        }
        
        if let gender = dict["gender"] as? String {
            self.gender = gender
        }
        
        if let email = dict["email"] as? String {
            self.email = email
        }

        if let phone = dict["phone"] as? String {
            self.phone = phone
        }
        
        if let birthday = dict["birthday"] as? String {
            self.birthday = birthday
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: birthday)
            
            if let year = date?.gregorianYear {
                birthYear = "\(year)"
            }
            if let age = date?.age {
                self.age = age
            }
        }
        
        if let description = dict["description"] as? String {
            self.userDescription = description
        }
        
        if let likes = dict["likes"] as? String {
            self.likes = Int64(likes)!
        }
        
        if let followers = dict["followers"] as? String {
            self.followers = Int(followers)!
        }
        
        if let followers = dict["followers"] as? Int {
            self.followersNumber = followers
        }
        
        if let following = dict["following"] as? String {
            self.following = Int(following)!
        }
        
        if let isLive = dict["is_live"] as? String {
            self.liveId = Int(isLive)!
        }
        
        if let isFeatured = dict["is_featured"] as? NSNumber {
            self.isFeatured = isFeatured.boolValue
        }
        
        if let isFavourite = dict["is_favourite"] as? NSNumber {
            self.isFavourite = isFavourite.boolValue
        }
        
        if let accountConfirmed = dict["account_confirmed"] as? NSNumber {
            self.accountConfirmed = accountConfirmed.boolValue
        }
        
        if let isPrivate = dict["is_private"] as? NSNumber {
            self.isPrivate = isPrivate.boolValue
        }
        
        if let followRequested = dict["follow_requested"] as? NSNumber {
            self.followRequested = followRequested.boolValue
        }
        
        if let followRequestId = dict["follow_request_id"] as? Int {
            self.followRequestId = followRequestId
        }
        
        if let isBanned = dict["is_banned"] as? NSNumber {
            self.isBanned = isBanned.boolValue
        }

        if let role = dict["role"] as? String {
            self.role = role
        }

        if let city = dict["city"] as? String {
            self.city = city
        }
        
        if let country = dict["country"] as? String {
            self.country = country
        }
        
        if let id = dict["user_id"] as? String {
            self.id = id
        } else if let id = dict["user_id"] as? NSNumber {
            self.id = String(id.int64Value)
        }
        
        if let creationTime = dict["creation_time"] as? String {
            self.creationTime = Utils.formatDateFromISODate(creationTime)
        }
        
        if let lastUpdateTime = dict["last_update"] as? String {
            self.lastUpdate = Utils.formatDateFromISODate(lastUpdateTime)
        }
        
        if let isFollowingMe = dict["following_me"] as? NSNumber {
            self.isFollowingMe = isFollowingMe.boolValue
        }
        
        if let isFollowingThem = dict["am_following"] as? NSNumber {
            self.isFollowingThem = isFollowingThem.boolValue
        } else if let isFollowing = dict["is_following"] as? NSNumber {
            self.isFollowingThem = isFollowing.boolValue
        }
        
        if let pushNotification = dict["push_notification"] as? NSNumber {
            self.pushNotification = pushNotification.boolValue
        }
        
        if let statusLevelId = dict["status_level_id"] as? NSNumber {
            self.statusLevelId = statusLevelId.floatValue
            // populate statusLevel if statuslevels list is available
                //  updateUserStatusLevel()
        }
        
        if let reviewState = dict["review_state"] as? String {
            self.idReviewState = IDReviewState(rawValue: reviewState)!
        }
        
        if let isPeeksUser = dict["peeks_user"] as? NSNumber {
            self.peeksUser = isPeeksUser.boolValue
        }
        
        if let isWatching = dict["watching"] as? NSNumber {
            self.isWatching = isWatching.boolValue
        }
        
        if let viewerRating = dict["viewer_rating"] as? String {
            self.viewerRating = Float(viewerRating)!
        }
        
        if let overallRating = dict["overall_rating"] as? String {
            self.overallRating = Float(overallRating)!
        }
        
        if let isBlocked = dict["am_blocking"] as? NSNumber {
            self.isBlocked = isBlocked.boolValue
        }
        
        if let termsAccepted = dict["terms_accepted"] as? NSNumber {
            self.termsAccepted = termsAccepted.boolValue
        }
        
        if let canSubscribe = dict["can_subscribe"] as? NSNumber {
            self.canSubscribe = canSubscribe.boolValue
        }
        
        if let subscribed = dict["subscribed"] as? NSNumber {
            self.subscribed = subscribed.boolValue
        }
        if let postCount = dict["post_count"] as? Int {
            self.post_count = postCount
        }
        if let prefix = dict["prefix"] as? String {
            self.prefix = prefix
        }
    }
    
//    convenience init(user: KeekUserCoreData) {
//        self.init()
//        self.gUserId = user.gUserId ?? ""
//        self.socialNetworkId = user.socialNetworkId ?? ""
//        self.socialNetworkType = user.socialNetworkType ?? ""
//        self.username = user.username ?? ""
//        self.fullname = user.fullname ?? ""
//        self.avatarUrl = user.avatarUrl ?? ""
//        self.gender = user.gender ?? ""
//        self.email = user.email ?? ""
//        self.phone = user.phone ?? ""
//        self.birthday = user.birthday ?? ""
//            let dateFormatter = DateFormatter()
//            dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            let date = dateFormatter.date(from: birthday)
//            
//            if let year = date?.gregorianYear {
//                birthYear = "\(year)"
//            }
//            if let age = date?.age {
//                self.age = age
//            }
//        
//        self.userDescription = user.userDescription ?? ""
//        self.likes = user.likes
//        self.followers = Int(user.followers)
//        self.followersNumber = Int(user.followers)
//        self.following = Int(user.following)
//        self.liveId = Int(user.liveId)
//        self.isFeatured = user.isFeatured
//        self.isFavourite = user.isFavorite
//        self.isPrivate = user.isPrivate
//        self.followRequested = user.followRequested
//        self.followRequestId = Int(user.followRequestId)
//        self.isBanned = user.isBanned
//        self.role = user.role ?? ""
//        self.city = user.city ?? ""
//        self.country = user.country ?? ""
//        self.id = user.id ?? ""
//        self.creationTime = user.creationTime
//        self.lastUpdate = user.lastUpdate
//        self.isFollowingMe = user.isFollowingMe
//        self.isFollowingThem = user.isFollowingThem
//        self.pushNotification = user.pushNotification
//        self.idReviewState = IDReviewState(rawValue: user.idReviewState ?? "")!
//        self.peeksUser = user.peeksUser
//        self.isWatching = user.isWatching
//        self.viewerRating = user.viewerRating
//        self.overallRating = user.overallRating
//        self.isBlocked = user.isBlocked
//        self.termsAccepted = user.termsAccepted
//        self.canSubscribe = user.canSubscribe
//        self.subscribed = user.subscribed
//        self.post_count = Int(user.post_count)
//        self.prefix = user.prefix ?? ""
//        self.accountConfirmed = user.accountConfirmed
//    }
    
    
    func getDict() -> [String: AnyObject] {
        
        var dict: [String: AnyObject] = [:]
        
        dict["gUserId"] = self.gUserId as AnyObject?
        dict["social_network_id"] = self.socialNetworkId as AnyObject?
        
        dict["social_network_type"] = self.socialNetworkType as AnyObject?
        
        dict["username"] = self.username as AnyObject?
        
        dict["fullname"] = self.fullname as AnyObject?
        
        dict["avatar"] = self.avatarUrl as AnyObject?
        
        dict["gender"] = self.gender as AnyObject?
        
        dict["email"] = self.email as AnyObject?
        
        dict["phone"] = self.phone as AnyObject?
        
        dict["description"] = self.userDescription as AnyObject?
        
        dict["birthday"] = self.birthday as AnyObject?
        
        dict["likes"] = self.likes as? AnyObject
        
        dict["followers"] = self.followers as AnyObject?
        
        dict["following"] = self.following as AnyObject?
        
        dict["is_live"] = self.liveId as AnyObject?
        
        dict["is_featured"] = self.isFeatured as AnyObject?
        
        dict["is_banned"] = self.isBanned as AnyObject?
        
        dict["role"] = self.role as AnyObject?
        
        dict["city"] = self.city as AnyObject?
        
        dict["country"] = self.country as AnyObject?
        
        dict["user_id"] = self.id as AnyObject?
        
        if let creationTime = self.creationTime {
            dict["creation_time"] = Utils.convertDateToISODate(creationTime) as AnyObject?
        }
        
        if let lastUpdateTime = self.lastUpdate {
            dict["last_update"] = Utils.convertDateToISODate(lastUpdateTime) as AnyObject?
        }
        
        dict["following_me"] = self.isFollowingMe as AnyObject?
        
        dict["am_following"] = self.isFollowingThem as AnyObject?
        
        dict["peeks_user"] = self.peeksUser as AnyObject?
        
        return dict
    }
    
    func parseClubAudienceUser(_ dict: [String: AnyObject]) {
        if let username = dict["username"] as? String {
            self.username = username
        }
        
        if let id = dict["user_id"] as? String {
            self.id = id
        } else if let id = dict["user_id"] as? NSNumber {
            self.id = String(id.int64Value)
        }
        
        if let avatar = dict["avatar"] as? String {
            self.avatarUrl = avatar
        }
        if let followers = dict["followers"] as? Int {
            self.followersNumber = followers
        }
    }
    

    
    
    func parsePeeksUserfromMessage(_ dict: [String: AnyObject]) {

        if let username = dict["name"] as? String {
            self.username = username
        }

        if let avatar = dict["avatar"] as? String {
            self.avatarUrl = avatar
        }
        
        if let isFeatured = dict["is_featured"] as? NSNumber {
            self.isFeatured = isFeatured.boolValue
        }
        
        if let isBlocked = dict["isBlocked"] as? NSNumber {
            self.isBlocked = isBlocked.boolValue
        }
        
        if let role = dict["role"] as? String {
            self.role = role
        }
        
        if let city = dict["city"] as? String {
            self.city = city
        }
        
        if let country = dict["country"] as? String {
            self.country = country
        }
        
        if let id = dict["user_id"] as? String {
            self.id = id
        } else if let id = dict["user_id"] as? NSNumber {
            self.id = String(id.int64Value)
        }

        if let isFollowingMe = dict["following_me"] as? NSNumber {
            self.isFollowingMe = isFollowingMe.boolValue
        }
        
        if let isFollowingThem = dict["am_following"] as? NSNumber {
            self.isFollowingThem = isFollowingThem.boolValue
        }
        
        if let isPeeksUser = dict["peeks_user"] as? NSNumber {
            self.peeksUser = isPeeksUser.boolValue
        }
    }
    
    func getMessageDict() -> [String: AnyObject] {
        
        var dict: [String: AnyObject] = [:]

        dict["name"] = self.username as AnyObject?
        
        if let avatarUrl = self.avatarUrl {
            dict["avatar"] = avatarUrl as AnyObject?
        }
        
        if self.isFeatured == true {
            dict["is_featured"] = 1 as AnyObject?
        } else {
            dict["is_featured"] = 0 as AnyObject?
        }
        
        if self.isBlocked == true {
            dict["is_blocked"] = 1 as AnyObject?
        } else {
            dict["is_bloked"] = 0 as AnyObject?
        }
        
        dict["user_id"] = self.id as AnyObject?
        
        dict["following_me"] = self.isFollowingMe as AnyObject?
        
        dict["am_following"] = self.isFollowingThem as AnyObject?
        
        dict["peeks_user"] = self.peeksUser as AnyObject?
        
        return dict
    }
    
    func getJSON(_ completion:@escaping (_ success: Bool, _ json: Data?, _ error: String?) -> Void) {
        let dict = self.getDict()
        
        Utils.encodeJSON(dict) { (success, json, error) in
            completion(success, json, error)
        }
    }
    
//    static func createPeeksUserFromJSON(_ json: Data, completion:@escaping (_ success: Bool, _ user: PeeksUser?, _ error: String?) -> Void) {
//        
//        Utils.decodeJSON(json) { (success, dict, error) in
//            if success {
//                let user = PeeksUser(params: dict!)
//                completion(true, user, nil)
//            } else {
//                completion(false, nil, error)
//            }
//        }
//    }
    
    static func parseListOfUsers(_ users: [[String: AnyObject]]) -> [User] {
        
        var arrayOfUsers: [User] = []
        for user in users {
            let userObj = User(params: user)
            arrayOfUsers.append(userObj)
        }
        
        return arrayOfUsers
    }
    
    static func parseListOfUsersFromMeta(_ userParams: [[String: AnyObject]]) -> [User] {
        
        var users: [User] = []
        
        for userParam in userParams {
            
            if let params = userParam["meta"] as? [String: AnyObject] {
                let userObj = User(params: params)
                if let username = userParam["name"] as? String {
                    userObj.username = username
                }
                
                if let avatar = userParam["thumbnail"] as? String {
                    userObj.avatarUrl = avatar
                }
                
                if let id = userParam["id"] as? String {
                    userObj.id = id
                } else if let id = userParam["id"] as? NSNumber {
                    userObj.id = String(id.int64Value)
                }
                
                if let meta = userParam["Meta"] as? [AnyHashable: AnyObject] {
                    userObj.isFollowingThem = meta["am_following"] as? Bool ?? false
                }
                
                if let isBlocked = userParam["isBlocked"] as? NSNumber {
                    userObj.isBlocked = isBlocked.boolValue
                }
                
                users.append(userObj)
                
            }
 
        }
        
        return users
    }

//    static func parseListOfWatchingUsers(_ users: [[String: AnyObject]]) -> [PeeksUser] {
//        
//        var arrayOfUsers: [PeeksUser] = []
//        for user in users {
//            let userObj = PeeksUser(params: user)
//            if userObj.isWatching {
//                arrayOfUsers.append(userObj)
//            }
//        }
//        
//        return arrayOfUsers
//    }
    
//    class func serialize(user: PeeksUser) -> NSDictionary {
//
//        var values: [AnyObject] = [user.id, user.username]
//        var keys = ["user_id", "name"]
//
//        if let avatar = user.avatarUrl {
//            values.append(avatar)
//            keys.append("avatar")
//        }
//
//        let dictionary: NSDictionary = NSDictionary(objects: values, forKeys: keys)
//        return dictionary
//    }
    
//    class func deserialize(data: NSDictionary) -> PeeksUser {
//        let user        = PeeksUser()
//        user.id         = data["user_id"] as! String
//        user.username   = data["name"] as! String
//        user.avatarUrl  = data["avatar"] as? String
//
//        return user
//    }
//    static func parseListOfSearch(_ users: [SearchUserList]) -> [PeeksUser] {
//        
//        var arrayOfUsers: [PeeksUser] = []
//        for user in users {
//            let userObj = PeeksUser(searchUser: user)
//            
//                arrayOfUsers.append(userObj)
//         
//        }
//        
//        return arrayOfUsers
//    }
    
    func getAvatarImageURL() -> URL? {
        if let avatarUrl = self.avatarUrl {
            if let url = URL(string: avatarUrl) {
                return url
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func chatUser() -> ChatUser {
        let cUser = ChatUser()
        
        cUser.userID = self.id
        cUser.userName = self.username
        cUser.avatarURL = self.avatarUrl ?? ""
        
        return cUser
    }
    
    func getLocationDescription() -> String {
        var city = ""
        var country = ""
        
        if self.city != "" && self.city != "unknown"{
            city = self.city.capitalizingFirstLetter()
        }
        
        if self.country != "" && (self.city != "unknown" && !self.city.isEmpty) {
            let locale = Locale.current
            let displayNameString = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: self.country)
            if let c = displayNameString {
                country = c.capitalizingFirstLetter()
            }
        }
        
        if city != "" && country != ""{
            return city + ", " + country
        } else if city != "" {
            return city
        } else {
            return country
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? User {
            return id == rhs.id
        }
        return false
    }
    
//    func updateUserStatusLevel() {
//        if StatusLevel.statusLevels.count > 0 && self.statusLevelId != 0 {
//            self.statusLevel = StatusLevel.getStatusLevelFromId(self.statusLevelId)
//        }
//    }
    
   static func parseKeekChatUser(_ users: [KeekChatUser]) -> [User] {
        var arrayOfUsers: [User] = []
        for user in users {
            let userObj = User(chatUser: user)
            arrayOfUsers.append(userObj)
        }
        return arrayOfUsers
    }
    
    convenience init(chatUser: KeekChatUser) {
        self.init()
        self.id = chatUser.externalUserId
        self.username = chatUser.userName
        self.avatarUrl = chatUser.dpUrl
    }
}
