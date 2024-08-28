//
//  ChatHttpRequestor.swift
//  MiiTV
//
//  Created by Ruchi Bukshete on 06/09/23.
//  Copyright © 2023 Riavera. All rights reserved.
//
import Foundation

class ChatHTTPRequestor: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    var ts: String {
        let time = "\(Date().timeIntervalSince1970)" as NSString
        
        return time.substring(with: NSRange(location: 0, length: 10))
    }
    var chatHost = ""
    var chatAuthHost = ""
    
    static let shared = ChatHTTPRequestor()
    
    static var sharedInstance: ChatHTTPRequestor {
        let instance = shared
        instance.chatHost = ChatModel.sharedInstance.nativeChatUrl
        instance.chatAuthHost = ChatModel.sharedInstance.nativeChatAuthUrl
        return instance
    }

    
//    let chatHost = ChatModel.sharedInstance.nativeChatUrl //"https://ottr.chavadi.com/chat"
//    let chatAuthHost = ChatModel.sharedInstance.nativeChatAuthUrl
    
    // MARK: - POST

    func POST(_ uri: String, parameters: [String: AnyObject], completion:@escaping (_ data: [String: AnyObject]?, _ error: String?, _ success: Bool) -> Void) {
        
        let uriString: String = chatHost + uri
        
        let uriRequest = URL(string: uriString)
        
        let request = NSMutableURLRequest(url: uriRequest!)
        
        request.httpMethod = "POST"
        let chatmodelParam: [String: AnyObject] = ["model": parameters as AnyObject]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: chatmodelParam, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(ChatModel.sharedInstance.keekChatToken)", forHTTPHeaderField: "Authorization")
        } catch {
            print(error)
            request.httpBody = nil
        }
        self.urlSessionCaller(uriString, requestType: "POST", request: request) { (response, success) -> Void in
            if success {
                if let data = response as? [String: AnyObject] {
                    completion(data, nil, true)
                } else {
                    completion(nil, "Incorrect data format was returned", false)
                }
            } else {
                completion(nil, self.parseErrorFromAPIResponse(response), false)
            }
        }
    }
    
    // MARK: - GET
    func GET(_ uri: String, queryParams: String?, parameters: [String: AnyObject]?, completion:@escaping (_ data: [String: AnyObject]?, _ error: String?, _ success: Bool) -> Void) {
        
        var uriString: String = chatHost + uri
       
        if let queryParams = queryParams {
            uriString += queryParams
        }
        let uriRequest = URL(string: uriString)
        
        if let url = uriRequest {
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(ChatModel.sharedInstance.keekChatToken)", forHTTPHeaderField: "Authorization")
            if parameters != nil {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                    if let jsonString = String(data:jsonData, encoding: .utf8) {
                        request.addValue("\(jsonString)", forHTTPHeaderField: "x-query")
                    }
                   
                       
                } catch {
                    print("Error sending x-query")
                }
            }
            self.urlSessionCaller(uriString, requestType: "GET", request: request) { (response, success) -> Void in
                if success {
                    if let data = response as? [String: AnyObject] {
                        completion(data, nil, true)
                    } else {
                        completion(nil, "Incorrect data format was returned", false)
                    }
                } else {
                    completion(nil, self.parseErrorFromAPIResponse(response), false)
                }
            }
        }
    }
    
    // MARK: - PUT
    func PUT(_ uri: String, parameters: [String: AnyObject], isAuth: Bool = false, completion:@escaping (_ data: [String: AnyObject]?, _ error: String?, _ success: Bool) -> Void) {
        
        var uriString: String = chatHost + uri
        
        if isAuth {
            uriString = chatAuthHost + uri
        }
        let uriRequest = URL(string: uriString)
        let request = NSMutableURLRequest(url: uriRequest!)
        
        request.httpMethod = "PUT"
        let chatmodelParam: [String: AnyObject] = ["model": parameters as AnyObject]
        print(chatmodelParam)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: chatmodelParam, options: .prettyPrinted)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(ChatModel.sharedInstance.keekChatToken)", forHTTPHeaderField: "Authorization")
            print(request.allHTTPHeaderFields)
        } catch {
            print(error)
            request.httpBody = nil
        }
        self.urlSessionCaller(uriString, requestType: "PUT", request: request) { (response, success) -> Void in
            if success {
                if let data = response as? [String: AnyObject] {
                    completion(data, nil, true)
                } else {
                    completion(nil, "Incorrect data format was returned", false)
                }
            } else {
                completion(nil, self.parseErrorFromAPIResponse(response), false)
            }
        }
    }
    
    
    // MARK: - DELETE
    func DELETE(_ uri: String, queryParams: String, parameters: [String: AnyObject] = [:], completion:@escaping (_ data: [String: AnyObject]?, _ error: String?, _ success: Bool) -> Void) {
        
        let uriString: String = chatHost + uri + queryParams
        // query paramters in GET/DELETE requests
        //should be URL-encoded individually - not the  entore parameter string .stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let uriRequest = URL(string: uriString)
        
        let request = NSMutableURLRequest(url: uriRequest!)
        
        request.httpMethod = "DELETE"
        let chatmodelParam: [String: AnyObject] = ["model": parameters as AnyObject]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: chatmodelParam, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(ChatModel.sharedInstance.keekChatToken)", forHTTPHeaderField: "Authorization")
            
        } catch {
            print(error)
            request.httpBody = nil
        }
        
        self.urlSessionCaller(uri, requestType: "DELETE", request: request) { (response, success) -> Void in
            if success {
                if let data = response as? [String: AnyObject] {
                    completion(data, nil, true)
                } else {
                    completion(nil, "Incorrect data format was returned", false)
                }
            } else {
                completion(nil, self.parseErrorFromAPIResponse(response), false)
            }
        }
    }
    
    // MARK: - URL Session Caller
    fileprivate func urlSessionCaller(_ uri: String, requestType: String, request: NSMutableURLRequest, completion: @escaping (_ response: AnyObject, _ success: Bool) -> Void) {
        
        if Reach().connectionStatus().description != "Offline" {
            let config = URLSessionConfiguration.default
            let session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: nil)
            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                do {
                    if let data = data {
                    if let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSDictionary {
                        if let hasError = json["isError"] as? Bool {
                            if hasError == false {
                                completion(json, true)
                            } else {
                                if let errorMessage = json["errorMessage"] as? String {
                                    completion("There was an error connecting to chat" as AnyObject, false)
                                }
                                
                            }
                        } else {
                            print("Could not parse data")
                            
                        }
                        
                    } else {
                        completion("poorInternetConnectivity".localized as AnyObject, false)
                    }
                }
                } catch let parseError {
                    completion("poorInternetConnectivity".localized as AnyObject, false)
                    print(parseError)
                }
            })
            
            task.resume()
            session.finishTasksAndInvalidate()
        } else {
            completion("internetIssue".localized as AnyObject, false)
        }
    }
    
    func parseErrorFromAPIResponse(_ response: AnyObject) -> String {
        if let error = response as? String {
            return error
        } else {
            return "No error response provided"
        }
    }
}
