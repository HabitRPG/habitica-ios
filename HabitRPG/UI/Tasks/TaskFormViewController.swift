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
    static let historySection = "historySection"
    static let tags = "tags"
    static let delete = "delete"
    static let historyButton = "historyButton"
    static let attributeSection = "attributeSection"
    static let attribute = "attribute"
    static let challengeName = "challengeName"
}

//swiftlint:disable:next type_body_length
class TaskFormViewController: FormViewController, Themeable {
    
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
    var taskTintColor: UIColor = UIColor.purple300 {
        didSet {
            updateTitleBarColor()
            self.view.tintColor = taskTintColor
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    var lightTaskTintColor: UIColor = UIColor.purple400
    var darkestTaskTintColor: UIColor = UIColor(white: 1, alpha: 0.7)
    
    var taskId: String?
    @objc var task: TaskProtocol = TaskRepository().getNewTask() {
        didSet {
            if let type = task.type, let newTaskType = TaskType(rawValue: type) {
                taskType = newTaskType
            }
            if let challengeID = task.challengeID, task.challengeBroken == nil, challenge == nil {
                if challenge == nil {
                    socialRepository.getChallenge(challengeID: challengeID, retrieveIfNotFound: true).on(value: {[weak self] challenge in
                        self?.challenge = challenge
                        self?.form.rowBy(tag: TaskFormTags.challengeName)?.title = challenge?.name
                        self?.form.rowBy(tag: TaskFormTags.challengeName)?.updateCell()
                        }).start()
                }
            }
            let theme = ThemeService.shared.theme
            if isCreating {
                darkestTaskTintColor = UIColor(white: 1, alpha: 0.7)
                if theme.isDark {
                    lightTaskTintColor = UIColor.purple300
                    taskTintColor = UIColor.purple200
                } else {
                    lightTaskTintColor = UIColor.purple400
                    taskTintColor = UIColor.purple300
                }
            } else {
                if task.value < -20 {
                    darkestTaskTintColor = UIColor(white: 1, alpha: 0.7)
                } else {
                    darkestTaskTintColor = UIColor.forTaskValueDarkest(task.value)
                }
                if theme.isDark {
                    lightTaskTintColor = UIColor.forTaskValue(task.value)
                    taskTintColor = UIColor.forTaskValueDark(task.value)
                } else {
                    lightTaskTintColor = UIColor.forTaskValueLight(task.value)
                    taskTintColor = UIColor.forTaskValue(task.value)
                }
            }
        }
    }
    var challenge: ChallengeProtocol?
    
    private let viewModel = TaskFormViewModel()
    private let taskRepository = TaskRepository()
    private let userRepository = UserRepository()
    private let socialRepository = SocialRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    private let repeatablesSummaryInteractor = TaskRepeatablesSummaryInteractor()
    
    private var showAttributeSection = false
    
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
                        if !taskTag.isValid || !tag.isValid {
                            return false
                        }
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
        
        userRepository.getUser().take(first: 1).on(value: {[weak self] user in
            let allocationMode = user.preferences?.allocationMode ?? ""
            self?.showAttributeSection = allocationMode == "taskbased"
            self?.form.sectionBy(tag: TaskFormTags.attributeSection)?.evaluateHidden()
        }).start()
        
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
        
        if taskType != .reward {
            form +++ Section {[weak self] section in
                section.tag = TaskFormTags.attributeSection
                section.hidden = Condition.function([], { _ -> Bool in
                    return self?.showAttributeSection != true
                })
                } <<< TaskAttributeRow(TaskFormTags.attribute) { row in
                    row.value = "str"
                    row.cellUpdate { (cell, _) in
                        cell.updateTintColor(self.taskTintColor)
                    }
            }
        }
        
        setupTags()
        
        if !isCreating {
            if (taskType == .habit || taskType == .daily) && false {
            form +++ Section { section in
                 section.tag = TaskFormTags.historySection
             }
             <<< ButtonRow(TaskFormTags.historyButton) { row in
                 row.title = L10n.taskHistory
                 row.onCellSelection({ (_, _) in
                     self.historyButtonTapped()
                 })
                 row.hidden = Condition(booleanLiteral: HabiticaAppDelegate.isRunningLive())
             }
            }
            form +++ Section()
                <<< ButtonRow(TaskFormTags.delete) { row in
                    row.title = L10n.delete
                    row.cell.tintColor = UIColor.red50
                    row.onCellSelection({ (_, _) in
                        self.deleteButtonTapped()
                    })
            }
            if let id = taskId, let task = taskRepository.getEditableTask(id: id) {
                self.task = task
            }
            fillForm()
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.save, style: .plain, target: self, action: #selector(rightButtonTapped))
        } else {
            task.type = taskType.rawValue
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.create, style: .plain, target: self, action: #selector(rightButtonTapped))
            
            let row = form.rowBy(tag: TaskFormTags.title) as? TaskTextInputRow
            row?.cell.textField.becomeFirstResponder()
            
            darkestTaskTintColor = UIColor(white: 1, alpha: 0.7)
            if ThemeService.shared.theme.isDark {
                lightTaskTintColor = UIColor.purple300
                taskTintColor = UIColor.purple200
            } else {
                lightTaskTintColor = UIColor.purple400
                taskTintColor = UIColor.purple300
            }
        }
        
        tableView.backgroundColor = .clear
        
        ThemeService.shared.addThemeable(themable: self, applyImmediately: false)
        tableView.separatorColor = ThemeService.shared.theme.tableviewSeparatorColor
    }
    
    @objc
    func rightButtonTapped() {
        let errors = self.form.validate()
        if errors.isEmpty {
            self.save()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func applyTheme(theme: Theme) {
        tableView.separatorColor = theme.tableviewSeparatorColor

        if isCreating {
            darkestTaskTintColor = UIColor(white: 1, alpha: 0.7)
            if theme.isDark {
                lightTaskTintColor = UIColor.purple300
                taskTintColor = UIColor.purple200
            } else {
                lightTaskTintColor = UIColor.purple400
                taskTintColor = UIColor.purple300
            }
        } else {
            if task.isValid {
                darkestTaskTintColor = UIColor.forTaskValueDarkest(task.value)
                if theme.isDark {
                    lightTaskTintColor = UIColor.forTaskValue(task.value)
                    taskTintColor = UIColor.forTaskValueDark(task.value)
                } else {
                    lightTaskTintColor = UIColor.forTaskValueLight(task.value)
                    taskTintColor = UIColor.forTaskValue(task.value)
                }
            }
        }
        updateTitleBarColor()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isEditing = true
        tableView.isEditing = true
        
        if #available(iOS 13.0, *) {
            if ThemeService.shared.themeMode == "dark" {
                self.overrideUserInterfaceStyle = .dark
            } else if ThemeService.shared.themeMode == "light" {
                self.overrideUserInterfaceStyle = .light
            } else {
                self.overrideUserInterfaceStyle = .unspecified
            }
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if task.challengeBroken != nil {
            showBrokenChallengeDialog()
        }
    }
    
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          self.tableView.contentInset = UIEdgeInsets(top: -2, left: 0, bottom: 0, right: 0)
    }
    
    private func setupBasicTaskInput() {
        let section = Section { section in
            var header = HeaderFooterView<UIView>(.class)
            header.height = { 0 }
            section.header = header
            }
        if task.isChallengeTask {
            section <<< LabelRow { row in
                row.title = L10n.editChallengeTasks
                row.cellUpdate { (cell, _) in
                    cell.backgroundColor = UIColor.red50
                    cell.textLabel?.textColor = UIColor.white
                }
            }
        }
            section <<< TaskTextInputRow(TaskFormTags.title) { row in
                row.title = L10n.title
                row.cellUpdate({ (cell, _) in
                    cell.updateTintColor(self.taskTintColor, self.darkestTaskTintColor)
                })
                row.topSpacing = 12
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnDemand
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
                row.onChange({[weak self] _ in
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                    self?.view.setNeedsLayout()
                })
            }
            <<< TaskTextInputRow(TaskFormTags.notes) { row in
                row.title = L10n.notes
                row.placeholder = L10n.Tasks.Form.notesPlaceholder
                row.cellUpdate({ (cell, _) in
                    cell.updateTintColor(self.taskTintColor, self.darkestTaskTintColor)
                })
                row.topSpacing = 8
                row.bottomSpacing = 12
                row.onChange({[weak self] _ in
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                    self?.view.setNeedsLayout()
                })
        }
        section <<< ButtonRow(TaskFormTags.challengeName) { row in
            row.hidden = Condition(booleanLiteral: !task.isChallengeTask && task.challengeBroken == nil)
            row.cellUpdate({ (cell, _) in
                cell.backgroundColor = self.taskTintColor
                cell.textLabel?.textColor = self.darkestTaskTintColor
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.font = CustomFontMetrics.scaledSystemFont(ofSize: 13, ofWeight: .semibold)
                cell.textLabel?.numberOfLines = 0
                cell.height = { return 36 }
            })
            }
        form +++ section
    }
    
    private func setupHabitControls() {
        form +++ Section(L10n.Tasks.Form.controls)
            <<< HabitControlsRow(TaskFormTags.habitControls) {row in
                row.value = HabitControlsValue()
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
                row.cellUpdate({ (cell, _) in
                    cell.updateTintColor(self.taskTintColor)
                })
        }
    }
    
    private func setupChecklist() {
        form +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                                    header: L10n.Tasks.Form.checklist) { section in
                                        section.tag = TaskFormTags.checklistSection
                                        if !task.isChallengeTask {
                                        section.addButtonProvider = { section in
                                            return ButtonRow { row in
                                                row.title = L10n.Tasks.Form.newChecklistItem
                                                row.cellUpdate({ (cell, _) in
                                                    cell.tintColor = self.lightTaskTintColor
                                                })
                                                row.onCellSelection({[weak self] (_, _) in
                                                    self?.view.setNeedsLayout()
                                                })
                                            }
                                        }
                                        }
                                        section.multivaluedRowToInsertAt = { index in
                                            return TextRow { row in
                                                row.cellUpdate({ (cell, _) in
                                                    cell.tintColor = self.lightTaskTintColor
                                                    cell.textField.textColor = ThemeService.shared.theme.primaryTextColor
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
                row.value = 1
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
                row.cellUpdate({ (cell, _) in
                    cell.updateTintColor(self.taskTintColor)
                })
        }
    }
    
    private func setupHabitResetStreak() {
        form +++ Section(L10n.Tasks.Form.resetStreak)
            <<< SegmentedRow<LabeledFormValue<String>>(TaskFormTags.habitResetStreak) { row in
                row.options = TaskFormViewController.habitResetStreakOptions
                row.value = TaskFormViewController.habitResetStreakOptions[0]
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
                row.cellUpdate({ (cell, _) in
                    cell.tintColor = self.taskTintColor
                    cell.segmentedControl.tintColor = self.taskTintColor
                })
            }
    }
    
    private func setupDailyScheduling() {
        schedulingSection = Section(L10n.Tasks.Form.scheduling)
            <<< DateRow(TaskFormTags.startDate) { row in
                row.title = L10n.Tasks.Form.startDate
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
                row.value = Date()
                row.cellUpdate({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self.lightTaskTintColor
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                })
                row.onChange({[weak self] _ in
                    self?.updateDailySchedulingFooter()
                })
        }
            <<< ActionSheetRow<LabeledFormValue<String>>(TaskFormTags.dailyRepeat) { row in
                row.title = L10n.Tasks.Form.repeats
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
                row.options = TaskFormViewController.dailyRepeatOptions
                row.value = TaskFormViewController.dailyRepeatOptions[0]
                row.selectorTitle = "Pick a repeat option"
                row.cellUpdate({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self.lightTaskTintColor
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                })
                row.onChange({[weak self] _ in
                    self?.updateDailySchedulingFooter()
                })
        }
            <<< PickerInputRow<Int>(TaskFormTags.dailyEvery) { row in
                row.title = L10n.Tasks.Form.every
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
                row.options = Array(0...366)
                row.value = 1
                row.cellUpdate({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self.lightTaskTintColor
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                })
                row.onChange({[weak self] _ in
                    self?.updateDailySchedulingFooter()
                })
        }
            <<< SegmentedRow<String>(TaskFormTags.repeatMonthlySegment) { row in
                row.options = [L10n.Tasks.Form.dayOfMonth, L10n.Tasks.Form.dayOfWeek]
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
                row.value = L10n.Tasks.Form.dayOfMonth
                row.hidden = Condition.function([TaskFormTags.dailyRepeat], { (form) -> Bool in
                    return (form.rowBy(tag: TaskFormTags.dailyRepeat) as? ActionSheetRow<LabeledFormValue<String>>)?.value?.value != "monthly"
                })
                row.cellUpdate({ (cell, _) in
                    cell.tintColor = self.taskTintColor
                    cell.segmentedControl.tintColor = self.taskTintColor
                })
                row.onChange({[weak self] _ in
                    self?.updateDailySchedulingFooter()
                })
        }
            <<< WeekdayRow(TaskFormTags.repeatWeekdays) { row in
                row.tintColor = self.taskTintColor
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
                row.hidden = Condition.function([TaskFormTags.dailyRepeat, TaskFormTags.repeatMonthlySegment], { (form) -> Bool in
                    return (form.rowBy(tag: TaskFormTags.dailyRepeat) as? ActionSheetRow<LabeledFormValue<String>>)?.value?.value != "weekly"
                })
                row.cellUpdate { (cell, _) in
                    cell.updateTintColor(newTint: self.taskTintColor)
                }
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
            <<< DateRow(TaskFormTags.dueDate) {[weak self] row in
                row.title = L10n.Tasks.Form.dueDate
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
                row.dateFormatter = self?.dateFormatter
                row.cellUpdate({ (cell, _) in
                    cell.tintColor = self?.lightTaskTintColor
                    cell.detailTextLabel?.textColor = self?.lightTaskTintColor
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                })
                row.onCellSelection({ (cell, row) in
                    if row.value == nil {
                        row.value = Date()
                        row.updateCell()
                    }
                    cell.textLabel?.textColor = self?.lightTaskTintColor
                })
            }
            <<< ButtonRow(TaskFormTags.dueDateClear) { row in
                row.title = L10n.Tasks.Form.clear
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
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
                row.disabled = Condition(booleanLiteral: task.isChallengeTask)
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
                                                row.cellUpdate({ (cell, _) in
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
                                                row.cellUpdate({ (cell, _) in
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
    
        disposable.inner.add(taskRepository.getTags().take(first: 1).on(value: {[weak self](tags, _) in
            self?.tags = tags
        }).start())
    }
    
    private func updateDailySchedulingFooter() {
        /*let values = form.values()
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
        schedulingSection?.footer = HeaderFooterView(title: summary)
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: schedulingSection?.index ?? 2), with: .automatic)
        tableView.endUpdates()*/
    }
    
    private func fillForm() {
        form.setValues([
            TaskFormTags.title: task.text,
            TaskFormTags.notes: task.notes,
            TaskFormTags.difficulty: task.priority,
            TaskFormTags.attribute: task.attribute
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
        var checklistSection = form.sectionBy(tag: TaskFormTags.checklistSection)
        task.checklist.forEach { (item) in
            let row = TextRow(item.id) { row in
                row.value = item.text
                row.cellUpdate({ (cell, _) in
                    cell.tintColor = self.lightTaskTintColor
                    cell.textField.textColor = ThemeService.shared.theme.primaryTextColor
                })
            }
            let lastIndex = (checklistSection?.count ?? 1) - 1
            checklistSection?.insert(row, at: lastIndex)
        }
    }
    
    private func fillReminderValues() {
        var reminderSection = form.sectionBy(tag: TaskFormTags.reminderSection)
        task.reminders.forEach { (reminder) in
            let row = TimeRow(reminder.id) { row in
                row.value = reminder.time
                row.cellUpdate { (cell, _) in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.detailTextLabel?.textColor = ThemeService.shared.theme.secondaryTextColor
                }
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
        if let attribute = values[TaskFormTags.attribute] as? String {
            task.attribute = attribute
        } else {
            task.attribute = "str"
        }
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
        if isCreating {
            navigationItem.title = L10n.Tasks.Form.create(taskType.prettyName())
        } else {
            navigationItem.title = L10n.Tasks.Form.edit(taskType.prettyName())
        }
    }
    
    private func updateTitleBarColor() {
        navigationController?.navigationBar.barTintColor = taskTintColor.darker(by: 16)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
            ]
    }
    
    private func deleteButtonTapped() {
        if task.isChallengeTask {
            if task.challengeBroken == nil {
                showChallengeTaskDeleteDialog()
            } else {
                showBrokenChallengeDialog()
            }
            return
        }
        let alertController = HabiticaAlertController(title: L10n.Tasks.Form.confirmDelete)
        alertController.addAction(title: L10n.delete, style: .default, isMainAction: true) {[weak self] (_) in
            if let task = self?.task {
                self?.taskRepository.deleteTask(task).observeCompleted {}
            }
            self?.dismiss(animated: true, completion: nil)
        }
        alertController.addCancelAction()
        alertController.show()
    }
        
    private func historyButtonTapped() {
        let nc = StoryboardScene.Tasks.taskHistoryNavigationController.instantiate()
        if let historyViewController = nc.topViewController as? TaskHistoryViewController {
            historyViewController.taskID = taskId
        }
        present(nc, animated: true, completion: nil)
    }
    
    private func showChallengeTaskDeleteDialog() {
        taskRepository.getChallengeTasks(id: task.challengeID ?? "").take(first: 1).on(
            value: { tasks in
                let taskCount = tasks.value.count
                let alert = HabiticaAlertController(title: L10n.deleteChallengeTask, message: L10n.deleteChallengeTaskDescription(taskCount, self.challenge?.name ?? "" ))
                alert.addAction(title: L10n.leaveAndDeleteTask, style: .destructive, isMainAction: true, handler: { _ in
                    self.socialRepository.leaveChallenge(challengeID: self.task.challengeID ?? "", keepTasks: true)
                        .flatMap(.latest) { _ in
                            return self.taskRepository.deleteTask(self.task)
                    }
                    .flatMap(.latest) { _ in
                        return self.taskRepository.retrieveTasks()
                    }.observeCompleted {}
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(title: L10n.leaveAndDeleteXTasks(taskCount), style: .destructive, isMainAction: false, handler: { _ in
                    self.socialRepository.leaveChallenge(challengeID: self.task.challengeID ?? "", keepTasks: false)
                    .flatMap(.latest) { _ in
                        return self.taskRepository.retrieveTasks()
                    }.observeCompleted {}
                    self.dismiss(animated: true, completion: nil)
                })
                alert.setCloseAction(title: L10n.close, handler: {})
                alert.show()
        }
        ).start()
    }
    
    private func showBrokenChallengeDialog() {
        taskRepository.getChallengeTasks(id: task.challengeID ?? "").take(first: 1).on(value: { tasks in
            let taskCount = tasks.value.count
            let alert = HabiticaAlertController(title: L10n.brokenChallenge, message: L10n.brokenChallengeDescription(taskCount))
            alert.addAction(title: L10n.keepXTasks(taskCount), style: .default, isMainAction: true) { _ in
                self.taskRepository.unlinkAllTasks(challengeID: self.task.challengeID ?? "", keepOption: "keep-all").observeCompleted {}
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(title: L10n.deleteXTasks(taskCount), style: .destructive) { _ in
                self.taskRepository.unlinkAllTasks(challengeID: self.task.challengeID ?? "", keepOption: "remove-all").observeCompleted {}
                self.dismiss(animated: true, completion: nil)
            }
            alert.setCloseAction(title: L10n.close, handler: {})
            alert.show()
            }).start()
    }
}
