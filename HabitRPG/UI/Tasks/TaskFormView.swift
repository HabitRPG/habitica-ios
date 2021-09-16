//
//  TaskFormView.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.06.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

struct TaskFormSection<Header: View, Content: View>: View {
    let header: Header
    let content: Content
    var backgroundColor: Color = Color(ThemeService.shared.theme.windowBackgroundColor)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header.font(.system(size: 13, weight: .semibold)).foregroundColor(Color(ThemeService.shared.theme.quadTextColor)).padding(.leading, 14)
            content.frame(maxWidth: .infinity).background(backgroundColor.cornerRadius(8))
        }
    }
}

struct DifficultyPicker: View {
    @Binding var selectedDifficulty: Float
    
    private let theme = ThemeService.shared.theme
    
    @ViewBuilder
    func difficultyOption(text: String, value: Float) -> some View {
        let color: Color = .accentColor
        VStack {
            let isActive = value == selectedDifficulty
            Image(uiImage: HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: .white, difficulty: value == 0.1 ? 0.1 : CGFloat(value), isActive: true).withRenderingMode(.alwaysTemplate))
                .foregroundColor(isActive ? .accentColor : Color(ThemeService.shared.theme.dimmedColor))
            Text(text)
                .font(.system(size: 15, weight: isActive ? .semibold : .regular))
                .foregroundColor(isActive ? color : Color(theme.ternaryTextColor))
                .frame(maxWidth: .infinity)
        }.onTapGesture {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
            selectedDifficulty = value
        }
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        HStack {
            difficultyOption(text: L10n.Tasks.Form.trivial, value: 0.1)
            difficultyOption(text: L10n.Tasks.Form.easy, value: 1.0)
            difficultyOption(text: L10n.Tasks.Form.medium, value: 1.5)
            difficultyOption(text: L10n.Tasks.Form.hard, value: 2.0)
        }
    }
}

struct HabitControlsFormView: View {
    let taskColor: UIColor
    @Binding var isUp: Bool
    @Binding var isDown: Bool
    
    let theme = ThemeService.shared.theme

    private func buildOption(text: String, icon: UIImage, isActive: Binding<Bool>) -> some View {
        return VStack(spacing: 12) {
            Image(uiImage: icon)
            Text(text)
                .font(.system(size: 15, weight: isActive.wrappedValue ? .semibold : .regular))
                .foregroundColor(isActive.wrappedValue ? .accentColor : Color(theme.ternaryTextColor))
        }
        .padding(.top, 4)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
            isActive.wrappedValue.toggle()
        }
    }
    
    var body: some View {
        HStack {
            buildOption(text: L10n.Tasks.Form.positive, icon: HabiticaIcons.imageOfHabitControlPlus(taskTintColor: taskColor, isActive: isUp), isActive: $isUp)
            buildOption(text: L10n.Tasks.Form.negative, icon: HabiticaIcons.imageOfHabitControlMinus(taskTintColor: taskColor, isActive: isDown), isActive: $isDown)
        }
    }
}

struct Separator: View {
    var body: some View {
        Rectangle().fill(Color(ThemeService.shared.theme.separatorColor)).frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1).padding(.leading, 15)
    }
}

struct TagList: View {
    @Binding var selectedTags: [TagProtocol]
    var allTags: [TagProtocol]
    var taskColor: Color
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(allTags, id: \.id) { tag in
                let isSelected = selectedTags.contains { selectedTag in
                    return selectedTag.id == tag.id
                }
                HStack {
                    Text(tag.text ?? "TagName").font(.body).foregroundColor(isSelected ? .accentColor : .primary)
                    Spacer()
                    if isSelected {
                        Image(Asset.checkmarkSmall.name).foregroundColor(.accentColor)
                    }
                }
                .background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
                .frame(height: 45).padding(.horizontal, 14)
                .onTapGesture {
                    UISelectionFeedbackGenerator.oneShotSelectionChanged()
                    if isSelected {
                        selectedTags.removeAll { selectedTag in
                            return selectedTag.id == tag.id
                        }
                    } else {
                        selectedTags.append(tag)
                    }
                }
                if tag.id != allTags.last?.id {
                    Separator()
                }
            }
        }
    }
}

