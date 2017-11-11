//
//  MainViewController.swift
//  ABTextViewExample
//
//  Created by Alexander Barobin
//  Copyright © 2017 Alexander Barobin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var items: [TableViewItem] = {
        return [
            TableViewItem(displayName: "Input view from storyboard", identifier: "from_storyboard"),
            TableViewItem(displayName: "Input view from code", identifier: "from_code")
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Main menu"
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

}

//MARK: - MainViewController (UITableViewDataSource)
extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
        cell.textLabel?.text = self.items[indexPath.row].displayName
        return cell
    }
}

//MARK: - MainViewController (UITableViewDelegate)
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row];
        
        switch item.identifier {
        case "from_storyboard":
            let storyboardInputVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoryboardInputViewController")
            storyboardInputVC.navigationItem.title = item.displayName
            self.navigationController?.pushViewController(storyboardInputVC, animated: true)
        case "from_code":
            let codeInputVC = CodeInputViewController()
            codeInputVC.navigationItem.title = item.displayName
            self.navigationController?.pushViewController(codeInputVC, animated: true)
        default:
            fatalError("unknown item.identifier: \(item.identifier)")
        }
    }
}
