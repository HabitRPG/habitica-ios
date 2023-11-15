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
            let accessibilityText = "Difficulty " + text + ", \(isActive ? "on" : "off")"
            if #available(iOS 14.0, *) {
                Group {
                    Image(uiImage: HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: .white, difficulty: value == 0.1 ? 0.1 : CGFloat(value), isActive: true).withRenderingMode(.alwaysTemplate))
                        .foregroundColor(isActive ? .accentColor : Color(ThemeService.shared.theme.dimmedColor))
                    Text(text)
                        .font(.system(size: 15, weight: isActive ? .semibold : .regular))
                        .foregroundColor(isActive ? color : Color(theme.ternaryTextColor))
                        .frame(maxWidth: .infinity)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityText)
                .accessibilityRemoveTraits(.isImage)
            } else {
                Group {
                    Image(uiImage: HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: .white, difficulty: value == 0.1 ? 0.1 : CGFloat(value), isActive: true).withRenderingMode(.alwaysTemplate))
                        .foregroundColor(isActive ? .accentColor : Color(ThemeService.shared.theme.dimmedColor))
                    Text(text)
                        .font(.system(size: 15, weight: isActive ? .semibold : .regular))
                        .foregroundColor(isActive ? color : Color(theme.ternaryTextColor))
                        .frame(maxWidth: .infinity)
                }
            }
            
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
            Group {
                Image(uiImage: icon)
                    .accessibilityHidden(true)
                Text(text)
                    .accessibilityHidden(true)
                    .font(.system(size: 15, weight: isActive.wrappedValue ? .semibold : .regular))
                    .foregroundColor(isActive.wrappedValue ? .accentColor : Color(theme.ternaryTextColor))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(text + " control, " + "\( isActive.wrappedValue ? "on": "off")")
            .accessibilityRemoveTraits(.isImage)
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
                    Text(tag.text ?? "TagName").font(.body).foregroundColor(isSelected ? .accentColor : Color(ThemeService.shared.theme.primaryTextColor))
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
    var action: (() -> Void)?
    
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

struct FormSheetSelector<TYPE: Equatable & Hashable>: View {
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
            return L10n.Tasks.Form.none
        }
    }
    
    var body: some View {
        VStack {
            FormRow(title: title, valueLabel: Text(valueText).foregroundColor(value != nil ? .accentColor : Color(ThemeService.shared.theme.dimmedTextColor))) {
                if value == nil {
                    value = Date()
                }
                withAnimation {
                    isOpen.toggle()
                }
            }
            if isOpen {
                    picker.datePickerStyle(GraphicalDatePickerStyle())
                        .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
            }
        }
    }
}

public struct FormTextFieldStyle: TextFieldStyle {
    // swiftlint:disable:next identifier_name
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
    }
}

struct DailySchedulingView: View {
    var isEditable: Bool
    @Binding var startDate: Date?
    @Binding var frequency: String
    @Binding var everyX: Int
    
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
            if everyX == 1 {
                return L10n.day
            } else {
                return L10n.days
            }
        case "weekly":
            if everyX == 1 {
                return L10n.week
            } else {
                return L10n.weeks
            }
        case "monthly":
            if everyX == 1 {
                return L10n.month
            } else {
                return L10n.months
            }
        case "yearly":
            if everyX == 1 {
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
            if isEditable {
                FormDatePicker(title: Text(L10n.Tasks.Form.startDate), value: $startDate)
                Separator()
                FormSheetSelector(title: Text(L10n.Tasks.Form.repeats), value: $frequency, options: DailySchedulingView.dailyRepeatOptions)
                Separator()
                NumberPickerFormView(title: Text(L10n.Tasks.Form.every), value: $everyX, minValue: 0, maxValue: 400, formatter: { value in
                    return "\(value) \(suffix.localizedCapitalized)"
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
            }
            Text(TaskRepeatablesSummaryInteractor().repeatablesSummary(frequency: frequency, everyX: everyX, monday: monday, tuesday: tuesday, wednesday: wednesday, thursday: thursday, friday: friday, saturday: saturday, sunday: sunday, startDate: startDate, daysOfMonth: nil, weeksOfMonth: nil))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(ThemeService.shared.theme.ternaryTextColor))
        }

    }
}

