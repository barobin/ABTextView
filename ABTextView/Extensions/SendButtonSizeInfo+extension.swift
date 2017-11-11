//
//  SendButtonSizeInfo+extension.swift
//  ABTextView
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import Foundation

extension ABMessageInputView.SendButtonSizeInfo {
    
    var horizontalSpace: CGFloat {
        return self.width + self.rightOffset
    }
    
    var verticalSpace: CGFloat {
        return self.topOffset + self.height + self.bottomOffset
    }
    
    var ab_safeInfo: ABMessageInputView.SendButtonSizeInfo {
        return ABMessageInputView.SendButtonSizeInfo(
            topOffset: max(0.0, self.topOffset),
            bottomOffset: max(0.0, self.bottomOffset),
            rightOffset: max(0.0, self.rightOffset),
            width: max(0.0, self.width),
            height: max(0.0, self.height)
        )
    }
}
