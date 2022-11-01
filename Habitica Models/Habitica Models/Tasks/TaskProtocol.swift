//
//  TaskProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public enum TaskType: String, EquatableStringEnumProtocol {
    case habit
    case daily
    case todo
    case reward
}

public enum TaskScoringDirection: String {
    case up
    case down
}

@objc
public protocol TaskProtocol: BaseRewardProtocol {
    var id: String? { get set }
    var text: String? { get set }
    var notes: String? { get set }
    var type: String? { get set }
    var value: Float { get set }
    var attribute: String? { get set }
    var completed: Bool { get set }
    var down: Bool { get set }
    var up: Bool { get set }
    var order: Int { get set }
    var priority: Float { get set }
    var counterUp: Int { get set }
    var counterDown: Int { get set }
    var duedate: Date? { get set }
    var isDue: Bool { get set }
    var streak: Int { get set }
    var frequency: String? { get set }
    var everyX: Int { get set }
    var challengeID: String? { get set }
    var challengeBroken: String? { get set }
    var groupID: String? { get set }
    var groupAssignedDetails: [AssignedDetailsProtocol] { get set }
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    var startDate: Date? { get set }
    var yesterDaily: Bool { get set }
    var tags: [TagProtocol] { get set }
    var checklist: [ChecklistItemProtocol] { get set }
    var reminders: [ReminderProtocol] { get set }
    var weekRepeat: WeekRepeatProtocol? { get set }
    var history: [TaskHistoryProtocol] { get set }
    var nextDue: [Date] { get set }
    var weeksOfMonth: [Int] { get set }
    var daysOfMonth: [Int] { get set }
        
    var isSynced: Bool { get set }
    var isSyncing: Bool { get set }
    var isNewTask: Bool { get set }
}

extension TaskProtocol {
    public func dueToday() -> Bool {
        return isDue
    }
    
    public func dueOn(date: Date, calendar: Calendar = Calendar.current) -> Bool {
        for dueDate in nextDue where calendar.isDate(dueDate, inSameDayAs: date) {
            return true
        }
        return false
    }
    
    public var isChallengeTask: Bool {
        return challengeID != nil
    }
    
    public var isGroupTask: Bool {
        return groupID != nil
    }
    
    public var isEditable: Bool {
        return !(isChallengeTask || isGroupTask)
    }
    
    public func completed(by userID: String?) -> Bool {
        if !isGroupTask {
            return completed
        } else {
            return groupAssignedDetails.first(where: { $0.assignedUserID == userID })?.completed ?? completed
        }
    }
    
    public func complete(forUser userID: String?, completed: Bool) {
        if isGroupTask && !groupAssignedDetails.isEmpty {
            groupAssignedDetails.first(where: { $0.assignedUserID == userID })?.completed = completed
            if groupAssignedDetails.filter({ $0.completed != completed }).isEmpty {
                self.completed = completed
            }
        } else {
            self.completed = completed
        }
    }
}

public class PreviewTask: TaskProtocol {
    public var groupAssignedDetails: [AssignedDetailsProtocol] = []
    
    public init() {}
    public var challengeBroken: String?
    
    public var history: [TaskHistoryProtocol] = []
    
    public var isValid: Bool = true
    public var isManaged: Bool = false
    
    public var nextDue: [Date] = []
    public var weeksOfMonth: [Int] = []
    public var daysOfMonth: [Int] = []

    public var isNewTask: Bool = false
    public var isSynced: Bool = true
    public var isSyncing: Bool = false
    public var createdAt: Date?
    public var updatedAt: Date?
    public var startDate: Date?
    public var yesterDaily: Bool = true
    public var weekRepeat: WeekRepeatProtocol?
    public var frequency: String?
    public var everyX: Int = 1
    public var tags: [TagProtocol] = []
    public var checklist: [ChecklistItemProtocol] = []
    public var reminders: [ReminderProtocol] = []
    
    public var id: String?
    public var text: String?
    public var notes: String?
    public var type: String?
    public var value: Float = 0
    public var attribute: String?
    public var completed: Bool = false
    public var down: Bool = false
    public var up: Bool = false
    public var order: Int = 0
    public var priority: Float = 1.0
    public var counterUp: Int = 0
    public var counterDown: Int = 0
    public var duedate: Date?
    public var isDue: Bool = false
    public var streak: Int = 0
    public var challengeID: String?
    public var groupID: String?
}

public class PreviewChecklistItem: ChecklistItemProtocol {
    public var isValid: Bool = true
    public var isManaged: Bool = false
    
    public init() {}
    public var text: String?
    public var completed: Bool = false
    public var id: String?
    
    public func detached() -> ChecklistItemProtocol {
        return self
    }
    
    init(text: String) {
        self.text = text
    }
}

public class PreviewReminder: ReminderProtocol {
    public var isValid: Bool = true
    public var isManaged: Bool = false
    public var id: String?
    public init() {}
    public var startDate: Date?
    public var time: Date?
    public var task: TaskProtocol?
    
    @objc
    public func detached() -> ReminderProtocol {
        return self
    }
}
