//
//  TaskFormView.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.06.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

struct TaskFormView: View {
    @ObservedObject var themeService = ThemeService.shared
    @Environment(\.presentationMode)
    var presentationMode
    @State private var isEditingText = false
    @State private var isEditingNotes = false
    @State private var isEditingCounterUp = false
    @State private var isEditingCounterDown = false

    var tags: [TagProtocol] = []
    
    @ObservedObject var viewModel: TaskFormViewModel
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    private static let habitResetStreakOptions = [
        LabeledFormValue<String>(value: "daily", label: L10n.daily),
        LabeledFormValue<String>(value: "weekly", label: L10n.weekly),
        LabeledFormValue<String>(value: "monthly", label: L10n.monthly)
    ]
    private static let statAllocationOptions = [
        LabeledFormValue<String>(value: "str", label: "STR"),
        LabeledFormValue<String>(value: "int", label: "INT"),
        LabeledFormValue<String>(value: "per", label: "PER"),
            LabeledFormValue<String>(value: "con", label: "CON")
    ]
    
    private var navigationTitle: String {
        if viewModel.isCreating {
            return L10n.Tasks.Form.create(viewModel.taskType.prettyName())
        } else {
            return L10n.Tasks.Form.edit(viewModel.taskType.prettyName())
        }
    }
    
    private var shouldShowKeyboardInitially: Bool {
        return viewModel.isCreating
    }
    
