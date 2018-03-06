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
    
    @objc weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.reloadData()
        }
    }
    
    @objc var predicate: NSPredicate
    
    internal let repository = TaskRepository()
    
    @objc var tasks = [TaskProtocol]()
    private var expandedIndexPath: IndexPath?
    
    @objc
    init(predicate: NSPredicate) {
        self.predicate = predicate
        super.init()
        disposable.inner.add(repository.getTasks(predicate: predicate).on(value: { (tasks, changes) in
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
            }
            
        }).start())
    }
    
    @objc
    func retrieveTasks(completed: (() -> Void)?) {
        disposable.inner.add(repository.retrieveTasks().observeCompleted {
            if let action = completed {
                action()
            }
        })
    }
    
    @objc
    func object(at indexPath: IndexPath) -> TaskProtocol? {
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
        if let taskCell = cell as? TaskTableViewCell, let task = object(at: indexPath) {
            configure(cell: taskCell, indexPath: indexPath, task: task)
        }
        return cell
    }
    
    func configure(cell: TaskTableViewCell, indexPath: IndexPath, task: TaskProtocol) {
        if let checkedCell = cell as? CheckedTableViewCell {
            checkedCell.isExpanded = self.expandedIndexPath?.item == indexPath.item
        }
        cell.configure(task: task)
    }
    
    internal func expandSelectedCell(indexPath: IndexPath) {
        var expandedPath = self.expandedIndexPath
        if tableView?.numberOfRows(inSection: 0) ?? 0 < (expandedPath?.item ?? 0) {
            expandedPath = nil
        }
        self.expandedIndexPath = indexPath
        if expandedPath == nil || indexPath.item == expandedPath?.item {
            if expandedPath?.item == self.expandedIndexPath?.item {
                self.expandedIndexPath = nil
            }
            tableView?.beginUpdates()
            tableView?.reloadRows(at: [indexPath], with: .none)
            tableView?.endUpdates()
        } else {
            if let path = expandedPath {
                tableView?.beginUpdates()
                tableView?.reloadRows(at: [indexPath, path], with: .none)
                tableView?.endUpdates()
            }
        }
    }
}
