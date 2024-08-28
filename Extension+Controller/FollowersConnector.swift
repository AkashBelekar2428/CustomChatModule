//
//  FollowersConnector.swift
//  Peeks
//
//  Created by Aaron Wong on 2016-04-01.
//  Copyright © 2016 Riavera. All rights reserved.
//

import UIKit

class FollowersConnector: Connector {
    
    /**
     * List of Followers
     * GET /user/{id}/followers
     *
     * List of followers of the supplied User Id.
     */
    func getListOfFollowers(_ id: String,
                            name: String?,
                            order: String?,
                            offset: Int?,
                            limit: Int?,
                            completion: @escaping (_ success: Bool, _ error: String?, _ followers: [User]?, _ totalRows: Int?, _ offset: Int?, _ limit: Int?) -> Void) {
        
        let ts = timestamp
        let path = "/user/\(id)/followers"
        
        var queryString = "?ts=\(ts)"
        
        if let name = name, let encoded = name.URLEncodedString() {
            queryString += "&name=\(encoded)"
        }
        
        if let order = order, let encoded = order.URLEncodedString() {
            queryString += "&order=\(encoded)"
        }
        
        if let offset = offset {
            queryString += "&offset=\(offset)"
        }
        
        if let limit = limit {
            queryString += "&limit=\(limit)"
        }
        
        let authToken: String = self.buildHash(RequestType.GET,
                                                uri: path,
                                                timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.GET(path, queryParams: queryString, authValue: authString) { (data, error, success) in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    var usersArray: [User] = []
                    if let users = data["followers"] as? [[String: AnyObject]] {
                        usersArray = User.parseListOfUsers(users)
                    }
//                    let offset : Int = Int(data["offset"] as! String)!
//                    let limit : Int = Int(data["limit"] as! String)!
//                    let totalRows : Int = data["total_rows"] as! Int
                    
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
                    
                    completion(true, nil, usersArray, totalRows, offset, limit)
                } else {
                    completion(false, "No data found in response", nil, nil, nil, nil)
                }
            } else {
                completion(false, error!, nil, nil, nil, nil)
            }
        }
    }
    
    /**
     * List of Followings
     * GET /user/{id}/followings
     *
     * List of followings of the supplied User Id.
     */
    func getListOfFollowing(_ id: String,
                            name: String?,
                            order: String?,
                            offset: Int?,
                            limit: Int?,
                            completion: @escaping (_ success: Bool, _ error: String?, _ followings: [User]?, _ totalRows: Int?, _ offset: Int?, _ limit: Int?) -> Void) {
        
        let ts = timestamp
        let path = "/user/\(id)/followings"
        
        var queryString = "?ts=\(ts)"
        
        if let name = name, let encoded = name.URLEncodedString() {
            queryString += "&name=\(encoded)"
        }
        
        if let order = order, let encoded = order.URLEncodedString() {
            queryString += "&order=\(encoded)"
        }
        
        if let offset = offset {
            queryString += "&offset=\(offset)"
        }
        
        if let limit = limit {
            queryString += "&limit=\(limit)"
        }
        
        let authToken: String = self.buildHash(RequestType.GET,
                                                uri: path,
                                                timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.GET(path, queryParams: queryString, authValue: authString) { (data, error, success) in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    var usersArray: [User] = []
                    if let users = data["followings"] as? [[String: AnyObject]] {
                        usersArray = User.parseListOfUsers(users)
                    }
                    
//                    let offset : Int = Int(data["offset"] as! String)!
//                    let limit : Int = Int(data["limit"] as! String)!
//                    let totalRows : Int = data["total_rows"] as! Int
                    
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
                    
                    completion(true, nil, usersArray, totalRows, offset, limit)
                } else {
                    completion(false, "No data found in response", nil, nil, nil, nil)
                }
            } else {
                completion(false, error!, nil, nil, nil, nil)
            }
        }
    }
    
    /**
     * Unfollow a user
     * POST /user/{id}/unfollowuser
     *
     * Unfollow a user.
     */
    func followerUser(_ followId: String, pushNotification: Bool?, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let ts = timestamp
        if let userId = ChatModel.sharedInstance.users?.id {
            let path = "/user/\(userId)/followuser"
            
            var params: [String: AnyObject] = ["ts": ts as AnyObject, "user_id": userId as AnyObject, "follow_id": followId as AnyObject]
            
            if let pushNotification = pushNotification {
                params["push_notification"] = pushNotification as AnyObject?
            }
            
            let authToken = self.buildHash(RequestType.POST,
                                           uri: path, timeStamp: ts,
                                           authentication: "\(userId)\(followId)",
                                           apiSecret: ChatModel.sharedInstance.apiSecret,
                                           sharedSecret: ChatModel.sharedInstance.sharedSecret)
            
            let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
            
            http.POST(path, authValue: authString, parameters: params) { (_ data, error, success) in
                if success {
                    completion(true, nil)
                } else {
                    completion(false, error!)
                }
            }
        }
    }
    
    /**
     * Unfollow a user
     * POST /user/{id}/unfollowuser
     *
     * Unfollow a user.
     */
    func followRequestUser(_ followId: String, pushNotification: Bool?, completion:@escaping (_ success: Bool, _ error: String?,_ requestId: String?) -> Void) {
        let ts = timestamp
        if let userId = ChatModel.sharedInstance.users?.id {
            let path = "/user/\(userId)/followuserrequest"
            
            var params: [String: AnyObject] = ["ts": ts as AnyObject, "user_id": userId as AnyObject, "follow_id": followId as AnyObject]
            
            if let pushNotification = pushNotification {
                params["push_notification"] = pushNotification as AnyObject?
            }
            
            let authToken = self.buildHash(RequestType.POST,
                                           uri: path, timeStamp: ts,
                                           authentication: "",
                                           apiSecret: ChatModel.sharedInstance.apiSecret,
                                           sharedSecret: ChatModel.sharedInstance.sharedSecret)
            
            let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
            
            http.POST(path, authValue: authString, parameters: params) { (_ data, error, success) in
                if success {
                    if let data = data!["data"] as? [String: AnyObject] {
                        completion(true, nil, data["follow_request_id"] as? String)
                    } else {
                        completion(false, "No data found in response", nil)
                    }
                } else {
                    completion(false, error!, nil)
                }
            }
        }
    }
    
    /**
     * Auto Follow an user
     * POST /post/follow-user
     *
     * Autofollow an user.
     */
    func autofollowUser(_ postId: String, completion:@escaping (_ success: Bool, _ error: String?,_ requestId: String?) -> Void) {
        let ts = timestamp
       
            let path = "/post/follow-user"
        if  let userID = ChatModel.sharedInstance.users?.id {
            var params: [String: AnyObject] = ["ts": ts as AnyObject, "user_id": userID as AnyObject, "post_id": postId as AnyObject]
            
            
            
            let authToken = self.buildHash(RequestType.POST,
                                           uri: path, timeStamp: ts,
                                           authentication: "",
                                           apiSecret: ChatModel.sharedInstance.apiSecret,
                                           sharedSecret: ChatModel.sharedInstance.sharedSecret)
            
            let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
            http.POST(path, authValue: authString, parameters: params) { (_ data, error, success) in
                if success {
                    
                    completion(true, nil, nil)
                    
                } else {
                    completion(false, nil, nil)
                }
            }
        }
        
    }
    
    /**
     * List of Followers
     * GET /user/{id}/followers
     *
     * List of followers of the supplied User Id.
     */
    func unfollowerUser(_ followId: String, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let ts = timestamp
        if let userId = ChatModel.sharedInstance.users?.id {
            let path = "/user/\(userId)/unfollowuser"
            
            let params: [String: AnyObject] = ["ts": ts as AnyObject, "user_id": userId as AnyObject, "follow_id": followId as AnyObject]
            
            let authToken = self.buildHash(RequestType.POST,
                                           uri: path, timeStamp: ts,
                                           authentication: "\(userId)\(followId)",
                apiSecret: ChatModel.sharedInstance.apiSecret,
                sharedSecret: ChatModel.sharedInstance.sharedSecret)
            
            let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
            
            http.POST(path, authValue: authString, parameters: params) { (_ data, error, success) in
                if success {
                    completion(true, nil)
                } else {
                    completion(false, error!)
                }
            }
        }
    }
    
    func removefollowerUser(followId: String, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let ts = timestamp
        if let userId = ChatModel.sharedInstance.users?.id {
            let path = "/user/\(userId)/removefollowuser"
            
            let params: [String: AnyObject] = ["ts": ts as AnyObject, "user_id": userId as AnyObject, "follow_id": followId as AnyObject]
            
            let authToken = self.buildHash(RequestType.POST,
                                           uri: path, timeStamp: ts,
                                           authentication: "\(userId)\(followId)",
                apiSecret: ChatModel.sharedInstance.apiSecret,
                sharedSecret: ChatModel.sharedInstance.sharedSecret)
            
            let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
            
            http.POST(path, authValue: authString, parameters: params) { (_ data, error, success) in
                if success {
                    completion(true, nil)
                } else {
                    completion(false, error!)
                }
            }
        }
    }
    
    /**
     * Update Request Status
     * PUT "/user/\(userId)/removefollowuser"
     *
     * Update a request status.
     */
    func updateRequestStatus(requestId: [Int],followStatus: String, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let ts = timestamp
        if let userId = ChatModel.sharedInstance.users?.id {
            let path = "/user/\(userId)/followuserrequest"
            
            let params: [String: AnyObject] = ["ts": ts as AnyObject, "follow_request_id": requestId as AnyObject, "follow_status": followStatus as AnyObject]
           
        let authToken: String = self.buildHash(RequestType.PUT,
                                               uri: path, timeStamp: ts,
                                               authentication: "",
                                               apiSecret: ChatModel.sharedInstance.apiSecret,
                                               sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.PUT(path, authValue: authString, parameters: params) { (_ data, error, success) in
            if success {
                completion(true, nil)
            } else {
                completion(false, error!)
            }
        }
    }
    }
    
    /**
     * Get Notification List
     * GET /notify/message/{user_id}
     *
     */
    
    func getFollowRequestList(offset: Int, limit: Int,completion:@escaping (_ success: Bool, _ error: String?, _ requests: [FollowRequest]?, _ totalRows: Int?) -> Void) {
        
        let ts = timestamp
        let path = "/user/\(ChatModel.sharedInstance.userId)/followuserrequest"
        let queryString = "?ts=\(ts)&offset=\(offset)&limit=\(limit)&follow_status=pending"
        
        let authToken: String = self.buildHash(RequestType.GET,
                                                uri: path, timeStamp: ts,
                                                authentication: "",
                                               
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.GET(path, queryParams: queryString, authValue: authString) { (data, error, success) in
            
            if success {
                var array: [FollowRequest] = []
                if let data = data!["data"]?["follow_request"] as? [[String: AnyObject]] {
                    array = FollowRequest.parseRequestList(data)

                }
                var totalRows = 0
                if let xInt = data!["data"]?["total_rows"] as? Int {
                    totalRows = xInt
                }
                completion(true, nil, array, totalRows)
            } else {
                completion(false, error!, nil, nil)
            }
        }
    }
}



