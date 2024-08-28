//
//  LoadMoreFooterView.swift
//  Peeks
//
//  Created by Sara Al-Kindy on 2017-03-16.
//  Copyright © 2017 Riavera. All rights reserved.
//

import Foundation
import UIKit

class LoadMoreFooterView: UIView {
    
    fileprivate var activityIndicator: UIActivityIndicatorView?
    
    var isLight: Bool = false {
        didSet {
            initalize()
        }
    }
    
    init(frame: CGRect, isLight: Bool) {
        super.init(frame: frame)
        self.isLight = isLight
        initalize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initalize()
    }
    
    fileprivate func initalize() {
        if let a = activityIndicator {
            a.style = isLight ? UIActivityIndicatorView.Style.medium : UIActivityIndicatorView.Style.large
            a.color = .MiiTV_ThemeClr()
        } else {
            activityIndicator = UIActivityIndicatorView(style: isLight ? UIActivityIndicatorView.Style.medium : UIActivityIndicatorView.Style.large)
            activityIndicator!.color = .MiiTV_ThemeClr()
            activityIndicator!.center = CGPoint(x: self.frame.width / 2, y: 20)
            self.addSubview(activityIndicator!)
        }
    }
    
    func startAnimating() {
        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
        }
    }
    
    func stopAnimating() {
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
        }
    }
}
