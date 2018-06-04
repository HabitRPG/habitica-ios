//
//  ToDoTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 6/7/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class ToDoTableViewController: TaskTableViewController {
    var emptyDataSource = SingleItemTableViewDataSource<EmptyTableViewCell>(cellIdentifier: "emptyCell", styleFunction: EmptyTableViewCell.todoStyle)
    
    override func viewDidLoad() {
        readableName = NSLocalizedString("To-Do", comment: "")
        typeName = "todo"
        dataSource = TodoTableViewDataSourceInstantiator.instantiate(predicate: self.getPredicate())
        
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "emptyCell")
        
        self.tutorialIdentifier = "todos";
    }
    
    override func getDefinitonForTutorial(_ tutorialIdentifier: String) -> [AnyHashable: Any]? {
        if tutorialIdentifier == "todos" {
            let localizedStringArray = [NSLocalizedString("Use To-Dos to keep track of tasks you need to do just once.", comment: ""),
                                        NSLocalizedString("If your To-Do has to be done by a certain time, set a due date. Looks like you can check one off — go ahead!", comment: "")]
            return ["textList" : localizedStringArray]
        }
        return super.getDefinitonForTutorial(tutorialIdentifier)
    }
    
    override func getCellNibName() -> String {
        return "ToDoTableViewCell"
    }
    
    func clearCompletedTasks(tapRecognizer: UITapGestureRecognizer) {
        dataSource?.clearCompletedTodos()
    }
    
    override func dataSourceIsEmpty() {
        tableView.dataSource = emptyDataSource
        tableView.reloadData()
    }

}
