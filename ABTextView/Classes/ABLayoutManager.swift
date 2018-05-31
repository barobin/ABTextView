//
//  ABLayoutManager.swift
//  ABTextView
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import UIKit

//MARK: ABLayoutManager
internal class ABLayoutManager: NSLayoutManager {
    
    private var storedTextStorage: NSTextStorage? {
        didSet {
            oldValue?.removeLayoutManager(self)
            storedTextStorage?.addLayoutManager(self)
        }
    }
    
    @objc var storageText: NSAttributedString? {
        get {
            if let storage = self.storedTextStorage {
                return storage
            }
            
            return nil
        }
        set {
            if let storage = self.storedTextStorage {
                let newStringValue = newValue ?? NSAttributedString()
                storage.replaceCharacters(in: NSMakeRange(0, storage.length), with: newStringValue)
                
            } else {
                if let newStringValue = newValue {
                    let textStorageValue = NSTextStorage(attributedString: newStringValue)
                    self.storedTextStorage = textStorageValue
                }
            }
        }
    }
    
    override init() {
        super.init()
        self.initABLayoutManager()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initABLayoutManager()
    }
    
    //MARK: Private
    private func initABLayoutManager() {
        let textContainer = NSTextContainer(size: CGSize(width: 100.0, height: 100.0))
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .byCharWrapping
        self.addTextContainer(textContainer)
    }
    
    //MARK: Public
    @objc func measureSize(for size: CGSize) -> CGSize {
        guard let text_container = self.textContainers.first else {
            return CGSize.zero
        }
        
        text_container.size = size
        return self.usedRect(for: text_container).size
    }
    
    @objc func measureLinesCount(for size: CGSize) -> Int {
        guard let text_container = self.textContainers.first else {
            return 0
        }
        
        text_container.size = size
        
        var lineRange = NSMakeRange(0, 0)
        let glyphRange = self.glyphRange(for: text_container)
        
        var numbersOfLines = 0
        var lastOriginY = CGFloat(-1.0)
        while (lineRange.location < NSMaxRange(glyphRange)) {
            let lineRect = self.lineFragmentRect(forGlyphAt: lineRange.location, effectiveRange: &lineRange)
            
            if (lineRect.minY > lastOriginY) {
                numbersOfLines += 1
            }
            
            lastOriginY = lineRect.minY
            lineRange.location = NSMaxRange(lineRange)
        }
        
        return numbersOfLines
    }
    
    @objc func measureSize(for width: CGFloat, linesCount count: Int) -> CGSize {
        guard let text_container = self.textContainers.first else {
            return CGSize.zero
        }
        
        var lineIndex = 0
        var result = CGSize(width: width, height: 0.0)
        let glyphRange = self.glyphRange(for: text_container)
        var lineRange = NSMakeRange(0, 0)
        
        while (lineRange.location < NSMaxRange(glyphRange)) {
            let lineRect = self.lineFragmentRect(forGlyphAt: lineRange.location, effectiveRange: &lineRange)
            result.height += lineRect.height
            
            lineIndex += 1
            if lineIndex == count {
                break
            }
            
            lineRange.location = NSMaxRange(lineRange)
        }
        
        return result
    }
}
