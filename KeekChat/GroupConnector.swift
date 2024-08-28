//
//  GroupConnector.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 28/07/22.
//  Copyright © 2022 Riavera. All rights reserved.
//


import Foundation
import UIKit
//import QuickTableViewController

class GroupConnector: Connector {
    
    /**
     * Get Group List
     * GET /club
     *
     */
    func getGroupList(completion:@escaping (_ success: Bool, _ error: String?, _ clubs: [Club]?) -> Void) {
        
        let ts = timestamp
        let path = "/club"
        let queryString = "?ts=\(ts)"
        
        let authToken: String = self.buildHash(RequestType.GET,
                                                uri: path, timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.GET(path, queryParams: queryString, authValue: authString) { (data, error, success) in
            
            if success {
                var array: [Club] = []
                if let data = data!["data"] as? [[String: AnyObject]] {
                    array = Club.parseClubList(data)
                    
                }
                completion(true, nil, array)
            } else {
                completion(false, error!, nil)
            }
        }
    }
    
    /**
     * Create Group
     * POST /club
     *
     */
    func createClub(_ clubName: String, audience: [String], completion:@escaping (_ success: Bool, _ error: String?, _ clubID: String?) -> Void) {
        let ts = timestamp
        
        let path = "/club"
        
        var params: [String: AnyObject] = ["ts": ts as AnyObject]
        
        params["club_name"] = clubName as AnyObject
       
        
//        if let audience = audience, !audience.isEmpty {
            params["audience"] = audience as AnyObject
//        }
        
        params["user_id"] = ChatModel.sharedInstance.userId as AnyObject
        
        let authToken: String = self.buildHash(RequestType.POST,
                                                uri: path, timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.POST(path, authValue: authString, parameters: params) { (data, error, success) in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    
                    completion(true, nil, data["club_id"] as? String)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                completion(false, error!, nil)
            }
        }
    }
    
    /**
     * Insert/Update Avatar
     * POST /user/{user_id}/avatar
     *
     * It inserts or updates the Avatar of the user
     */
    func uploadAvatar(_ clubID: String, image: UIImage, delegate: HTTPRequesterDelegate?, completion: ((_ success: Bool, _ error: String?, _ avatarUrl: String?) -> Void)? = nil) {
        let ts = timestamp
        let path = "/club/\(clubID)/avatar"
        
        
        //crop image to sqaure 640x640
        let newImage = Utils.cropToBounds(image, width: 640, height: 640)
        
        let percentage = 100
        
        
        let finalPercentage = Float(percentage) / 100
        
        let imageData: Data = NSData(data: newImage.jpegData(compressionQuality: CGFloat(finalPercentage))!) as Data
        
//        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        let filename = getDocumentsDirectory().appendingPathComponent("temp.jpg")
        try? imageData.write(to: URL(fileURLWithPath: filename), options: [.atomic])
        
        let params: [String: AnyObject] = ["ts": ts as AnyObject, "file": "\(imageData)" as AnyObject]
        
        let authToken: String = self.buildHash(RequestType.POST,
                                                uri: path,
                                                timeStamp: ts,
                                               authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        http.delegate = delegate
        
        http.fileUploader(path, authValue: authString, parameters: params, fileName: "file", filePath: filename) { (data, error, success) in
            if success {
                    completion?(true, nil, nil)
            } else {
                completion?(false, error!, nil)
            }
        }
    }
    
    func uploadChatMessageMedia(_ event: String, mediaPath: String, delegate: HTTPRequesterDelegate?, completion: ((_ success: Bool, _ error: String?, _ mediaMsg: MediaMessage?) -> Void)? = nil) {
        let ts = timestamp
        let path = "/chat/upload"
        let percentage = 100
        
        
        let finalPercentage = Float(percentage) / 100
        if let image = try? Data(contentsOf: URL(fileURLWithPath: mediaPath)) {
            // Use the data as needed
            print("Data read from file successfully.")
            let imageData: Data = NSData(data: image) as Data
            
    //        let imageData = UIImageJPEGRepresentation(image, 1.0)
            
            let filename = getDocumentsDirectory().appendingPathComponent("temp.jpg")
            try? imageData.write(to: URL(fileURLWithPath: filename), options: [.atomic])
            
            let params: [String: AnyObject] = ["ts": ts as AnyObject, "file": "\(imageData)" as AnyObject, "event": event as AnyObject]
            
            let authToken: String = self.buildHash(RequestType.POST,
                                                    uri: path,
                                                    timeStamp: ts,
                                                   authentication: "",
                                                    apiSecret: ChatModel.sharedInstance.apiSecret,
                                                    sharedSecret: ChatModel.sharedInstance.sharedSecret)
            let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
            http.delegate = delegate
            
            http.fileUploader(path, authValue: authString, parameters: params, fileName: "file", filePath: mediaPath) { (data, error, success) in
                print("Chat media upload \(data)")
                if success {
                    if let data = data!["data"] as? [String: AnyObject] {
                        let media = MediaMessage(params: data)
                        completion?(true, nil, media)
                    } else {
                        completion?(false, "Could not upload image", nil)
                    }
                } else {
                    completion?(false, error!, nil)
                }
            }
        } else {
            print("Could not upload media")
        }
     
    }
    
    func uploadGroupProfileImage(_ event: String, image: UIImage, delegate: HTTPRequesterDelegate?, completion: ((_ success: Bool, _ error: String?, _ mediaMsg: MediaMessage?) -> Void)? = nil) {
        let ts = timestamp
        let path = "/chat/upload"
        
        //crop image to sqaure 640x640
//        let newImage = Utils.cropToBounds(image, width: 640, height: 640)
        
        let percentage = 100
        
        
        let finalPercentage = Float(percentage) / 100
        
        let imageData: Data = NSData(data: image.jpegData(compressionQuality: CGFloat(finalPercentage))!) as Data
        
//        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        let filename = getDocumentsDirectory().appendingPathComponent("temp.jpg")
        try? imageData.write(to: URL(fileURLWithPath: filename), options: [.atomic])
        
        let params: [String: AnyObject] = ["ts": ts as AnyObject, "file": "\(imageData)" as AnyObject, "event": event as AnyObject]
        
        let authToken: String = self.buildHash(RequestType.POST,
                                                uri: path,
                                                timeStamp: ts,
                                               authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        http.delegate = delegate
        
        http.fileUploader(path, authValue: authString, parameters: params, fileName: "file", filePath: filename) { (data, error, success) in
            print("Chat media upload \(data)")
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    let media = MediaMessage(params: data)
                    completion?(true, nil, media)
                } else {
                    completion?(false, "Could not upload image", nil)
                }
            } else {
                completion?(false, error!, nil)
            }
        }
    }
    
    /**
     * Create Group
     * PUT /club/{group_id}
     *
     */
    func updateClub(_ clubID: String, clubName: String, audience: [String], completion:@escaping (_ success: Bool, _ error: String?, _ clubID: String?) -> Void) {
        let ts = timestamp
        
        let path = "/club/\(clubID)"
        
        var params: [String: AnyObject] = ["ts": ts as AnyObject]
        
        params["club_name"] = clubName as AnyObject
       
        
    //        if let audience = audience, !audience.isEmpty {
            params["audience"] = audience as AnyObject
    //        }
        
        params["user_id"] = ChatModel.sharedInstance.userId as AnyObject
        
        let authToken: String = self.buildHash(RequestType.PUT,
                                                uri: path, timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.PUT(path, authValue: authString, parameters: params) { (data, error, success) in
            if success {
                    completion(true, nil, nil)
            } else {
                completion(false, error!, nil)
            }
        }
    }
    
    /**
     * Delete Group
     * DELETE /club/{group_id}
     *
     *
     */
    func deleteGroup(_ clubID: Int64, completion:@escaping (_ success: Bool, _ error: String?) -> Void) {
        let ts = timestamp
        let path = "/club/\(clubID)"
        
        let authToken: String = self.buildHash(RequestType.DELETE,
                                                uri: path, timeStamp: ts,
                                                authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.DELETE(path, queryParams: "?ts=\(ts)", authValue: authString) { (_ data, error, success) in
            if success {
                completion(true, nil)
            } else {
                completion(false, error!)
            }
        }
    }
    
    /**
     * Lookup club
     * GET /post/{postid}
     *
     * Lookup an individual post entry.
     */
    func lookupClub(_ clubID: String, completion:@escaping (_ success: Bool, _ error: String?, _ club: Club?) -> Void) {
        let ts = timestamp
        
        let path = "/club/\(clubID)"
        
        let authToken: String = self.buildHash(RequestType.GET, uri: path,
                                                timeStamp: ts, authentication: "",
                                                apiSecret: ChatModel.sharedInstance.apiSecret,
                                                sharedSecret: ChatModel.sharedInstance.sharedSecret)
        
        let authString = "\(ChatModel.sharedInstance.apiKey):\(authToken)"
        
        http.GET(path, queryParams:"?ts=\(ts)", authValue: authString) { (data, error, success) in
            if success {
                if let data = data!["data"] as? [String: AnyObject] {
                    let club = Club(params: data)
                    completion(true, nil, club)
                } else {
                    completion(false, "No data found in response", nil)
                }
            } else {
                completion(false, error!, nil)
            }
        }
    }

}
 
