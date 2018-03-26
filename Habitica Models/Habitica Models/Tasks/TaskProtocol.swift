//
//  TaskProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public enum TaskType: String {
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
public protocol TaskProtocol {
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
    
}

extension TaskProtocol {
    public func dueToday(withOffset: Int) -> Bool {
        return isDue
    }
}
