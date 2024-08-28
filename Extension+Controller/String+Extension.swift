//
//  String+Extension.swift
//  Pods
//
//  Created by Matheus Ruschel on 2017-07-04.
//
//

import Foundation

public extension String {
    
    public func localized(_ bundle: Bundle) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
    
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var isWebSite: Bool {
        let url = "((https?)://)?(([\\w\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)\\-\\+\\=\\(\\)\\[\\]\\{\\}\\?\\<\\>])*)+([\\.|/](([\\w\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)\\-\\+\\=\\(\\)\\[\\]\\{\\}\\?\\<\\>])+))+"
        let urlPredicate = NSPredicate(format: "SELF MATCHES %@", url)
        return urlPredicate.evaluate(with: self)
    }
    
    func currencySymbol() -> String {
        let locale = NSLocale(localeIdentifier: self)
        return locale.displayName(forKey: .currencySymbol, value: self) ?? self
    }

}

public protocol NumericPrintable {
    func value() -> NSNumber
}
extension Float: NumericPrintable {
    public func value() -> NSNumber {
        return NSNumber(value: self)
    }
}
extension Double: NumericPrintable {
    public func value() -> NSNumber {
        return NSNumber(value: self)
    }
}
extension NumericPrintable {
    public func string(fractionDigits:Int) -> String {
        return String(format: "%.\(fractionDigits)f", value().doubleValue)
    }
    
    public var twoDecimalFormat: String {
        return string(fractionDigits: 2)
    }
}