struct FormRow<TitleView: View, LabelView: View>: View {
    let title: TitleView
    let valueLabel: LabelView
    var action: (() -> Void)? = nil
    
    var body: some View {
        if let action = action {
            Button(action: action, label: {
                HStack {
                    title.foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                    Spacer()
                    valueLabel
                }.frame(height: 45).padding(.horizontal, 14)
            })
        } else {
            HStack {
                title.foregroundColor(.primary)
                Spacer()
                valueLabel.foregroundColor(.accentColor)
            }.frame(height: 45).padding(.horizontal, 14)
        }
    }
}

struct FormSheetSelector<TYPE: Equatable>: View {
    let title: Text
    @Binding var value: TYPE
    let options: [LabeledFormValue<TYPE>]
    
    @State var isOpen = false
    
    var body: some View {
        var buttons = options.map({ option in
            return ActionSheet.Button.default(Text(option.label)) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    value = option.value
                }
            }
        })
        
        buttons.append(.cancel())
        return FormRow(title: title, valueLabel: Text(options.first(where: { $0.value == value })?.label ?? ""), action: {
            withAnimation { isOpen.toggle() }
        })
        .actionSheet(isPresented: $isOpen, content: {
            ActionSheet(title: title, message: nil, buttons: buttons)
        })
    }
}

struct FormDatePicker<TitleView: View>: View {
    let title: TitleView
    @Binding var value: Date?

    @State var isOpen = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private var dateProxy: Binding<Date> {
        Binding<Date>(get: { self.value ?? Date() }, set: {
            self.value = $0
        })
    }
    
    @ViewBuilder
    private var picker: some View {
        DatePicker(selection: dateProxy,
                          displayedComponents: [.date],
                          label: {
                   title
                          })
    }
    
    private var valueText: String {
        if let date = value {
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    var body: some View {
        VStack {
            FormRow(title: title, valueLabel: Text(valueText)) {
                withAnimation {
                    isOpen.toggle()
                }
            }
            if isOpen {
                if #available(iOS 14.0, *) {
                    picker.datePickerStyle(GraphicalDatePickerStyle())
                } else {
                    picker.datePickerStyle(WheelDatePickerStyle())
                }
            }
        }
    }
}

struct DailySchedulingView: View {
    @Binding var startDate: Date?
    @Binding var frequency: String
    @Binding var everyX: String
    
    @Binding var monday: Bool
    @Binding var tuesday: Bool
    @Binding var wednesday: Bool
    @Binding var thursday: Bool
    @Binding var friday: Bool
    @Binding var saturday: Bool
    @Binding var sunday: Bool
    @Binding var daysOfMonth: [Int]
    @Binding var weeksOfMonth: [Int]
    @Binding var dayOrWeekMonth: String
    
    private static let dailyRepeatOptions = [
        LabeledFormValue<String>(value: "daily", label: L10n.daily),
        LabeledFormValue<String>(value: "weekly", label: L10n.weekly),
        LabeledFormValue<String>(value: "monthly", label: L10n.monthly),
        LabeledFormValue<String>(value: "yearly", label: L10n.yearly)
    ]
    
    private var suffix: String {
        switch frequency {
        case "daily":
            if everyX == "1" {
                return L10n.day
            } else {
                return L10n.days
            }
        case "weekly":
            if everyX == "1" {
                return L10n.week
            } else {
                return L10n.weeks
            }
        case "monthly":
            if everyX == "1" {
                return L10n.month
            } else {
                return L10n.months
            }
        case "yearly":
            if everyX == "1" {
                return L10n.year
            } else {
                return L10n.years
            }
        default:
            return ""
        }
    }
    
