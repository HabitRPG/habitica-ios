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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header.font(.system(size: 13, weight: .semibold)).foregroundColor(Color(ThemeService.shared.theme.quadTextColor)).padding(.leading, 14)
            content.frame(maxWidth: .infinity).background(Color(ThemeService.shared.theme.windowBackgroundColor)).cornerRadius(8)
        }
    }
}

struct DifficultyPicker: View {
    @Binding var selectedDifficulty: Float
    var tintColor: Color
    
    private let theme = ThemeService.shared.theme
    
    @ViewBuilder
    func difficultyOption(text: String, value: Float) -> some View {
        VStack {
            let isActive = value == selectedDifficulty
            Image(uiImage: HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: tintColor.uiColor(), difficulty: value == 0.1 ? 0.1 : CGFloat(value), isActive: isActive))
                .animation(.easeInOut)
            Text(text)
                .font(.system(size: 15, weight: isActive ? .semibold : .regular))
                .foregroundColor(isActive ? tintColor : Color(theme.ternaryTextColor))
                .frame(maxWidth: .infinity)
        }.onTapGesture {
            selectedDifficulty = value
        }.frame(maxWidth: .infinity)
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

struct TagList: View {
    @Binding var selectedTags: [TagProtocol]
    var allTags: [TagProtocol]
    
    var body: some View {
        VStack {
            ForEach(allTags, id: \.id) { tag in
                HStack {
                    Text(tag.text ?? "")
                    if selectedTags.contains { $0.id == tag.id } {
                        Spacer()
                        
                    }
                }

            }
        }
    }
}

struct TaskFormView: View {
    @State private var isEditingText = false
    @State private var isEditingNotes = false
    
    private let tags: [TagProtocol] = []
    
    var isCreating: Bool
    var taskType: TaskType
    var taskTintColor: Color = Color(.purple300)
    var darkTaskTintColor: Color = Color(.purple200)
    var lightTaskTintColor: Color = Color(.purple400)
    var darkestTaskTintColor: Color = Color(UIColor(white: 1, alpha: 0.7))
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    var task: TaskProtocol? {
        didSet {
            _text = State(initialValue: task?.text ?? "")
            _notes = State(initialValue: task?.notes ?? "")
            _priority = State(initialValue: task?.priority ?? 1.0)
            _frequency = State(initialValue: task?.frequency ?? "")
        }
    }
    
    @State var text: String = ""
    @State var notes: String = ""
    @State var priority: Float = 1.0
    @State var frequency: String = "daily"
    @State var stat: String = "strength"
    
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
    private static let statAllocationOptions = [
        LabeledFormValue<String>(value: "strength", label: "STR"),
        LabeledFormValue<String>(value: "intelligence", label: "INT"),
        LabeledFormValue<String>(value: "perception", label: "PER"),
            LabeledFormValue<String>(value: "constitution", label: "CON")
    ]
    
    private var navigationTitle: String {
        if isCreating {
            return L10n.Tasks.Form.create(taskType.prettyName())
        } else {
            return L10n.Tasks.Form.edit(taskType.prettyName())
        }
    }
    
    var body: some View {
        let theme = ThemeService.shared.theme
        ScrollView {
            VStack {
                VStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.title).foregroundColor(darkestTaskTintColor).font(.body).padding(.leading, 8)
                        TextField("", text: $text)
                            .padding(8)
                            .frame(minHeight: 40)
                            .foregroundColor(isEditingText ? .white : darkestTaskTintColor)
                            .background(darkTaskTintColor)
                            .cornerRadius(12)
                        Text(L10n.notes).foregroundColor(darkestTaskTintColor).font(.body).padding(.leading, 8).padding(.top, 10)
                        TextField("", text: $notes)
                            .padding(8)
                            .frame(minHeight: 40)
                            .foregroundColor(isEditingNotes ? .white : darkestTaskTintColor)
                            .background(darkTaskTintColor)
                            .cornerRadius(12)
                    }.padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    VStack(spacing: 25) {
                        TaskFormSection(header: Text(L10n.Tasks.Form.difficulty.uppercased()),
                                        content: DifficultyPicker(selectedDifficulty: $priority, tintColor: taskTintColor).padding(8))
                        if taskType == .habit {
                            TaskFormSection(header: Text(L10n.Tasks.Form.resetStreak.uppercased()),
                                            content: TaskFormPicker(options: TaskFormView.habitResetStreakOptions, selection: $frequency, tintColor: lightTaskTintColor))
                        }
                        TaskFormSection(header: Text(L10n.statAllocation.uppercased()),
                                        content: TaskFormPicker(options: TaskFormView.statAllocationOptions, selection: $stat, tintColor: lightTaskTintColor))
                        TaskFormSection(header: Text(L10n.Tasks.Form.tags.uppercased()),
                                        content: TagList(selectedTags: .constant([]), allTags: tags))
                    }.padding(16).background(Color(theme.contentBackgroundColor).edgesIgnoringSafeArea(.bottom)).cornerRadius(8)
                }.background(taskTintColor.cornerRadius(12).edgesIgnoringSafeArea(.bottom))
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color(theme.contentBackgroundColor).edgesIgnoringSafeArea(.bottom).padding(.top, 40))
        .navigationBarTitle(navigationTitle)
    }
}

class TaskFormController: UIHostingController<TaskFormView> {
    var taskType: TaskType = .habit
    var editedTask: TaskProtocol?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: TaskFormView(isCreating: editedTask != nil,
                                                           taskType: taskType,
                                                           taskTintColor: Color(editedTask != nil ? .forTaskValue(editedTask?.value ?? 0) : .purple300),
                                                           lightTaskTintColor: Color(editedTask != nil ? .forTaskValueLight(editedTask?.value ?? 0) : .purple400),
                                                           darkestTaskTintColor: Color(editedTask != nil ? .forTaskValueDarkest(editedTask?.value ?? 0) : UIColor(white: 1, alpha: 0.7)),
                                                           task: PreviewTask()))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let color = editedTask != nil ? UIColor.forTaskValueDark(editedTask?.value ?? 0) : .purple200
        rootView.isCreating = editedTask != nil
        rootView.taskType = taskType
        rootView.task = editedTask
        rootView.taskTintColor = Color(editedTask != nil ? .forTaskValue(editedTask?.value ?? 0) : .purple300)
        rootView.lightTaskTintColor = Color(editedTask != nil ? .forTaskValueLight(editedTask?.value ?? 0) : .purple400)
        rootView.darkTaskTintColor = Color(color)

        rootView.darkestTaskTintColor = Color(editedTask != nil ? .forTaskValueDarkest(editedTask?.value ?? 0) : UIColor(white: 1, alpha: 0.7))
        if let controller = navigationController as? ThemedNavigationController {
            controller.navigationBarColor = color
            controller.textColor = .white
            controller.navigationBar.isTranslucent = false
            controller.navigationBar.shadowImage = UIImage()
        }
        view.backgroundColor = color
    }
}

struct TaskFormView_Previews: PreviewProvider {
    static var previews: some View {
        TaskFormView(isCreating: false, taskType: .habit, task: PreviewTask())
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
