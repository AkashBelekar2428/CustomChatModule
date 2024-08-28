//
//  RatingEnum.swift
//  Peeks
//
//  Created by Sara Al-kindy on 2016-05-19.
//  Copyright © 2016 Riavera. All rights reserved.
//

enum RatingType: Int {
    case g
    case plus14
    case plus18
    case none
    
    static let allValues = [g, plus14, plus18]
    
    func getTitle() -> String {
        switch self {
        case .none: return "Please pick a rating"
        case .g: return "G"
        case .plus14: return "14+"
        case .plus18: return "18+"
        }
    }
    
    func getValue() -> String {
        switch self {
        case .g: return "G"
        case .plus14: return "PLUS_14"
        case .plus18: return "PLUS_18"
        default: return ""
        }
    }
    
    func parseFromApi(_ param: String) -> RatingType {
        if param == "G"{
            return RatingType.g
        }
        
        if param == "PLUS_14"{
            
            return RatingType.plus14
        }
        
        if param == "PLUS_18"{
            return RatingType.plus18
        }
        
        return RatingType.none
    }
    
    func getIcon() -> String {
        switch self {
        case .g: return "g"
        case .plus14: return "14_plus"
        case .plus18: return "18_plus"
        default: return ""
        }
    }
    
    func getWarningTitle() -> String {
        switch self {
        case .g: return "rating_title_warning_low"
        case .plus14: return "rating_title_warning_high"
        case .plus18: return "rating_title_warning_high"
        default: return ""
        }
    }
    
    func getWarningMessage() -> String {
        switch self {
        case .g: return "rating_message_low"
        case .plus14: return "rating_message_medium"
        case .plus18: return "rating_message_high"
        default: return ""
        }
    }
    
    func getWarningFooter() -> String {
        switch self {
        case .g: return "rating_footer_low"
        case .plus14: return "rating_footer_medium"
        case .plus18: return "rating_footer_high"
        default: return ""
        }
    }
}
