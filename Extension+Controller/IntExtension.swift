//
//  IntExtension.swift
//  Peeks
//
//  Created by Amena Amro on 6/8/16.
//  Copyright © 2016 Riavera. All rights reserved.
//
import UIKit
// from http://stackoverflow.com/questions/18267211/ios-convert-large-numbers-to-smaller-format

extension Int {
    func abbreviatedFormat() -> NSString {
        var abbrevNum: NSString = ""
        var num = self
        var number = Double(num)
        
        func doubleToString(_ val: Double) -> NSString {
            var ret = NSString(format: "%.1f", val)
            var c = ret.character(at: ret.length - 1)
            
            while c == 48 { // 0
                ret = ret.substring(to: ret.length - 1) as NSString
                c = ret.character(at: ret.length - 1)
                
                //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
                if c == 46 { // .
                    ret = ret.substring(to: ret.length - 1) as NSString
                }
            }
            
            return ret
        }
        
        if  num > 1000 {
            let abbreviations = ["K", "M", "B"]
			for i in (0...(abbreviations.count - 1)).reversed() {
				let size: Double = pow(10.0, (Double(i)+1.0)*3.0)
				if size <= number {
					// Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
					number /= size
					let numberString = doubleToString(number)
					abbrevNum = NSString(format: "%@%@", numberString, abbreviations[i])
				}
			}
        } else {
            abbrevNum = NSString(format: "%d", Int(number))
        }
        
        return abbrevNum
    }
}

extension Int64 {
    func suffixNumber() -> String {
        var num: Double = Double(self)
        let sign = ((num < 0) ? "-" : "" )
        
        num = abs(num)
        
        if num < 1000 {
            return "\(sign)\(Int(num))"
        }
        
        let exp: Int = Int(log10(num) / 3.0 )
        
        let units: [String] = ["K", "M", "G", "T", "P", "E"]
        
        let roundedNum: Double = round(10 * num / pow(1000.0, Double(exp))) / 10
        
        return "\(sign)\(roundedNum)\(units[exp-1])"
    }
}
