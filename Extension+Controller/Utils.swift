//
//  Utils.swift
//  Peeks
//
//  Created by Aaron Wong on 2016-03-29.
//  Copyright © 2016 Riavera. All rights reserved.
//

import UIKit

struct Utils {
    
    static func convertDateToISODate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'" //"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        let iso8601String = dateFormatter.string(from: date)
        return iso8601String
    }
    
    static func formatDateFromString(date: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        if let date = dateFormatter.date(from: date) {
            return date
        } else {
            return nil
        }
    }
    
    static func formatDateFromISODate(_ isoDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        if let date = dateFormatter.date(from: isoDate) {
            return date
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ssZZZ"
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            
            if let date = dateFormatter.date(from: isoDate) {
                return date
            } else {
                return nil
            }
        }
    }
    
    
    static func convertDateToHours(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" //format style. Browse online to get a format that fits your needs.
        return dateFormatter.string(from: date)
    }
    
    static func getStringFromDateForCurrentLocale(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "d MMM yyyy, HH:mm"
        return dateFormatter.string(from: date)
    }
    
    static func dateToStringYearMonthDay(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        let usLocale = Locale(identifier: "en_US")
        dateFormatter.locale = usLocale
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    static func timeInSecondsToString(_ totalSeconds: Float64) -> String {
        let hours: Int = Int(totalSeconds / 3600)
        let minutes: Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds: Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    
    static func getDateRange(_ month: Int, year: Int) -> [String: Date] {
        
        var firstDateData = Date()
        var lastDateData = Date()
        
        var firstDateComponents = DateComponents()
        var lastDateComponents = DateComponents()
        
        firstDateComponents.day = 1
        firstDateComponents.month = month
        firstDateComponents.year = year
        
        lastDateComponents.day = 0
        lastDateComponents.month = month + 1
        lastDateComponents.year = year
        
        firstDateData = Calendar.current.date(from: firstDateComponents)!
        lastDateData = Calendar.current.date(from: lastDateComponents)!
        
        return ["start": firstDateData, "end": lastDateData]
    }
    
   static func getFormattedTimeUTC(dateToFormat: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
       dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let formattedDate = dateFormatter.string(from: dateToFormat)
        return formattedDate
    }
    
    static func doubleIntoString(_ double: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: double))!
    }
    
    func delay(_ delay: Double, closure:@escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    static func encodeJSON(_ dict: [String: AnyObject], completion: (Bool, _ json: Data?, _ error: String?) -> Void) {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            completion(true, jsonData, nil)
        } catch let error as NSError {
            completion(false, nil, error.localizedDescription)
        }
    }
    
    static func decodeJSON(_ json: Data, completion:(_ success: Bool, _ dict: [String: AnyObject]?, _ error: String?) -> Void) {
        do {
            if let decoded: [String: AnyObject] = try JSONSerialization.jsonObject(with: json, options: []) as? [String: AnyObject] {
                completion(true, decoded, nil)
            } else {
                let jsonStr = NSString(data: json, encoding: String.Encoding.utf8.rawValue)    // No error thrown, but not NSDictionary
                completion(false, nil, "Error could not parse JSON: \(String(describing: jsonStr))")
            }
            
        } catch let error as NSError {
            completion(false, nil, error.localizedDescription)
        }
    }
    
    static func getCurrencySymbolForCurrencyCode(_ currencyCode: String) -> String? {
        let currencySymbol = Locale.availableIdentifiers.map { Locale(identifier: $0) }.first { $0.currencyCode == currencyCode }
        if let symbol = currencySymbol {
            return symbol.currencySymbol
        } else {
            return nil
        }
    }
    
    static func calculateAge (_ birthday: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: birthday, to: Date(), options: []).year!
    }
    
    // MARK: image processing
    static func cropToBounds(_ image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    static func calculateImageBeforeUpload(_ percentage: Int, myImage: UIImage) -> Int {
        
        let myNumber = Float(percentage) / 100
        print("The percentage is: \(percentage)")
        print("The number is: \(myNumber)")
        
        let myCGFloat = CGFloat(myNumber)
        
        print("The myCGFloat is: \(myCGFloat)")
        
        let imgData: Data = NSData(data:myImage.jpegData(compressionQuality: myCGFloat)!) as Data
        let imageSize: Int = imgData.count
        
        print("size of image : \(imageSize)")
        var dou: Double = 0.0
        dou = Double(imageSize) / 1024.0
        
        print("size of image in KB: %f ", dou)
        print("resolution in pixels: \(myImage.size)")
        print("=========================================================")
        
        return imageSize
        
    }
    
	static func randomStringWithLength (_ len: Int) -> NSString {
		
		let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		
		let randomString: NSMutableString = NSMutableString(capacity: len)
		
		for _ in 0 ..< len {
			let length = UInt32 (letters.length)
			let rand = arc4random_uniform(length)
			randomString.appendFormat("%C", letters.character(at: Int(rand)))
		}
		
		return randomString
	}
}
