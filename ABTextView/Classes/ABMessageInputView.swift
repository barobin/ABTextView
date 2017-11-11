//
//  ABMessageInputView.swift
//  ABTextView
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import UIKit

//MARK: ABMessageInputViewDelegate
@objc public protocol ABMessageInputViewDelegate: class {
    func messageInputView(_ inputView: ABMessageInputView, willChangeHeight height: CGFloat, animated: Bool)
    func messageInputView(_ inputView: ABMessageInputView, didChangeAttributedText text: NSAttributedString?)
    @objc optional func messageInputViewDidSendText(_ inputView: ABMessageInputView)
    @objc optional func messageInputViewDidBeginEditing(_ inputView: ABMessageInputView)
    @objc optional func messageInputViewDidEndEditing(_ inputView: ABMessageInputView)
}

//MARK: - ABMessageInputView
public class ABMessageInputView: UIView {
    
    public enum Consts {
        
        public enum Input {
            public static let minHeight = CGFloat(44.0)
        }
        
        public enum Separator {
            public static let defaultColor = UIColor.lightGray
        }
        
        public enum SendButton {
            public static let title = "Send"
            public static let titleFont: UIFont! = UIFont.boldSystemFont(ofSize: 16.0)
            public static let enabledTitleColor = UIColor(red: 0.0, green: 117.0 / 255.0, blue: 183.0 / 255.0, alpha: 1.0)
            public static let disabledTitleColor = UIColor(white: 200.0 / 255.0, alpha: 1.0)
            public static let highlightedTitleColor = UIColor(red: 0.0, green: 117.0 / 255.0, blue: 183.0 / 255.0, alpha: 0.5)
        }
    }
    
    public struct SendButtonSizeInfo {
        
        public let topOffset: CGFloat
        
        public let bottomOffset: CGFloat
        
        public let rightOffset: CGFloat
        
        public let width: CGFloat
        
        public let height: CGFloat
    }
    
    public enum SendButtonAlighBehaviour {
        case alignTop
        case alignCenter
        case alignBottom
    }
    
    private weak var separatorView: ABSeparatorView!
    
    private weak var inputBackgroundView: ABMessageTextBorderView!
    
    public private(set) weak var inputTextView: ABTextView!
    
    public private(set) weak var sendButton: UIButton!
    
    private weak var inputViewLeftInset: NSLayoutConstraint!
    private weak var inputViewRightInset: NSLayoutConstraint!
    fileprivate weak var inputViewTopInset: NSLayoutConstraint!
    fileprivate weak var inputViewBottomInset: NSLayoutConstraint!
    private weak var constraintSendButtonWidth: NSLayoutConstraint!
    private weak var constraintSendButtonTrailing: NSLayoutConstraint!
    private var constraintSendButtonTop: NSLayoutConstraint!
    private var constraintSendButtonBottom: NSLayoutConstraint!
    private var constraintSendButtonCenterY: NSLayoutConstraint!
    private var constraintSendButtonHeight: NSLayoutConstraint!
    
    public var sendButtonSizeInfo: SendButtonSizeInfo = SendButtonSizeInfo(topOffset: 4.0, bottomOffset: 4.0, rightOffset: 16.0, width: 44.0, height: 44.0) {
        didSet {
            sendButtonSizeInfo = sendButtonSizeInfo.ab_safeInfo
            self.updateSendButtonConstraints()
        }
    }
    
