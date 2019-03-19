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
import ReactiveSwift

enum TaskFormTags {
    static let title = "title"
    static let notes = "notes"
    static let habitControls = "habitControls"
    static let checklistSection = "checklistSection"
    static let difficulty = "difficulty"
    static let habitResetStreak = "habitResetStreak"
    static let startDate = "startDate"
    static let dueDate = "dueDate"
    static let dueDateClear = "dueDateClear"
    static let dailyRepeat = "dailyRepeat"
    static let dailyEvery = "dailyEvery"
    static let repeatMonthlySegment = "repeatMonthlySegment"
    static let repeatWeekdays = "repeatWeekdays"
    static let rewardCost = "rewardCost"
    static let reminderSection = "reminderSection"
    static let tagSection = "tagSection"
    static let tags = "tags"
    static let delete = "delete"
}

//swiftlint:disable:next type_body_length
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
            self.view.tintColor = taskTintColor
            if tableView != nil {
                tableView.reloadData()
            }
            modalContainerViewController?.screenDimView.backgroundColor = taskTintColor.darker(by: 50).withAlphaComponent(0.6)
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
    
    private let viewModel = TaskFormViewModel()
    private let taskRepository = TaskRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    private let repeatablesSummaryInteractor = TaskRepeatablesSummaryInteractor()
    
    private var schedulingSection: Section?
    
    private static let habitResetStreakOptions = [
        LabeledFormValue<String>(value: "daily", label: L10n.daily),
        LabeledFormValue<String>(value: "weekly", label: L10n.weekly),
        LabeledFormValue<String>(value: "monthly", label: L10n.monthly)
    ]
    private static let dailyRepeatOptions = [
        LabeledFormValue<String>(value: "daily", label: L10n.daily),
        LabeledFormValue<String>(value: "weekly", label: L10n.weekly),
        LabeledFormValue<String>(value: "monthly", label: L10n.monthly),
        LabeledFormValue<String>(value: "yearly", label: L10n.yearly)
    ]
    
    private var tags = [TagProtocol]() {
        didSet {
            guard let section = self.form.sectionBy(tag: TaskFormTags.tagSection) else {
                return
            }
            section.removeAll()
            tags.forEach({ (tag) in
                let row = CheckRow(tag.id) { row in
                    row.title = tag.text
                    if !self.task.isValid {
                        return
                    }
                    row.value = self.task.tags.contains(where: { (taskTag) -> Bool in
                        return taskTag.id == tag.id
                    })
                    row.cellUpdate({ (cell, _) in
                        cell.tintColor = self.taskTintColor
                        cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                        cell.detailTextLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    })
                }
                section.append(row)
            })
        }
    }
    
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
        } else if taskType == .reward {
            setupRewardCost()
        }
        if taskType != .habit && taskType != .reward {
            setupReminders()
        }
        setupTags()
        
        if !isCreating {
            form +++ Section()
                <<< ButtonRow(TaskFormTags.delete) { row in
                    row.title = L10n.delete
                    row.cell.tintColor = UIColor.red50()
                    row.onCellSelection({ (_, _) in
                        self.deleteButtonTapped()
                    })
            }
            fillForm()
            modalContainerViewController?.rightButton.setTitle(L10n.save, for: .normal)
        } else {
            task.type = taskType.rawValue
            modalContainerViewController?.rightButton.setTitle(L10n.create, for: .normal)
        }
        
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        
        modalContainerViewController?.onRightButtonTapped = {
            let errors = self.form.validate()
            if errors.isEmpty {
                self.save()
                self.modalContainerViewController?.dismiss()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isEditing = true
        tableView.isEditing = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
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
                row.onChange({[weak self] _ in
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                    self?.view.setNeedsLayout()
                })
            }
            <<< TaskTextInputRow(TaskFormTags.notes) { row in
                row.title = L10n.notes
                row.placeholder = L10n.Tasks.Form.notesPlaceholder
                row.tintColor = taskTintColor
                row.topSpacing = 8
                row.bottomSpacing = 12
                row.onChange({[weak self] _ in
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                    self?.view.setNeedsLayout()
                })
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
                                                row.onCellSelection({[weak self] (_, _) in
                                                    self?.view.setNeedsLayout()
                                                })
                                            }
                                        }
                                        section.multivaluedRowToInsertAt = { index in
                                            return TextRow { row in
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = self.lightTaskTintColor
                                                })
                                                row.onCellHighlightChanged({[weak self] (_, _) in
                                                    self?.view.setNeedsLayout()
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
            <<< SegmentedRow<LabeledFormValue<String>>(TaskFormTags.habitResetStreak) { row in
                row.options = TaskFormViewController.habitResetStreakOptions
                row.value = TaskFormViewController.habitResetStreakOptions[0]
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.taskTintColor
                    cell.segmentedControl.tintColor = self.taskTintColor
                })
            }
    }
    
    private func setupDailyScheduling() {
        schedulingSection = Section(L10n.Tasks.Form.scheduling)
            <<< DateRow(TaskFormTags.startDate) { row in
                row.title = L10n.Tasks.Form.startDate
                row.value = Date()
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self.lightTaskTintColor
                })
                row.onChange({[weak self] _ in
                    self?.updateDailySchedulingFooter()
                })
        }
            <<< ActionSheetRow<LabeledFormValue<String>>(TaskFormTags.dailyRepeat) { row in
                row.title = L10n.Tasks.Form.repeats
                row.options = TaskFormViewController.dailyRepeatOptions
                row.value = TaskFormViewController.dailyRepeatOptions[0]
                row.selectorTitle = "Pick a repeat option"
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self.lightTaskTintColor
                })
                row.onChange({[weak self] _ in
                    self?.updateDailySchedulingFooter()
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
                row.onChange({[weak self] _ in
                    self?.updateDailySchedulingFooter()
                })
        }
            <<< SegmentedRow<String>(TaskFormTags.repeatMonthlySegment) { row in
                row.options = [L10n.Tasks.Form.dayOfMonth, L10n.Tasks.Form.dayOfWeek]
                row.value = L10n.Tasks.Form.dayOfMonth
                row.hidden = Condition.function([TaskFormTags.dailyRepeat], { (form) -> Bool in
                    return (form.rowBy(tag: TaskFormTags.dailyRepeat) as? ActionSheetRow<LabeledFormValue<String>>)?.value?.value != "monthly"
                })
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.taskTintColor
                    cell.segmentedControl.tintColor = self.taskTintColor
                })
                row.onChange({[weak self] _ in
                    self?.updateDailySchedulingFooter()
                })
        }
            <<< WeekdayRow(TaskFormTags.repeatWeekdays) { row in
                row.tintColor = self.taskTintColor
                row.hidden = Condition.function([TaskFormTags.dailyRepeat, TaskFormTags.repeatMonthlySegment], { (form) -> Bool in
                    return (form.rowBy(tag: TaskFormTags.dailyRepeat) as? ActionSheetRow<LabeledFormValue<String>>)?.value?.value != "weekly"
                })
                row.onChange({[weak self] _ in
                    self?.updateDailySchedulingFooter()
                })
        }
        if let section = schedulingSection {
            form +++ section
        }
    }
    
    private func setupToDoScheduling() {
        form +++ Section(L10n.Tasks.Form.scheduling)
            <<< DateRow(TaskFormTags.dueDate) { row in
                row.title = L10n.Tasks.Form.dueDate
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self.lightTaskTintColor
                }).onCellSelection({ (_, row) in
                    if row.value == nil {
                        row.value = Date()
                        row.updateCell()
                    }
                })
            }
            <<< ButtonRow(TaskFormTags.dueDateClear) { row in
                row.title = L10n.Tasks.Form.clear
                row.hidden = Condition.function([TaskFormTags.dueDate], { (form) -> Bool in
                    return (form.rowBy(tag: TaskFormTags.dueDate) as? DateRow)?.value == nil
                })
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self.lightTaskTintColor
                })
                row.onCellSelection({ (_, _) in
                    (self.form.rowBy(tag: TaskFormTags.dueDate) as? DateRow)?.value = nil
                    self.form.rowBy(tag: TaskFormTags.dueDate)?.reload()
                })
        }
    }
    
    private func setupRewardCost() {
        form +++ Section(L10n.Tasks.Form.cost)
            <<< DecimalRow(TaskFormTags.rewardCost) { row in
                row.title = L10n.Tasks.Form.cost
                row.cellSetup({ (cell, _) in
                    cell.tintColor = self.taskTintColor
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
                                                row.onCellSelection({[weak self] (_, _) in
                                                    self?.view.setNeedsLayout()
                                                })
                                            }
                                        }
                                        section.multivaluedRowToInsertAt = { index in
                                            return TimeRow { row in
                                                row.title = L10n.Tasks.Form.remindMe
                                                row.value = Date()
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = self.lightTaskTintColor
                                                })
                                                row.onCellHighlightChanged({[weak self] (_, _) in
                                                    self?.view.setNeedsLayout()
                                                })
                                            }
                                        }
        }
    }
    
    private func setupTags() {
        form +++ Section(L10n.Tasks.Form.tags) { section in
            section.tag = TaskFormTags.tagSection
        }
    
        disposable.inner.add(taskRepository.getTags().on(value: {[weak self](tags, _) in
            self?.tags = tags
        }).start())
    }
    
    private func updateDailySchedulingFooter() {
        let values = form.values()
        let weekdays = values[TaskFormTags.repeatWeekdays] as? WeekdaysValue
        let summary = repeatablesSummaryInteractor.repeatablesSummary(frequency: values[TaskFormTags.dailyRepeat] as? String,
                                                                      everyX: values[TaskFormTags.dailyEvery] as? Int,
                                                                      monday: weekdays?.monday,
                                                                      tuesday: weekdays?.tuesday,
                                                                      wednesday: weekdays?.wednesday,
                                                                      thursday: weekdays?.thursday,
                                                                      friday: weekdays?.friday,
                                                                      saturday: weekdays?.saturday,
                                                                      sunday: weekdays?.sunday,
                                                                      startDate: values[TaskFormTags.startDate] as? Date,
                                                                      daysOfMonth: [],
                                                                      weeksOfMonth: [])
        /*schedulingSection?.footer = HeaderFooterView(title: summary)
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: schedulingSection?.index ?? 2), with: .automatic)
        tableView.endUpdates()*/
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
            TaskFormTags.habitControls: controls,
            TaskFormTags.habitResetStreak: TaskFormViewController.habitResetStreakOptions.first(where: { (option) -> Bool in
                return option.value == task.frequency
            })
            ])
    }
    
    private func fillDailyValues() {
        let weekRepeat = WeekdaysValue(monday: task.weekRepeat?.monday ?? true,
                                   tuesday: task.weekRepeat?.tuesday ?? true,
                                   wednesday: task.weekRepeat?.wednesday ?? true,
                                   thursday: task.weekRepeat?.thursday ?? true,
                                   friday: task.weekRepeat?.friday ?? true,
                                   saturday: task.weekRepeat?.saturday ?? true,
                                   sunday: task.weekRepeat?.sunday ?? true)
        form.setValues([
            TaskFormTags.startDate: task.startDate,
            TaskFormTags.dailyRepeat: TaskFormViewController.dailyRepeatOptions.first(where: { (option) -> Bool in
                return option.value == task.frequency
            }),
            TaskFormTags.dailyEvery: task.everyX,
            TaskFormTags.repeatWeekdays: weekRepeat
            ])
        if task.daysOfMonth.isEmpty == false {
            form.setValues([TaskFormTags.repeatMonthlySegment: L10n.Tasks.Form.dayOfMonth])
        }
        if task.weeksOfMonth.isEmpty == false {
            form.setValues([TaskFormTags.repeatMonthlySegment: L10n.Tasks.Form.dayOfWeek])
        }
        fillChecklistValues()
        fillReminderValues()
    }
    
    private func fillToDoValues() {
        form.setValues([
            TaskFormTags.dueDate: task.duedate
            ])
        fillChecklistValues()
        fillReminderValues()
    }
    
    private func fillRewardValues() {
        form.setValues([TaskFormTags.rewardCost: Double(task.value)])
    }
    
    private func fillChecklistValues() {
        var checklistSection = self.form.sectionBy(tag: TaskFormTags.checklistSection)
        task.checklist.forEach { (item) in
            let row = TextRow(item.id) { row in
                row.value = item.text
            }
            let lastIndex = (checklistSection?.count ?? 1) - 1
            checklistSection?.insert(row, at: lastIndex)
        }
    }
    
    private func fillReminderValues() {
        var reminderSection = self.form.sectionBy(tag: TaskFormTags.reminderSection)
        task.reminders.forEach { (reminder) in
            let row = TimeRow(reminder.id) { row in
                row.value = reminder.time
            }
            let lastIndex = (reminderSection?.count ?? 1) - 1
            reminderSection?.insert(row, at: lastIndex)
        }
    }
    
    private func save() {
        let values = form.values()
        saveCommon(values: values)
        saveTags()
        if taskType == .habit {
            saveHabit(values: values)
        } else if taskType == .daily {
            saveDaily(values: values)
            saveChecklist()
            saveReminders()
        } else if taskType == .todo {
            saveToDo(values: values)
            saveChecklist()
            saveReminders()
        } else if taskType == .reward {
            saveReward(values: values)
        }
        task.isSyncing = true
        task.isSynced = false
        if isCreating {
            task.id = UUID().uuidString
            taskRepository.createTask(task).observeCompleted {}
        } else {
            taskRepository.updateTask(task).observeCompleted {}
        }
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
        task.frequency = (values[TaskFormTags.habitResetStreak] as? LabeledFormValue<String>)?.value
    }
    
    private func saveDaily(values: [String: Any?]) {
        task.startDate = values[TaskFormTags.startDate] as? Date
        task.everyX = values[TaskFormTags.dailyEvery] as? Int ?? 1
        task.frequency = (values[TaskFormTags.dailyRepeat] as? LabeledFormValue<String>)?.value
        if task.frequency == "monthly", let startDate = task.startDate {
            let calendar = Calendar.current
            let selectedValue = values[TaskFormTags.repeatMonthlySegment] as? String
            if selectedValue == L10n.Tasks.Form.dayOfMonth {
                task.daysOfMonth = [calendar.component(.day, from: startDate)]
                task.weeksOfMonth = []
            } else {
                var weeks = 0
                var currentDate = calendar.date(byAdding: .day, value: -7, to: startDate) ?? startDate
                while calendar.component(.month, from: currentDate) == calendar.component(.month, from: startDate) {
                    weeks += 1
                    currentDate = calendar.date(byAdding: .day, value: -7, to: currentDate) ?? currentDate
                }
                task.weeksOfMonth = [weeks]
                task.daysOfMonth = []
            }
        }
        let weekdays = values[TaskFormTags.repeatWeekdays] as? WeekdaysValue
        task.weekRepeat?.monday = weekdays?.monday ?? true
        task.weekRepeat?.tuesday = weekdays?.tuesday ?? true
        task.weekRepeat?.wednesday = weekdays?.wednesday ?? true
        task.weekRepeat?.thursday = weekdays?.thursday ?? true
        task.weekRepeat?.friday = weekdays?.friday ?? true
        task.weekRepeat?.saturday = weekdays?.saturday ?? true
        task.weekRepeat?.sunday = weekdays?.sunday ?? true
    }
    
    private func saveToDo(values: [String: Any?]) {
        task.duedate = values[TaskFormTags.dueDate] as? Date
    }
    
    private func saveReward(values: [String: Any?]) {
        task.value = Float(values[TaskFormTags.rewardCost] as? Double ?? 0)
    }
    
    private func saveChecklist() {
        guard let section = form.sectionBy(tag: TaskFormTags.checklistSection) else {
            return
        }
        let oldChecklist = task.checklist
        task.checklist.removeAll()
        for row in section {
            if let checklistRow = row as? TextRow {
                let item = taskRepository.getNewChecklistItem()
                item.id = checklistRow.tag
                if item.id == nil {
                    item.id = UUID().uuidString
                }
                item.text = checklistRow.value
                item.completed = oldChecklist.first(where: { (oldItem) -> Bool in
                    return oldItem.id == item.id
                })?.completed ?? false
                task.checklist.append(item)
            }
        }
    }
    
    private func saveReminders() {
        guard let section = form.sectionBy(tag: TaskFormTags.reminderSection) else {
            return
        }
        task.reminders.removeAll()
        for row in section {
            if let reminderRow = row as? TimeRow {
                let reminder = taskRepository.getNewReminder()
                reminder.id = reminderRow.tag
                if reminder.id == nil {
                    reminder.id = UUID().uuidString
                }
                reminder.time = reminderRow.value
                task.reminders.append(reminder)
            }
        }
    }
    
    private func saveTags() {
        task.tags.removeAll()
        tags.forEach { (tag) in
            guard let tagId = tag.id else {
                return
            }
            let row = form.rowBy(tag: tagId) as? CheckRow
            if row?.value == true {
                task.tags.append(tag)
            }
        }
    }
    
    private func updateTitle() {
        if let visualEffectViewController = modalContainerViewController {
            if isCreating {
                visualEffectViewController.title = L10n.Tasks.Form.create(taskType.prettyName())
            } else {
                visualEffectViewController.title = L10n.Tasks.Form.edit(taskType.prettyName())
            }
        }
    }
    
    private func updateTitleBarColor() {
        if let visualEffectViewController = modalContainerViewController {
            visualEffectViewController.titleBar.backgroundColor = taskTintColor.darker(by: 16)
        }
    }
    
    private func deleteButtonTapped() {
        let alertController = HabiticaAlertController(title: L10n.Tasks.Form.confirmDelete)
        alertController.addCancelAction()
        alertController.addAction(title: L10n.delete, style: .default, isMainAction: true) { (_) in
            self.taskRepository.deleteTask(self.task).observeCompleted {}
            self.dismiss(animated: true, completion: nil)
        }
        alertController.show()
    }
}
