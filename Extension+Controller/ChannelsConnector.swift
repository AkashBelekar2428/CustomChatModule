//
//  ChannelsConnector.swift
//  Peeks
//
//  Created by Sara Al-Kindy on 2016-12-22.
//  Copyright © 2016 Riavera. All rights reserved.
//

import UIKit

class ChannelsConnector: Connector {
    
    /**
     * List of Channels
     * GET /channels
     *
     * List channels
     */
    
    let cache: PeeksCache<Data> = PeeksCache<Data>.sharedInstance()
    
    func getListOfChannels(_ userId: String?, system: Bool?, orderBy: String?, offset: Int?, limit: Int?, completion: @escaping (_ success: Bool, _ error: String?, _ channels: [Channel]?) -> Void) {
        
        let ts = timestamp
        var queryString = "?ts=\(ts)"
        let path = "/channels"
        
        var authentication: String = ""
        
        if let userId = userId {
            queryString += "&user_id=\(userId.URLEncodedString()!)"
            authentication += userId.URLEncodedString()!
        }
        
        if let system = system {
            let n = system ? "1" : "0"
            queryString += "&system=\(n.URLEncodedString()!)"
            authentication += n.URLEncodedString()!
        }
        
        if let orderBy = orderBy {
            queryString += "&order_by=\(orderBy.URLEncodedString()!)"
            authentication += orderBy.URLEncodedString()!
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
                                                authentication: authentication,
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.GET(path, queryParams: queryString, authValue: authString) { (data, error, success) in
            if success {
                let c = [Channel]()
                if data != nil {
                    completion(true, nil, c)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                completion(false, error!, nil)
            }
        }
    }
    
    /**
     * Lookup Channel Group By Name
     * GET /channel/group/by_name/{group_name}
     *
     * Lookup a channel group
     */
    func lookupChannelByGroupName(_ groupName: String,
                                  completion:@escaping (_ success: Bool, _ error: String?, _ channels: [Channel]?) -> Void) {
        
        let ts = timestamp
        let queryString = "?ts=\(ts)"
        let path = "/channel/group/by_name/\(groupName)"
        
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
                    var array: [Channel] = []
                    let dataExample: Data = NSKeyedArchiver.archivedData(withRootObject: data)
                    self.cache.addObject(dataExample, forKey: path)
                    
                    if let channels = data["children"] as? [[String: AnyObject]] {
                        array = Channel.parseList(channels)
                    }
                    completion(true, nil, array)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                completion(false, error!, nil)
            }
        }
        
    }
    
    /**
     * List Channel Streams
     * GET /channel/{channel_id}/streams
     *
     * List streams for a channel
     */
    func getListOfStreamsForChannel(_ channelId: Int,
                                    order: String?,
                                    beforeDate: String?,
                                    afterDate: String?,
                                    offset: Int?,
                                    limit: Int?,
                                    completion:@escaping (_ success: Bool, _ error: String?, _ streams: [Stream]?, _ offset: Int, _ limit: Int, _ totalRows: Int) -> Void) {
        
        let ts = timestamp
        var queryString = "?ts=\(ts)"
        let path = "/channel/\(channelId)/streams"
        
        if let order = order {
            queryString += "&order=\(order)"
        }
        
        if let beforeDate = beforeDate {
            queryString += "&before_date=\(beforeDate)"
        }
        
        if let afterDate = afterDate {
            queryString += "&after_date=\(afterDate)"
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
                    var array: [Stream] = []
                    
                    if let streams = data["streams"] as? [[String: AnyObject]] {
                     //   array = Stream.parseListOfStreams(streams)
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
                    
                    completion(true, nil, array, offset, limit, totalRows)
                } else {
                    completion(false, "No data found in response", nil, 0, 0, 0)
                }
            } else {
                completion(false, error!, nil, 0, 0, 0)
            }
        }
    }
    
    /**
     * Lookup Channel Group By ID
     * GET /channel/group/{group_id}
     *
     * Lookup a channel group
     */
    func lookupChannelByGroupIDChannels(_ groupId: Int, offset: Int?, limit: Int?,
                                completion: @escaping (_ success: Bool, _ error: String?, _ channels: [Channel]?, _ offset: Int?, _ limit: Int?, _ totalRows: Int?) -> Void) {
        
        lookupChannelByGroupID(groupId, offset: offset, limit: limit, completion: {
            success, error, object, offset, limit, totalRows in
            var array: [Channel] = []
            
            if success {
                array = Channel.parseList(object!)
                completion(true, nil, array, offset, limit, totalRows)

            } else {
                completion(false, error!, nil, nil, nil, nil)
            }
        })
    
    }
    
    func lookupChannelByGroupID(_ groupId: Int, offset: Int?, limit: Int?,
                                completion: @escaping (_ success: Bool, _ error: String?, _ object: [[String: AnyObject]]?, _ offset: Int?, _ limit: Int?, _ totalRows: Int?) -> Void) {
        
        let ts = timestamp
        var queryString = "?ts=\(ts)"
        
        if let offset = offset, let limit = limit {
            queryString += "&offset=\(offset)&limit=\(limit)"
        }
        
        let path = "/channel/group/\(groupId)"
        
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
                    var object: [[String: AnyObject]] = [[:]]
                    var offset: Int?
                    var limit: Int?
                    var totalRows: Int?
                    
                    if let channels = data["children"] as? [[String: AnyObject]] {
                        object = channels
                    }
                    
                    if let o = data["offset"] as? Int {
                        offset = o
                    } else if let o = Int(data["offset"] as? String ?? "0") {
                        offset = o
                    }
                    
                    if let l = data["limit"] as? Int {
                        limit = l
                    } else if let l = Int(data["limit"] as? String ?? "0") {
                         limit = l
                    }
                    
                    if let t = data["total_rows"] as? Int {
                        totalRows = t
                    }
                    
                    completion(true, nil, object, offset, limit, totalRows)
                } else {
                    completion(false, "No data found in response", nil, nil, nil, nil)
                }
            } else {
                completion(false, error!, nil, nil, nil, nil)
            }
        }
    }
    
    func lookupUsersByGroupID(_ groupId: Int, offset: Int?, limit: Int?,
                              completion:@escaping (_ success: Bool, _ error: String?, _ users: [User]?, _ offset: Int?, _ limit: Int?, _ totalRows: Int?) -> Void) {
        
        lookupChannelByGroupID(groupId, offset: offset, limit: limit, completion: {
            success, error, object, offset, limit, totalRows in
            var array: [User] = []
            
            if success {
                array = User.parseListOfUsersFromMeta(object!)
                completion(true, nil, array, offset, limit, totalRows)
                
            } else {
                completion(false, error!, nil, nil, nil, nil)
            }
        })
        
    }
}
