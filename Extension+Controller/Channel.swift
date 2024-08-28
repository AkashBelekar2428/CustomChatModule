//
//  Channel.swift
//  Peeks
//
//  Created by Sara Al-Kindy on 2016-12-22.
//  Copyright © 2016 Riavera. All rights reserved.
//

enum ChannelType {
    case channel
    case group
    case custom
    case user
    
    static func getTypeFromString(_ type: String) -> ChannelType {
        if type == "channel"{
            return .channel
        }
        
        if type == "group"{
            return .group
        }
        
        if type == "custom"{
            return .custom
        }
        
        if type == "user"{
            return .user
        }
        
        return .channel
    }
}
 
 public enum ResultStatus<T> {
    case success(T)
    case failure(String)
 }
 
 public typealias ChannelCallback<T> = (ResultStatus<T>) -> Void

import UIKit

class Channel: NSObject {
    
    var meta: Meta?
    var id: Int?
    var name: String?
    var thumbnail: String?
    var type: ChannelType?
    var streams = [Stream]()
    var groupChannels = [Channel]()
    var users = [User]()
    var channelOffset: Int?
    var userOffset: Int = 0
    var channelLimit: Int?
    var channelTotalRows: Int?
    var allChannelsLoaded = false
    var featuredStreamsLoaded = false
	var numberOfFeaturedStreams: Int = 0
    
    override init () {
        
        self.meta       = nil
        self.id         = nil
        self.name       = ""
        self.thumbnail  = nil
        self.type       = .channel
        self.channelOffset     = 0
        self.channelLimit      = 15
        self.channelTotalRows  = nil
    }
    
    convenience init(params: [String: AnyObject]) {
        self.init()
        self.parse(params)
    }
    
    func parse(_ dict: [String: AnyObject]) {
        
        if let id = dict["id"] as? String {
            self.id = Int(id)
        }
        
        if let name = dict["name"] as? String {
            self.name = name
        }
        
        if let thumbnail = dict["thumbnail"] as? String {
            self.thumbnail = thumbnail
        }
        
        if let type = dict["type"] as? String {
            self.type = ChannelType.getTypeFromString(type)
        }
        
        if let offset = dict["offset"] as? NSNumber {
            self.channelOffset = offset.intValue
        }
        
        if let limit = dict["limit"] as? NSNumber {
            self.channelLimit = limit.intValue
        }
        
        if let totalRows = dict["totalRows"] as? NSNumber {
            self.channelTotalRows = totalRows.intValue
        }
        
        if let meta = dict["meta"] as? [String: AnyObject] {
            self.meta = Meta(params: meta)
        }
        
        if meta?.customLayout == .userGroup {
            self.type = ChannelType.user
        }
        
    }
    
    static func parseList(_ channels: [[String: AnyObject]]) -> [Channel] {
        
        var array: [Channel] = []
        for channel in channels {
            let channelObj = Channel(params: channel)
            array.append(channelObj)
        }
        
        return array
    }
    
    static func parseFromCache(_ cachedData: Data) -> [Channel] {
        
        let jsonChildren = NSKeyedUnarchiver.unarchiveObject(with: cachedData) as? [String: AnyObject] ?? [:]
         var array: [Channel] = []
        
        if let channels = jsonChildren["children"] as? [[String: AnyObject]] {
            array = Channel.parseList(channels)
        }
        
        return array
    }
        
    func loadStreams(_ order: String?, beforeDate: String?, afterDate: String?, completion:@escaping ChannelCallback<Int>) {
        if let featuredMeta = meta?.featuredMeta {
			if featuredStreamsLoaded {
				loadRegularStreams(order: order, beforeDate: beforeDate, afterDate: afterDate, completion: completion)
			} else {
				loadFeaturedStreams(featuredMeta: featuredMeta, order: order, beforeDate: beforeDate, afterDate: afterDate, completion: completion)
			}
        } else {
            loadRegularStreams(order: order, beforeDate: beforeDate, afterDate: afterDate, completion: completion)
        }
    }
    
    func loadFeaturedStreams(featuredMeta: FeaturedMeta, order: String?, beforeDate: String?, afterDate: String?, completion:@escaping ChannelCallback<Int>) {
        
        var channelId = featuredMeta.channelId
        var orderParam = order
        var beforeDateParam = beforeDate
        var afterDateParam = afterDate
        var offsetParam = (streams.count - featuredMeta.featuredLimit <= 0) ? 0 : streams.count - featuredMeta.featuredLimit
        var limit =  20
 
        if streams.count == 0 && !featuredStreamsLoaded {
            channelId = featuredMeta.featuredChannelId
            orderParam = nil
            beforeDateParam = nil
            afterDateParam = nil
            offsetParam = 0
            limit = featuredMeta.featuredLimit
        }
        featuredStreamsLoaded = true
        ChannelsConnector().getListOfStreamsForChannel(channelId, order: orderParam, beforeDate: beforeDateParam, afterDate: afterDateParam, offset: offsetParam, limit: limit) { (success, error, streams, _, _, totalRows) in
            if success, let streams = streams {
				
                self.numberOfFeaturedStreams = streams.count
				
                if self.streams.count == 0 {
                    for stream in streams {
                      //  stream.featured = true
                    }
                    self.streams = streams
                    self.loadRegularStreams(order: order, beforeDate: beforeDate, afterDate: afterDate, completion: completion)
                } else {
                    self.streams += streams
                    completion(.success(totalRows + featuredMeta.featuredLimit))
                }
                
            } else {
                completion(.failure(error ?? "Something went wrong"))
            }
        }
    }
    
