//
//  TaskFormViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 14.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import Habitica_Database

struct TaskFormRow {
    let cellIdentifier: String
    
    init(cellIdentifier: String) {
        self.cellIdentifier = cellIdentifier
    }
}

struct TaskFormSection {
    let identifier: String
    let title: String?
    let rows: [TaskFormRow]
    
    init(identifier: String, title: String?, rows: [TaskFormRow]) {
        self.identifier = identifier
        self.title = title
        self.rows = rows
    }
}

class TaskFormViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var modalContainerViewController: VisualEffectModalViewController?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @objc var isCreating = true {
        didSet {
            updateTitle()
        }
    }
    var taskType: TaskType = .habit {
        didSet {
            updateTitle()
        }
    }
    var taskTintColor: UIColor = UIColor.purple300() {
        didSet {
            updateTitleBarColor()
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }
    var taskId: String? {
        get {
            return task.id
        }
        set {
            if let id = newValue, let task = taskRepository.getEditableTask(id: id) {
                self.task = task
            }
        }
    }
    @objc var task: TaskProtocol = TaskRepository().getNewTask() {
        didSet {
            if let type = task.type, let newTaskType = TaskType(rawValue: type) {
                taskType = newTaskType
            }
            if isCreating {
                taskTintColor = UIColor.purple300()
            } else {
                taskTintColor = UIColor.forTaskValue(Int(task.value))
            }
        }
    }
    
    private var sections: [TaskFormSection] = []
    private var viewModel = TaskFormViewModel()
    private var taskRepository = TaskRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sections = viewModel.sectionsFor(taskType: taskType)
        
        task.up = true
        task.priority = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rowAt(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellIdentifier, for: indexPath)
        if let taskFormCell = cell as? TaskFormCell {
            if let textInputCell = taskFormCell as? TextInputTaskFormCell {
                if indexPath.item == 0 {
                    textInputCell.inputType = .title
                } else {
                    textInputCell.inputType = .notes
                }
            }
            taskFormCell.setTaskTintColor(color: taskTintColor)
            taskFormCell.configureFor(task: task)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        } else {
            return 28
        }
    }
    
    private func rowAt(indexPath: IndexPath) -> TaskFormRow {
        return sections[indexPath.section].rows[indexPath.item]
    }
    
    private func updateTitle() {
        if let visualEffectViewController = modalContainerViewController {
            if isCreating {
                visualEffectViewController.title = L10n.Tasks.create(taskType.prettName())
            } else {
                visualEffectViewController.title = L10n.Tasks.edit(taskType.prettName())
            }
        }
    }
    
    private func updateTitleBarColor() {
        if let visualEffectViewController = modalContainerViewController {
            visualEffectViewController.titleBar.backgroundColor = taskTintColor.darker(by: 16)
        }
    }
}
