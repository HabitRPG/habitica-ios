//
//  ReactiveTableViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

@objc
class TaskTableViewDataSource: BaseReactiveDataSource, UITableViewDataSource {

    @objc weak var viewController: HRPGTableViewController? {
        didSet {
            tableView = viewController?.tableView
        }
    }
    
    weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.reloadData()
        }
    }
    
    @objc var predicate: NSPredicate
    
    private let repository = TaskRepository()
    
    private var tasks = [TaskProtocol]()
    
    @objc
    init(predicate: NSPredicate) {
        self.predicate = predicate
        super.init()
        repository.getTasks(predicate: predicate).on(value: { (tasks, changes) in
            self.tasks = tasks
            if changes?.initial == true {
                self.tableView?.reloadData()
            } else {
                guard let changes = changes else {
                    return
                }
                self.tableView?.beginUpdates()
                self.tableView?.insertRows(at: changes.inserted.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.tableView?.deleteRows(at: changes.deleted.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.tableView?.reloadRows(at: changes.updated.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.tableView?.endUpdates()
            }        }).start()
    }
    
    @objc
    func object(at indexPath: IndexPath) -> TaskProtocol {
        return tasks[indexPath.item]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let taskCell = cell as? TaskTableViewCell {
            taskCell.configure(task: object(at: indexPath))
        }
        return cell
    }
}
