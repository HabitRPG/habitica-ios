//
//  TodosTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/30/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class TodosTableViewController: HRPGTableViewController, TasksDataSourceDelegate {
    var viewModel = TasksViewModel(tasksCall: GetTasksCall(configuration: HRPGServerConfig.stub))
    let dataSource = TasksDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.delegate = dataSource

        self.tutorialIdentifier = "todos"

        viewModel.tasksUpdatedSignal.observeValues { (tasks) in
            self.dataSource.tasks = tasks?.filter { $0.type == "todo" }
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    override func refresh() {
        super.refresh()
        viewModel.refresh()
    }
    
    // swiftlint:disable force_unwrapping
    override func getDefinitonForTutorial(_ tutorialIdentifier: String!) -> [AnyHashable : Any]! {
        if tutorialIdentifier == "todos" {
            let defs = [NSLocalizedString("Use To-Dos to keep track of tasks you need to do just once.", tableName: nil, comment: ""),
                        NSLocalizedString("If your To-Do has to be done by a certain time, set a due date. Looks like you can check one off — go ahead!", tableName: nil, comment: "")]
            return ["textList": defs]
        }
        return super.getDefinitonForTutorial(tutorialIdentifier)
    }
    // swiftlint:enable force_unwrapping
    
    override func getCellNibName() -> String {
        return "ToDoTableViewCell"
    }
    
    override func didChangeFilter(_ notification: Notification!) {
        super.didChangeFilter(notification)
        if self.filterType == TaskToDoFilterType.done.rawValue {
            self.refresh()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
    }

}
