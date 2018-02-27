//
//  TaskDetailLineViewTests.swift
//  Habitica
//
//  Created by Phillip Thelen on 19/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import XCTest
@testable import Habitica
import Nimble

class TaskDetailLineViewTests: HabiticaTests {
    
    let taskDetailLine = TaskDetailLineView(frame: CGRect(x: 0, y: 0, width: 350, height: 21))
    var task = Task()
    
    override func setUp() {
        super.setUp()
        self.initializeCoreDataStorage()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        taskDetailLine.dateFormatter = dateFormatter
        
        guard let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: HRPGManager.shared().getManagedObjectContext()) as? Task else {
            return;
        }
        self.task = task
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
        expect(self.taskDetailLine.tagIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
        expect(self.taskDetailLine.hasContent) == false
    }
    
    func testTagsVisible() {
        guard let tag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: HRPGManager.shared().getManagedObjectContext()) as? Tag else {
            return;
        }
        tag.id = "id"
        task.tags = Set(arrayLiteral: tag)
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.tagIconView.isHidden) == false
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
    }
    
    func testChallengeVisible() {
        task.challengeID = "challengeId"
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == false
        expect(self.taskDetailLine.tagIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
    }
    
    func testReminderVisible() {
        guard let reminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: HRPGManager.shared().getManagedObjectContext()) as? Reminder else {
            return;
        }
        task.reminders = NSOrderedSet(array: [reminder])
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.tagIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == false
        expect(self.taskDetailLine.streakIconView.isHidden) == true
    }
    
    func testStreakVisible() {
        task.streak = NSNumber(integerLiteral: 2)
        task.type = "daily"
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.tagIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == false
        expect(self.taskDetailLine.streakLabel.text) == "2"
    }
    
    func testStreakHiddenIfZero() {
        task.streak = NSNumber(integerLiteral: 0)
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.tagIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
    }
    
    func testTodoDueToday() {
        task.duedate = Date()
        task.type = "todo"
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.tagIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
        expect(self.taskDetailLine.calendarIconView.isHidden) == false
        expect(self.taskDetailLine.detailLabel.text) == "Due today"
    }
    
    func testTodoDueTomorrow() {
        task.duedate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        task.type = "todo"
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.tagIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
        expect(self.taskDetailLine.calendarIconView.isHidden) == false
        expect(self.taskDetailLine.detailLabel.text) == "Due tomorrow"
    }
    
    func testTodoDueIn3Days() {
        task.duedate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
        task.type = "todo"
        taskDetailLine.configure(task: task)
        expect(self.taskDetailLine.challengeIconView.isHidden) == true
        expect(self.taskDetailLine.tagIconView.isHidden) == true
        expect(self.taskDetailLine.reminderIconView.isHidden) == true
        expect(self.taskDetailLine.streakIconView.isHidden) == true
        expect(self.taskDetailLine.calendarIconView.isHidden) == false
        expect(self.taskDetailLine.detailLabel.text) == "Due in 3 days"
    }
}