    private func weekOption(initial: String, isEnabled: Binding<Bool>) -> some View {
        return Text(initial).font(.system(size: 15))
            .foregroundColor(isEnabled.wrappedValue ? .white : Color(ThemeService.shared.theme.dimmedTextColor))
            .frame(width: 32, height: 32)
            .background(Circle().fill(isEnabled.wrappedValue ? Color.accentColor : Color(ThemeService.shared.theme.offsetBackgroundColor)))
            .animation(.easeInOut)
            .frame(maxWidth: .infinity)
            .onTapGesture {
                UISelectionFeedbackGenerator.oneShotSelectionChanged()
                withAnimation {
                    isEnabled.wrappedValue.toggle()
                }
            }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            FormDatePicker(title: Text(L10n.Tasks.Form.startDate), value: $startDate)
            Separator()
            FormSheetSelector(title: Text(L10n.Tasks.Form.repeats), value: $frequency, options: DailySchedulingView.dailyRepeatOptions)
            Separator()
            FormRow(title: Text(L10n.Tasks.Form.every), valueLabel: HStack {
                TextField("", text: $everyX).multilineTextAlignment(.trailing)
                Text(suffix.localizedCapitalized)
            })
            if frequency == "weekly" {
                Separator()
                HStack {
                    weekOption(initial: "M", isEnabled: $monday)
                    weekOption(initial: "T", isEnabled: $tuesday)
                    weekOption(initial: "W", isEnabled: $wednesday)
                    weekOption(initial: "T", isEnabled: $thursday)
                    weekOption(initial: "F", isEnabled: $friday)
                    weekOption(initial: "S", isEnabled: $saturday)
                    weekOption(initial: "S", isEnabled: $sunday)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.horizontal, 14).padding(.top, 10)
            }
            if frequency == "monthly" {
                Separator()
                TaskFormPicker(options: [
                    LabeledFormValue(value: "day", label: L10n.Tasks.Form.dayOfMonth),
                    LabeledFormValue(value: "week", label: L10n.Tasks.Form.dayOfWeek)
                ], selection: $dayOrWeekMonth)
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.horizontal, 12).padding(.top, 10)
            }
            Text(TaskRepeatablesSummaryInteractor().repeatablesSummary(frequency: frequency, everyX: Int(everyX), monday: monday, tuesday: tuesday, wednesday: wednesday, thursday: thursday, friday: friday, saturday: saturday, sunday: sunday, startDate: startDate, daysOfMonth: nil, weeksOfMonth: nil))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(ThemeService.shared.theme.ternaryTextColor))
        }

    }
}

struct TaskFormChecklistItemView: View {
    var item: ChecklistItemProtocol {
        didSet {
            text = item.text ?? ""
        }
    }
    let onDelete: () -> Void
    
    init(item: ChecklistItemProtocol, onDelete: @escaping () -> Void) {
        self.item = item
        self.onDelete = onDelete
        _text = State(initialValue: item.text ?? "")
    }
    
    @State private var text: String = ""
    
    var body: some View {
        HStack {
            Button(action: {
                onDelete()
            }, label: {
                Rectangle().fill(Color.white).frame(width: 9, height: 2)
                    .background(Circle().fill(Color.accentColor).frame(width: 21, height: 21))
                    .frame(width: 48, height: 48)
            })
            TextField("Enter your checklist line", text: $text, onEditingChanged: { _ in
                item.text = text
            })
        }.frame(maxWidth: .infinity).background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
        .transition(.opacity)
    }
}