struct TaskFormReminderItemView: View {
    var item: ReminderProtocol
    var isExpanded: Bool
    var showDate: Bool
    var onDelete: () -> Void
    
    @State private var time: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    @ViewBuilder
    private func buildPicker(value: Binding<Date>) -> some View {
        DatePicker(selection: value,
                   displayedComponents: showDate ? [.date, .hourAndMinute] : [.hourAndMinute],
                          label: {
                   Text("")
                          })
            .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
    }
    
    init(item: ReminderProtocol, isExpanded: Bool, showDate: Bool, onDelete: @escaping () -> Void) {
        self.item = item
        self.isExpanded = isExpanded
        self.showDate = showDate
        self.onDelete = onDelete
        _time = State(initialValue: item.time ?? Calendar.current.date(bySetting: .second, value: 0, of: Date()) ?? Date())
    }
    
    private var timeProxy: Binding<Date> {
        Binding<Date>(get: { self.time }, set: {
            self.time = $0
            if !self.item.isManaged {
                self.item.time = $0
            }
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
                Spacer()
                buildPicker(value: timeProxy)
            }
        }.frame(maxWidth: .infinity).background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
        .transition(.opacity)
    }
}

struct TaskFormReminderView: View {
    var showDate: Bool
    private let taskRepository = TaskRepository()
    @Binding var items: [ReminderProtocol]
    
