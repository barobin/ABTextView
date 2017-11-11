//
//  UIEdgeInsets+extension.swift
//  ABTextView
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import Foundation

extension UIEdgeInsets {
    
    var ab_safeInsets: UIEdgeInsets {
        return UIEdgeInsets(top: max(0.0, self.top), left: max(0.0, self.left), bottom: max(0.0, self.bottom), right: max(0.0, self.right))
    }
    
    var ab_reversed: UIEdgeInsets {
        return UIEdgeInsets(top: -self.top, left: -self.left, bottom: -self.bottom, right: -self.right)
    }
}