struct TaskFormChecklistView: View {
    private let taskRepository = TaskRepository()
    @Binding var items: [ChecklistItemProtocol]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Tasks.Form.checklist.uppercased()).font(.system(size: 13, weight: .semibold)).foregroundColor(Color(ThemeService.shared.theme.quadTextColor)).padding(.leading, 14)
            VStack(spacing: 8) {
                ForEach(items, id: \.id) { item in
                    TaskFormChecklistItemView(item: item, onDelete: {
                        withAnimation {
                            if let index = items.firstIndex(where: { $0.id == item.id }) {
                                items.remove(at: index)
                            }
                        }
                    })
                }
                Button(action: {
                    let item = taskRepository.getNewChecklistItem()
                    item.id = UUID().uuidString
                    items.append(item)
                }, label: {
                    Text(L10n.Tasks.Form.newChecklistItem).font(.system(size: 15, weight: .semibold)).foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                }).frame(maxWidth: .infinity).frame(height: 48).background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
            }.animation(.easeInOut)
        }
    }
}

struct TaskFormReminderItemView: View {
    var item: ReminderProtocol
    var isExpanded: Bool
    var onDelete: () -> Void
    
    @State private var time: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
    
    @ViewBuilder
    private func buildPicker(value: Binding<Date>) -> some View {
        DatePicker(selection: value,
                   displayedComponents: [.hourAndMinute],
                          label: {
                   Text("")
                          })
    }
    
    init(item: ReminderProtocol, isExpanded: Bool, onDelete: @escaping () -> Void) {
        self.item = item
        self.isExpanded = isExpanded
        self.onDelete = onDelete
        _time = State(initialValue: item.time ?? Date())
    }
    
    private var timeProxy: Binding<Date> {
        Binding<Date>(get: { self.time }, set: {
            self.time = $0
            self.item.time = $0
        })
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    onDelete()
                }, label: {
                    Rectangle().fill(Color.white).frame(width: 9, height: 2)
                        .background(Circle().fill(Color.accentColor).frame(width: 21, height: 21))
                        .frame(width: 48, height: 48)
                })
                Text(dateFormatter.string(from: time))
                Spacer()
            }
            if isExpanded {
                buildPicker(value: timeProxy).datePickerStyle(WheelDatePickerStyle())
            }
        }.frame(maxWidth: .infinity).background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
        .transition(.opacity)
    }
}

struct TaskFormReminderView: View {
    private let taskRepository = TaskRepository()
    @Binding var items: [ReminderProtocol]
    
    @State private var expandedItem: ReminderProtocol?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Tasks.Form.reminders.uppercased()).font(.system(size: 13, weight: .semibold)).foregroundColor(Color(ThemeService.shared.theme.quadTextColor)).padding(.leading, 14)
            VStack(spacing: 8) {
                ForEach(items, id: \.id) { item in
                    TaskFormReminderItemView(item: item, isExpanded: item.id == expandedItem?.id) {
                        withAnimation {
                            if let index = items.firstIndex(where: { $0.id == item.id }) {
                                items.remove(at: index)
                            }
                        }
                    }.onTapGesture {
                        withAnimation {
                            if expandedItem?.id == item.id {
                                expandedItem = nil
                            } else {
                                expandedItem = item
                            }
                        }
                    }
                }
                Button(action: {
                    let item = taskRepository.getNewReminder()
                    item.id = UUID().uuidString
                    items.append(item)
                }, label: {
                    Text(L10n.Tasks.Form.newReminder).font(.system(size: 15, weight: .semibold)).foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                }).frame(maxWidth: .infinity).frame(height: 48).background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
            }.animation(.easeInOut)
        }
    }
}

struct RewardAmountView: View {
    @Binding var value: String
    
    var body: some View {
        HStack {
            Button(action: {
                let intValue = (Int(value) ?? 0) + 1
                value = String(intValue)
            }, label: {
                Image(uiImage: Asset.plus.image.withRenderingMode(.alwaysTemplate)).frame(width: 50, height: 50)
            })
            HStack {
                Image(uiImage: HabiticaIcons.imageOfGold)
                TextField("", text: $value)
            }.padding(.horizontal, 16).frame(width: 112, height: 50)
                .background(Color(ThemeService.shared.theme.windowBackgroundColor))
            .border(Color(ThemeService.shared.theme.separatorColor), width: 1)
            .cornerRadius(8)
            Button(action: {
                let intValue = (Int(value) ?? 1) - 1
                value = String(intValue)
            }, label: {
                Image(uiImage: Asset.minus.image.withRenderingMode(.alwaysTemplate)).frame(width: 50, height: 50)
            })
        }
    }
}

