//
//  UserConnector.swift
//  Peeks
//
//  Created by Sara Al-Kindy on 2016-02-03.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//swiftlint:disable function_parameter_count type_body_length

import UIKit
import MobileCoreServices
//import Kratos

class UserConnector: Connector {
    
    // MARK: - Get User Info
    
    /**
     * Lookup User
     * GET /user/{id}
     *
     * Get the user's profile.
     */
    
    public enum LookupCurrentUserErrorType: Error {
        case server(errorMsg: String)
        case ageRestriction
    }
    
//    func lookUpCurrentUser(completion: @escaping ObjectCallBack<User>) {
//        lookupUser(ChatModel.sharedInstance.userId) { (success, error, User) in
//            if success {
//                if let birthday = User?.birthday {
//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "yyyy-MM-dd"
//                    formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//                    let age = formatter.date(from: birthday)?.age
//                    if let age = age {
//                        if age < 14 {
//                            completion(.failure(LookupCurrentUserErrorType.ageRestriction))
//                        } else {
//                            
//                            ChatModel.sharedInstance.User = User!
//                            
//                            OBNetworkConfiguration.sharedInstance = OBNetworkConfiguration(
//                                userId: ChatModel.sharedInstance.User?.gUserId ??
//                                    ChatModel.sharedInstance.User?.id ?? "",
//                                username: ChatModel.sharedInstance.User?.username ?? "No username",
//                                adConfig: NetworkConfig.adMain,
//                                giftingConfig: NetworkConfig.giftingMain,
//                                commonObjectsConfig: NetworkConfig.commonObjectsMain)
//                            
//                                let user = ChatModel.sharedInstance.User!
//                                user.id = ChatModel.sharedInstance.userId
//                            UserDefaultsUtil.addUserInfo(username:user.username, avatarUrl: user.avatarUrl)
//                                //ChatModel.sharedInstance.loginXMPP()
//                                OfferManager().lookupPublisher()
//                                UserDefaultsUtil.addUserInfo(username:user.username, avatarUrl: user.avatarUrl)
//                            completion(.success(User!))
//                        }
//                    }
//                }
//            } else {
//                completion(.failure(LookupCurrentUserErrorType.server(errorMsg: error!)))
//            }
//        }
//    }
    
    func lookupUser(_ userId: String, completion:@escaping (_ success: Bool, _ error: String?, _ User: User?) -> Void) {
        let ts = timestamp
        
        let queryString = "?ts=\(ts)"

        let path = "/user/\(userId)"
        
        let authToken: String = self.buildHash(RequestType.GET, uri: path,
                                                timeStamp: ts, authentication: "",
                                                apiSecret:ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.GET(path, queryParams: queryString, authValue: authString) { (data, error, success) in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    let User = User(params: data)
                    if !userId.contains("@") {
                        User.id = userId
                    }
                    if userId == ChatModel.sharedInstance.userId {
//                        DBHelper.sharedDBHelper.deleteAllKeekUserData()
//                        DBHelper.sharedDBHelper.createUserDataObject(dict: data)
                    }
                    completion(true, nil, User)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                completion(false, error!, nil)
            }
        }
    }
    
//    func getUserPreferences(_ userId: String, completion:@escaping (_ success: Bool, _ error: String?, _ userPreferences: UserPreferences?) -> Void) {
//        let ts = timestamp
//        
//        let queryString = "?ts=\(ts)"
//        
//        let path = "/user/\(userId)/prefs"
//        
//        let authToken: String = self.buildHash(RequestType.GET,
//                                                uri: path, timeStamp: ts,
//                                                authentication: "",
//                                                apiSecret: ChatModel.sharedInstance.apiSecret,
//                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
//        
//        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
//        
//        http.GET(path, queryParams: queryString, authValue: authString) { (data, error, success) in
//            if success {
//
//                if let data = data!["data"] as? [String: AnyObject] {
//                    let pushSettings = UserPreferences(params: data)
//                    completion(true, nil, pushSettings)
//                } else {
//                    completion(false, "No data found in response", nil)
//                }
//            } else {
//                completion(false, error!, nil)
//            }
//        }
//    }
    
    // MARK: - UPDATE
    
