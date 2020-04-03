//
//  TableViewController.swift
//  ZeroUtil
//
//  Created by lyp on 2020/3/19.
//  Copyright © 2020 lyp@zurp.date. All rights reserved.
//

import UIKit
import ZeroUtil

class TableViewController: UITableViewController {
    private let viewControllers: [(type: BaseViewController.Type, title: String)] = [
        (LogViewController.self, "Test Log Feature")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.separatorInset = .zero
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        if let turple = viewControllers.z[safe: indexPath.row] {
            cell.textLabel?.text = turple.title
        } else {
            cell.textLabel?.text = "error cell!!!"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let turple = viewControllers.z[safe: indexPath.row] {
            let viewController = turple.type.init()
            viewController.title = turple.title
            navigationController?.pushViewController(viewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