class TaskFormViewModel: ObservableObject {
    private let taskRepository = TaskRepository()

    @Published var text: String = ""
    @Published var notes: String = ""
    @Published var priority: Float = 1.0
    @Published var frequency: String = "daily"
    @Published var value: String = "1"
    @Published var stat: String = "strength"
    @Published var up: Bool = true
    @Published var down: Bool = false
    @Published var everyX: String = "1"
    @Published var startDate: Date? = Date()
    @Published var dueDate: Date?
    @Published var selectedTags: [TagProtocol] = []
    
    @Published var monday: Bool = true
    @Published var tuesday: Bool = true
    @Published var wednesday: Bool = true
    @Published var thursday: Bool = true
    @Published var friday: Bool = true
    @Published var saturday: Bool = true
    @Published var sunday: Bool = true
    @Published var daysOfMonth: [Int] = []
    @Published var weeksOfMonth: [Int] = []
    @Published var dayOrWeekMonth: String = "day"
    
    @Published var checklistItems: [ChecklistItemProtocol] = []
    @Published var reminders: [ReminderProtocol] = []
    
    @Published var isCreating: Bool = true
    @Published var taskType: TaskType = .habit
    @Published var taskTintColor: Color = Color(.purple300)
    @Published var backgroundTintColor: Color = Color(.purple300)
    @Published var darkTaskTintColor: Color = Color(.purple200)
    @Published var lightTaskTintColor: Color = Color(.purple400)
    @Published var pickerTintColor: Color = Color(.purple400)
    @Published var darkestTaskTintColor: Color = Color(UIColor(white: 1, alpha: 0.7))
    @Published var lightestTaskTintColor: Color = Color(.purple500)
    @Published var showStatAllocation = false
    @Published var showTaskGraphs = false
    
    var onTaskDelete: (() -> Void)?
    
    var task: TaskProtocol? {
        didSet {
            _text = Published(initialValue: task?.text ?? "")
            _notes = Published(initialValue: task?.notes ?? "")
            _priority = Published(initialValue: task?.priority ?? 1.0)
            _frequency = Published(initialValue: task?.frequency ?? "daily")
            _value = Published(initialValue: String(task?.value ?? 1))
            _up = Published(initialValue: task?.up ?? true)
            _down = Published(initialValue: task?.down ?? false)
            _everyX = Published(initialValue: String(task?.everyX ?? 1))
            _startDate = Published(initialValue: task?.startDate ?? Date())
            _dueDate = Published(initialValue: task?.duedate)

            _selectedTags = Published(initialValue: task?.tags ?? [])
            
            _monday = Published(initialValue: task?.weekRepeat?.monday ?? true)
            _tuesday = Published(initialValue: task?.weekRepeat?.tuesday ?? true)
            _wednesday = Published(initialValue: task?.weekRepeat?.wednesday ?? true)
            _thursday = Published(initialValue: task?.weekRepeat?.thursday ?? true)
            _friday = Published(initialValue: task?.weekRepeat?.friday ?? true)
            _saturday = Published(initialValue: task?.weekRepeat?.saturday ?? true)
            _sunday = Published(initialValue: task?.weekRepeat?.sunday ?? true)
            _daysOfMonth = Published(initialValue: task?.daysOfMonth ?? [])
            _weeksOfMonth = Published(initialValue: task?.weeksOfMonth ?? [])
            if !weeksOfMonth.isEmpty {
                _dayOrWeekMonth = Published(initialValue: "week")
            }
            _checklistItems = Published(initialValue: task?.checklist.map({ item in
                return item.detached()
            }) ?? [])
            _reminders = Published(initialValue: task?.reminders.map({ item in
                return item.detached()
            }) ?? [])
        }
    }
}