    /**
     * Update User
     * PUT /user/{id}
     *
     * Update user's profile.
     */
    func updateUser(_ params: [String: AnyObject], completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        var params = params
        let ts = timestamp
        let userId = ChatModel.sharedInstance.userId
        let path = "/user/\(userId)"
        
        params["ts"] = ts as AnyObject
        params["userId"] = userId as AnyObject
        
        let authToken = self.buildHash(RequestType.PUT, uri: path,
                                                timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.PUT(path, authValue: authString, parameters: params) { (_ data, error, success) in
            if success {
                completion(true, nil)
            } else {
                completion(success, error!)
            }
        }
    }

    func updateUserPreference(_ preferenceType: UserPreferenceType, value: Bool, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let ts = timestamp
        let userId = ChatModel.sharedInstance.userId
        let path = "/user/\(userId)/prefs"
        
        var params: [String: AnyObject] = ["ts": ts as AnyObject]
        
        params[preferenceType.getKeyString()] = value as AnyObject?
        let authToken: String = self.buildHash(RequestType.PUT,
                                                uri: path,
                                                timeStamp: ts,
                                                authentication: value ? "true" : "false",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.PUT(path, authValue: authString, parameters: params) { (_ data, error, success) in
            if success {
                completion(true, nil)
            } else {
                completion(success, error!)
            }
        }
    }

    /**
     * Insert/Update Avatar
     * POST /user/{user_id}/avatar
     *
     * It inserts or updates the Avatar of the user
     */
    func uploadAvatar(_ userId: String, image: UIImage, delegate: HTTPRequesterDelegate?, completion: ((_ success: Bool, _ error: String?, _ avatarUrl: String?) -> Void)? = nil) {
        let ts = timestamp
        let path = "/user/\(userId)/avatar"
        
        
        //crop image to sqaure 640x640
        let newImage = Utils.cropToBounds(image, width: 640, height: 640)
        
        let percentage = 100
        
        print("percentage: \(percentage)")
        
        let finalPercentage = Float(percentage) / 100
        
        let imageData: Data = NSData(data: newImage.jpegData(compressionQuality: CGFloat(finalPercentage))!) as Data
        
//        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        let filename = getDocumentsDirectory().appendingPathComponent("temp.jpg")
        try? imageData.write(to: URL(fileURLWithPath: filename), options: [.atomic])
        
        let params: [String: AnyObject] = ["ts": ts as AnyObject, "user_id": userId as AnyObject, "file": "\(imageData)" as AnyObject]
        
        let authToken: String = self.buildHash(RequestType.POST,
                                                uri: path,
                                                timeStamp: ts,
                                                authentication: String(userId),
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.delegate = delegate
        
        http.fileUploader(path, authValue: authString, parameters: params, fileName: "file", filePath: filename) { (data, error, success) in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    let image = data["file_url"] as? String
                    completion?(true, nil, image)
                } else {
                    completion?(false, "No data found in response", nil)
                }
            } else {
                completion?(false, error!, nil)
            }
        }
    }
    
    // MARK: - LIST USERS
    
    /**
     * List of Users
     * GET /users
     *
     * List of users with some basic filter/search.     
     */
    func listOfUsers(_ name: String?,
                     username: String?,
                     city: String?,
                     country: String?,
                     live: String?,
                     order: String?,
                     offset: Int?,
                     limit: Int?,isFromSearch: Bool = false,
                     completion:@escaping (_ success: Bool, _ error: String?, _ users: [User]?, _ offset: Int?, _ limit: Int?, _ totalRows: Int?) -> Void) {
        
        let ts = timestamp
        let path = "/users"
        
        var queryParams: String = "?ts=\(ts)"
        var authentication: String = ""
        
        if let name = name, let encoded = name.URLEncodedString() {
            queryParams += "&name=\(encoded)"
            authentication += encoded
        }
        
        if let username = username?.removeUnwantedSpaces(), let encoded = username.removeUnwantedSpaces().URLEncodedString() {
            queryParams += "&username=\(encoded)"
            authentication += username
        }
        
        if let city = city, let encoded = city.URLEncodedString() {
            queryParams += "&city=\(encoded)"
            authentication += encoded
        }
        
        if let country = country, let encoded = country.URLEncodedString() {
            queryParams += "&country=\(encoded)"
            authentication += encoded
        }
        
        if let live = live, let encoded = live.URLEncodedString() {
            queryParams += "&live=\(encoded)"
        }
        
        if let order = order, let encoded = order.URLEncodedString() {
            queryParams += "&order=\(encoded)"
        }
        
        if let offset = offset {
            queryParams += "&offset=\(offset)"
        }
        
        if let limit = limit {
            queryParams += "&limit=\(limit)"
        }
        
        let authToken: String = self.buildHash(RequestType.GET,
                                                uri: path,
                                                timeStamp: ts,
                                                authentication: authentication,
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.GET(path, queryParams: queryParams, authValue: authString) { (data, error, success) in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    print("\(data)")
                    var usersArray: [User] = []
                    if let users = data["users"] as? [[String: AnyObject]] {
                        usersArray = User.parseListOfUsers(users)
                        if offset == 0 && isFromSearch && username == "" {
                           // DBHelper.sharedDBHelper.deleteAllSearchListData()
                        }
                        if offset == 0 && isFromSearch && username == "" {
                          //  DBHelper.sharedDBHelper.parseCoreDataSearchList(users)
                        }
                    }
                    
                    //unwrap optionals, do not force downcast
                    
                    var offset = 0
                    if let xInt = data["offset"] as? Int {
                        offset = xInt
                    } else if let xString = data["offset"] as? String, let xInt = Int(xString) {
                        offset = xInt
                    }
                    
                    var limit = 0
                    if let xInt = data["limit"] as? Int {
                        limit = xInt
                    } else if let xString = data["limit"] as? String, let xInt = Int(xString) {
                        limit = xInt
                    }
                    
                    var totalRows = 0
                    if let xInt = data["total_rows"] as? Int {
                        totalRows = xInt
                    } else if let xString = data["total_rows"] as? String, let xInt = Int(xString) {
                        totalRows = xInt
                    }
                    
                    completion(true, nil, usersArray, offset, limit, totalRows)
                } else {
                    completion(false, "No data found in response", nil, nil, nil, nil)
                }
            } else {
                completion(false, error!, nil, nil, nil, nil)
            }
        }
    }
    
