//
//  TaskListViewController.swift
//  HabiticaTests
//
//  Created by Phillip Thelen on 09.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest
import UIKit
import Nimble

class TaskListTests: HabiticaAppTests {

    override func setUp() {
        super.setUp()
        stubData["user"] = stubFileResponse(name: "user")
        stubData["tasks/user"] = stubFileResponse(name: "tasks")
    }
    
    func testDisplaysHeader() {
        app.launch(withStubs:stubData)
        XCTAssertTrue(app.staticTexts["Level 16"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.otherElements["Health 50 of 50"].exists)
    }
    
    func testDisplaysEmptyStateHabit() {
        stubData["tasks/user"] = stubEmptyListResponse()
        app.launch(withStubs:stubData)
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.staticTexts[L10n.Empty.Habits.title].exists)
    }
    
    func testDisplaysEmptyStateDailies() {
        stubData["tasks/user"] = stubEmptyListResponse()
        app.launch(withStubs:stubData)
        let tablesQuery = app.tables
        app.tabBars["Tab Bar"].buttons[L10n.Tasks.dailies].tap()
        XCTAssertTrue(tablesQuery.staticTexts[L10n.Empty.Dailies.title].exists)
    }
    
    func testDisplaysEmptyStateTodos() {
        stubData["tasks/user"] = stubEmptyListResponse()
        app.launch(withStubs:stubData)
        let tablesQuery = app.tables
        app.tabBars["Tab Bar"].buttons[L10n.Tasks.todos].tap()
        XCTAssertTrue(tablesQuery.staticTexts[L10n.Empty.Todos.title].exists)
    }
    
    func testDisplaysHabits() {
        app.launch(withStubs:stubData)
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.otherElements["HTTPS://google.com, Value: Neutral"].waitForExistence(timeout: 2))
    }
    
    func testDisplaysDailies() {
        app.launch(withStubs:stubData)
        app.tabBars["Tab Bar"].buttons[L10n.Tasks.dailies].tap()
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.otherElements["Due, 文字入力を試みても変換が出来ず, Value: Neutral, 1 checklist items"].waitForExistence(timeout: 1))
    }
    
    func testDisplaysTodos() {
        app.launch(withStubs:stubData)
        app.tabBars["Tab Bar"].buttons[L10n.Tasks.todos].tap()
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.otherElements["Not Completed, test. todo, Value: Neutral"].waitForExistence(timeout: 1))
    }
}

extension XCUIElement {
    func waitToGet() -> XCUIElement {
        XCTAssertTrue(waitForExistence(timeout: 2))
        return self
    }
}
