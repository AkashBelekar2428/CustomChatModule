//
//  UIUtil.swift
//  Peeks
//
//  Created by Sara Al-kindy on 2016-03-23.
//  Copyright © 2016 Riavera. All rights reserved.
//

import UIKit

class UIUtil: NSObject {
    var bubbleColor = UIColor(red: 79.0/255.0, green: 83.0/255.0, blue: 88.0/255.0, alpha: 1.0)
    func switchSelectedBubble(_ selected: [UIButton]?, deselected: [UIButton]?) {
        if let selected = selected {
            for sButton in selected {
                DispatchQueue.main.async {
                //    sButton.setSelectedBubble(self.bubbleColor)
                }
            }
        }
        
        if let deselected = deselected {
            for dButton in deselected {
                DispatchQueue.main.async {
               //     dButton.setUnselectedBubble()
                }
            }
        }
    }
    
    static func apiFailure(_ error: String, vc: UIViewController) {
        DispatchQueue.main.async {
            vc.resignFirstResponder()
            self.showAlert(NSLocalizedString("error", comment: ""), message: error, vc: vc)
        }
    }
    
    static func errorMessage(_ message: String, vc: UIViewController) {
        DispatchQueue.main.async {
            vc.resignFirstResponder()
            self.showAlert(NSLocalizedString("error", comment: ""), message: message, vc: vc)
        }
    }
    
