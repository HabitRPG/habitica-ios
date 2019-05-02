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
public protocol TaskTableViewDataSourceProtocol {
    @objc var userDrivenDataUpdate: Bool { get set }
    @objc weak var tableView: UITableView? { get set }
    @objc var predicate: NSPredicate { get set }
    @objc var sortKey: String { get set }
    @objc var emptyDelegate: DataSourceEmptyDelegate? { get set }
    @objc var isEmpty: Bool { get set }
    
    @objc var tasks: [TaskProtocol] { get set }
    @objc var taskToEdit: TaskProtocol? { get set }
    
    @objc
    func task(at indexPath: IndexPath) -> TaskProtocol?
    @objc
    func idForObject(at indexPath: IndexPath) -> String?
    @objc
    func retrieveData(completed: (() -> Void)?)
    @objc
    func selectRowAt(indexPath: IndexPath)
    @objc
    func fixTaskOrder(movedTask: TaskProtocol, toPosition: Int)
    @objc
    func moveTask(task: TaskProtocol, toPosition: Int, completion: @escaping () -> Void)
    @objc
    func clearCompletedTodos()
    @objc
    func fetchCompletedTodos()
    
    @objc
    func predicates(filterType: Int) -> [NSPredicate]
}

class TaskTableViewDataSource: BaseReactiveTableViewDataSource<TaskProtocol>, TaskTableViewDataSourceProtocol {
    
    var taskType: TaskType
    var tasks: [TaskProtocol] {
        get {
            return sections[0].items
        }
        set {
            sections[0].items = newValue
        }
    }
    
    func task(at indexPath: IndexPath) -> TaskProtocol? {
        return item(at: indexPath)
    }
    
    var predicate: NSPredicate {
        didSet {
            fetchTasks()
        }
    }
    var sortKey: String = "order" {
        didSet {
            fetchTasks()
        }
    }
    
    override func didSetTableView() {
        tableView?.reloadData()
    }
    
    internal let userRepository = UserRepository()
    internal let repository = TaskRepository()
    
    @objc var taskToEdit: TaskProtocol?
    private var expandedIndexPath: IndexPath?
    private var fetchTasksDisposable: Disposable?
    
    init(predicate: NSPredicate, taskType: TaskType) {
        self.predicate = predicate
        self.taskType = taskType
        super.init()
        sections.append(ItemSection<TaskProtocol>())
    }
    
    override func retrieveData(completed: (() -> Void)?) {
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
        fetchTasksDisposable = repository.getTasks(predicate: predicate, sortKey: sortKey).on(value: {[weak self] (tasks, changes) in
            self?.sections[0].items = tasks
            self?.notify(changes: changes)
        }).start()
    }

    @objc
    func idForObject(at indexPath: IndexPath) -> String? {
        return item(at: indexPath)?.id
    }
    
    @objc
    func clearCompletedTodos() {
        repository.clearCompletedTodos().observeCompleted {}
    }
    
    @objc
    func fetchCompletedTodos() {
        repository.retrieveCompletedTodos().observeCompleted {}
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let task = self.item(at: indexPath) {
                repository.deleteTask(task).observeCompleted {}
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let taskCell = cell as? TaskTableViewCell, let task = item(at: indexPath) {
            configure(cell: taskCell, indexPath: indexPath, task: task)
        }
        return cell
    }
    
    func configure(cell: TaskTableViewCell, indexPath: IndexPath, task: TaskProtocol) {
        if !task.isValid {
            return
        }
        if let checkedCell = cell as? CheckedTableViewCell {
            checkedCell.isExpanded = self.expandedIndexPath?.item == indexPath.item
        }
        cell.configure(task: task)
        cell.syncErrorTouched = {[weak self] in
            let alertController = HabiticaAlertController(title: L10n.Errors.sync, message: L10n.Errors.syncMessage)
            alertController.addAction(title: L10n.resyncTask, style: .default, isMainAction: false, handler: {[weak self] (_) in
                self?.repository.syncTask(task).observeCompleted {}
            })
            alertController.addCancelAction()
            alertController.show()
        }
    }
    
    internal func expandSelectedCell(indexPath: IndexPath) {
        var expandedPath = self.expandedIndexPath
        if tableView?.numberOfRows(inSection: 0) ?? 0 < (expandedPath?.item ?? 0) {
            expandedPath = nil
        }
        if item(at: indexPath) == nil || (expandedPath != nil && item(at: expandedPath) == nil) {
            return
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
    
    @objc
    func selectRowAt(indexPath: IndexPath) {
        taskToEdit = item(at: indexPath)
    }
    
    @objc
    func fixTaskOrder(movedTask: TaskProtocol, toPosition: Int) {
        repository.fixTaskOrder(movedTask: movedTask, toPosition: toPosition)
    }
    
    @objc
    func moveTask(task: TaskProtocol, toPosition: Int, completion: @escaping () -> Void) {
        repository.moveTask(task, toPosition: toPosition).observeCompleted {
            completion()
        }
    }
    
    func predicates(filterType: Int) -> [NSPredicate] {
        var predicates = [NSPredicate]()
        predicates.append(NSPredicate(format: "type == %@", taskType.rawValue))
        return predicates
    }
}
