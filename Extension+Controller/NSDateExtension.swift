//
//  NSDate+Extension.swift
//  Tasty
//
//  Created by Vitaliy Kuzmenko on 17/10/14.
//  http://github.com/vitkuzmenko
//  Copyright (c) 2014 Vitaliy Kuz'menko. All rights reserved.
//

import Foundation

let kMinute = 60
let kDay    = kMinute * 24
let kWeek   = kDay * 7
let kMonth  = kDay * 31
let kYear   = kDay * 365

func NSDateTimeAgoLocalizedStrings(_ key: String) -> String {
    
    let resourcePath = Bundle.main.resourcePath
    let path = NSString(string: resourcePath!).appendingPathComponent("NSDateTimeAgo.bundle")
    let bundle = Bundle(path: path)
    
    return NSLocalizedString(key, tableName: "NSDateTimeAgo", bundle: bundle!, comment: "")
}

extension Foundation.Date {
    
    struct DateFormat {
        static let formatterShortDate = DateFormatter(dateFormat: "dd-MM-yyyy")
        static let invertedFormatterShortDate = DateFormatter(dateFormat: "yyyy-MM-dd")
    }
    var shortDate: String {
        return DateFormat.formatterShortDate.string(from: self)
    }
    var invertedShortDate: String {
        return DateFormat.invertedFormatterShortDate.string(from: self)
    }
    
    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            return formatter
        }()
    }
    var iso8601: String { return Formatter.iso8601.string(from: self) }

    // shows 1 or two letter abbreviation for units.
    // does not include 'ago' text ... just {value}{unit-abbreviation}
    // does not include interim summary options such as 'Just now'
    var timeAgoSimple: String {
        let now = Foundation.Date()
        let deltaSeconds = Int64(fabs(timeIntervalSince(now)))
        let deltaMinutes = Int(truncatingIfNeeded: deltaSeconds / 60)
        var value: Int!
        if deltaSeconds < kMinute {
            // Seconds
            return "\(deltaSeconds)s"
        } else if deltaMinutes < kMinute {
            // Minutes
            return stringFromFormat("%%d%@m", withValue: deltaMinutes)
        } else if deltaMinutes < kDay {
            // Hours
            value = Int(floor(Float(deltaMinutes / kMinute)))
            return stringFromFormat("%%d%@h", withValue: value)
        } else if deltaMinutes < kWeek {
            // Days
            value = Int(floor(Float(deltaMinutes / kDay)))
            return stringFromFormat("%%d%@d", withValue: value)
        } else if deltaMinutes < kMonth {
            // Weeks
            value = Int(floor(Float(deltaMinutes / kWeek)))
            return stringFromFormat("%%d%@w", withValue: value)
        } else if deltaMinutes < kYear {
            // Month
            value = Int(floor(Float(deltaMinutes / kMonth)))
            return stringFromFormat("%%d%@mo", withValue: value)
        }
        // Years
        value = Int(floor(Float(deltaMinutes / kYear)))
        return stringFromFormat("%%d%@yr", withValue: value)
    }
    
    var timeAgo: String {
        let now = Foundation.Date()
        let deltaSeconds = Int64(fabs(timeIntervalSince(now)))
        let deltaMinutes = Int(truncatingIfNeeded: deltaSeconds / 60)
        var value: Int!
        if deltaSeconds < 5 {
            // Just Now
            return NSDateTimeAgoLocalizedStrings("Just now")
        } else if deltaSeconds < kMinute {
            // Seconds Ago
            return "\(deltaSeconds) seconds ago"
        } else if deltaSeconds < 120 {
            // A Minute Ago
            return NSDateTimeAgoLocalizedStrings("A minute ago")
        } else if deltaMinutes < kMinute {
            // Minutes Ago
            return stringFromFormat("%%d %@minutes ago", withValue: deltaMinutes)
        } else if deltaMinutes < 120 {
            // An Hour Ago
            return NSDateTimeAgoLocalizedStrings("An hour ago")
        } else if deltaMinutes < kDay {
            // Hours Ago
            value = Int(floor(Float(deltaMinutes / kMinute)))
            return stringFromFormat("%%d %@hours ago", withValue: value)
        } else if deltaMinutes < (kDay * 2) {
            // Yesterday
            return NSDateTimeAgoLocalizedStrings("Yesterday")
        } else if deltaMinutes < kWeek {
            // Days Ago
            value = Int(floor(Float(deltaMinutes / kDay)))
            return stringFromFormat("%%d %@days ago", withValue: value)
        } else if deltaMinutes < (kWeek * 2) {
            // Last Week
            return NSDateTimeAgoLocalizedStrings("Last week")
        } else if deltaMinutes < kMonth {
            // Weeks Ago
            value = Int(floor(Float(deltaMinutes / kWeek)))
            return stringFromFormat("%%d %@weeks ago", withValue: value)
        } else if deltaMinutes < (kDay * 61) {
            // Last month
            return NSDateTimeAgoLocalizedStrings("Last month")
        } else if deltaMinutes < kYear {
            // Month Ago
            value = Int(floor(Float(deltaMinutes / kMonth)))
            return stringFromFormat("%%d %@months ago", withValue: value)
        } else if deltaMinutes < (kDay * (kYear * 2)) {
            // Last Year
            return NSDateTimeAgoLocalizedStrings("Last Year")
        }
        
        // Years Ago
        value = Int(floor(Float(deltaMinutes / kYear)))
        return stringFromFormat("%%d %@years ago", withValue: value)
        
    }
    
    func stringFromFormat(_ format: String, withValue value: Int) -> String {
        
        let localeFormat = String(format: format, getLocaleFormatUnderscoresWithValue(Double(value)))
        
        return String(format: NSDateTimeAgoLocalizedStrings(localeFormat), value)
    }
    
    func getLocaleFormatUnderscoresWithValue(_ value: Double) -> String {
        
        //let localeCode = NSLocale.preferredLanguages().first as String!
        
        /*
        if localeCode == "ru" {
            let XY = Int(floor(value)) % 100
            let Y = Int(floor(value)) % 10
            
            if Y == 0 || Y > 4 || (XY > 10 && XY < 15) {
                return ""
            }
            
            if Y > 1 && Y < 5 && (XY < 10 || XY > 20) {
                return "_"
            }
            
            if Y == 1 && XY != 11 {
                return "__"
            }
        }
        */
        
        return ""
    }
    
    func lessThan24Hours(_ date: Foundation.Date) -> Bool {
        let distanceBetweenDates = Foundation.Date().timeIntervalSince(date)
        let secondsInAnHour = 3600.0
        let hoursBetweenDates = distanceBetweenDates / secondsInAnHour
        return (hoursBetweenDates < 24.0)
    }
    
    func getFirstOfMonth() -> Foundation.Date {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components: DateComponents = (Calendar.current as NSCalendar).components([.month, .year], from: self)
        let newDate = calendar.date(from: components)
        
        return newDate!
    }
    
    func yearsFrom(_ date: Foundation.Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    
    func monthsFrom(_ date: Foundation.Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    
    func weeksFrom(_ date: Foundation.Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    
    func daysFrom(_ date: Foundation.Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    
    func hoursFrom(_ date: Foundation.Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    
    func minutesFrom(_ date: Foundation.Date) -> Int {
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    
    func secondsFrom(_ date: Foundation.Date) -> Int {
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    
    func offsetFrom(_ date: Foundation.Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
    
    var age: Int {
         let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        return gregorian.dateComponents([.year], from: self, to: Date()).year ?? Date().gregorianYear
    }
    
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func getNextMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)
    }
    
    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }
    
}

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
