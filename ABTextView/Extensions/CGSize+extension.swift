//
//  CGSize+extension.swift
//  ABTextView
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import Foundation

extension CGSize {
    
    mutating func ab_ceil() {
        self.width = Darwin.ceil(self.width)
        self.height = Darwin.ceil(self.height)
    }
}
