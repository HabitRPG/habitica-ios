//
//  Habitica_Snapshots.swift
//  Habitica Snapshots
//
//  Created by Phillip Thelen on 11.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import XCTest

class Habitica_Snapshots: XCTestCase {

    override func setUp() {
        let app = XCUIApplication()
        setupSnapshot(app)
        
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons.element(boundBy: 0).tap()

        tabBarsQuery.buttons.element(boundBy: 1).tap()
        sleep(1)
        snapshot("Dailies")
        tabBarsQuery.buttons.element(boundBy: 1).tap()
        XCUIApplication().tables.cells.element(boundBy: 0).tap()
        sleep(1)
        snapshot("LevelUp")
        
        app.buttons.element(matching: .button, identifier: "Close").tap()
        tabBarsQuery.buttons.element(boundBy: 4).tap()
        
        
        app.tables.cells.element(boundBy: 10).tap()
        sleep(3)
        snapshot("Stable")
        tabBarsQuery.buttons.element(boundBy: 4).tap()
        app.tables.cells.element(boundBy: 3).tap()
        
        
        app.scrollViews.otherElements.matching(identifier: "QuestDetailButton").element.tap()
        sleep(3)
        snapshot("Quest")
        
        tabBarsQuery.buttons.element(boundBy: 4).tap()
        app.tables.cells.element(boundBy: 3).tap()

        let scrollView = XCUIApplication().scrollViews.otherElements.scrollViews.element(boundBy: 0)
        let memberElement = XCUIApplication().scrollViews.otherElements.scrollViews.otherElements.staticTexts["Aiden M."]
        scrollView.scrollToElement(element: memberElement)
        
        sleep(3)
        snapshot("Members")
    }
}

extension XCUIElement {
    func scrollToElement(element: XCUIElement) {
        while !element.visible() {
            swipeUp()
        }
    }
    
    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
}
