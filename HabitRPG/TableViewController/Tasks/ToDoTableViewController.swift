//
//  ToDoTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 6/7/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class ToDoTableViewController: TaskTableViewController {
    
    override func viewDidLoad() {
        readableName = L10n.Tasks.todo
        typeName = "todo"
        super.viewDidLoad()
        dataSource?.emptyDataSource = TaskEmptyTableViewDataSource<EmptyTableViewCell>(tableView: tableView, cellIdentifier: "emptyCell", styleFunction: EmptyTableViewCell.todoStyle)
        
        self.tutorialIdentifier = "todos"
        configureTitle(L10n.Tasks.todos)
    }
    
    override func createDataSource() {
        dataSource = TodoTableViewDataSource(predicate: self.getPredicate())
    }
    
    override func getDefinitionFor(tutorial: String) -> [String] {
        if tutorial == tutorialIdentifier {
            return [L10n.Tutorials.todos1, L10n.Tutorials.todos2]
        }
        return super.getDefinitionFor(tutorial: tutorial)
    }
    
    override func getCellNibName() -> String {
        return "ToDoTableViewCell"
    }
    
    func clearCompletedTasks(tapRecognizer: UITapGestureRecognizer) {
        dataSource?.clearCompletedTodos()
    }
    
    override func refresh() {
        if let dataSource = dataSource {
            let taskRepository = TaskRepository()
            let tasks = dataSource.tasks
            for task in tasks {
                 taskRepository.syncTask(task).observeCompleted {}
            }
            
            dataSource.retrieveData(completed: { [weak self] in
                self?.refreshControl?.endRefreshing()
                if self?.filterType == 2 {
                    self?.dataSource?.fetchCompletedTodos()
                }
            })
        }
        
    }
    
    override func didChangeFilter() {
        super.didChangeFilter()
        if filterType == 2 {
            dataSource?.fetchCompletedTodos()
        }
    }
}
