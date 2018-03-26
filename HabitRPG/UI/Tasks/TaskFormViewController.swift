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
    static let checklistSection = "checklistSection"
    static let difficulty = "difficulty"
    static let habitResetStreak = "habitResetStreak"
    static let startDate = "startDate"
    static let dueDate = "dueDate"
    static let dailyRepeat = "dailyRepeat"
    static let dailyEvery = "dailyEvery"
    static let repeatMonthlySegment = "repeatMonthlySegment"
    static let repeatWeekdays = "repeatWeekdays"
    static let reminderSection = "reminderSection"
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
    var lightTaskTintColor: UIColor = UIColor.purple400()
    
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
                lightTaskTintColor = UIColor.purple400()
                taskTintColor = UIColor.purple300()
            } else {
                lightTaskTintColor = UIColor.forTaskValueLight(Int(task.value))
                taskTintColor = UIColor.forTaskValue(Int(task.value))
            }
        }
    }
    
    private var viewModel = TaskFormViewModel()
    private var taskRepository = TaskRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            fillForm()
            modalContainerViewController?.rightButton.setTitle(L10n.save, for: .normal)
        } else {
            modalContainerViewController?.rightButton.setTitle(L10n.create, for: .normal)
        }
        
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        
        modalContainerViewController?.onRightButtonTapped = {
            let errors = self.form.validate()
            if errors.count == 0 {
                self.save()
                self.modalContainerViewController?.dismiss()
            }
        }
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
        form +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                                    header: L10n.Tasks.Form.checklist) { section in
                                        section.tag = TaskFormTags.checklistSection
                                        section.addButtonProvider = { section in
                                            return ButtonRow { row in
                                                row.title = L10n.Tasks.Form.newChecklistItem
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = self.lightTaskTintColor
                                                })
                                            }
                                        }
                                        section.multivaluedRowToInsertAt = { index in
                                            return NameRow { row in
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = self.lightTaskTintColor
                                                })
                                            }
                                        }
        }
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
                    cell.tintColor = self.taskTintColor
                })
            }
    }
    
    private func setupDailyScheduling() {
        form +++ Section(L10n.Tasks.Form.scheduling)
            <<< DateRow(TaskFormTags.startDate) { row in
                row.title = L10n.Tasks.Form.startDate
                row.value = Date()
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self.lightTaskTintColor
                })
        }
            <<< ActionSheetRow<String>(TaskFormTags.dailyRepeat) { row in
                row.title = L10n.Tasks.Form.repeats
                row.options = [L10n.daily, L10n.weekly, L10n.monthly, L10n.yearly]
                row.value = L10n.daily
                row.selectorTitle = "Pick a repeat option"
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self.lightTaskTintColor
                })
        }
            <<< PickerInputRow<Int>(TaskFormTags.dailyEvery) { row in
                row.title = L10n.Tasks.Form.every
                row.options = Array(0...366)
                row.value = 1
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self.lightTaskTintColor
                })
        }
            <<< SegmentedRow<String>(TaskFormTags.repeatMonthlySegment) { row in
                row.options = [L10n.Tasks.Form.dayOfMonth, L10n.Tasks.Form.dayOfWeek]
                row.value = L10n.Tasks.Form.dayOfMonth
                row.hidden = Condition.predicate(NSPredicate.init(format: "$\(TaskFormTags.dailyRepeat) != '\(L10n.monthly)'"))
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.taskTintColor
                })
        }
            <<< WeekdayRow(TaskFormTags.repeatWeekdays) { row in
                row.tintColor = self.taskTintColor
                row.hidden = Condition.function([TaskFormTags.dailyRepeat, TaskFormTags.repeatMonthlySegment], { (form) -> Bool in
                    return (form.rowBy(tag: TaskFormTags.dailyRepeat) as? ActionSheetRow<String>)?.value != L10n.weekly
                })
        }
    }
    
    private func setupToDoScheduling() {
        form +++ Section(L10n.Tasks.Form.scheduling)
            <<< DateRow(TaskFormTags.dueDate) { row in
                row.title = L10n.Tasks.Form.dueDate
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self.lightTaskTintColor
                })
            }
    }
    
    private func setupReminders() {
        form +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                                    header: L10n.Tasks.Form.reminders) { section in
                                        section.tag = TaskFormTags.reminderSection
                                        section.addButtonProvider = { section in
                                            return ButtonRow { row in
                                                row.title = L10n.Tasks.Form.newReminder
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = self.lightTaskTintColor
                                                })
                                            }
                                        }
                                        section.multivaluedRowToInsertAt = { index in
                                            return TimeRow { row in
                                                row.title = L10n.Tasks.Form.remindMe
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = self.lightTaskTintColor
                                                })
                                            }
                                        }
        }
    }
    
    private func setupTags() {
        form +++ Section(L10n.Tasks.Form.tags)
    }
    
    private func fillForm() {
        form.setValues([
            TaskFormTags.title: task.text,
            TaskFormTags.notes: task.notes,
            TaskFormTags.difficulty: task.priority
            ])
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
    
    private func fillHabitValues() {
        let controls = HabitControlsValue(positive: task.up, negative: task.down)
        form.setValues([
            TaskFormTags.habitControls: controls
            ])
    }
    
    private func fillDailyValues() {
        form.setValues([
            TaskFormTags.dueDate: task.duedate,
            TaskFormTags.dailyRepeat: task.frequency,
            TaskFormTags.dailyEvery: task.everyX
            ])
        fillChecklistValues()
    }
    
    private func fillToDoValues() {
        form.setValues([
            TaskFormTags.dueDate: task.duedate
            ])
        fillChecklistValues()
    }
    
    private func fillRewardValues() {
        
    }
    
    private func fillChecklistValues() {
        var checklistSection = self.form.sectionBy(tag: TaskFormTags.checklistSection)
        task.checklist.forEach { (item) in
            let row = NameRow(item.id) { row in
                row.value = item.text
            }
            let lastIndex = (checklistSection?.count ?? 1) - 1
            checklistSection?.insert(row, at: lastIndex)
        }
    }
    
    private func fillTags() {
        taskRepository.getTags()
    }
    
    private func save() {
        let values = form.values()
        saveCommon(values: values)
        if taskType == .habit {
            saveHabit(values: values)
        } else if taskType == .daily {
            saveDaily(values: values)
        } else if taskType == .todo {
            saveToDo(values: values)
        } else if taskType == .reward {
            saveReward(values: values)
        }
        
        taskRepository.save(task: task)
    }
    
    private func saveCommon(values: [String: Any?]) {
        task.text = values[TaskFormTags.title] as? String
        task.notes = values[TaskFormTags.notes] as? String
        task.priority = values[TaskFormTags.difficulty] as? Float ?? 1
    }
    
    private func saveHabit(values: [String: Any?]) {
        let controls = values[TaskFormTags.habitControls] as? HabitControlsValue
        task.up = controls?.positive ?? true
        task.down = controls?.negative ?? true
    }
    
    private func saveDaily(values: [String: Any?]) {
        task.everyX = values[TaskFormTags.dailyEvery] as? Int ?? 1
    }
    
    private func saveToDo(values: [String: Any?]) {
        task.duedate = values[TaskFormTags.dueDate] as? Date
    }
    
    private func saveReward(values: [String: Any?]) {
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