    public var inputViewInsets: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0) {
        didSet {
            inputViewInsets = inputViewInsets.ab_safeInsets
        }
    }
    
    public var inputTextFieldInsets: UIEdgeInsets = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0) {
        didSet {
            inputTextFieldInsets = inputTextFieldInsets.ab_safeInsets
        }
    }
    
    public var sendButtonAlignBehaviour = SendButtonAlighBehaviour.alignCenter {
        didSet {
            self.updateSendButtonAlign()
        }
    }
    
    public var maxInputHeight: CGFloat = 88.0 {
        didSet {
            if maxInputHeight < Consts.Input.minHeight {
                maxInputHeight = Consts.Input.minHeight
            }
        }
    }
    
    public var maxInputLinesCount: Int = 1 {
        didSet {
            self.inputTextView.measureText(force: true)
        }
    }
    
    public var separatorColor: UIColor {
        get {
            return self.separatorView.lineColor
        }
        set {
            self.separatorView.lineColor = newValue
        }
    }
    
    public var inputBackgroundColor: UIColor {
        get {
            return self.inputBackgroundView.inputBackgroundColor
        }
        set {
            self.inputBackgroundView.inputBackgroundColor = newValue
        }
    }
    
    public var inputBackgroundBorderColor: UIColor {
        get {
            return self.inputBackgroundView.inputBackgroundBorderColor
        }
        set {
            self.inputBackgroundView.inputBackgroundBorderColor = newValue
        }
    }
    
    public var attributedText: NSAttributedString? {
        get {
            return self.inputTextView.attributedText
        }
        set {
            self.inputTextView.attributedText = newValue
            
            if let text = newValue {
                self.sendButton.isEnabled = text.length > 0
                
            } else {
                self.sendButton.isEnabled = false
            }
        }
    }
    
    public var placeholderText: String? {
        get {
            return self.inputTextView.placeholderText
        }
        set {
            self.inputTextView.placeholderText = newValue
        }
    }
    
    public var useLinesCountForHeight: Bool {
        get {
            return self.inputTextView.useLinesCountForHeight
        }
        set {
            self.inputTextView.useLinesCountForHeight = newValue
        }
    }
    
    public weak var delegate: ABMessageInputViewDelegate? {
        didSet {
            var newInputHeight = self.inputTextView.bounds.height + self.inputViewInsets.top + self.inputViewInsets.bottom
            if (newInputHeight < Consts.Input.minHeight) {
                newInputHeight = Consts.Input.minHeight
            }
            
            let buttonVerticalMinSpace = self.sendButtonSizeInfo.verticalSpace
            if newInputHeight < buttonVerticalMinSpace {
                newInputHeight = buttonVerticalMinSpace
            }
            
            self.delegate?.messageInputView(self, willChangeHeight: newInputHeight, animated: false)
        }
    }
    
    #if DEBUG
    public var showDebugBorders: Bool {
        get {
            return self.sendButton?.layer.borderWidth == 1.0
        }
        set {
            if newValue {
                self.sendButton?.layer.borderWidth = 1.0
                self.sendButton?.layer.borderColor = UIColor.blue.cgColor
                
                self.inputTextView?.layer.borderWidth = 1.0
                self.inputTextView?.layer.borderColor = UIColor.red.cgColor
                
                self.inputBackgroundView?.layer.borderWidth = 1.0
                self.inputBackgroundView?.layer.borderColor = UIColor.orange.cgColor
            } else {
                self.sendButton?.layer.borderWidth = 0.0
                self.sendButton?.layer.borderColor = nil
                
                self.inputTextView?.layer.borderWidth = 0.0
                self.inputTextView?.layer.borderColor = nil
                
                self.inputBackgroundView?.layer.borderWidth = 0.0
                self.inputBackgroundView?.layer.borderColor = nil
            }
        }
    }
    #endif
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initABMessageInputView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initABMessageInputView()
    }
    
    public override var isFirstResponder: Bool {
        return self.inputTextView.isFirstResponder
    }
    
    public override func becomeFirstResponder() -> Bool {
        return self.inputTextView.becomeFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        return self.inputTextView.resignFirstResponder()
    }
    
    //MARK: Private
    
    private func initABMessageInputView() {
        let separatorViewFrame = CGRect(size: CGSize(width: self.bounds.size.width, height: 1.0))
        let separatorView = ABSeparatorView(frame: separatorViewFrame)
        separatorView.lineColor = Consts.Separator.defaultColor
        self.addSubview(separatorView)
        self.separatorView = separatorView
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let inputFrame = CGRect(
            x: self.inputViewInsets.left,
            y: self.inputViewInsets.top,
            width: self.bounds.width - (self.inputViewInsets.left + self.inputViewInsets.right) - self.sendButtonSizeInfo.horizontalSpace,
            height: self.bounds.height - self.inputViewInsets.top - self.inputViewInsets.bottom
        )
        
        let inputBackgroundView = ABMessageTextBorderView(frame: inputFrame)
        self.addSubview(inputBackgroundView)
        self.inputBackgroundView = inputBackgroundView
        
        /* input view: leading inset */
        inputBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        let inputViewLeftInset = inputBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.inputViewInsets.left)
        inputViewLeftInset.isActive = true
        self.inputViewLeftInset = inputViewLeftInset
        
        /* input view: top inset */
        let inputViewTopInset = inputBackgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.inputViewInsets.top)
        inputViewTopInset.isActive = true
        self.inputViewTopInset = inputViewTopInset
        
        /* input view: bottom inset */
        let inputViewBottomInset = self.bottomAnchor.constraint(equalTo: inputBackgroundView.bottomAnchor, constant: self.inputViewInsets.bottom)
        inputViewBottomInset.isActive = true
        self.inputViewBottomInset = inputViewBottomInset
        
        let inputTextView = ABTextView(frame: UIEdgeInsetsInsetRect(inputFrame, self.inputTextFieldInsets))
        inputTextView.delegate = self
        self.addSubview(inputTextView)
        self.inputTextView = inputTextView
        inputTextView.measureText()
        
        let sendButton = UIButton(type: UIButtonType.custom)
        sendButton.setTitle(Consts.SendButton.title, for: .normal)
        sendButton.titleLabel?.font = Consts.SendButton.titleFont
        sendButton.setTitleColor(Consts.SendButton.enabledTitleColor, for: .normal)
        sendButton.setTitleColor(Consts.SendButton.disabledTitleColor, for: .disabled)
        sendButton.setTitleColor(Consts.SendButton.highlightedTitleColor, for: UIControlState.highlighted)
        sendButton.frame = CGRect(
            x: self.bounds.width - (self.inputViewInsets.left + self.inputViewInsets.right),
            y: self.sendButtonSizeInfo.topOffset,
            width: self.sendButtonSizeInfo.width,
            height: self.sendButtonSizeInfo.height
        )
        sendButton.addTarget(self, action: #selector(onEvent_sendButtonClick(_:)), for: .touchUpInside)
        self.addSubview(sendButton)
        self.sendButton = sendButton

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        /* input view: trailing inset */
        let inputViewRightInset = sendButton.leadingAnchor.constraint(equalTo: inputBackgroundView.trailingAnchor, constant: self.inputViewInsets.right)
        inputViewRightInset.isActive = true
        self.inputViewRightInset = inputViewRightInset
        
        /* send button: width */
        let constraintSendButtonWidth = sendButton.widthAnchor.constraint(equalToConstant: self.sendButtonSizeInfo.width)
        constraintSendButtonWidth.isActive = true
        self.constraintSendButtonWidth = constraintSendButtonWidth
        
        /* send button: trailing inset */
        let constraintSendButtonTrailing = self.trailingAnchor.constraint(equalTo: sendButton.trailingAnchor, constant: self.sendButtonSizeInfo.rightOffset)
        constraintSendButtonTrailing.isActive = true
        self.constraintSendButtonTrailing = constraintSendButtonTrailing
        
        /* send button: top inset */
        let constraintSendButtonTop = sendButton.topAnchor.constraint(equalTo: self.topAnchor, constant: self.sendButtonSizeInfo.topOffset)
        constraintSendButtonTop.isActive = true
        self.constraintSendButtonTop = constraintSendButtonTop
        
        /* send button: bottom inset */
        let constraintSendButtonBottom = self.bottomAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: self.sendButtonSizeInfo.bottomOffset)
        constraintSendButtonBottom.isActive = true
        self.constraintSendButtonBottom = constraintSendButtonBottom
        
        /* send button: centerY */
        let constraintSendButtonCenterY = sendButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        constraintSendButtonCenterY.isActive = true
        self.constraintSendButtonCenterY = constraintSendButtonCenterY
        
        /* send button: height */
        let constraintSendButtonHeight = sendButton.heightAnchor.constraint(equalToConstant: self.sendButtonSizeInfo.height)
        constraintSendButtonHeight.isActive = true
        self.constraintSendButtonHeight = constraintSendButtonHeight
        
        self.updateSendButtonAlign()
    }
    
    //MARK: Events
    
    func onEvent_sendButtonClick(_ sender: UIButton!) {
        self.delegate?.messageInputViewDidSendText?(self)
    }
    
    //MARK: Private
    private func updateSendButtonAlign() {
        switch self.sendButtonAlignBehaviour {
        case .alignTop:
            self.constraintSendButtonCenterY.isActive = false
            self.constraintSendButtonBottom.isActive = false
            self.constraintSendButtonTop.isActive = true
        case .alignBottom:
            self.constraintSendButtonCenterY.isActive = false
            self.constraintSendButtonTop.isActive = false
            self.constraintSendButtonBottom.isActive = true
        case .alignCenter:
            self.constraintSendButtonTop.isActive = false
            self.constraintSendButtonBottom.isActive = false
            self.constraintSendButtonCenterY.isActive = true
        }
    }
    
    private func updateSendButtonConstraints() {
        self.constraintSendButtonWidth?.constant = self.sendButtonSizeInfo.width
    }
}

