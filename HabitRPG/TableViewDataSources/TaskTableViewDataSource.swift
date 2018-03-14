//
//  ReactiveTableViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

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
    
    @objc var predicate: NSPredicate {
        didSet {
            fetchTasks()
        }
    }
    
    internal let userRepository = UserRepository()
    internal let repository = TaskRepository()
    
    @objc var tasks = [TaskProtocol]()
    private var expandedIndexPath: IndexPath?
    private var fetchTasksDisposable: Disposable?
    
    @objc
    init(predicate: NSPredicate) {
        self.predicate = predicate
        super.init()
    }
    
    @objc
    func retrieveTasks(completed: (() -> Void)?) {
        disposable.inner.add(userRepository.retrieveUser().observeCompleted {
            if let action = completed {
                action()
            }
        })
    }
    
    private func fetchTasks() {
        if let disposable = fetchTasksDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
        fetchTasksDisposable = repository.getTasks(predicate: predicate).on(value: { (tasks, changes) in
            self.tasks = tasks
            self.notifyDataUpdate(tableView: self.tableView, changes: changes)
        }).start()
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