    func loadRegularStreams(order: String?, beforeDate: String?, afterDate: String?, completion:@escaping ChannelCallback<Int>) {
        if let channelID = id {
			ChannelsConnector().getListOfStreamsForChannel(channelID, order: order, beforeDate: beforeDate, afterDate: afterDate, offset: (streams.count - self.numberOfFeaturedStreams < 0) ? 0 : streams.count - numberOfFeaturedStreams, limit: 20) { (success, error, streams, _, _, totalRows) in
                if success, let streams = streams {
                    for stream in streams {
                  //      stream.featured = false
                    }
                    self.streams += streams
                    completion(.success(totalRows))
                } else {
                    completion(.failure(error ?? "Something went wrong"))
                }
            }
        }
    }

    func loadChannels(_ completion:@escaping ChannelCallback<String>) {
        if let groupID = self.id {
            ChannelsConnector().lookupChannelByGroupIDChannels(groupID, offset: self.channelOffset, limit: 15) { (success, error, channels, _, limit, totalRows) in
                if success {
                    if let channels = channels {
                        self.groupChannels +=  channels
                        self.channelOffset = self.groupChannels.count
                    }
                    
                    if let limit = limit {
                        self.channelLimit = limit
                    }
                    
                    if let totalRows = totalRows {
                        self.channelTotalRows = totalRows
                    }
                    
                    if self.channelTotalRows == self.groupChannels.count {
                        self.allChannelsLoaded = true
                    }
                    
                    completion(.success("ok"))
                    
                } else {
                    completion(.failure(error ?? "Something went wrong"))
                }
            }
        }
    }
    
    func loadUsers(_ completion:@escaping ChannelCallback<String>) {
        if let groupID = self.id {
            ChannelsConnector().lookupUsersByGroupID(groupID, offset: self.userOffset, limit: 15) { (success, error, users, offset, limit, totalRows) in
                if success {
                    
                    if let limit = limit {
                        self.channelLimit = limit
                    }
                    
                    if let totalRows = totalRows {
                        self.channelTotalRows = totalRows
                    }
                    
                    if let users = users {
                        self.users += users.filter({ return !$0.isBlocked })
                        self.userOffset = offset! + limit!
                        
                        if self.users.count <= 10 && self.channelTotalRows != self.groupChannels.count {
                            self.loadUsers(completion)
                            return
                        }
                    }
                    
                    if self.channelTotalRows == self.groupChannels.count {
                        self.allChannelsLoaded = true
                    }
                    
                    completion(.success("ok"))
                } else {
                    completion(.failure(error ?? "Something went wrong"))
                }
            }
        }
    }
    
}

struct FeaturedMeta {
    
    var channelId: Int
    var featuredChannelId: Int
    var featuredLimit: Int
}

class Meta: NSObject {
    
    enum Layout {
        case userGroup
        case `default`
    }
    
    var name: String?
    var type: String?
    var rating: RatingType
    var customLayout: Layout
    var featuredMeta: FeaturedMeta?
    
    override init () {
        self.name       = ""
        self.type       = ""
        self.rating     = .none
        self.customLayout = .default
    }
    
    convenience init(params: [String: AnyObject]) {
        self.init()
        self.parse(params)
    }
    
    func parse(_ dict: [String: AnyObject]) {
        
        if let name = dict["name"] as? String {
            self.name = name
        }
        
        if let type = dict["type"] as? String {
            self.type = type
        }
        
        if let rating = dict["rating"] as? String {
            self.rating = self.rating.parseFromApi(rating)
        }
        
        if let layout = dict["custom_layout"] as? String, layout == "user_group" {
                customLayout = .userGroup
        }
        
        if let featuredMetaArray = dict["aggregate_channels"] as? [[String: AnyObject]] {
            guard let channelId = featuredMetaArray[1]["channel_id"] as? Int else { return }
            guard let featuredChannelId = featuredMetaArray[0]["channel_id"] as? Int else { return }
            guard let featuredChannelLimit = featuredMetaArray[0]["limit"] as? Int else { return }

            self.featuredMeta = FeaturedMeta(channelId: channelId, featuredChannelId: featuredChannelId, featuredLimit: featuredChannelLimit)
        }
    }
}