struct DailyProgressView: View {
    let history: [TaskHistoryProtocol]
    
    private let theme = ThemeService.shared.theme
    private let today = Date()
    private let calendar = Calendar.current
    
    private let gray = Color(UIColor.gray400)
    
    @State private var dayItemHeight: CGFloat = 40
    
    @ViewBuilder
    private func icon(wasCompleted: Bool, wasActive: Bool) -> some View {
        if wasActive {
            if wasCompleted {
                Image(Asset.checkmarkSmall.name)
            } else {
                Image(Asset.close.name)
            }
        } else {
            if wasCompleted {
                Image(Asset.checkmarkSmall.name)
            } else {
                Text("")
            }
        }
    }
    
    @ViewBuilder
    private func dayItem(size: CGFloat, offset: Int) -> some View {
        let examinedDay = today.addingTimeInterval(-(Double(offset * 24 * 60 * 60)))
        
        let historyEntry = history.last { item in
            if let timestamp = item.timestamp {
                return Calendar.current.isDate(timestamp, inSameDayAs: examinedDay)
            }
            return false
        }
        let wasActive = historyEntry?.isDue ?? false
        let wasCompleted = historyEntry?.completed ?? false
        
        let day = calendar.component(.day, from: examinedDay)
        let color = wasCompleted ? Color(UIColor.green100) : Color(UIColor.red100)
        let borderColor = wasActive ? color : gray
        let width: CGFloat = wasActive ? 2 : 1
        VStack(alignment: .center, spacing: 5) {
            icon(wasCompleted: wasCompleted, wasActive: wasActive).frame(width: 8, height: 8).foregroundColor(color).padding(.top, 2)
            Text(String(day)).font(.system(size: 11)).foregroundColor(borderColor)
        }.frame(width: size, height: size, alignment: .center)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(borderColor, lineWidth: width)
        )
    }
    
    var body: some View {
        VStack {
            GeometryReader { reader in
                let size = (reader.size.width - 62) / 7
                HStack(spacing: 7) {
                    ForEach(0..<7) { offset in
                        dayItem(size: size, offset: 6 - offset)
                    }
                }.padding(.horizontal, 10).padding(.vertical, 10).background(Color(theme.windowBackgroundColor).cornerRadius(8))
                .background(GeometryReader { gp -> Color in
                    DispatchQueue.main.async {
                        self.dayItemHeight = size
                    }
                    return Color.clear
                })
            }.frame(height: dayItemHeight + 20)
        }
    }
}

