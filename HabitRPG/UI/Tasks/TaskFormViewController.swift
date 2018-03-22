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
import Eureka

class TaskFormViewController: FormViewController {

    weak var modalContainerViewController: VisualEffectModalViewController?
    
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
    
    private var viewModel = TaskFormViewModel()
    private var taskRepository = TaskRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        task.up = true
        task.priority = 1
        
        setupBasicTaskInput()
        
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let visualEffectViewController = modalContainerViewController {
            visualEffectViewController.contentHeightConstraint.constant = tableView.contentSize.height
        }
        tableView.frame = view.frame
    }
    
    func setupBasicTaskInput() {
        form +++ Section { section in
            var header = HeaderFooterView<UIView>(.class)
            header.height = { 0 }
            section.header = header
            }
            <<< TaskTextInputRow { row in
                row.title = "Title"
                row.tintColor = taskTintColor
                row.topSpacing = 12
            }
            <<< TaskTextInputRow { row in
                row.title = "Notes"
                row.placeholder = "Include any notes to help you out"
                row.tintColor = taskTintColor
                row.topSpacing = 8
                row.bottomSpacing = 12
        }
    }
    
    func setupHabitControls() {
        form +++ Section()
    }
    
    func setupTaskDifficulty() {
        
    }
    
    func setupHabitResetStreak() {
        
    }
    
    func setupTags() {
        
    }
    
    private func updateTitle() {
        if let visualEffectViewController = modalContainerViewController {
            if isCreating {
                visualEffectViewController.title = L10n.Tasks.Form.create(taskType.prettName())
            } else {
                visualEffectViewController.title = L10n.Tasks.Form.edit(taskType.prettName())
            }
        }
    }
    
    private func updateTitleBarColor() {
        if let visualEffectViewController = modalContainerViewController {
            visualEffectViewController.titleBar.backgroundColor = taskTintColor.darker(by: 16)
        }
    }
}
