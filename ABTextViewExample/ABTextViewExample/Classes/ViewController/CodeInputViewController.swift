//
//  CodeInputViewController.swift
//  ABTextViewExample
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import UIKit
import ABTextView

//MARK: CodeInputViewController
class CodeInputViewController: UIViewController {

    fileprivate weak var tableView: UITableView!
    
    fileprivate weak var inputMessageView: ABMessageInputView!
    
    fileprivate weak var constraintInputMessageViewBottom: NSLayoutConstraint!
    
    fileprivate weak var constraintInputMessageViewHeight: NSLayoutConstraint!
    
    private let tableViewData: TableViewData = TableViewData()
    
    private let keyboardObserver: KeyboardEventsObserver = KeyboardEventsObserver()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.initCodeInputViewController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initCodeInputViewController()
    }
    
    deinit {
        self.tableViewData.unsubscibeForContentSizeChanges(delegate: self)
    }
    
    override func loadView() {
        super.loadView()
        
        let tableView = UITableView(frame: self.view.bounds, style: .grouped)
        self.view.addSubview(tableView)
        self.tableView = tableView
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        let inputMessageViewFrame = CGRect(x: 0.0, y: self.view.bounds.height - 44.0, width: self.view.bounds.width, height: 44.0)
        let inputMessageView = ABMessageInputView(frame: inputMessageViewFrame)
        inputMessageView.backgroundColor = UIColor.white
        self.view.addSubview(inputMessageView)
        self.inputMessageView = inputMessageView
        
        inputMessageView.translatesAutoresizingMaskIntoConstraints = false
        inputMessageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        inputMessageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.constraintInputMessageViewBottom = self.view.bottomAnchor.constraint(equalTo: inputMessageView.bottomAnchor)
        self.constraintInputMessageViewBottom.isActive = true
        self.constraintInputMessageViewHeight = inputMessageView.heightAnchor.constraint(equalToConstant: 44.0)
        self.constraintInputMessageViewHeight.isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
        self.tableView.tableFooterView = UIView()
        self.tableView.tableHeaderView = UIView()
        self.tableView.dataSource = self.tableViewData
        self.tableView.delegate = self.tableViewData

        self.inputMessageView.delegate = self.tableViewData
        self.inputMessageView.placeholderText = "Enter text here..."
        self.inputMessageView.useLinesCountForHeight = true
        self.inputMessageView.maxInputLinesCount = 2
        self.inputMessageView.inputTextView.returnKeyType = UIReturnKeyType.done
        
        self.tableViewData.subscribeForContentSizeChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.keyboardObserver.subscribe()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.keyboardObserver.unsubscribe()
    }

    //MARK: Private
    
    private func initCodeInputViewController() {
        self.tableViewData.initializeSections()
        self.tableViewData.delegate = self
        
        self.keyboardObserver.delegate = self
    }
}

//MARK: - CodeInputViewController (TableViewDataDelegate)
extension CodeInputViewController: TableViewDataDelegate {
    
    @objc var t_inputMessageView: ABMessageInputView? {
        return self.inputMessageView
    }
    
    @objc var t_tableView: UITableView! {
        return self.tableView
    }
    
    @objc var t_bottomInputOffset: CGFloat {
        get {
            return self.constraintInputMessageViewBottom.constant
        }
        set {
            self.constraintInputMessageViewBottom.constant = newValue
        }
    }
    
    @objc var t_inputHeight: CGFloat {
        get {
            return self.constraintInputMessageViewHeight.constant
        }
        set {
            self.constraintInputMessageViewHeight.constant = newValue
        }
    }
}

//MARK: - CodeInputViewController (TableViewDataDelegate)
extension CodeInputViewController: KeyboardEventsObserverDelegate {
    
    @objc var k_tableView: UITableView! {
        return self.tableView
    }
    
    @objc var k_bottomInputOffset: CGFloat {
        get {
            return self.constraintInputMessageViewBottom.constant
        }
        set {
            self.constraintInputMessageViewBottom.constant = newValue
        }
    }
    
    @objc var k_inputHeight: CGFloat {
        get {
            return self.constraintInputMessageViewHeight.constant
        }
        set {
            self.constraintInputMessageViewHeight.constant = newValue
        }
    }
}
