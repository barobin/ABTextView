//
//  KeyboardObserver.swift
//  ABTextViewExample
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import Foundation
import UIKit

//MARK: KeyboardEventsObserverDelegate
protocol KeyboardEventsObserverDelegate: UIViewControllerDataSource {
    
    var k_tableView: UITableView! { get }
    
    var k_bottomInputOffset: CGFloat { get set }
    
    var k_inputHeight: CGFloat { get set }
}

//MARK: - KeyboardEventsObserver
@objc class KeyboardEventsObserver: NSObject {
    
    weak var delegate: KeyboardEventsObserverDelegate?
    
    @objc private(set) var subscibed: Bool = false
    
    @objc func subscribe() {
        if self.subscibed {
            return
        }
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(notificationKeyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(notificationKeyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.subscibed = true
    }
    
    @objc func unsubscribe() {
        if !self.subscibed {
            return
        }
        
        let center = NotificationCenter.default
        center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        self.subscibed = false
    }
    
    //MARK: Notifications
    @objc private func notificationKeyboardWillShow(_ notification: NSNotification) {
        guard let d = self.delegate else { return }
        let kai = notification.ab_keyboardAnimationInfo(from: d.u_rootView.window!)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(kai.animationDuration)
        UIView.setAnimationCurve(kai.animationCurve)
        
        let tableOnBottom = d.k_tableView.ext_isScrollPositionOnBottom || !d.k_tableView.ext_isContentSizeGreaterThanHeight
        
        var contentInset = d.k_tableView.contentInset
        contentInset.top = d.u_topLayoutGuide.length
        contentInset.bottom = d.k_inputHeight + kai.endFrame.height
        
        d.k_bottomInputOffset = kai.endFrame.size.height
        d.u_rootView.layoutIfNeeded()
        
        let contentSize = d.k_tableView.contentSize
        if (contentSize.height > 0.0) {
            var contentViewSize = d.k_tableView.bounds.size
            contentViewSize.height -= (contentInset.top + contentInset.bottom)
            
            if (contentViewSize.height > contentSize.height) {
                contentInset.top += (contentViewSize.height - contentSize.height)
            }
        }
        
        d.k_tableView.contentInset = contentInset
        d.k_tableView.scrollIndicatorInsets = contentInset
        
        UIView.commitAnimations()
        
        if tableOnBottom {
            d.k_tableView.ext_scrollToBottom(animated: false)
        }
    }
    
    @objc private func notificationKeyboardWillHide(_ notification: NSNotification) {
        guard let d = self.delegate else { return }
        let kai = notification.ab_keyboardAnimationInfo(from: d.u_rootView.window!)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(kai.animationDuration)
        UIView.setAnimationCurve(kai.animationCurve)
        
        var contentInset = d.k_tableView.contentInset
        contentInset.top = d.u_topLayoutGuide.length
        contentInset.bottom = d.k_inputHeight
        
        d.k_bottomInputOffset = d.u_bottomLayoutGuide.length
        d.u_rootView.layoutIfNeeded()
        
        let contentSize = d.k_tableView.contentSize
        if (contentSize.height > 0.0) {
            var contentViewSize = d.k_tableView.bounds.size
            contentViewSize.height -= (contentInset.top + contentInset.bottom)
            
            if (contentViewSize.height > contentSize.height) {
                contentInset.top += (contentViewSize.height - contentSize.height)
            }
        }
        
        d.k_tableView.contentInset = contentInset
        d.k_tableView.scrollIndicatorInsets = contentInset
        
        UIView.commitAnimations()
    }
}
