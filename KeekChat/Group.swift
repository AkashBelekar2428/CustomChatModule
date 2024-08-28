//
//  Group.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 28/07/22.
//  Copyright © 2022 Riavera. All rights reserved.
//
// swiftlint:disable force_cast

import Foundation

class Club: NSObject {
    
    var clubID: Int64 = 0
    var clubName = ""
    var createdBy: Int64 = 0
    var clubIcon = ""
    var entryDate: Date?
    var clubAudience: [User] = []
    
    convenience init(params: [String: AnyObject]) {
        self.init()
        if let id = params["club_id"] as? Int64 {
            self.clubID = id
        } else if let id = params["club_id"] as? String {
            self.clubID = Int64(id) ?? 0
        } else {
            self.clubID = 0
        }
//        self.clubID = params["club_id"] as? Int64 ?? 0
        self.clubName = params["club_name"] as? String ?? ""
        self.createdBy = params["created_by"] as? Int64 ?? 0
        self.clubIcon = params["avatar"] as? String ?? ""
        if let entry = params["entry_date"] as? String {
            self.entryDate = Utils.formatDateFromString(date: entry, format: "yyyy-MM-dd HH:mm:ss.SSSSSSZ")
        }
        
        if let tempAudience = params["audience"] as? [NSDictionary] {
            for obj in tempAudience {
                let audienceObj = User(clubParams: obj as! [String : AnyObject])
                self.clubAudience.append(audienceObj)
            }
        }
        
    }
    
    static func parseClubList(_ clubs: [[String: AnyObject]]) -> [Club]{
        var arrayOfClubs: [Club] = []
        for club in clubs {
            let clubObj = Club(params: club)
            arrayOfClubs.append(clubObj)
        }
        return arrayOfClubs
        
    }
}
