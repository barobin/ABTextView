//
//  ABTextView.swift
//  ABTextView
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import UIKit

//MARK: ABTextViewDelegate
public protocol ABTextViewDelegate: class {
    func textView(_ textView: ABTextView, beginSetNewHeight height: CGFloat)
    func textView(_ textView: ABTextView, endSetNewHeight height: CGFloat)
    func textView(_ textView: ABTextView, allowNewHeight height: CGFloat, butMaxAllowedHeight allowedHeight: inout CGFloat) -> Bool
    func textViewMaxNumberOfLinesAllowed(_ textView: ABTextView) -> Int
    func textView(_ textView: ABTextView, didChangedAttributedText text: NSAttributedString?)
    func textViewDidBeginEditing(_ textView: ABTextView)
    func textViewDidEndEditing(_ textView: ABTextView)
}

//MARK: - ABTextView
public class ABTextView: UIView {
    
    public enum Consts {
        
        public enum Input {
            static let textFont = UIFont.systemFont(ofSize: 14.0)
            static let textColor = UIColor.black
        }
        
        public enum Placeholder {
            static let textColor = UIColor.lightGray
        }
        
    }
    
    private var layoutManager = ABLayoutManager()
    
    fileprivate var attributedTextSet: Bool = true
    
    fileprivate weak var textView: UITextView!
    
    private weak var placeholderLabel: UILabel!

    public weak var delegate: ABTextViewDelegate?
    
    @objc public var keyboardType: UIKeyboardType {
        get {
            return self.textView.keyboardType
        }
        set {
            self.textView.keyboardType = newValue
        }
    }
    
    @objc public var returnKeyType: UIReturnKeyType {
        get {
            return self.textView.returnKeyType
        }
        set {
            self.textView.returnKeyType = newValue
        }
    }
    
    @objc public var useLinesCountForHeight: Bool = false {
        didSet {
            self.measureText(force: true)
        }
    }
    
    @objc public var attributedText: NSAttributedString? {
        didSet {
            if self.attributedTextSet {
                self.textView.attributedText = attributedText
                self.updatePlaceholder()
            }
            
            self.measureText()
        }
    }
    
    @objc public var placeholderText: String? {
        didSet {
            if let text = self.attributedText {
                if text.length > 0 {
                    self.placeholderLabel.text = nil
                    
                } else {
                    if self.textView.isFirstResponder {
                        self.placeholderLabel.text = nil
                        
                    } else {
                        self.placeholderLabel.text = placeholderText
                    }
                }
            } else {
                if self.textView.isFirstResponder {
                    self.placeholderLabel.text = nil
                    
                } else {
                    self.placeholderLabel.text = placeholderText
                }
            }
        }
    }
    
