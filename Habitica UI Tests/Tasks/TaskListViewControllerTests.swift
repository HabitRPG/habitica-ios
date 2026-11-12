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
        XCTAssertTrue(app.staticTexts["Lvl 16"].waitForExistence(timeout: 10))
        expectExists(withPrefix: "HP 50", in: app.otherElements)
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
        openTab(L10n.Tasks.dailies)
        XCTAssertTrue(tablesQuery.staticTexts[L10n.Empty.Dailies.title].exists)
    }
    
    func testDisplaysEmptyStateTodos() {
        stubData["tasks/user"] = stubEmptyListResponse()
        app.launch(withStubs:stubData)
        let tablesQuery = app.tables
        openTab(L10n.Tasks.todos)
        XCTAssertTrue(tablesQuery.staticTexts[L10n.Empty.Todos.title].exists)
    }
    
    func testDisplaysHabits() {
        app.launch(withStubs:stubData)
        expectExists(withPrefix: "HTTPS://google.com", in: app.tables.otherElements)
    }

    func testDisplaysDailies() {
        app.launch(withStubs:stubData)
        openTab(L10n.Tasks.dailies)
        expectExists(withPrefix: "Due, 文字入力を試みても変換が出来ず", in: app.tables.otherElements)
    }

    func testDisplaysTodos() {
        app.launch(withStubs:stubData)
        openTab(L10n.Tasks.todos)
        expectExists(withPrefix: "Not Completed, test. todo", in: app.tables.otherElements)
    }
}

extension TaskListTests {
    // iPadOS 18+ floats tabs at the top instead of a TabBar, so look the button up app-wide.
    // Right after launch the first tap can be swallowed while the app settles, so tap again if the tab didn't switch.
    func openTab(_ name: String) {
        let tab = app.buttons[name].firstMatch
        XCTAssertTrue(tab.waitForExistence(timeout: 10))
        tab.tap()
        if !tab.isSelected {
            tab.tap()
        }
    }
}

extension XCUIElement {
    func waitToGet() -> XCUIElement {
        XCTAssertTrue(waitForExistence(timeout: 2))
        return self
    }
}
