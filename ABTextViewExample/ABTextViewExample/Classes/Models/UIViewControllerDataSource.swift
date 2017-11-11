//
//  UIViewControllerDataSource.swift
//  ABTextViewExample
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import Foundation
import UIKit

//MARK: UIViewControllerDataSource
protocol UIViewControllerDataSource: class {
    
    var u_rootView: UIView! { get }
    
    var u_topLayoutGuide: UILayoutSupport { get }
    
    var u_bottomLayoutGuide: UILayoutSupport { get }
}

//MARK: - UIViewControllerDataSource
extension UIViewControllerDataSource where Self : UIViewController {
    
    var u_rootView: UIView! {
        return self.view
    }
    
    var u_topLayoutGuide: UILayoutSupport {
        return self.topLayoutGuide
    }
    
    var u_bottomLayoutGuide: UILayoutSupport {
        return self.bottomLayoutGuide
    }
}
