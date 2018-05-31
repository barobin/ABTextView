//
//  TableViewData.swift
//  ABTextViewExample
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import UIKit
import ABTextView

//MARK: TableViewDataDelegate
protocol TableViewDataDelegate: UIViewControllerDataSource {
    
    var t_inputMessageView: ABMessageInputView? { get }
    
    var t_tableView: UITableView! { get }
    
    var t_bottomInputOffset: CGFloat { get set }
    
    var t_inputHeight: CGFloat { get set }
}

//MARK: - TableViewData
class TableViewData: NSObject {

    weak var delegate: TableViewDataDelegate?
    
    fileprivate var sections = [TableViewSection]()
    
    @objc private(set) var subscribedForContentSizeChanges: Bool = false
    
    deinit {
        self.unsubscibeForContentSizeChanges()
    }
    
    @objc func subscribeForContentSizeChanges() {
        if self.subscribedForContentSizeChanges {
            return
        }
        
        self.delegate?.t_tableView.addObserver(self, forKeyPath: "contentSize", options: [.initial, .new], context: nil)
        
        self.subscribedForContentSizeChanges = true
    }
    
    func unsubscibeForContentSizeChanges(delegate: TableViewDataDelegate? = nil) {
        if !self.subscribedForContentSizeChanges {
            return
        }
        
        let tableView = self.delegate?.t_tableView ?? delegate?.t_tableView
        tableView?.removeObserver(self, forKeyPath: "contentSize", context: nil)
        
        self.subscribedForContentSizeChanges = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let kp = keyPath, kp == "contentSize" {
            guard let d = self.delegate else { return }
            guard let nsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue else { return }
            
            var contentInsets = d.t_tableView.contentInset
            contentInsets.top = d.u_topLayoutGuide.length
            contentInsets.bottom = d.t_bottomInputOffset + d.t_inputHeight
            
            var tableViewSize = d.t_tableView.bounds.size
            tableViewSize.height -= (contentInsets.top + contentInsets.bottom)
            let contentSize = nsValue.cgSizeValue
            if contentSize.height < tableViewSize.height {
                contentInsets.top += (tableViewSize.height - contentSize.height)
            }
            
            if !UIEdgeInsetsEqualToEdgeInsets(d.t_tableView.contentInset, contentInsets) {
                d.t_tableView.contentInset = contentInsets
                d.t_tableView.scrollIndicatorInsets = contentInsets
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

//MARK: - TableViewData ()
extension TableViewData {
    
    @objc func initializeSections() {
        self.sections.removeAll()
        
        let alignTopItem = TableViewItem(displayName: "align to top", identifier: "align_to_top")
        let alignCenterItem = TableViewItem(displayName: "align to center", identifier: "align_to_center")
        let alignBottomItem = TableViewItem(displayName: "align to bottom", identifier: "align_to_bottom")
        let sendButtonSection = TableViewSection(identifier: "align", displayName: "Send button", items: [alignTopItem, alignCenterItem, alignBottomItem])
        self.sections.append(sendButtonSection)
        
        let oneLineMaxItem = TableViewItem(displayName: "1 line", identifier: "one_line")
        let twoLineMaxItem = TableViewItem(displayName: "2 lines", identifier: "two_lines")
        let threeLineMaxItem = TableViewItem(displayName: "3 lines", identifier: "three_lines")
        let fourLineMaxItem = TableViewItem(displayName: "4 lines", identifier: "four_lines")
        let lineSection = TableViewSection(identifier: "number_of_lines", displayName: "Number of lines", items: [oneLineMaxItem, twoLineMaxItem, threeLineMaxItem, fourLineMaxItem])
        self.sections.append(lineSection)
        
        let inputActivateItem = TableViewItem(displayName: "activated", identifier: "input_activate")
        let inputDeactivateItem = TableViewItem(displayName: "deactivated", identifier: "input_deactivate")
        let inputSection = TableViewSection(identifier: "input", displayName: "Input", items: [inputActivateItem, inputDeactivateItem])
        self.sections.append(inputSection)
    }
    
    fileprivate func setup(cell: UITableViewCell, for indexPath: IndexPath) {
        let item = self.sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.displayName
        
        switch item.identifier {
        case "align_to_top":
            cell.accessoryType = self.delegate?.t_inputMessageView?.sendButtonAlignBehaviour == .alignTop ? .checkmark : .none
        case "align_to_center":
            cell.accessoryType = self.delegate?.t_inputMessageView?.sendButtonAlignBehaviour == .alignCenter ? .checkmark : .none
        case "align_to_bottom":
            cell.accessoryType = self.delegate?.t_inputMessageView?.sendButtonAlignBehaviour == .alignBottom ? .checkmark : .none
        case "input_activate":
            cell.accessoryType = self.delegate?.t_inputMessageView?.isFirstResponder == true ? .checkmark : .none
        case "input_deactivate":
            cell.accessoryType = self.delegate?.t_inputMessageView?.isFirstResponder == false ? .checkmark : .none
        case "one_line":
            cell.accessoryType = self.delegate?.t_inputMessageView?.maxInputLinesCount == 1 ? .checkmark : .none
        case "two_lines":
            cell.accessoryType = self.delegate?.t_inputMessageView?.maxInputLinesCount == 2 ? .checkmark : .none
        case "three_lines":
            cell.accessoryType = self.delegate?.t_inputMessageView?.maxInputLinesCount == 3 ? .checkmark : .none
        case "four_lines":
            cell.accessoryType = self.delegate?.t_inputMessageView?.maxInputLinesCount == 4 ? .checkmark : .none
        default:
            fatalError("unknown item.identifier: \(item.identifier)")
        }
    }
}

//MARK: - TableViewData (UITableViewDataSource)
extension TableViewData: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
        self.setup(cell: cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].displayName
    }
}

//MARK: - TableViewData (UITableViewDelegate)
extension TableViewData: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let item = self.sections[indexPath.section].items[indexPath.row]
        switch item.identifier {
        case "align_to_top":
            self.delegate?.t_inputMessageView?.sendButtonAlignBehaviour = .alignTop
        case "align_to_center":
            self.delegate?.t_inputMessageView?.sendButtonAlignBehaviour = .alignCenter
        case "align_to_bottom":
            self.delegate?.t_inputMessageView?.sendButtonAlignBehaviour = .alignBottom
        case "input_activate":
            if self.delegate?.t_inputMessageView?.isFirstResponder == false {
                let _ = self.delegate?.t_inputMessageView?.becomeFirstResponder()
            }
        case "input_deactivate":
            if self.delegate?.t_inputMessageView?.isFirstResponder == true {
                let _ = self.delegate?.t_inputMessageView?.resignFirstResponder()
            }
        case "one_line":
            self.delegate?.t_inputMessageView?.maxInputLinesCount = 1
        case "two_lines":
            self.delegate?.t_inputMessageView?.maxInputLinesCount = 2
        case "three_lines":
            self.delegate?.t_inputMessageView?.maxInputLinesCount = 3
        case "four_lines":
            self.delegate?.t_inputMessageView?.maxInputLinesCount = 4
        default:
            fatalError("unknown item.identifier: \(item.identifier)")
        }
        
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }
}

