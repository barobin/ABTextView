//
//  NSObject+extension.swift
//  ABTextViewExample
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import UIKit

extension NSObject {
    
    @objc public class var className: String {
        guard let result = String(describing: self).components(separatedBy: ".").last else {
            return String(describing: self)
        }
        
        return result
    }
    
    @objc public var className: String {
        return type(of: self).className
    }
    
}
