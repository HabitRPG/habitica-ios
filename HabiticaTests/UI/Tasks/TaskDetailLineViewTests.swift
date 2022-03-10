//
//  TaskDetailLineViewTests.swift
//  Habitica
//
//  Created by Phillip Thelen on 19/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import XCTest
@testable import Habitica
import Habitica_Models
import Nimble


class TaskDetailLineViewTests: HabiticaTests {
    
    let taskDetailLine = TaskDetailLineView(frame: CGRect(x: 0, y: 0, width: 350, height: 21))
    var task = TestTask()
    
    override func setUp() {
        super.setUp()
        
        taskDetailLine.monthDayFormatter = DateFormatter()
        taskDetailLine.monthDayFormatter?.dateStyle = .none
        taskDetailLine.monthDayFormatter?.timeStyle = .none
        taskDetailLine.monthDayFormatter?.setLocalizedDateFormatFromTemplate("MMMd")
        
        guard let preferredLocale = Locale.preferredLanguages.first else {
            return
        }
        taskDetailLine.shortLocalizedFormatter = DateFormatter()
        taskDetailLine.shortLocalizedFormatter?.dateStyle = .none
        taskDetailLine.shortLocalizedFormatter?.timeStyle = .none
        taskDetailLine.shortLocalizedFormatter?.locale = Locale.init(identifier: preferredLocale)
        taskDetailLine.shortLocalizedFormatter?.setLocalizedDateFormatFromTemplate("yy-MM-dd")
        
        self.task = TestTask()
        task.text = "Task Title"
        task.notes = "Task notes"
        task.type = "habit"
        
        self.recordMode = true
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDefaultEmpty() {
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
        expect(self.taskDetailLine.hasContent) == false
    }
    
    func testTagsVisible() {
        task.tags = [MockTag()]
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
    }
    
    func testChallengeVisible() {
        task.challengeID = "challengeId"
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == false
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
    }
    
    func testReminderVisible() {
        task.reminders = [MockReminder()]
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == false
        expect(self.taskDetailLine.streakIconView.isHidden) == true
    }
    
    func testStreakVisible() {
        task.streak = 2
        task.type = "daily"
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == false
        expect(self.taskDetailLine.streakLabel.text) == "2"
    }
    
    func testStreakHiddenIfZero() {
        task.streak = 0
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
    }
    
    func testTodoDueToday() {
        task.duedate = Date()
        task.type = "todo"
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
        expect(self.taskDetailLine.calendarIconView.isHidden) == false
        expect(self.taskDetailLine.detailLabel.text) == "Today"
    }
    
    func testTodoDueTomorrow() {
        task.duedate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        task.type = "todo"
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
        expect(self.taskDetailLine.calendarIconView.isHidden) == false
        expect(self.taskDetailLine.detailLabel.text) == "Tomorrow"
    }
    
    func testTodoDueIn3Days() {
        task.duedate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
        task.type = "todo"
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
        expect(self.taskDetailLine.calendarIconView.isHidden) == false
        expect(self.taskDetailLine.detailLabel.text) == "In 3 days"
    }
}

class TestTask: TaskProtocol {
    var groupID: String?
    var isManaged: Bool = false
    
    var challengeBroken: String?
    
    var history: [TaskHistoryProtocol] = []
    
    var isValid: Bool = true
    
    var nextDue: [Date] = []
    var weeksOfMonth: [Int] = []
    var daysOfMonth: [Int] = []

    var isNewTask: Bool = false
    var isSynced: Bool = true
    var isSyncing: Bool = false
    var createdAt: Date?
    var updatedAt: Date?
    var startDate: Date?
    var yesterDaily: Bool = true
    var weekRepeat: WeekRepeatProtocol?
    var frequency: String?
    var everyX: Int = 1
    var tags: [TagProtocol] = []
    var checklist: [ChecklistItemProtocol] = []
    var reminders: [ReminderProtocol] = []
    
    var id: String?
    var text: String?
    var notes: String?
    var type: String?
    var value: Float = 0
    var attribute: String?
    var completed: Bool = false
    var down: Bool = false
    var up: Bool = false
    var order: Int = 0
    var priority: Float = 0
    var counterUp: Int = 0
    var counterDown: Int = 0
    var duedate: Date?
    var isDue: Bool = false
    var streak: Int = 0
    var challengeID: String?
}

class MockTag: TagProtocol {
    var isManaged: Bool = false
    var isValid: Bool = true
    
    var id: String?
    var text: String?
    var order: Int = 0
}


class MockReminder: ReminderProtocol {
    func detached() -> ReminderProtocol {
        return self
    }
    var isManaged: Bool = false
    var isValid: Bool = true
    
    var id: String?
    var startDate: Date?
    var time: Date?
    var task: TaskProtocol?
}