//MARK: - ABMessageInputView (ABTextViewDelegate)
extension ABMessageInputView: ABTextViewDelegate {
    
    public func textView(_ textView: ABTextView, beginSetNewHeight height: CGFloat) {
        let inputViewInsets = self.inputViewInsets
        let inputFieldInsets = self.inputTextFieldInsets
        
        var newInputHeight = height + inputViewInsets.top + inputViewInsets.bottom + inputFieldInsets.top + inputFieldInsets.bottom
        if (newInputHeight < Consts.Input.minHeight) {
            newInputHeight = Consts.Input.minHeight
        }
        
        let buttonVerticalMinSpace = self.sendButtonSizeInfo.verticalSpace
        if newInputHeight < buttonVerticalMinSpace {
            newInputHeight = buttonVerticalMinSpace
        }
        
        if self.bounds.height != newInputHeight {
            self.delegate?.messageInputView(self, willChangeHeight: newInputHeight, animated: self.window != nil)
        }
        
        var newInputFrame = self.inputTextView.frame
        newInputFrame.size.height = height
        newInputFrame.origin.y = newInputHeight * 0.5 - height * 0.5
        self.inputTextView.frame = newInputFrame
    }
    
    public func textView(_ growingTextView: ABTextView, endSetNewHeight height: CGFloat) {
        
    }
    
