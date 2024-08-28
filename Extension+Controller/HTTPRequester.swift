//
//  HTTPRequester.swift
//  Peeks
//
//  Created by Aaron Wong on 2016-03-29.
//  Copyright © 2016 Riavera. All rights reserved.
//

// swiftlint:disable line_length cyclomatic_complexity type_body_length function_body_length
import UIKit
import MobileCoreServices
import TrustKit

enum RequestType: String {
    case POST       //= "POST"
    case GET        //= "GET"
    case PUT        //= "PUT"
    case DELETE     //= "DELETE"
}

enum FileUploadType: String {
    case Video      //= "Video"
    case Image      //= "Image"
}

@objc protocol HTTPRequesterDelegate: class {
    @objc optional func HTTPRequesterFileUploadProgress(_ uploadProgress: Float, progressPercentage: Int)
}

class HTTPRequester: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    var ts: String {
        let time = "\(Date().timeIntervalSince1970)" as NSString
        
        return time.substring(with: NSRange(location: 0, length: 10))
    }
    static let sharedInstance = HTTPRequester()
    let config = Config()
    var version: String {
        get {
            if let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
                return "iOS-\(UIDevice.current.systemVersion)/\(versionString)"
            } else {
                return "iOS-\(UIDevice.current.systemVersion)"
            }
        }
    }
    
    weak var delegate: HTTPRequesterDelegate?
    let langStr: String = Locale.preferredLanguages[0]
    
    // MARK: - GET
    func GET(_ uri: String, queryParams: String?, authValue: String?, completion:@escaping (_ data: [String: AnyObject]?, _ error: String?, _ success: Bool) -> Void) {
        
        var uriString: String = config.api() + uri
        
        if let queryParams = queryParams {
            uriString += queryParams
            // query paramters in GET/DELETE requests should be URL-encoded individually 
            //- not the  entore parameter 
            //string .stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        }
        
        let uriRequest = URL(string: uriString)
        if let url = uriRequest {
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(langStr, forHTTPHeaderField: "Accept-Language")
            request.addValue(version, forHTTPHeaderField: "X-ClientVersion")
            
            if let auth = authValue {
                request.addValue("Basic \(auth.toBase64())", forHTTPHeaderField: "Authorization")
            }
            
            self.urlSessionCaller(uriString, requestType: "GET", request: request) { (response, success) -> Void in
                if success {
                    if let data = response as? [String: AnyObject] {
//                        print("\(data)")
                        completion(data, nil, true)
                    } else {
                        completion(nil, "Incorrect data format was returned", false)
                    }
                } else {
                    completion(nil, self.parseErrorFromAPIResponse(response), false)
                }
                print("\(uriString)")
            }
        }
    }
    
    // MARK: - POST
    func POST(_ uri: String, authValue: String?, parameters: [String: AnyObject], rawData: Bool = false, userId: String = "", completion:@escaping (_ data: [String: AnyObject]?, _ error: String?, _ success: Bool) -> Void) {
        
        // The 'rawData' parameter will return the response without being parsed
        
        let uriString: String = config.api() + uri
        
        let uriRequest = URL(string: uriString)
        print(uriRequest)

        let request = NSMutableURLRequest(url: uriRequest!)
        
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(langStr, forHTTPHeaderField: "Accept-Language")
            request.addValue(version, forHTTPHeaderField: "X-ClientVersion")
            if userId != "" {
                request.addValue(userId, forHTTPHeaderField: "user_id")
            }
            if let auth = authValue {
                request.addValue("Basic \(auth.toBase64())", forHTTPHeaderField: "Authorization")
            }
            
        } catch {
            print(error)
            request.httpBody = nil
        }
        print(request.allHTTPHeaderFields)
        self.urlSessionCaller(uriString, requestType: "POST", request: request, rawData: rawData) { (response, success) -> Void in
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

    func POSTFILE(_ uri: String, authValue: String?, parameters: [String: AnyObject], rawData: Bool = false, completion:@escaping (_ data: [String: AnyObject]?, _ error: String?, _ success: Bool) -> Void) {
        
        // The 'rawData' parameter will return the response without being parsed
        
        let uriString: String = config.api() + uri
        
        let uriRequest = URL(string: uriString)
        
        let request = NSMutableURLRequest(url: uriRequest!)
        
        request.httpMethod = "POST"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            request.addValue("multipart/form-data", forHTTPHeaderField: "Accept")
            request.addValue(langStr, forHTTPHeaderField: "Accept-Language")
            request.addValue(version, forHTTPHeaderField: "X-ClientVersion")
            
            if let auth = authValue {
                request.addValue("Basic \(auth.toBase64())", forHTTPHeaderField: "Authorization")
            }
            
        } catch {
            print(error)
            request.httpBody = nil
        }
        
        self.urlSessionCaller(uriString, requestType: "POST", request: request, rawData: rawData) { (response, success) -> Void in
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

    // MARK: - PUT
    func PUT(_ uri: String, authValue: String?, parameters: [String: AnyObject], completion:@escaping (_ data: [String: AnyObject]?, _ error: String?, _ success: Bool) -> Void) {
        
        let uriString: String = config.api() + uri
        
        let uriRequest = URL(string: uriString)
        let request = NSMutableURLRequest(url: uriRequest!)
        
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(langStr, forHTTPHeaderField: "Accept-Language")
            request.addValue(version, forHTTPHeaderField: "X-ClientVersion")
            
            if let auth = authValue {
                request.addValue("Basic \(auth.toBase64())", forHTTPHeaderField: "Authorization")
            }
            
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
    func DELETE(_ uri: String, queryParams: String, authValue: String?,parameters: [String: AnyObject] = [:], completion:@escaping (_ data: [String: AnyObject]?, _ error: String?, _ success: Bool) -> Void) {
        
        let uriString: String = config.api() + uri + queryParams
        // query paramters in GET/DELETE requests 
        //should be URL-encoded individually - not the  entore parameter string .stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let uriRequest = URL(string: uriString)
        
        let request = NSMutableURLRequest(url: uriRequest!)
        
        request.httpMethod = "DELETE"
        if parameters.count != 0 {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                print(error)
                request.httpBody = nil
            }
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(langStr, forHTTPHeaderField: "Accept-Language")
        request.addValue(version, forHTTPHeaderField: "X-ClientVersion")
        
        if let auth = authValue {
            request.addValue("Basic \(auth.toBase64())", forHTTPHeaderField: "Authorization")
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
    
    // MARK: - IMAGE DOWNLOADERS
    static func asyncDownloadImageWithURL(_ urlString: String, completion:@escaping (_ image: UIImage?, _ success: Bool) -> Void) {
        let url = URL(string: urlString)
        let session = Foundation.URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: { (data, _ response, error) -> Void in
            guard data != nil else {
                completion(nil, false)
                print(error!.localizedDescription)
                return
            }
            
            do {
                let image = UIImage(data: data!)
                completion(image, true)
            }
        }) 
        task.resume()
    }
    
    // MARK: - FILE UPLOADER POST
    func fileUploader(_ uri: String,
                      authValue: String?,
                      parameters: [String: AnyObject],
                      fileName: String, filePath: String,
                      completion:@escaping (_ data: [String: AnyObject]?, _ error: String?, _ success: Bool) -> Void) {
        
        let uriString: String = config.api() + uri
        
        let boundary = self.generateBoundaryString()
        
        let requestData = self.createMultipartBodyWithParameters(parameters, filePathKey: fileName, paths: [filePath], boundary: boundary)
        
        let request = self.createDataUploadRequestWithParams(uriString, authValue: authValue, requestParams: requestData, boundary: boundary)
        
        self.uploadSessionCaller(uri, request: request) { (response, success) in
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
    fileprivate func urlSessionCaller(_ uri: String, requestType: String, request: NSMutableURLRequest, rawData: Bool = false, completion: @escaping (_ response: AnyObject, _ success: Bool) -> Void) {
        let isLogOut = UserDefaults.standard.value(forKey: "LoggingOut") as? Bool ?? false
        if isLogOut && !(uri.contains("logout", compareOption: .caseInsensitive)) {
            return
        }
        print("urlSessionCaller->rawData: \(rawData)")
        
        // The 'rawData' parameter will return the response without being parsed
        
        if Reach().connectionStatus().description != "Offline" {
            let config = URLSessionConfiguration.default
            config.httpAdditionalHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
            let session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: nil)
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, _ response, error) -> Void in
                guard data != nil else {
                    if let errorDescription = error?.localizedDescription {
                        if errorDescription.contains("The request timed out") || errorDescription.contains("Invalid request signature") {
                            var timeoutError = "poorInternetConnectivity".localized
                            completion( "\(timeoutError)" as AnyObject, false)
                        } else {
                            completion("\(errorDescription)" as AnyObject, false)
                        }
                    } else {
                        completion("\(error?.localizedDescription ?? "")" as AnyObject, false)
                    }
                    
                    session.finishTasksAndInvalidate()
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments]) as? NSDictionary {
                        if let status = json["status"] as? String {
                            if status == "ok" {
                                completion(json, true)
                            } else {
                                var fieldsInvalid = ""
                                if let errorCode = json["error_code"] as? Int {
                                    print("Testing Error code is \(errorCode)")
                                    if errorCode == 4002 {
                                        if let errorFields = json["error_fields"] as? NSDictionary {
                                            print("error_fields...")
                                            
                                            fieldsInvalid = "\n\n"
                                            
                                            let errorCodes = ErrorCodes()
                                            
                                            if rawData == true {
                                                completion(errorFields, true)
                                                session.finishTasksAndInvalidate()
                                                return
                                            }
                                            
                                            for (key, value) in errorFields {
                                                print("Property: \(key) -> \(value)")
                                                
                                                let codeString = errorCodes.getErrorCode(value as AnyObject)
                                                
                                                if codeString.isEmpty == false {
                                                    fieldsInvalid += codeString + ".\n"
                                                } else {
                                                    fieldsInvalid += "The " + (key as? String)! + " is invalid.\n"
                                                }
                                            }
                                        }
                                        
                                    } else if errorCode == 41304 {
                                        fieldsInvalid = "This post is no longer available."
                                    } else if errorCode == 2519 {
                                        fieldsInvalid = "Your account has been disabled. Please contact our customer care for further assistance."
                                    } else if errorCode == 1006 {
                                        fieldsInvalid = "Authentication Failed"
                                    } else if errorCode == 2501 || errorCode == 4501 {
                                        fieldsInvalid = "Invalid Email/Username"
                                    } else if errorCode == 4524 {
                                        fieldsInvalid = "Session expired"
                                    } else if errorCode == 15000 && !(uri.contains("logout", compareOption: .caseInsensitive))  {
                                        self.accountDisabled(error: (json["error_message"] as? String) ?? "")
                                        session.finishTasksAndInvalidate()
                                        return
                                    }
                                }
                                
                                if let errorMessage = json["error_message"] as? String {
                                    if fieldsInvalid != "" {
                                        completion("\(fieldsInvalid)" as AnyObject, false)
                                    } else {
                                        completion("\(errorMessage)" as AnyObject, false)
                                    }
                                } else {
                                    completion("There was no error_message provided from the server. Please refer to the console" as AnyObject, false)
                                }
                            }
                        } else {
                            completion("There is no status response from the server. Please refer to the console" as AnyObject, false)
                        }
                        
                    } else {
                        completion("poorInternetConnectivity".localized as AnyObject, false)
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
    
    // MARK: - Upload Session Caller
    fileprivate func uploadSessionCaller(_ uri: String, request: URLRequest, completion:@escaping (_ response: AnyObject, _ success: Bool) -> Void) {
        
        if Reach().connectionStatus().description != "Offline" {
            let config = URLSessionConfiguration.default
            config.httpMaximumConnectionsPerHost = 1
            
            let uploadSession = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
            
            let uploadTask = uploadSession.dataTask(with: request, completionHandler: { (data, _ response, error) in
                guard data != nil else {
                    completion("\(error!.localizedDescription)" as AnyObject, false)
                    uploadSession.finishTasksAndInvalidate()
                    return
                }
                
                // if response was JSON, then parse it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: [JSONSerialization.ReadingOptions.allowFragments]) as? NSDictionary {
//                        print("URL: \(uri)")
//                        print("REQUEST TYPE: POST")
//                        print("RESPONSE: \(json)")
                        
                        if let status = json["status"] as? String {
                            if status == "ok" {
                                completion(json, true)
                            } else {
                                if let errorMessage = json["error_message"] as? String {
                                    completion(errorMessage as AnyObject, false)
                                } else {
                                    completion("There was no error_message provided from the server. Please refer to the console" as AnyObject, false)
                                }
                            }
                        } else {
                            completion("There is no status response from the server. Please refer to the console" as AnyObject, false)
                        }
                        
                    } else {
//                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                        completion("poorInternetConnectivity".localized as AnyObject, false)
                    }
                } catch let parseError {
                    
//                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    completion("poorInternetConnectivity".localized as AnyObject, false)
                    print(parseError)
                }
            })
            uploadTask.resume()
            uploadSession.finishTasksAndInvalidate()
        } else {
            completion("You currently have no access to the internet. Please check your internet connection and try again" as AnyObject, false)
        }
    }

    // MARK: - MULTIPART/FORM-DATA Delegates
    // CREATE UPLOAD REQUEST
    func createDataUploadRequestWithParams(_ uri: String, authValue: String?, requestParams: Data, boundary: String) -> URLRequest {
        let uriRequest = URL(string: uri)
        let request = NSMutableURLRequest(url: uriRequest!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Keep-Alive", forHTTPHeaderField: "Connection")
        request.addValue(langStr, forHTTPHeaderField: "Accept-Language")
        request.httpBody = requestParams
        
        if let auth = authValue {
            request.addValue("Basic \(auth.toBase64())", forHTTPHeaderField: "Authorization")
        }
        
        print("Upload Request Header Fields: \(request.allHTTPHeaderFields!)")
        
        return request as URLRequest
    }
    
    // Create body of the multipart/form-data request
    //
    // :param: parameters   The optional dictionary containing keys and values to be passed to web service
    // :param: filePathKey  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    // :param: paths        The optional array of file paths of the files to be uploaded
    // :param: boundary     The multipart/form-data boundary
    //
    // :returns:            The NSData of the body of the request
    fileprivate func createMultipartBodyWithParameters(_ parameters: [String: AnyObject]?, filePathKey: String?, paths: [String]?, boundary: String) -> Data {
        
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                
                if let value = value as? [String: AnyObject] {
                    for (dictKey, dictValue) in value {
                        body.appendString("--\(boundary)\r\n")
                        body.appendString("Content-Disposition: form-data; name=\"\(key)[\(dictKey)]\"\r\n\r\n")
                        body.appendString("\(dictValue)\r\n")
                    }
                } else {
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.appendString("\(value)\r\n")
                }
            }
        }
        
        if paths != nil {
            for path in paths! {
                let url = URL(fileURLWithPath: path)
                let filename = url.lastPathComponent
                //let data = try! Data(contentsOf: URL(fileURLWithPath: path))
                var data = Data()
                do {
                    data = try Data(contentsOf: URL(fileURLWithPath: path))
                } catch {
                    print(error)
                }
                
                let mimetype = mimeTypeForPath(path)
                
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
                body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                body.append(data)
                body.appendString("\r\n")
            }
        }
        
        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }
    
    // Create boundary string for multipart/form-data request
    // :returns:            The boundary string that consists of "Boundary-" followed by a UUID string
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    // Determine mime type on the basis of extension of a file.
    // This requires MobileCoreServices framework.
    // :param: path         The path of the file for which we are going to determine the mime type.
    // :returns:            Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.
    func mimeTypeForPath(_ path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    // MARK: - NSURLSession Delegates
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let pinningValidator = TrustKit.sharedInstance().pinningValidator
        pinningValidator.handle(challenge, completionHandler: completionHandler)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
        let progressPercent = Int(uploadProgress * 100)
        
        if let delegate = self.delegate {
            delegate.HTTPRequesterFileUploadProgress?(uploadProgress, progressPercentage: progressPercent)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if (error) != nil {
            print(error!.localizedDescription)
        } else {
            print("URLSession complete without errors")
        }
    }
    
    func parseErrorFromAPIResponse(_ response: AnyObject) -> String {
        if let error = response as? String {
            return error
        } else {
            return "No error response provided"
        }
    }
    
    static func clearCookieforUrl(_ url: String, completion:(_ success: Bool, _ error: String?) -> Void) {
        if let url = URL(string: url) {
            let cookieStorage: HTTPCookieStorage = HTTPCookieStorage.shared
            let cookies = cookieStorage.cookies(for: url)
            
            if let cookies = cookies {
                if cookies.count > 0 {
                    for cookie in cookies {
                        cookieStorage.deleteCookie(cookie as HTTPCookie)
                    }
                    
                    completion(true, nil)
                } else {
                    completion(false, "No cookies found for \(url)")
                }
                
            } else {
                completion(false, "No access to cookies with \(url)")
            }
        } else {
            completion(false, "Cannot convert url: \(url)")
        }
    }
    
    // Disable account handler
    func accountDisabled (error: String) {
        DispatchQueue.main.async {
            UIUtil.showAlertWithButtons(btnNo: "", btnYes: "OK", msg: error ?? "Your account is disabled" , vc: UIApplication.getTopViewController()!) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "LogoutCall"), object: nil)
                UserDefaults.standard.set(false, forKey: "LoggingOut")
            }
        }
    }
}