struct TaskFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isEditingText = false
    @State private var isEditingNotes = false
    
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
        LabeledFormValue<String>(value: "strength", label: "STR"),
        LabeledFormValue<String>(value: "intelligence", label: "INT"),
        LabeledFormValue<String>(value: "perception", label: "PER"),
            LabeledFormValue<String>(value: "constitution", label: "CON")
    ]
    
    private var navigationTitle: String {
        if viewModel.isCreating {
            return L10n.Tasks.Form.create(viewModel.taskType.prettyName())
        } else {
            return L10n.Tasks.Form.edit(viewModel.taskType.prettyName())
        }
    }
    
    private var textFields: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L10n.title).foregroundColor(viewModel.darkestTaskTintColor).font(.system(size: 13, weight: isEditingText ? .semibold : .regular)).padding(.leading, 8)
            TextField("", text: $viewModel.text, onEditingChanged: { isEditing in
                isEditingText = isEditing
            })
                .padding(8)
                .frame(minHeight: 40)
                .foregroundColor(isEditingText ? viewModel.darkestTaskTintColor : viewModel.darkestTaskTintColor.opacity(0.75))
                .background(viewModel.lightestTaskTintColor)
                .cornerRadius(12)
            Text(L10n.notes).foregroundColor(viewModel.darkestTaskTintColor).font(.system(size: 13, weight: isEditingNotes ? .semibold : .regular)).padding(.leading, 8).padding(.top, 10)
            TextField("", text: $viewModel.notes, onEditingChanged: { isEditing in
                isEditingNotes = isEditing
            })
                .padding(8)
                .frame(minHeight: 40)
                .foregroundColor(isEditingNotes ? viewModel.darkestTaskTintColor : viewModel.darkestTaskTintColor.opacity(0.75))
                .background(viewModel.lightestTaskTintColor)
                .cornerRadius(12)
        }.padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var graphs: some View {
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
                .foregroundColor(Color(ThemeService.shared.theme.errorColor))
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity).background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
        })
    }
    
    @ViewBuilder
    private var dynamicFormPart: some View {
        if viewModel.taskType == .habit {
            TaskFormSection(header: Text(L10n.Tasks.Form.controls.uppercased()),
                            content: HabitControlsFormView(taskColor: viewModel.lightTaskTintColor.uiColor(), isUp: $viewModel.up, isDown: $viewModel.down).padding(8))
            TaskFormSection(header: Text(L10n.Tasks.Form.resetCounter.uppercased()),
                            content: TaskFormPicker(options: TaskFormView.habitResetStreakOptions, selection: $viewModel.frequency, tintColor: viewModel.pickerTintColor))
        } else if viewModel.taskType == .reward {
            TaskFormSection(header: Text(L10n.Tasks.Form.difficulty.uppercased()),
                            content: RewardAmountView(value: $viewModel.value), backgroundColor: .clear)
        } else if viewModel.taskType == .daily {
            TaskFormSection(header: Text(L10n.Tasks.Form.scheduling.uppercased()),
                            content: DailySchedulingView(startDate: $viewModel.startDate, frequency: $viewModel.frequency, everyX: $viewModel.everyX, monday: $viewModel.monday, tuesday: $viewModel.tuesday, wednesday: $viewModel.wednesday, thursday: $viewModel.thursday, friday: $viewModel.friday, saturday: $viewModel.saturday, sunday: $viewModel.sunday, daysOfMonth: $viewModel.daysOfMonth, weeksOfMonth: $viewModel.weeksOfMonth, dayOrWeekMonth: $viewModel.dayOrWeekMonth
                                                         ))
        } else if viewModel.taskType == .todo {
            TaskFormSection(header: Text(L10n.Tasks.Form.scheduling.uppercased()),
                            content: DueDateFormView(date: $viewModel.dueDate))
        }
    }
    
    var body: some View {
        let theme = ThemeService.shared.theme
        ScrollView {
            VStack {
                VStack {
                    textFields
                    VStack(spacing: 25) {
                        graphs
                        if viewModel.taskType == .daily || viewModel.taskType == .todo {
                            TaskFormChecklistView(items: $viewModel.checklistItems)
                        }
                        dynamicFormPart
                        if viewModel.taskType != .reward {
                            TaskFormSection(header: Text(L10n.Tasks.Form.difficulty.uppercased()),
                                            content: DifficultyPicker(selectedDifficulty: $viewModel.priority).padding(8))
                        }
                        if viewModel.taskType == .daily || viewModel.taskType == .todo {
                            TaskFormReminderView(items: $viewModel.reminders)
                            }
                        if viewModel.showStatAllocation {
                            TaskFormSection(header: Text(L10n.statAllocation.uppercased()),
                                            content: TaskFormPicker(options: TaskFormView.statAllocationOptions, selection: $viewModel.stat, tintColor: viewModel.pickerTintColor))
                        }
                        TaskFormSection(header: Text(L10n.Tasks.Form.tags.uppercased()),
                                        content: TagList(selectedTags: $viewModel.selectedTags, allTags: tags, taskColor: viewModel.taskTintColor))
                        if viewModel.task?.id != nil {
                            deleteButton
                        }
                    }.padding(16).background(Color(theme.contentBackgroundColor).edgesIgnoringSafeArea(.bottom)).cornerRadius(8)
                }.background(viewModel.backgroundTintColor.cornerRadius(12).edgesIgnoringSafeArea(.bottom))
            }
        }
        .accentColor(viewModel.taskTintColor)
        .frame(maxHeight: .infinity)
        .background(Color(theme.contentBackgroundColor).edgesIgnoringSafeArea(.bottom).padding(.top, 40))
        .navigationBarTitle(navigationTitle)
    }
}

