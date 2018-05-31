//
//  UIScrollView+extension.swift
//  ABTextView
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import UIKit

public extension UIScrollView {
    
    private var verticalOffsetForTop: CGFloat {
        return -self.contentInset.top
    }
    
    private var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = self.bounds.size.height
        let scrollContentSizeHeight = self.contentSize.height
        let bottomInset = self.contentInset.bottom
        return scrollContentSizeHeight + bottomInset - scrollViewHeight
    }
    
    @objc public var ext_isScrollPositionOnTop: Bool {
        return self.contentOffset.y <= self.verticalOffsetForTop
    }
    
    @objc public var ext_isScrollPositionOnBottom: Bool {
        return self.contentOffset.y >= self.verticalOffsetForBottom
    }
    
    @objc public var ext_isContentSizeGreaterThanHeight: Bool {
        var scrollViewHeight = self.bounds.height
        let contentInsets = self.contentInset
        scrollViewHeight -= (contentInsets.top + contentInsets.bottom)
        if (self.contentSize.height > scrollViewHeight) {
            return true
        }
        
        return false
    }
    
    @objc public func ext_scrollToTop(animated: Bool) {
        self.setContentOffset(CGPoint(x: 0.0, y: self.verticalOffsetForTop), animated: animated)
    }
    
    @objc public func ext_scrollToBottom(animated: Bool) {
        let contentSize = self.contentSize
        var boundsSize = self.bounds.size
        let contentInset = self.contentInset
        boundsSize.height -= (contentInset.top + contentInset.bottom)
        
        if (contentSize.height > boundsSize.height) {
            var contentOffset = self.contentOffset;
            contentOffset.y = contentSize.height - boundsSize.height - contentInset.top
            if !self.contentOffset.equalTo(contentOffset) {
                self.setContentOffset(contentOffset, animated: animated)
            }
        }
    }
}