    // MARK: - PRIVATE USER
    
    
    
    
    // MARK: - FAVORITE USER
    
    /**
     * Favorite User
     * POST /user/{user_id}/favoredfollowers
     *
     * It will favorite the user.
     */
    func favoriteUser(_ user: User, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let ts = timestamp
        let path = "/user/\(ChatModel.sharedInstance.userId)/favoredfollowers"
        
        let authToken: String = self.buildHash(RequestType.POST,
                                                uri: path,
                                                timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        var params: [String: AnyObject] = ["ts": ts as AnyObject]
        
        params["follow_id"] = user.id as AnyObject
        http.POST(path, authValue: authString, parameters: params) { (_ data, error, success) in
            if success {
                completion(true, nil)
            } else {
                completion(false, error!)
            }
        }
    }
    
    /**
     * un-Favorite User
     * POST /user/{user_id}/unfavoredfollowers
     *
     * It will favorite the user.
     */
    func unFavoriteUser(_ user: User, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let ts = timestamp
        let path = "/user/\(ChatModel.sharedInstance.userId)/unfavoredfollowers"
        
        let authToken: String = self.buildHash(RequestType.POST,
                                                uri: path,
                                                timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        var params: [String: AnyObject] = ["ts": ts as AnyObject]
        
        params["follow_id"] = user.id as AnyObject
        http.POST(path, authValue: authString, parameters: params) { (_ data, error, success) in
            if success {
                completion(true, nil)
            } else {
                completion(false, error!)
            }
        }
    }
    
    // MARK: - BLOCK/UNBLOCK
    
    /**
     * Block User
     * POST /user/{user_id}/block
     *
     * It will block the user.
     */
    func blockUser(_ user: User, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let ts = timestamp
        let path = "/user/\(user.id)/block"
        
        let authToken: String = self.buildHash(RequestType.POST,
                                                uri: path,
                                                timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        let params: [String: AnyObject] = ["ts": ts as AnyObject]
        
        http.POST(path, authValue: authString, parameters: params) { (_ data, error, success) in
            if success {
                completion(true, nil)
                self.blockUserInChat(user.id)
            } else {
                completion(false, error!)
            }
        }
    }
    
    func blockUserInChat(_ userID: String) {
        print("External user id \(userID)")
        ChatConnector().blockUserForChat(userID) { success, error in
           
            if success {
                ChatCoreDataHelper.sharedChatDBHelper.markUserBlocked(extAppUserId: userID)
            } else {
                print("Error blocking user in chat")
            }
        }
    }
    
    func unblockUserInChat(_ userID: String) {
        ChatConnector().unblockUserForChat(userID) { success, error in
            if success {
                ChatCoreDataHelper.sharedChatDBHelper.markUserUnBlocked(extAppUserId: userID)
            } else {
                print("Error unblocking user in chat")
            }
        }
    }
    
    /**
     * Unblock User
     * POST /user/{user_id}/unblock
     *
     * It will unblock the user.
     */
    func unblockUser(_ user: User, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let ts = timestamp
        let path = "/user/\(user.id)/unblock"
        
        let authToken: String = self.buildHash(RequestType.POST,
                                                uri: path,
                                                timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        let params: [String: AnyObject] = ["ts": ts as AnyObject]
        
        http.POST(path, authValue: authString, parameters: params) { (_ data, error, success) in
            if success {
                completion(true, nil)
                self.unblockUserInChat(user.id)
            } else {
                completion(false, error!)
            }
        }
    }
    
    /**
     * List of Block users
     * GET /user/{user_id}/blocks
     *
     * It will return a list of users whom have been blocked by the signed user.
     */
    func listOfBlockedUsers(_ completion:@escaping (_ success: Bool, _ error: String?, _ users: [User]?) -> Void) {
        let ts = timestamp
        
        let mainUser = ChatModel.sharedInstance
        
        let path = "/user/\(mainUser.userId)/blocks"
        
        let queryParams: String = "?ts=\(ts)"
        
        let authToken: String = self.buildHash(RequestType.GET,
                                                uri: path,
                                                timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.GET(path, queryParams: queryParams, authValue: authString) { (data, error, success) in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    var usersArray: [User] = []
                    if let users = data["users"] as? [[String: AnyObject]] {
                        usersArray = User.parseListOfUsers(users)
                    }
                    
                    completion(true, nil, usersArray)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                completion(false, error!, nil)
            }
        }
    }
    
    /**
     * List of User Status_levels
     * GET /user/status_levels
     *
     * It will return a List the available user status levels.
     */
    func listOfUserStatusLevels(_ completion:@escaping (_ success: Bool, _ error: String?, _ levels: [StatusLevel]?) -> Void) {
        let ts = timestamp
        
        let path = "/user/status_levels"
        
        let queryParams: String = "?ts=\(ts)"
        
        let authToken: String = self.buildHash(RequestType.GET,
                                                uri: path,
                                                timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.GET(path, queryParams: queryParams, authValue: authString) { (data, error, success) in
            if success {
                if let data = data!["data"] as? [[String: AnyObject]] {
                    var levelsArray: [StatusLevel] = []
                    levelsArray = StatusLevel.parseListOfStatusLevels(data)
                    
                    completion(true, nil, levelsArray)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                completion(false, error!, nil)
            }
        }
    }
    
    // MARK: Storage Referral from Deep Link 
    
    /**
     *  Storage Referral from Deep Link
     * POST /referral/{referral_value}
     *
     */
    
    func storeReferralLink(_ referralValue: String,
                           id: String?, action: String,
                           tracker: String?,
                           userId: String?,
                           keekUserId: String?,
                           campaign: String?,
                           completion:@escaping (_ success: Bool, _ error: String?, _ tracker: String?) -> Void) {
        
        let ts = timestamp
        let path = "/referral/\(referralValue)"
        
        var authentication: String = ""
        
        var params: [String: AnyObject] = ["ts": ts as AnyObject]
        
        params["referral_value"] = referralValue as AnyObject?
        
        if let id = id {
            params["id"] = id as AnyObject?
            authentication += id
        }
        
        params["action"] = action as AnyObject?
        authentication += action
        
        if let tracker = tracker {
            params["tracker"] = tracker as AnyObject?
            authentication += tracker
        }
        
        if let user_id = userId {
            params["user_id"] = user_id as AnyObject?
            authentication += user_id
        }
        
        if let keek_user_id = keekUserId {
            params["keek_user_id"] = keek_user_id as AnyObject?
            authentication += keek_user_id
        }
        
        if let campaign = campaign {
            params["campaign"] = campaign as AnyObject?
        } else {
            params["campaign"] = "" as AnyObject?
        }

        let (apiSecret, sharedSecret, usernameShared) = Config.shared.peeks()
        
        let authToken: String = self.buildHash(RequestType.POST, uri: path, timeStamp: ts, authentication: authentication, apiSecret: apiSecret, sharedSecret: sharedSecret)
        
        let authString = "\(usernameShared):\(authToken)"
        
        http.POST(path, authValue: authString, parameters: params) { (data, error, success) in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    if let tracker = data["tracker"] as? String {
                         completion(true, nil, tracker)
                    }
                }
                
                completion(true, nil, nil)
               
            } else {
                completion(false, error, tracker)
            }
        }
        
    }
	
	func getKeekProfile(_ userName: String, password: String, userId: String, completion:@escaping (_ success: Bool, _ error: String?, _ User: User?) -> Void) {
		let ts = timestamp
		
		var queryString = "?ts=\(ts)"
		
		let path = "/keek_profile"
		
		let (apiSecret, sharedSecret, usernameShared) = Config.shared.peeks()
		
		var authentication: String = ""
		
		if !userName.isEmpty {
            let uName: String = userName
			authentication = uName
			queryString += "&keek_username=\(uName)"
			if !password.isEmpty {
                let pword: String = password
				authentication += pword
				queryString += "&password=\(pword)"
			} else if !userId.isEmpty {
                let uId: String = userId
				authentication = uId
				queryString = "?ts=\(ts)"
				queryString += "&keek_user_id=\(uId)"
			} else {
				authentication = ""
				queryString = "?ts=\(ts)"
			}
		} else if !userId.isEmpty {
            let uId: String = userId
			authentication = uId
			queryString += "&keek_user_id=\(uId)"
		}
		
        let authToken: String = self.buildHash(RequestType.GET, uri: path, timeStamp: ts, authentication: authentication, apiSecret: apiSecret, sharedSecret: sharedSecret)
		
		let authString = "\(usernameShared):\(authToken)"
		
		http.GET(path, queryParams: queryString, authValue: authString) { (data, error, success) in
			if success {
				if let data = data!["data"] as? [String: AnyObject] {
					let User = User(params: data)
					completion(true, nil, User)
				} else {
					completion(false, "No data found in response", nil)
				}
			} else {
				completion(false, error!, nil)
			}
		}
	}
    
    
    func generateUserAuthToken(userId: String,  completion:@escaping (_ success: Bool, _ error: String?, _ token: String?) -> Void) {
        let ts = timestamp
        
        let queryString = "?ts=\(ts)"
        
        let path = "/user/\(userId)/generate-auth-token"
        
        let authToken: String = self.buildHash(RequestType.GET,
                                                uri: path, timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.GET(path, queryParams: queryString, authValue: authString) { (data, error, success) in
            if success {
                if let data = data, let response = data["data"] as? [String: Any?], let authToken = response["auth_token"] as? [String: Any?], let token = authToken["token"] as? String {
                    completion(true, nil, token)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                completion(false, error!, nil)
            }
        }
    }
    
    // MARK: Get Referrals
    
    /**
     *  Get Referrals history
     * GET /referral}
     *
     */
    
//    func getReferral(completion:@escaping (_ success: Bool, _ error: String?, _ refObj: ReferralObject?) -> Void) {
//        
//        let ts = timestamp
//        let path = "/referral"
//        
//        let queryString = "?ts=\(ts)"
//        
//        let authToken: String = self.buildHash(RequestType.GET, uri: path,
//                                                timeStamp: ts, authentication: "",
//                                                apiSecret:ChatModel.sharedInstance.apiSecret,
//                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
//        
//        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
//        
//        http.GET(path, queryParams: queryString, authValue: authString) { (data, error, success) in
//            if success {
//                if let data = data!["data"] as? [String: AnyObject] {
//                    let links = data["links"] as? Array<Any>
//                    var refObj : ReferralObject!
//                    var refUrl = ""
//                    var total_ref_count = 0
//                    var total_ref_imp_count = 0
//                    if links != nil {
//                        if links!.count > 0 {
//                            let linkDict = links?[0] as? [String :AnyObject]
//                            if let url = linkDict!["url"] {
//                                refUrl = url as! String
//                            }
//                        }
//                    }
//                    total_ref_count = data["total_referral_count"] as! Int 
//                    total_ref_imp_count = (data["total_referral_imp_earned"] as! Int) 
//                    
//                    refObj = ReferralObject(url: refUrl, total_referral_count: total_ref_count, total_referral_imp_earned: total_ref_imp_count)
//                    completion(true, nil, refObj)
//                } else {
//                    completion(false, "No data found in response", nil)
//                }
//            } else {
//                completion(false, error!, nil)
//            }
//        }
//    }
}