//MARK: - TableViewData (ABMessageInputViewDelegate)
extension TableViewData: ABMessageInputViewDelegate {
    
    func messageInputView(_ inputView: ABMessageInputView, willChangeHeight height: CGFloat, animated: Bool) {
        guard let d = self.delegate else { return }
        
        var contentInset = d.t_tableView.contentInset
        contentInset.bottom = d.t_bottomInputOffset + height
        let tableOnBottom = d.t_tableView.ext_isScrollPositionOnBottom || !d.t_tableView.ext_isContentSizeGreaterThanHeight
        
        self.delegate?.t_inputHeight = height
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.delegate?.u_rootView.layoutIfNeeded()
                
                self.delegate?.t_tableView.contentInset = contentInset
                self.delegate?.t_tableView.scrollIndicatorInsets = contentInset
            })
        } else {
            self.delegate?.t_tableView.contentInset = contentInset
            self.delegate?.t_tableView.scrollIndicatorInsets = contentInset
        }
        
        if tableOnBottom {
            self.delegate?.t_tableView.ext_scrollToBottom(animated: animated)
        }
    }
    
    func messageInputView(_ inputView: ABMessageInputView, didChangeAttributedText text: NSAttributedString?) { }
    
    func messageInputViewDidBeginEditing(_ inputView: ABMessageInputView) {
        if let sectionIndex = self.sections.index(where: { $0.identifier == "input" }) {
            self.delegate?.t_tableView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
        }
    }
    
    func messageInputViewDidEndEditing(_ inputView: ABMessageInputView) {
        if let sectionIndex = self.sections.index(where: { $0.identifier == "input" }) {
            self.delegate?.t_tableView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
        }
    }
}