    @State private var expandedItem: ReminderProtocol?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Tasks.Form.reminders.uppercased()).font(.system(size: 13, weight: .semibold)).foregroundColor(Color(ThemeService.shared.theme.quadTextColor)).padding(.leading, 14)
            VStack(spacing: 8) {
                ForEach(items, id: \.id) { item in
                    TaskFormReminderItemView(item: item, isExpanded: item.id == expandedItem?.id, showDate: showDate) {
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
                    item.time = Date()
                    items.append(item)
                }, label: {
                    Text(L10n.Tasks.Form.newReminder).font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
                })
            }
        }.animation(.easeInOut)
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
    
    @Published var isTaskEditable: Bool = true

    @Published var text: String = ""
    @Published var notes: String = ""
    @Published var priority: Float = 1.0
    @Published var frequency: String = "daily"
    @Published var value: String = "0"
    @Published var stat: String = "str"
    @Published var up: Bool = true
    @Published var down: Bool = false
    @Published var everyX: Int = 1
    @Published var startDate: Date? = Date()
    @Published var dueDate: Date?
    @Published var selectedTags: [TagProtocol] = []
    
    @Published var streak: String = "0"
    @Published var counterUp: String = "0"
    @Published var counterDown: String = "0"
    
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
    @Published var textFieldTintColor: Color = Color(.purple10)
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
            _stat = Published(initialValue: task?.attribute ?? "str")
            _value = Published(initialValue: String(task?.value ?? 0))
            _up = Published(initialValue: task?.up ?? true)
            _down = Published(initialValue: task?.down ?? false)
            _everyX = Published(initialValue: task?.everyX ?? 1)
            _startDate = Published(initialValue: task?.startDate ?? Date())
            _dueDate = Published(initialValue: task?.duedate)
            
            _streak = Published(initialValue: String(task?.streak ?? 0))
            _counterUp = Published(initialValue: String(task?.counterUp ?? 0))
            _counterDown = Published(initialValue: String(task?.counterDown ?? 0))

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
            
            _isTaskEditable = Published(initialValue: task?.isEditable != false)
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
                .background(GeometryReader { _ -> Color in
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
    @State private var scrollViewContentOffset = CGFloat(0)

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
                Text(L10n.title).foregroundColor(viewModel.darkestTaskTintColor).font(.system(size: 13, weight: isEditingText ? .semibold : .regular)).padding(.leading, 8)
                if !viewModel.isTaskEditable {
                Image(uiImage: HabiticaIcons.imageOfLocked().withRenderingMode(.alwaysTemplate)).foregroundColor(viewModel.darkestTaskTintColor)
                }
            }
            MultilineTextField("", text: $viewModel.text, onCommit: {
            }, onEditingChanged: { isEditing in
                isEditingText = isEditing
            }, giveInitialResponder: shouldShowKeyboardInitially,
                               textColor: isEditingText ? viewModel.textFieldTintColor : viewModel.textFieldTintColor.opacity(0.75))
                .padding(8)
                .frame(minHeight: 40)
                .background(viewModel.lightestTaskTintColor)
                .cornerRadius(12)
                .disabled(!viewModel.isTaskEditable)
                .opacity(viewModel.isTaskEditable ? 1.0 : 0.6)
            Text(L10n.notes).foregroundColor(viewModel.darkestTaskTintColor).font(.system(size: 13, weight: isEditingNotes ? .semibold : .regular)).padding(.leading, 8).padding(.top, 10)
            MultilineTextField("", text: $viewModel.notes, onEditingChanged: { isEditing in
                isEditingNotes = isEditing
            },
                               textColor: isEditingNotes ? viewModel.textFieldTintColor : viewModel.textFieldTintColor.opacity(0.75))
                .padding(8)
                .frame(minHeight: 40)
                .background(viewModel.lightestTaskTintColor)
                .cornerRadius(12)
        }.padding(.horizontal, 16)
        .padding(.vertical, 12)
        .preferredColorScheme(ThemeService.shared.theme.isDark ? .dark : .light)
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
        if viewModel.taskType == .habit && viewModel.isTaskEditable {
            TaskFormSection(header: Text(L10n.Tasks.Form.controls.uppercased()),
                            content: HabitControlsFormView(taskColor: viewModel.lightTaskTintColor.uiColor(), isUp: $viewModel.up, isDown: $viewModel.down).padding(8))
            TaskFormSection(header: Text(L10n.Tasks.Form.resetCounter.uppercased()),
                            content: TaskFormPicker(options: TaskFormView.habitResetStreakOptions, selection: $viewModel.frequency, tintColor: viewModel.pickerTintColor))
        } else if viewModel.taskType == .reward && viewModel.isTaskEditable {
            TaskFormSection(header: Text(L10n.Tasks.Form.difficulty.uppercased()),
                            content: RewardAmountView(value: $viewModel.value), backgroundColor: .clear)
        } else if viewModel.taskType == .daily {
            TaskFormSection(header: Text(L10n.Tasks.Form.scheduling.uppercased()),
                            content: DailySchedulingView(isEditable: viewModel.isTaskEditable, startDate: $viewModel.startDate, frequency: $viewModel.frequency, everyX: $viewModel.everyX, monday: $viewModel.monday, tuesday: $viewModel.tuesday, wednesday: $viewModel.wednesday, thursday: $viewModel.thursday, friday: $viewModel.friday, saturday: $viewModel.saturday, sunday: $viewModel.sunday, daysOfMonth: $viewModel.daysOfMonth, weeksOfMonth: $viewModel.weeksOfMonth, dayOrWeekMonth: $viewModel.dayOrWeekMonth
                                                         ))
        } else if viewModel.taskType == .todo && viewModel.isTaskEditable {
            TaskFormSection(header: Text(L10n.Tasks.Form.scheduling.uppercased()),
                            content: DueDateFormView(date: $viewModel.dueDate))
        }
    }
    
    var body: some View {
        let theme = ThemeService.shared.theme
        TrackableScrollView(contentOffset: $scrollViewContentOffset.onChange { _ in
        }) {
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
                            TaskFormSection(header: Text(L10n.Tasks.Form.difficulty.uppercased()),
                                            content: DifficultyPicker(selectedDifficulty: $viewModel.priority).padding(8))
                        }
                        if viewModel.taskType == .daily || viewModel.taskType == .todo {
                            TaskFormReminderView(showDate: viewModel.taskType == .todo, items: $viewModel.reminders)
                            }
                        if viewModel.showStatAllocation && viewModel.isTaskEditable {
                            TaskFormSection(header: Text(L10n.statAllocation.uppercased()),
                                            content: TaskFormPicker(options: TaskFormView.statAllocationOptions, selection: $viewModel.stat, tintColor: viewModel.pickerTintColor))
                        }
                        if viewModel.taskType == .daily && viewModel.task?.id != nil {
                            TaskFormSection(header: Text(L10n.Tasks.Form.adjustStreak.uppercased()),
                                            content: FormRow(title: Text(L10n.streak), valueLabel: TextField(L10n.streak, text: $viewModel.streak)
                                                .multilineTextAlignment(.trailing)
                                                .keyboardType(.numberPad)))
                            
                        } else if viewModel.taskType == .habit && viewModel.task?.id != nil {
                            TaskFormSection(header: Text(L10n.Tasks.Form.adjustCounter.uppercased()),
                                            content: VStack {
                                FormRow(title: Text(L10n.Tasks.Form.positive), valueLabel: TextField(L10n.Tasks.Form.positive, text: $viewModel.counterUp)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.numberPad))
                                FormRow(title: Text(L10n.Tasks.Form.negative), valueLabel: TextField(L10n.Tasks.Form.negative, text: $viewModel.counterDown)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.numberPad))
                            })
                        }
                        TaskFormSection(header: Text(L10n.Tasks.Form.tags.uppercased()),
                                        content: TagList(selectedTags: $viewModel.selectedTags, allTags: tags, taskColor: viewModel.taskTintColor))
                        if viewModel.task?.id != nil {
                            deleteButton
                        }
                        if !viewModel.isTaskEditable {
                            Text(L10n.Tasks.Form.notEditableDisclaimer)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color(ThemeService.shared.theme.quadTextColor))
                                .font(.caption)
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
    private let userRepository = UserRepository()
    private let taskRepository = TaskRepository()
    private let configRepository = ConfigRepository.shared
    
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
        userRepository.getUser().on(value: {[weak self] user in
            self?.viewModel.showStatAllocation = user.preferences?.allocationMode == "taskbased"
        }).start()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: L10n.cancel, style: .plain, target: self, action: #selector(leftButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.save, style: .plain, target: self, action: #selector(rightButtonTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let controller = navigationController as? ThemedNavigationController, editedTask == nil {
            controller.navigationBarColor = .purple200
            controller.textColor = .white
            controller.navigationBar.tintColor = .white
            controller.navigationBar.isTranslucent = false
            controller.navigationBar.shadowImage = UIImage()
        }
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
        task.value = Float(viewModel.value) ?? 0
        task.up = viewModel.up
        task.down = viewModel.down
        task.everyX = viewModel.everyX
        task.startDate = viewModel.startDate
        task.duedate = viewModel.dueDate
        task.tags = viewModel.selectedTags
        task.attribute = viewModel.stat
        
        task.streak = Int(string: viewModel.streak) ?? 0
        task.counterUp = Int(string: viewModel.counterUp) ?? 0
        task.counterDown = Int(string: viewModel.counterDown) ?? 0
        
        task.weekRepeat?.monday = viewModel.monday
        task.weekRepeat?.tuesday = viewModel.tuesday
        task.weekRepeat?.wednesday = viewModel.wednesday
        task.weekRepeat?.thursday = viewModel.thursday
        task.weekRepeat?.friday = viewModel.friday
        task.weekRepeat?.saturday = viewModel.saturday
        task.weekRepeat?.sunday = viewModel.sunday
        task.daysOfMonth = []
        task.weeksOfMonth = []
        
        if let startDate = task.startDate {
            if viewModel.dayOrWeekMonth == "week" {
                task.weeksOfMonth.append(Calendar.current.component(.weekOfMonth, from: startDate)-1)
            } else {
                task.daysOfMonth.append(Calendar.current.component(.day, from: startDate))
            }
        }
        
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
