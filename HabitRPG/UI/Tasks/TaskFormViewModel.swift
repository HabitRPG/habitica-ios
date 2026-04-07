//
//  TaskFormViewModel.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

class TaskFormViewModel: ObservableObject {
    private let taskRepository = TaskRepository()
    
    @Published var isTaskEditable: Bool = true

    @Published var text: String = ""
    @Published var notes: String = ""
    @Published var priority: Float = 1.0
    @Published var frequency: String = "daily"
    @Published var value: Int = 0
    @Published var stat: String = "str"
    @Published var up: Bool = true
    @Published var down: Bool = false
    @Published var everyX: Int = 1
    @Published var startDate: Date? = Date()
    @Published var dueDate: Date?
    @Published var selectedTags: [TagProtocol] = []
    
    @Published var streak: Int = 0
    @Published var counterUp: Int = 0
    @Published var counterDown: Int = 0
    
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
            _value = Published(initialValue: Int(task?.value ?? 0))
            _up = Published(initialValue: task?.up ?? true)
            _down = Published(initialValue: task?.down ?? false)
            _everyX = Published(initialValue: task?.everyX ?? 1)
            _startDate = Published(initialValue: task?.startDate ?? Date())
            _dueDate = Published(initialValue: task?.duedate)
            
            _streak = Published(initialValue: task?.streak ?? 0)
            _counterUp = Published(initialValue: task?.counterUp ?? 0)
            _counterDown = Published(initialValue: task?.counterDown ?? 0)

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