    public func textView(_ textView: ABTextView, allowNewHeight height: CGFloat, butMaxAllowedHeight allowedHeight: inout CGFloat) -> Bool {
        allowedHeight = self.maxInputHeight
        return (height <= self.maxInputHeight)
    }
    
    public func textViewMaxNumberOfLinesAllowed(_ textView: ABTextView) -> Int {
        return self.maxInputLinesCount
    }
    
    public func textView(_ textView: ABTextView, didChangedAttributedText text: NSAttributedString?) {
        self.delegate?.messageInputView(self, didChangeAttributedText: text)
        
        if let unwrappedText = text {
            self.sendButton.isEnabled = unwrappedText.length > 0
        } else {
            self.sendButton.isEnabled = false
        }
    }
    
    public func textViewDidBeginEditing(_ textView: ABTextView) {
        self.delegate?.messageInputViewDidBeginEditing?(self)
    }
    
    public func textViewDidEndEditing(_ textView: ABTextView) {
        self.delegate?.messageInputViewDidEndEditing?(self)
    }
}

//MARK: - ABMessageTextBorderView
private class ABMessageTextBorderView: UIView {
    
    private weak var backgroundLayer: CAShapeLayer!
    
    var inputBackgroundColor: UIColor = UIColor(white: 242.0 / 255.0, alpha: 1.0) {
        didSet {
            self.backgroundLayer?.fillColor = inputBackgroundColor.cgColor
        }
    }
    
    var inputBackgroundBorderColor: UIColor = UIColor(white: 232.0 / 255.0, alpha: 1.0) {
        didSet {
            self.backgroundLayer?.strokeColor = inputBackgroundBorderColor.cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.backgroundLayer == nil) {
            let backgroundLayerValue = CAShapeLayer()
            backgroundLayerValue.contentsScale = self.layer.contentsScale
            self.layer.addSublayer(backgroundLayerValue)
            self.backgroundLayer = backgroundLayerValue
            
            backgroundLayerValue.fillColor = self.inputBackgroundColor.cgColor
            backgroundLayerValue.strokeColor = self.inputBackgroundBorderColor.cgColor
            backgroundLayerValue.lineWidth = 0.5
        }
        
        self.backgroundLayer.frame = self.layer.bounds
        let roundPath = UIBezierPath(roundedRect: self.layer.bounds, cornerRadius: 4.0)
        self.backgroundLayer.path = roundPath.cgPath
    }
}
