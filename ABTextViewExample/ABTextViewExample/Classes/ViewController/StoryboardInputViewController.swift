//
//  StoryboardInputViewController.swift
//  ABTextViewExample
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import UIKit
import ABTextView

//MARK: StoryboardInputViewController
class StoryboardInputViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var inputMessageView: ABMessageInputView!
    
    @IBOutlet weak var constraintInputMessageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constraintInputMessageViewBottom: NSLayoutConstraint!
    
    @objc let tableViewData: TableViewData = TableViewData()
    
    @objc let keyboardObserver: KeyboardEventsObserver = KeyboardEventsObserver()
    
    deinit {
        self.tableViewData.unsubscibeForContentSizeChanges(delegate: self)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.initStoryboardInputViewController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initStoryboardInputViewController()
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
        self.inputMessageView.maxInputLinesCount = 2
        self.inputMessageView.useLinesCountForHeight = true
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
    private func initStoryboardInputViewController() {
        self.tableViewData.initializeSections()
        self.tableViewData.delegate = self
        
        self.keyboardObserver.delegate = self
    }
}

//MARK: - StoryboardInputViewController (TableViewDataDelegate)
extension StoryboardInputViewController: TableViewDataDelegate {
    
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

//MARK: - StoryboardInputViewController (KeyboardEventsObserverDelegate)
extension StoryboardInputViewController: KeyboardEventsObserverDelegate {
    
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
