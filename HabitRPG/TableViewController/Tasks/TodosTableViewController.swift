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
    let dateFormatter = DateFormatter()
    var expandedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.delegate = dataSource

        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .none

        self.tutorialIdentifier = "todos"

        viewModel.tasksUpdatedSignal.observeValues { (tasks) in
            self.dataSource.tasks = tasks?.filter { $0.type == "todo" }
            self.tableView.reloadData()
        }
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
    
    override func configureCell(_ tableCell: UITableViewCell!, at indexPath: IndexPath!, withAnimation animate: Bool) {
        let task = dataSource.tasks[indexPath.row]
        if let cell = tableCell as? ToDoTableViewCell {
            if let expandedPath = expandedIndexPath {
                cell.isExpanded = indexPath.item == expandedPath.item
            }
            
            cell.configureNew(task: task)
            cell.taskDetailLine.dateFormatter = dateFormatter
            
            let btnTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandSelectedCell(gesture:)))
            btnTapRecognizer.numberOfTapsRequired = 1
            cell.checklistIndicator.addGestureRecognizer(btnTapRecognizer)
            
            cell.checklistItemTouched = { item in
                
            }
            
            cell.checkBox.wasTouched = {
                if !task.currentlyChecking {
                    
                }
            }
        }
    }
    
    func expandSelectedCell(gesture: UITapGestureRecognizer) {
        let p = gesture.location(in: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: p) {
            if let cell: CheckedTableViewCell = self.tableView.cellForRow(at: indexPath) as? CheckedTableViewCell {
                if let expandedPath = self.expandedIndexPath {
                    self.expandedIndexPath = indexPath
                    if indexPath.item == expandedPath.item {
                        toggleCellExpansion(cell, indexPath)
                    } else {
                        let oldCell: CheckedTableViewCell? = self.tableView.cellForRow(at: expandedPath) as? CheckedTableViewCell
                        cell.isExpanded = true
                        oldCell?.isExpanded = false
                        self.tableView.beginUpdates()
                        self.tableView.reloadRows(at: [indexPath, expandedPath], with: .none)
                        self.tableView.endUpdates()
                    }
                } else {
                    toggleCellExpansion(cell, indexPath)
                }
            }
        }
    }
    
    func toggleCellExpansion(_ cell: CheckedTableViewCell, _ indexPath: IndexPath!) {
        cell.isExpanded = !cell.isExpanded
        if !cell.isExpanded {
            self.expandedIndexPath = nil;
        }
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [indexPath], with: .none)
        self.tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
    }

}