    static func showAlertWithButtons(btnNo: String, btnYes: String, msg: String, title: String = "Alert", vc: UIViewController, closure:@escaping()->()) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message:
                msg, preferredStyle: UIAlertController.Style.alert)
            alertController.view.accessibilityIdentifier = title
            if btnNo.length > 0 {
                alertController.addAction(UIAlertAction.init(title: btnNo, style: .default, handler: { (action) in
                    
                }))
            }
            if btnYes.count > 0 {
                alertController.addAction(UIAlertAction.init(title: btnYes, style: .default, handler: { (action) in
                    closure()
                }))
            }
            vc.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func showAlert(_ title: String, message: String, vc: UIViewController) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: nil))
			if !vc.isBeingDismissed {
                if let tempVC = UIApplication.getTopViewController() {
                    tempVC.present(alert, animated: true, completion: nil)
                }
			}
        })
    }

    static func convertToSeconds(timeString: String) -> Int {
        
        if timeString == "" {
            return 0
        }
        let timeParts = timeString.components(separatedBy: ":")
        guard timeParts.count == 3 else {
            // Handle the case where the time string is not in the correct format
            fatalError("Invalid time string format")
        }

        let hours = Int(timeParts[0]) ?? 0
        let minutes = Int(timeParts[1]) ?? 0
        let seconds = Int(timeParts[2]) ?? 0

        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        return totalSeconds
    }
    
    static func showLoaderOnTopWithMessage( msg: String?) {
        DispatchQueue.main.async {
            ProgressHUD.animationType = .circleStrokeSpin
            ProgressHUD.spinnerAtTop = true            
            ProgressHUD.colorStatus = .MiiTV_ThemeClr()
            ProgressHUD.colorAnimation = .MiiTV_ThemeClr()
            ProgressHUD.show(msg, interaction: true)
        }
    }
    
    static func indicateActivityForView(_ view: UIView, labelText: String?, color: UIColor = UIColor.black, spinnerAtTop: Bool = false) {
        DispatchQueue.main.async {
            ProgressHUD.animationType = .circleStrokeSpin
            ProgressHUD.spinnerAtTop = spinnerAtTop
            ProgressHUD.colorStatus = .MiiTV_ThemeClr()
            ProgressHUD.colorAnimation = .MiiTV_ThemeClr()
            showLoaderWithMsg(msg: labelText ?? "")
        }
    }
    // Loader Methods
    
    static func showLoader() {
        DispatchQueue.main.async {
            ProgressHUD.animationType = .circleStrokeSpin
            ProgressHUD.colorStatus = .MiiTV_ThemeClr()
            ProgressHUD.colorAnimation = .MiiTV_ThemeClr()
            ProgressHUD.show("", interaction: false)
        }
    }
    
    static func showLoaderWithMsg(msg:String) {
        DispatchQueue.main.async {
            ProgressHUD.animationType = .circleStrokeSpin
            ProgressHUD.colorStatus = .MiiTV_ThemeClr()
            ProgressHUD.colorAnimation = .MiiTV_ThemeClr()
            ProgressHUD.show(msg, interaction: false)
        }
    }
    
    static func hideLoader() {
        DispatchQueue.main.async {
            ProgressHUD.dismiss()
        }
    }
    
    static func removeActivityViewFromView(_ view: UIView) {
        DispatchQueue.main.async {
            hideLoader()
        }
    }
    
    static func createMessageLabel(_ vc: UIViewController, message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: vc.view.bounds.size.width, height: 30))
        messageLabel.center = CGPoint(x: vc.view.center.x, y: vc.view.center.y)
        messageLabel.textAlignment = .center
        messageLabel.tag = 1313
        messageLabel.font = messageLabel.font.withSize(20)
        messageLabel.textColor = UIColor.white
        messageLabel.text = message
        vc.view.addSubview(messageLabel)
    }
    
    static func removeMessageLabel(_ vc: UIViewController) {
        if let subView: UIView = vc.view.viewWithTag(1313) {
            subView.removeFromSuperview()
        }
    }
    
    static func dateToMilliseconds(date: Date?) -> Int64 {
        let milliseconds = Int64(date!.timeIntervalSince1970 * 1000)
            return milliseconds
      
    }
    
    static func dateToString(dateToConvert: Date?) -> String {
        if dateToConvert == nil {
            return ""
        }
        let dateFormatter = DateFormatter()
                let currentDate = Date()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if Calendar.current.isDateInToday(dateToConvert!) {
                    // Message was sent today, format with time only
                    dateFormatter.dateFormat = "hh:mm a"
                    let formattedTime = dateFormatter.string(from: dateToConvert!)
                   return formattedTime
                } else if Calendar.current.isDate(dateToConvert!, equalTo: currentDate, toGranularity: .weekOfYear) {
                    // Message was sent this week, format with the day of the week
                    dateFormatter.dateFormat = "EEEE" // Full day name
                    let formattedDay = dateFormatter.string(from: dateToConvert!)
                    return formattedDay
                } else {
                    // Message was sent on a different day, format with date only
                    dateFormatter.dateFormat = "MMM dd"
                    let formattedDate = dateFormatter.string(from: dateToConvert!)
                    return formattedDate
                }
        return ""
    }
    
    static func dateToTopString(dateToConvert: Date?) -> String {
        if dateToConvert == nil {
            return ""
        }
        let dateFormatter = DateFormatter()
                let currentDate = Date()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if Calendar.current.isDateInToday(dateToConvert!) {
                    // Message was sent today, format with time only
                   return "Today"
                } else if Calendar.current.isDate(dateToConvert!, equalTo: currentDate, toGranularity: .weekOfYear) {
                    // Message was sent this week, format with the day of the week
                    dateFormatter.dateFormat = "EEEE" // Full day name
                    let formattedDay = dateFormatter.string(from: dateToConvert!)
                    return formattedDay
                } else {
                    // Message was sent on a different day, format with date only
                    dateFormatter.dateFormat = "dd MMMM YYYY"
                    let formattedDate = dateFormatter.string(from: dateToConvert!)
                    return formattedDate
                }
        return ""
    }
    
    static func stringDateToTopString(dateToConvert: String?) -> String {
        guard let dateString = dateToConvert else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let date = dateFormatter.date(from: dateString) else {
            return ""
        }
        
        let currentDate = Date()
        
        if Calendar.current.isDateInToday(date) {
            return "Today".localized
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday".localized
        } else if Calendar.current.isDate(date, equalTo: currentDate, toGranularity: .weekOfYear) {
            dateFormatter.dateFormat = "EEEE" // Full day name
            
            let formattedDay = dateFormatter.string(from: date)
            
            return formattedDay.localized
        } else {
            dateFormatter.dateFormat = "dd MMMM yyyy"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        }
    }
    
    static func dayDateFromString(dateToConvert: String?) -> String {
        guard let dateString = dateToConvert else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let date = dateFormatter.date(from: dateString) else {
            return ""
        }
        
        let currentDate = Date()
        
        if Calendar.current.isDateInToday(date) {
            dateFormatter.dateFormat = "hh:mm a" // Full day name
            let formattedDay = dateFormatter.string(from: date)
            return formattedDay
        } else if Calendar.current.isDate(date, equalTo: currentDate, toGranularity: .weekOfYear) {
            dateFormatter.dateFormat = "EEEE" // Full day name
            let formattedDay = dateFormatter.string(from: date)
            return formattedDay
        } else {
            dateFormatter.dateFormat = "EEEE, dd MMM"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        }
    }
    
    static func dateToTimeString(dateToConvert: Date?) -> String {
        if dateToConvert == nil {
            return ""
        }
        print("Date to convert \(dateToConvert)")
        let dateFormatter = DateFormatter()
                let currentDate = Date()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale.current

        dateFormatter.dateFormat = "hh:mm a"
        let formattedTime = dateFormatter.string(from: dateToConvert!)
       return formattedTime
        
    }
   static func dateFromMillisecondsDateString(date: Int64) -> String {
        if date == 0 {
            return ""
        }
        let style = "hh:mm a"
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.dateFormat = style //hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US") //uncomment if you don't want to get the system default format.
        dateFormatter.timeZone = TimeZone.current
        
        var dateObj: Date?
        dateObj = Date(timeIntervalSince1970: (Double(date) / 1000.0))
       
        return dateObj == nil ? "": dateFormatter.string(from: dateObj!)
    }
    
    static func dayDateFromMilliseconds(milliseconds: Int64) -> String {
        let currentDate = Date()
        let inputDate = Date(timeIntervalSince1970: Double(milliseconds) / 1000.0)
            
            let calendar = Calendar.current
            
            // Check if the date is today
            if calendar.isDateInToday(inputDate) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                return dateFormatter.string(from: inputDate)
            }
            
            if calendar.isDateInYesterday(inputDate) {
                return "Yesterday".localized
            }
        
            // Check if the date is within this week
            if calendar.isDate(inputDate, equalTo: currentDate, toGranularity: .weekOfYear) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"  // Day of the week
                return dateFormatter.string(from: inputDate)
            }
            
            // If not today or within this week, show the full date and time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            return dateFormatter.string(from: inputDate)
        
    }
    
    static func convertDateStringToMilliseconds(dateString: String) -> TimeInterval? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateString) {
            // Calculate milliseconds since Unix epoch
            return date.timeIntervalSince1970 * 1000.0
        }
        
        return 0
    }
}

extension UINavigationController {
    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)

        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }

    func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)

        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}

//MARK: UIApplication Extension
extension UIApplication {
    static func getTopViewController() -> UIViewController? {
        if #available(iOS 13, *) {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            
            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            }
        } else {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            }
        }
        return nil
    }
}