    private var textFields: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(L10n.title).foregroundStyle(viewModel.darkestTaskTintColor).font(.system(size: 13, weight: isEditingText ? .semibold : .regular)).padding(.leading, 8)
                if !viewModel.isTaskEditable {
                    Image(uiImage: HabiticaIcons.imageOfLocked().withRenderingMode(.alwaysTemplate)).foregroundStyle(viewModel.darkestTaskTintColor)
                }
            }
            MultilineTextField("", text: $viewModel.text, onCommit: {
            }, onEditingChanged: { isEditing in
                isEditingText = isEditing
            }, giveInitialResponder: shouldShowKeyboardInitially,
                               textColor: isEditingText ? viewModel.textFieldTintColor : viewModel.textFieldTintColor.opacity(0.75))
            .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(minHeight: 40)
                .background(viewModel.lightestTaskTintColor)
                .cornerRadius(UIConstants.largeCornerRadius)
                .disabled(!viewModel.isTaskEditable)
                .opacity(viewModel.isTaskEditable ? 1.0 : 0.6)
            Text(L10n.notes).foregroundStyle(viewModel.darkestTaskTintColor).font(.system(size: 13, weight: isEditingNotes ? .semibold : .regular)).padding(.leading, 8).padding(.top, 10)
            MultilineTextField("", text: $viewModel.notes, onEditingChanged: { isEditing in
                isEditingNotes = isEditing
            },
                               textColor: isEditingNotes ? viewModel.textFieldTintColor : viewModel.textFieldTintColor.opacity(0.75))
            .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(minHeight: 40)
                .background(viewModel.lightestTaskTintColor)
                .cornerRadius(UIConstants.largeCornerRadius)
        }.padding(.horizontal, 16)
        .padding(.vertical, 12)
        .preferredColorScheme(themeService.theme.isDark ? .dark : .light)
    }
    
    @ViewBuilder private var graphs: some View {
        if viewModel.taskType == .daily && viewModel.showTaskGraphs, let task = viewModel.task {
            TaskFormSection(header: Text(L10n.Tasks.Form.completion.uppercased()),
                            content: DailyProgressView(history: task.history), backgroundColor: .clear)
        } else if viewModel.taskType == .habit && viewModel.showTaskGraphs, let task = viewModel.task {
            TaskFormSection(header: Text(L10n.Tasks.Form.completion.uppercased()),
                            content: HabitProgressView(history: task.history, up: viewModel.up, down: viewModel.down), backgroundColor: .clear)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            viewModel.onTaskDelete?()
        }, label: {
            Text(L10n.delete).frame(height: 45)
        }).buttonStyle { configuration in
            configuration.label
                .foregroundStyle(Color(themeService.theme.errorColor))
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity).background(Color(themeService.theme.errorColor.withAlphaComponent(0.14)).cornerRadius(UIConstants.largeCornerRadius))
        }
    }
    
    @ViewBuilder private var dynamicFormPart: some View {
        if viewModel.taskType == .habit && viewModel.isTaskEditable {
            TaskFormSection(header: Text(L10n.Tasks.Form.controls.localizedCapitalized),
                            content: HabitControlsFormView(taskColor: viewModel.pickerTintColor, isUp: $viewModel.up, isDown: $viewModel.down), backgroundColor: .clear)
        } else if viewModel.taskType == .reward && viewModel.isTaskEditable {
            TaskFormSection(header: Text(L10n.Tasks.Form.cost.localizedCapitalized),
                            content: PlusMinusStepperView(amount: $viewModel.value, icon: Image(uiImage: HabiticaIcons.imageOfGold)), backgroundColor: .clear)
        } else if viewModel.taskType == .daily {
            TaskFormSection(header: Text(L10n.Tasks.Form.scheduling.localizedCapitalized),
                            content: DailySchedulingView(isEditable: viewModel.isTaskEditable,
                                                         startDate: $viewModel.startDate,
                                                         frequency: $viewModel.frequency,
                                                         everyX: $viewModel.everyX,
                                                         monday: $viewModel.monday,
                                                         tuesday: $viewModel.tuesday,
                                                         wednesday: $viewModel.wednesday,
                                                         thursday: $viewModel.thursday,
                                                         friday: $viewModel.friday,
                                                         saturday: $viewModel.saturday,
                                                         sunday: $viewModel.sunday,
                                                         daysOfMonth: $viewModel.daysOfMonth,
                                                         weeksOfMonth: $viewModel.weeksOfMonth,
                                                         dayOrWeekMonth: $viewModel.dayOrWeekMonth,
                                                         tintColor: viewModel.taskTintColor,
                                                         pickerTintColor: viewModel.pickerTintColor
                                                         ))
        } else if viewModel.taskType == .todo && viewModel.isTaskEditable {
            TaskFormSection(header: Text(L10n.Tasks.Form.scheduling.localizedCapitalized),
                            content: DueDateFormView(date: $viewModel.dueDate))
        }
    }
    
    @ViewBuilder private var habitCounterSection: some View {
        TaskFormSection(header: Text(L10n.Tasks.Form.adjustCounter.localizedCapitalized),
                        content: VStack(spacing: 12) {
            FormRow(title: Text(L10n.Tasks.Form.positive), valueLabel: PlusMinusStepperView(amount: $viewModel.counterUp, icon: EmptyView(), minAmount: 0), embedValueLabel: false)
            FormRow(title: Text(L10n.Tasks.Form.negative), valueLabel: PlusMinusStepperView(amount: $viewModel.counterDown, icon: EmptyView(), minAmount: 0), embedValueLabel: false
            )
        }, backgroundColor: .clear)
    }
    
    var body: some View {
        let theme = themeService.theme
        ScrollView {
            if viewModel.task == nil || viewModel.task?.isValid == true {
                VStack {
                    VStack {
                        textFields
                        VStack(spacing: 25) {
                            graphs
                            if viewModel.taskType == .daily || viewModel.taskType == .todo {
                                TaskFormChecklistView(items: $viewModel.checklistItems)
                            }
                            dynamicFormPart
                            if viewModel.taskType != .reward && viewModel.isTaskEditable {
                                TaskFormSection(header: Text(L10n.Tasks.Form.difficulty.localizedCapitalized),
                                                content: DifficultyPicker(selectedDifficulty: $viewModel.priority, tintColor: viewModel.pickerTintColor), backgroundColor: .clear)
                            }
                            if viewModel.taskType == .daily || viewModel.taskType == .todo {
                                TaskFormReminderView(showDate: viewModel.taskType == .todo, items: $viewModel.reminders)
                            }
                            if viewModel.showStatAllocation && viewModel.isTaskEditable {
                                TaskFormSection(header: Text(L10n.assignedStat.localizedCapitalized),
                                                content: TaskFormPicker(options: TaskFormView.statAllocationOptions, selection: $viewModel.stat, tintColor: viewModel.pickerTintColor))
                            }
                            if viewModel.taskType == .habit {
                                TaskFormSection(header: Text(L10n.Tasks.Form.resetCounter.localizedCapitalized),
                                                content: TaskFormPicker(options: TaskFormView.habitResetStreakOptions, selection: $viewModel.frequency, tintColor: viewModel.pickerTintColor))
                            }
                            if viewModel.taskType == .daily && viewModel.task?.id != nil {
                                TaskFormSection(header: Text(L10n.Tasks.Form.adjustStreak.localizedCapitalized),
                                                content: PlusMinusStepperView(amount: $viewModel.streak, icon: EmptyView(), minAmount: 0), backgroundColor: .clear)
                            } else if viewModel.taskType == .habit && viewModel.task?.id != nil {
                                habitCounterSection
                            }
                            TaskFormSection(header: Text(L10n.Tasks.Form.tags.localizedCapitalized),
                                            content: TagList(selectedTags: $viewModel.selectedTags, allTags: tags, taskColor: viewModel.taskTintColor))
                            if viewModel.task?.id != nil {
                                deleteButton
                            }
                            if !viewModel.isTaskEditable {
                                Text(L10n.Tasks.Form.notEditableDisclaimer)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                                    .foregroundStyle(Color(theme.quadTextColor))
                                    .font(.caption)
                            }
                        }.padding(16).background(Color(theme.contentBackgroundColor).edgesIgnoringSafeArea(.bottom)).cornerRadius(UIConstants.largeCornerRadius)
                    }.background(viewModel.backgroundTintColor.cornerRadius(UIConstants.largeCornerRadius).edgesIgnoringSafeArea(.bottom))
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .tint(viewModel.taskTintColor)
        .frame(maxHeight: .infinity)
        .background(Color(theme.contentBackgroundColor).edgesIgnoringSafeArea(.bottom).padding(.top, 200))
        .navigationBarTitle(navigationTitle)
    }
}

protocol ChallengeTaskFormDelegate {
    func updated(taskType: TaskType, task: TaskProtocol)
    func created(taskType: TaskType, task: TaskProtocol)
    func deleted(taskType: TaskType, task: TaskProtocol)
}

class TaskFormController: UIHostingController<TaskFormView> {
    private let userRepository = UserRepository()
    private let taskRepository = TaskRepository()
    private let configRepository = ConfigRepository.shared
    
    private let viewModel = TaskFormViewModel()
    
    var challengeTaskDelegate: ChallengeTaskFormDelegate?
    
    var taskType: TaskType = .habit {
        didSet {
            viewModel.taskType = taskType
        }
    }
    var editedTask: TaskProtocol? {
        didSet {
            let color = editedTask != nil ? UIColor.forTaskValueLight(editedTask?.value ?? 0) : .purple300
            viewModel.isCreating = editedTask == nil
            viewModel.task = editedTask
            
            viewModel.onTaskDelete = {[weak self] in
                self?.confirmTaskDeletion()
            }
            viewModel.lightTaskTintColor = Color(editedTask != nil ? .forTaskValueLight(editedTask?.value ?? 0) : .purple400)
            var tintColor: UIColor = editedTask != nil ? .forTaskValueLight(editedTask?.value ?? 0) : .purple300
            if tintColor == .yellow100 {
                tintColor = .yellow10
                viewModel.pickerTintColor = Color(.yellow10)
            } else {
                viewModel.pickerTintColor = viewModel.lightTaskTintColor
            }
            if ThemeService.shared.theme.isDark && tintColor == .purple300 {
                tintColor = .purple500
            }
            viewModel.taskTintColor = Color(tintColor)
            viewModel.backgroundTintColor = Color(editedTask != nil ? .forTaskValueLight(editedTask?.value ?? 0) : .purple300)
            viewModel.darkTaskTintColor = Color(color)
            viewModel.lightestTaskTintColor = Color(editedTask != nil ? .forTaskValueExtraLight(editedTask?.value ?? 0) : .purple500)

            viewModel.showTaskGraphs = configRepository.bool(variable: .showTaskGraphs)
            let darkestColor: UIColor = editedTask != nil ? .forTaskValueDarkest(editedTask?.value ?? 0) : .white
            viewModel.darkestTaskTintColor = Color(darkestColor)
            viewModel.textFieldTintColor = editedTask != nil ? viewModel.darkestTaskTintColor : Color(.purple10)
            
            if let controller = navigationController as? ThemedNavigationController {
                if #unavailable(iOS 26.0) {
                    controller.navigationBarColor = color
                    controller.navigationBar.tintColor = darkestColor
                    controller.navigationBar.isTranslucent = false
                    controller.navigationBar.shadowImage = UIImage()
                }
                controller.textColor = darkestColor
            }
            view.backgroundColor = color
            
            if editedTask != nil {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.save, style: .plain, target: self, action: #selector(rightButtonTapped))
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.create, style: .plain, target: self, action: #selector(rightButtonTapped))
            }
            if ThemeService.shared.theme.isDark {
                navigationItem.rightBarButtonItem?.tintColor = .white
                navigationItem.leftBarButtonItem?.tintColor = .white
                if #available(iOS 26.0, *) {
                    navigationItem.leftBarButtonItem?.style = .prominent
                    navigationItem.rightBarButtonItem?.style = .prominent
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: TaskFormView(viewModel: viewModel))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskRepository.getTags().on(value: {[weak self] tags in
            self?.rootView.tags = tags.value
        }).start()
        view.backgroundColor = .purple200
        if ThemeService.shared.theme.isDark && viewModel.taskTintColor.uiColor() == .purple300 {
            viewModel.taskTintColor = Color(.purple500)
        }
        userRepository.getUser().on(value: {[weak self] user in
            self?.viewModel.showStatAllocation = user.preferences?.allocationMode == "taskbased"
        }).start()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: L10n.cancel, style: .plain, target: self, action: #selector(leftButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.save, style: .plain, target: self, action: #selector(rightButtonTapped))
        
        _ = viewModel.$text.receive(on: DispatchQueue.main)
            .sink { text in
                self.navigationItem.rightBarButtonItem?.isEnabled = !text.isEmpty
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let controller = navigationController as? ThemedNavigationController, editedTask == nil {
            if #unavailable(iOS 26.0) {
                controller.navigationBarColor = .purple200
                controller.navigationBar.tintColor = .white
                controller.navigationBar.isTranslucent = false
                controller.navigationBar.shadowImage = UIImage()
            }
            controller.textColor = .white
        }
    }
        
    @objc
    func rightButtonTapped() {
        if viewModel.text.isEmpty {
            return
        }
        if let delegate = challengeTaskDelegate {
            let task = updatedTask()
            if editedTask != nil {
                delegate.updated(taskType: taskType, task: task)
            } else {
                delegate.created(taskType: taskType, task: task)
            }
        } else {
            self.save()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func leftButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updatedTask() -> TaskProtocol {
        let task: TaskProtocol
        if let edited = editedTask {
            if edited.isManaged, let unmanaged = taskRepository.getEditableTask(id: editedTask?.id ?? "") {
                task = unmanaged
            } else {
                task = edited
            }
        } else {
            task = taskRepository.getNewTask()
        }
        if task.id == nil {
            task.id = UUID().uuidString
        }
        if task.createdAt == nil {
            task.createdAt = Date()
            task.order = -1
        }
        task.type = taskType.rawValue
        task.text = viewModel.text
        task.notes = viewModel.notes
        task.priority = viewModel.priority
        task.frequency = viewModel.frequency
        task.value = Float(viewModel.value)
        task.up = viewModel.up
        task.down = viewModel.down
        task.everyX = viewModel.everyX
        task.startDate = viewModel.startDate
        task.duedate = viewModel.dueDate
        task.tags = viewModel.selectedTags
        task.attribute = viewModel.stat
        
        task.streak = viewModel.streak
        task.counterUp = viewModel.counterUp
        task.counterDown = viewModel.counterDown
        
        task.daysOfMonth = []
        task.weeksOfMonth = []

        if let startDate = task.startDate, viewModel.frequency == "monthly" {
            if viewModel.dayOrWeekMonth == "week" {
                let day = Calendar.current.component(.day, from: startDate)
                let weekIndex = (day - 1) / 7
                task.weeksOfMonth.append(weekIndex)

                let dayOfWeek = Calendar.current.component(.weekday, from: startDate)
                task.weekRepeat?.monday = (dayOfWeek == 2)
                task.weekRepeat?.tuesday = (dayOfWeek == 3)
                task.weekRepeat?.wednesday = (dayOfWeek == 4)
                task.weekRepeat?.thursday = (dayOfWeek == 5)
                task.weekRepeat?.friday = (dayOfWeek == 6)
                task.weekRepeat?.saturday = (dayOfWeek == 7)
                task.weekRepeat?.sunday = (dayOfWeek == 1)
            } else {
                task.daysOfMonth.append(Calendar.current.component(.day, from: startDate))
            }
        }
        if !(viewModel.frequency == "monthly" && viewModel.dayOrWeekMonth == "week") {
            task.weekRepeat?.monday = viewModel.monday
            task.weekRepeat?.tuesday = viewModel.tuesday
            task.weekRepeat?.wednesday = viewModel.wednesday
            task.weekRepeat?.thursday = viewModel.thursday
            task.weekRepeat?.friday = viewModel.friday
            task.weekRepeat?.saturday = viewModel.saturday
            task.weekRepeat?.sunday = viewModel.sunday
        }
        
        task.checklist = viewModel.checklistItems
        task.reminders = viewModel.reminders
        return task
    }
    
    private func save() {
        let task = updatedTask()
        if editedTask != nil {
            taskRepository.updateTask(task).observeCompleted {}
        } else {
            taskRepository.createTask(task).observeCompleted {
                NotificationManager.showPendingOnboardingAchievement(key: "createdTask")
            }
        }
    }
    
    func confirmTaskDeletion() {
        let alert = HabiticaAlertController(title: L10n.deleteX(taskType.prettyName()), message: L10n.deleteTaskConfirmation)
        alert.addAction(title: L10n.deleteX(L10n.task), style: .destructive) { _ in
            if let task = self.editedTask {
                if let delegate = self.challengeTaskDelegate {
                    delegate.deleted(taskType: self.taskType, task: task)
                } else {
                    self.taskRepository.deleteTask(task).observeCompleted {
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
        alert.addCancelAction()
        alert.enqueue()
    }
}

struct TaskFormView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TaskFormViewModel()
        viewModel.task = PreviewTask()
        return Group {
            TaskFormView(tags: [PreviewTag(), PreviewTag(), PreviewTag()], viewModel: viewModel)
                .previewDisplayName("Habits")
            TaskFormView(tags: [PreviewTag(), PreviewTag(), PreviewTag()], viewModel: viewModel)
                .previewDisplayName("Dailies")
            TaskFormView(tags: [PreviewTag(), PreviewTag(), PreviewTag()], viewModel: TaskFormViewModel())
                .previewDisplayName("Todos")
            TaskFormView(tags: [PreviewTag(), PreviewTag(), PreviewTag()], viewModel: TaskFormViewModel())
                .previewDisplayName("Rewards")
        }
    }
}

extension Binding {
    init(_ source: Binding<Value?>, _ defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in
                source.wrappedValue = newValue
        })
    }
}
