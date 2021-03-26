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
        dataSource?.emptyDataSource = SingleItemTableViewDataSource<EmptyTableViewCell>(cellIdentifier: "emptyCell", styleFunction: EmptyTableViewCell.todoStyle)
        
        self.tutorialIdentifier = "todos"
        configureTitle(L10n.Tasks.todos)
    }
    
    override func createDataSource() {
        dataSource = HabitTableViewDataSource(predicate: self.getPredicate())
    }
    
    override func getDefinitonForTutorial(_ tutorialIdentifier: String) -> [AnyHashable: Any]? {
        if tutorialIdentifier == "todos" {
            let localizedStringArray = [L10n.Tutorials.todos1, L10n.Tutorials.todos2]
            return ["textList": localizedStringArray]
        }
        return super.getDefinitonForTutorial(tutorialIdentifier)
    }
    
    override func getCellNibName() -> String {
        return "ToDoTableViewCell"
    }
    
    func clearCompletedTasks(tapRecognizer: UITapGestureRecognizer) {
        dataSource?.clearCompletedTodos()
    }
    
    override func refresh() {
        dataSource?.retrieveData(completed: { [weak self] in
            self?.refreshControl?.endRefreshing()
            if self?.filterType == 2 {
                self?.dataSource?.fetchCompletedTodos()
            }
        })
    }
    
    override func didChangeFilter() {
        super.didChangeFilter()
        if filterType == 2 {
            dataSource?.fetchCompletedTodos()
        }
    }
}
