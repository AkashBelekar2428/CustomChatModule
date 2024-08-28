//  Peeks
//
//  Created by George Fang on 2017-06-30.
//  Copyright © 2017 Riavera. All rights reserved.
//

import UIKit

extension Date {
    
    var gregorianYear: Int {
        let gregorian = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let todayDateComps  = gregorian?.components(.year, from: self)
        return todayDateComps?.year ?? Date().gregorianYear
    }
}
