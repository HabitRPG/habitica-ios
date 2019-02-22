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
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    var startDate: Date? { get set }
    var yesterDaily: Bool { get set }
    var tags: [TagProtocol] { get set }
    var checklist: [ChecklistItemProtocol] { get set }
    var reminders: [ReminderProtocol] { get set }
    var weekRepeat: WeekRepeatProtocol? { get set }
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
        for dueDate in nextDue {
            if calendar.isDate(dueDate, inSameDayAs: date) {
                return true
            }
        }
        return false
    }
    
    public var isChallengeTask: Bool {
        return challengeID != nil
    }
}
