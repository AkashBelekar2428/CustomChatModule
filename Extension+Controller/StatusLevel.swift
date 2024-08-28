//
//  StatusLevel.swift
//  Peeks
//
//  Created by Amena Amro on 7/25/16.
//  Copyright © 2016 Riavera. All rights reserved.
//

import ObjectiveC
import Foundation
import UIKit

class StatusLevel: NSObject {
    
    var id: Float?
    var order: Float?
    var name: String?
    var shortName: String?
    var levelDescription: String?
    var followersFrom: Float?
    var followersTo: Float?
    var likesFrom: Float?
    var likesTo: Float?
    var hoursFrom: Float?
    var hoursTo: Float?
    var revShare: Float?
    var icon: String?
    var totalAmountFrom: Float?
    var totalAmountTo: Float?
    var currency: String?
    
    static var statusLevels: [StatusLevel] = []
    
    override init () {
        self.id = nil
        self.order = nil
        self.name = nil
        self.shortName = nil
        self.levelDescription = nil
        self.followersFrom = 0.0
        self.followersTo = 0.0
        self.likesFrom = 0.0
        self.likesTo = 0.0
        self.hoursFrom = 0.0
        self.hoursTo = 0.0
        self.revShare = 0.0
        self.icon = nil
        self.totalAmountFrom = 0.0
        self.totalAmountTo = 0.0
        self.currency = nil
    }
    
    convenience init(params: [String: AnyObject]) {
        self.init()
        self.parseStatusLevel(params)
    }
    
    /*
     { "level_id" : <numeric>,
     "level_order" : <numeric>, /* higher order == higher status level */
     "name" : <string>,
     "short_name" : <string>,
     "description" : <string>,
     "followers_from" : <numeric>,
     "followers_to" : <numeric>,
     "likes_from" : <numeric>,
     "likes_to": <numeric>,
     "hours_from" : <numeric>,
     "hours_to" : <numeric>,
     "total_amount_from" : <numeric>,
     "total_amount_to" : <numeric>,
     "rev_share" : <numeric>,
     "icon" : <string>
     },
     */
    
    func parseStatusLevel(_ dict: [String: AnyObject]) {
        
        if let id = dict["level_id"] as? NSNumber {
            self.id = id.floatValue
        }
        
        if let order = dict["level_order"] as? NSNumber {
            self.order = order.floatValue
        }
        
        if let name = dict["name"] as? String {
            self.name = name
        }
        
        if let shortName = dict["short_name"] as? String {
            self.shortName = shortName
        }
        
        if let description = dict["description"] as? String {
            self.levelDescription = description
        }
        
        if let followersFrom = dict["followers_from"] as? NSNumber {
            self.followersFrom = followersFrom.floatValue
        }
        
        if let followersTo = dict["followers_to"] as? NSNumber {
            self.followersTo = followersTo.floatValue
        }
        
        if let likesFrom = dict["likes_from"] as? NSNumber {
            self.likesFrom = likesFrom.floatValue
        }
        
        if let likesTo = dict["likes_to"] as? NSNumber {
            self.likesTo = likesTo.floatValue
        }
        
        if let hoursFrom = dict["hours_from"] as? NSNumber {
            self.hoursFrom = hoursFrom.floatValue
        }
        
        if let hoursTo = dict["hours_to"] as? NSNumber {
            self.hoursTo = hoursTo.floatValue
        }
        
        if let revShare = dict["rev_share"] as? NSNumber {
            self.revShare = revShare.floatValue
        }
        
        if let icon = dict["icon"] as? String {
            self.icon = icon
        }
        
        if let totalAmountFrom = dict["total_amount_from"] as? NSNumber {
            self.totalAmountFrom = totalAmountFrom.floatValue
        }
        
        if let totalAmountTo = dict["total_amount_to"] as? NSNumber {
            self.totalAmountTo = totalAmountTo.floatValue
        }
        
    }
    
    static func parseListOfStatusLevels(_ dataArray: [[String: AnyObject]]) -> [StatusLevel] {
        
        var arrayOfStatusLevels: [StatusLevel] = []
        
        for entry in dataArray {
            
            if let levelsArray = entry["levels"] as? [[String: AnyObject]] {
                
                for level in levelsArray {
                    let levelObj = StatusLevel(params: level)
                    //get currency from parent node
                    if let currency = entry["currency"] as? String {
                        levelObj.currency = currency
                    }
                    
                    arrayOfStatusLevels.append(levelObj)
                }
                
            }
            
        }
        return arrayOfStatusLevels
    }
    
    func getStatusLevels() {
        UserConnector().listOfUserStatusLevels({ (success, error, levels) in
            if success {
                StatusLevel.statusLevels = levels!
                //update user status level
                if let user = ChatModel.sharedInstance.users {
                    user.updateUserStatusLevel()
                }
            } else {
                print("getListOfStatusLevels ERROR: \(error!)")
            }
        })
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? StatusLevel {
            return id == rhs.id
        }
        return false
    }
    
    static func getStatusLevelFromId(_ statusLevelId: Float) -> StatusLevel? {
        let level: StatusLevel = StatusLevel()
        level.id = statusLevelId
        // to find object in object array, override isEqual
        if let index = StatusLevel.statusLevels.index(of: level) {
            return StatusLevel.statusLevels[index]
        }
        
        return nil
        
    }
    
    //SHOOTINGSTAR, RISINGSTAR, STAR, CELEB, SUPERSTAR, ELITE
    
    func getBackgroundColor() -> UIColor {

        return UIColor(red: 255.0/255.0, green: 202.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    }
}