    public override var isFirstResponder: Bool {
        get {
            return self.textView.isFirstResponder
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initABTextView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initABTextView()
    }
    
    public override func becomeFirstResponder() -> Bool {
        return self.textView.becomeFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        return self.textView.resignFirstResponder()
    }
    
    //MARK: Private
    
    private func initABTextView() {
        let textView = UITextView(frame: self.bounds)
        textView.delegate = self
        textView.backgroundColor = UIColor.clear
        textView.isOpaque = false
        textView.clipsToBounds = true
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0.0
        textView.isScrollEnabled = true
        textView.textContainer.lineBreakMode = .byCharWrapping
        textView.font = Consts.Input.textFont
        textView.textColor = Consts.Input.textColor
        self.addSubview(textView)
        self.textView = textView
        
        let placeholderLabel = UILabel(frame: self.bounds)
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.isOpaque = false
        placeholderLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        placeholderLabel.textAlignment = .left
        placeholderLabel.font = Consts.Input.textFont
        placeholderLabel.textColor = Consts.Placeholder.textColor
        placeholderLabel.numberOfLines = 0
        self.addSubview(placeholderLabel)
        self.placeholderLabel = placeholderLabel
    }
    
    //MARK: Public
    
    @objc public func measureText(force: Bool = false) {
        var text: NSAttributedString! = self.attributedText
        if (text == nil || text.length == 0) {
            text = NSAttributedString(string: "Sample", attributes: [NSAttributedStringKey.font: self.textView.font!])
        }
        
        self.layoutManager.storageText = text
        var textSize = self.layoutManager.measureSize(for: CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        textSize.ab_ceil()
        textSize.width = self.bounds.width
        
        if !self.bounds.size.equalTo(textSize) || force {
            if self.useLinesCountForHeight {
                let linesCount = self.layoutManager.measureLinesCount(for: CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
                
                let maxNumbersOfLines = self.delegate?.textViewMaxNumberOfLinesAllowed(self) ?? 1
                if (linesCount <= maxNumbersOfLines) {
                    self.delegate?.textView(self, beginSetNewHeight: textSize.height)
                    self.textView.frame = CGRect(size: textSize)
                    self.textView.textContainer.size = self.textView.frame.size
                    self.delegate?.textView(self, endSetNewHeight: textSize.height)
                    
                } else {
                    self.textView.textContainer.size = textSize
                    textSize = self.layoutManager.measureSize(for: self.bounds.width, linesCount: maxNumbersOfLines)
                    textSize.ab_ceil()
                    textSize.width = self.bounds.width
                    let textFrameIsChanging = !self.textView.frame.size.equalTo(textSize)
                    
                    if textFrameIsChanging {
                        self.delegate?.textView(self, beginSetNewHeight: textSize.height)
                        self.textView.frame = CGRect(size: textSize)
                    }
                    
                    self.textView.scrollRangeToVisible(self.textView.selectedRange)
                    
                    if textFrameIsChanging {
                        self.delegate?.textView(self, endSetNewHeight: textSize.height)
                    }
                }
                
            } else {
                var allowedHeight = CGFloat(0.0)
                let allowNewHeight = self.delegate?.textView(self, allowNewHeight: textSize.height, butMaxAllowedHeight: &allowedHeight) ?? false
                if allowNewHeight {
                    self.delegate?.textView(self, beginSetNewHeight: textSize.height)
                    self.textView.frame = CGRect(size: textSize)
                    self.textView.textContainer.size = self.textView.frame.size
                    self.delegate?.textView(self, endSetNewHeight: textSize.height)
                    
                } else {
                    self.textView.textContainer.size = textSize
                    
                    textSize = self.layoutManager.measureSize(for: CGSize(width: self.bounds.width, height: allowedHeight))
                    textSize.ab_ceil()
                    textSize.width = self.bounds.width
                    let textFrameIsChanging = !self.textView.frame.size.equalTo(textSize)
                    
                    if textFrameIsChanging {
                        self.delegate?.textView(self, beginSetNewHeight: textSize.height)
                        self.textView.frame = CGRect(size: textSize)
                    }
                    
                    self.textView.scrollRangeToVisible(self.textView.selectedRange)
                    
                    if textFrameIsChanging {
                        self.delegate?.textView(self, endSetNewHeight: textSize.height)
                    }
                }
            }
        }
    }
    
    fileprivate func updatePlaceholder() {
        if let text = self.textView.attributedText {
            if text.length > 0 {
                self.placeholderLabel.text = nil
            } else {
                if self.textView.isFirstResponder {
                    self.placeholderLabel.text = nil
                } else {
                    self.placeholderLabel.text = self.placeholderText
                }
            }
        } else {
            if self.textView.isFirstResponder {
                self.placeholderLabel.text = nil
            } else {
                self.placeholderLabel.text = self.placeholderText
            }
        }
    }
}

//MARK: - ABTextView (UITextViewDelegate)
extension ABTextView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        self.textView.layer.removeAllAnimations()
        
        self.attributedTextSet = false
        self.attributedText = self.textView.attributedText
        self.attributedTextSet = true
        
        self.delegate?.textView(self, didChangedAttributedText: self.attributedText)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        self.updatePlaceholder()
        self.delegate?.textViewDidBeginEditing(self)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        self.updatePlaceholder()
        self.delegate?.textViewDidEndEditing(self)
    }
}
