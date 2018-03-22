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

enum TaskFormTags {
    static let title = "title"
    static let notes = "notes"
    static let habitControls = "habitControls"
    static let difficulty = "difficulty"
    static let habitResetStreak = "habitResetStreak"
    static let startDate = "startDate"
    static let dueDate = "dueDate"
    static let dailyRepeat = "dailyRepeat"
    static let dailyEvery = "dailyEvery"
    static let tags = "tags"
}

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
        if taskType == .habit {
            setupHabitControls()
        } else if taskType != .reward {
            setupChecklist()
        }
        if taskType != .reward {
            setupTaskDifficulty()
        }
        if taskType == .habit {
            setupHabitResetStreak()
        } else if taskType == .daily {
            setupDailyScheduling()
        } else if taskType == .todo {
            setupToDoScheduling()
        }
        if taskType != .habit && taskType != .reward {
            setupReminders()
        }
        setupTags()
        
        if !isCreating {
            fillCommonTaskValues()
            if taskType == .habit {
                fillHabitValues()
            } else if taskType == .daily {
                fillDailyValues()
            } else if taskType == .todo {
                fillToDoValues()
            } else if taskType == .reward {
                fillRewardValues()
            }
        }
        
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
    
    private func setupBasicTaskInput() {
        form +++ Section { section in
            var header = HeaderFooterView<UIView>(.class)
            header.height = { 0 }
            section.header = header
            }
            <<< TaskTextInputRow(TaskFormTags.title) { row in
                row.title = L10n.title
                row.tintColor = taskTintColor
                row.topSpacing = 12
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnDemand
            }
            <<< TaskTextInputRow(TaskFormTags.notes) { row in
                row.title = L10n.notes
                row.placeholder = L10n.Tasks.Form.notesPlaceholder
                row.tintColor = taskTintColor
                row.topSpacing = 8
                row.bottomSpacing = 12
        }
    }
    
    private func setupHabitControls() {
        form +++ Section(L10n.Tasks.Form.controls)
            <<< HabitControlsRow(TaskFormTags.habitControls) {row in
                row.tintColor = taskTintColor
                row.value = HabitControlsValue()
        }
    }
    
    private func setupChecklist() {
        form +++ Section(L10n.Tasks.Form.checklist)
    }
    
    private func setupTaskDifficulty() {
        form +++ Section(L10n.Tasks.Form.difficulty)
            <<< TaskDifficultyRow(TaskFormTags.difficulty) { row in
                row.tintColor = taskTintColor
                row.value = 1
        }
    }
    
    private func setupHabitResetStreak() {
        form +++ Section(L10n.Tasks.Form.resetStreak)
            <<< SegmentedRow<String>(TaskFormTags.habitResetStreak) { row in
                row.options = [L10n.daily, L10n.weekly, L10n.monthly]
                row.value = L10n.daily
                row.cellSetup({ (cell, _) in
                    cell.segmentedControl.tintColor = self.taskTintColor
                })
            }
    }
    
    private func setupDailyScheduling() {
        form +++ Section(L10n.Tasks.Form.scheduling)
            <<< DateRow(TaskFormTags.startDate) { row in
                row.title = L10n.Tasks.Form.startDate
                row.value = Date()
                row.cellSetup({ (cell, _) in
                    cell.textLabel?.textColor = self.taskTintColor
                })
        }
            <<< PushRow<String>(TaskFormTags.dailyRepeat) { row in
                row.title = L10n.Tasks.Form.repeats
                row.options = [L10n.daily, L10n.weekly, L10n.monthly, L10n.yearly]
                row.value = L10n.daily
                row.selectorTitle = "Pick a repeat option"
                row.cellSetup({ (cell, _) in
                    cell.textLabel?.textColor = self.taskTintColor
                })
        }
    }
    
    private func setupToDoScheduling() {
        form +++ Section(L10n.Tasks.Form.scheduling)
            <<< DateRow(TaskFormTags.dueDate) { row in
                row.title = L10n.Tasks.Form.dueDate
                row.cellSetup({ (cell, _) in
                    cell.textLabel?.textColor = self.taskTintColor
                })
            }
    }
    
    private func setupReminders() {
        form +++ Section(L10n.Tasks.Form.reminders)
    }
    
    private func setupTags() {
        form +++ Section(L10n.Tasks.Form.tags)
    }
    
    private func fillCommonTaskValues() {
        form.setValues([
            TaskFormTags.title: task.text,
            TaskFormTags.notes: task.notes,
            TaskFormTags.difficulty: task.priority
            ])
    }
    
    private func fillHabitValues() {
        let controls = HabitControlsValue(positive: task.up, negative: task.down)
        form.setValues([
            TaskFormTags.habitControls: controls
            ])
    }
    
    private func fillDailyValues() {
    }
    
    private func fillToDoValues() {
        form.setValues([
            TaskFormTags.dueDate: task.duedate
            ])
    }
    
    private func fillRewardValues() {
        
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
