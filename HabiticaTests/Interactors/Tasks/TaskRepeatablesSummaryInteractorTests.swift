//
//  TaskRepeatablesSummaryInteractorTests.swift
//  Habitica
//
//  Created by Phillip Thelen on 20/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
@testable import Habitica
import Result
import Nimble

class TaskRepeatablesSummaryInteractorTests: HabiticaTests {
    
    let interactor = TaskRepeatablesSummaryInteractor()
    
    private let observer = TestObserver<String, NSError>()
    private var task = Task()
    
    override func setUp() {
        super.setUp()
        
        self.initializeCoreDataStorage()
        guard let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: HRPGManager.shared().getManagedObjectContext()) as? Task else {
            return;
        }
        self.task = task
        task.text = "Task Title"
        task.notes = "Task notes"
        task.type = "daily"
        task.startDate = Date(timeIntervalSince1970: 1485887999)
    }
    
    func testDailyNeverRepeats() {
        task.everyX = 0
        task.frequency = "daily"
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats never"
    }
    
    func testDailyEvery() {
        task.everyX = 1
        task.frequency = "daily"
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats daily"
    }
    
    func testDailyEveryThree() {
        task.everyX = 3
        task.frequency = "daily"
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats every 3 days"
    }
    
    func testWeeklyNeverRepeats() {
        task.everyX = 1
        task.frequency = "weekly"
        task.monday = false
        task.tuesday = false
        task.wednesday = false
        task.thursday = false
        task.friday = false
        task.saturday = false
        task.sunday = false
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats never"
    }
    
    func testWeeklyEveryAllDays() {
        task.everyX = 1
        task.frequency = "weekly"
        task.monday = true
        task.tuesday = true
        task.wednesday = true
        task.thursday = true
        task.friday = true
        task.saturday = true
        task.sunday = true
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats weekly on every day"
    }
    
    func testWeeklyEveryOneDay() {
        task.everyX = 1
        task.frequency = "weekly"
        task.monday = false
        task.tuesday = true
        task.wednesday = false
        task.thursday = false
        task.friday = false
        task.saturday = false
        task.sunday = false
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats weekly on Tuesday"
    }
    
    func testWeeklyEveryThreeDay() {
        task.everyX = 1
        task.frequency = "weekly"
        task.monday = false
        task.tuesday = true
        task.wednesday = false
        task.thursday = true
        task.friday = false
        task.saturday = true
        task.sunday = false
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats weekly on Tuesday, Thursday, Saturday"
    }
    
    func testWeeklyEveryWeekdays() {
        task.everyX = 1
        task.frequency = "weekly"
        task.monday = true
        task.tuesday = true
        task.wednesday = true
        task.thursday = true
        task.friday = true
        task.saturday = false
        task.sunday = false
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats weekly on weekdays"
    }
    
    func testWeeklyEveryWeekend() {
        task.everyX = 1
        task.frequency = "weekly"
        task.monday = false
        task.tuesday = false
        task.wednesday = false
        task.thursday = false
        task.friday = false
        task.saturday = true
        task.sunday = true
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats weekly on weekends"
    }
    
    func testWeeklyEveryThreeAllDays() {
        task.everyX = 3
        task.frequency = "weekly"
        task.monday = true
        task.tuesday = true
        task.wednesday = true
        task.thursday = true
        task.friday = true
        task.saturday = true
        task.sunday = true
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats every 3 weeks on every day"
    }
    
    func testMonthyEveryDayOfMonth() {
        task.everyX = 1
        task.frequency = "monthly"
        task.daysOfMonth = Set(arrayLiteral: 31)
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats monthly on the 31"
    }
    
    func testMonthyEveryThreeDayOfMonth() {
        task.everyX = 3
        task.frequency = "monthly"
        task.daysOfMonth = Set(arrayLiteral: 31)
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats every 3 months on the 31"
    }
    
    func testMonthyEveryWeekOfMonth() {
        task.everyX = 1
        task.frequency = "monthly"
        task.weeksOfMonth = Set(arrayLiteral: 5)
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats monthly on the 5 Tuesday"
    }
    
    func testMonthyEveryThreeWeekOfMonth() {
        task.everyX = 3
        task.frequency = "monthly"
        task.weeksOfMonth = Set(arrayLiteral: 5)
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats every 3 months on the 5 Tuesday"
        
    }
    
    func testYearlyEvery() {
        task.everyX = 1
        task.frequency = "yearly"
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats yearly on January 31"
    }
    
    func testYearlyEveryThree() {
        task.everyX = 3
        task.frequency = "yearly"
        expect(self.interactor.repeatablesSummary(self.task)) == "Repeats every 3 years on January 31"
    }
}
