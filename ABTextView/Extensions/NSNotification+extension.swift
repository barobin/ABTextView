//
//  NSNotification+extension.swift
//  ABTextView
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import Foundation

public struct KeyboardAnimationInfo {
    
    public let beginFrame: CGRect
    
    public let endFrame: CGRect
    
    public let animationDuration: TimeInterval
    
    public let animationCurve: UIViewAnimationCurve
}

public extension NSNotification {
    
    public func ab_keyboardAnimationInfo(from view: UIView) -> KeyboardAnimationInfo {
        let info = self.userInfo ?? [:]
        
        let beginFrame = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let keyboardBeginFrame = view.convert(beginFrame, from: nil)
        
        let endFrame = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let keyboardEndFrame = view.convert(endFrame, from: nil)
        
        let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? Double(0.25)
        
        let curveValue = (info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? UIViewAnimationCurve.linear.rawValue
        let animationCurve = UIViewAnimationCurve(rawValue: curveValue)!
        
        return KeyboardAnimationInfo(
            beginFrame: keyboardBeginFrame,
            endFrame: keyboardEndFrame,
            animationDuration: animationDuration,
            animationCurve: animationCurve
        )
    }
}
