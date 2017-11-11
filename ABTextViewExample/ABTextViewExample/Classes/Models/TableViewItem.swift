//
//  TableViewItem.swift
//  ABTextViewExample
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import UIKit

struct TableViewSection {
    
    let identifier: String
    
    let displayName: String
    
    var items: [TableViewItem]
}

struct TableViewItem {
    
    let displayName: String
    
    let identifier: String
}