class TaskFormController: UIHostingController<TaskFormView> {
    private let taskRepository = TaskRepository()
    private let configRepository = ConfigRepository()
    
    private let viewModel = TaskFormViewModel()
    
    var taskType: TaskType = .habit {
        didSet {
            viewModel.taskType = taskType
        }
    }
    var editedTask: TaskProtocol? {
        didSet {
            let color = editedTask != nil ? UIColor.forTaskValue(editedTask?.value ?? 0) : .purple200
            viewModel.isCreating = editedTask == nil
            viewModel.task = editedTask
            
            viewModel.onTaskDelete = {[weak self] in
                if let task = self?.editedTask {
                    self?.taskRepository.deleteTask(task).observeCompleted {
                    }
                }
                self?.dismiss(animated: true, completion: nil)
            }
            viewModel.lightTaskTintColor = Color(editedTask != nil ? .forTaskValueLight(editedTask?.value ?? 0) : .purple400)
            var tintColor: UIColor = editedTask != nil ? .forTaskValueLight(editedTask?.value ?? 0) : .purple300
            if tintColor == .yellow100 {
                tintColor = .yellow10
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
            
            if let controller = navigationController as? ThemedNavigationController {
                controller.navigationBarColor = color
                controller.textColor = darkestColor
                controller.navigationBar.tintColor = darkestColor
                controller.navigationBar.isTranslucent = false
                controller.navigationBar.shadowImage = UIImage()
            }
            view.backgroundColor = color
            
            if editedTask != nil {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.save, style: .plain, target: self, action: #selector(rightButtonTapped))
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.create, style: .plain, target: self, action: #selector(rightButtonTapped))
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
        
        if let controller = navigationController as? ThemedNavigationController, editedTask == nil {
            controller.navigationBarColor = .purple200
            controller.textColor = .white
            controller.navigationBar.isTranslucent = false
            controller.navigationBar.shadowImage = UIImage()
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: L10n.cancel, style: .plain, target: self, action: #selector(leftButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.save, style: .plain, target: self, action: #selector(rightButtonTapped))
    }
    
    @objc
    func rightButtonTapped() {
        self.save()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func leftButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func save() {
        let task = taskRepository.getEditableTask(id: editedTask?.id ?? "") ?? taskRepository.getNewTask()
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
        task.value = Float(viewModel.value) ?? 1
        task.up = viewModel.up
        task.down = viewModel.down
        task.everyX = Int(viewModel.everyX) ?? 1
        task.startDate = viewModel.startDate
        task.duedate = viewModel.dueDate
        task.tags = viewModel.selectedTags
        
        task.weekRepeat?.monday = viewModel.monday
        task.weekRepeat?.monday = viewModel.tuesday
        task.weekRepeat?.monday = viewModel.wednesday
        task.weekRepeat?.monday = viewModel.thursday
        task.weekRepeat?.monday = viewModel.friday
        task.weekRepeat?.monday = viewModel.saturday
        task.weekRepeat?.monday = viewModel.sunday
        task.daysOfMonth = viewModel.daysOfMonth
        task.weeksOfMonth = viewModel.weeksOfMonth
        
        task.checklist = viewModel.checklistItems
        task.reminders = viewModel.reminders
        
        if editedTask != nil {
            taskRepository.updateTask(task).observeCompleted {}
        } else {
            taskRepository.createTask(task).observeCompleted {}
        }
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

extension Color {
 
    func uiColor() -> UIColor {
        if #available(iOS 14.0, *) {
            return UIColor(self)
        }

        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            alpha = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (red, green, blue, alpha)
    }
}
