//
//  Habitica_Snapshots.swift
//  Habitica Snapshots
//
//  Created by Phillip on 31.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import XCTest

class Habitica_Snapshots: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let app = XCUIApplication()
        
        app.buttons["Skip"].tap()
        app.scrollViews.otherElements.containing(.button, identifier:"Register").buttons["Login"].tap()
        
        
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.textFields["Email / Username"].tap()
        elementsQuery.textFields["Email / Username"].typeText("maya")
        
        
        let passwordSecureTextField = scrollViewsQuery.otherElements.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("t")
        scrollViewsQuery.otherElements.containing(.activityIndicator, identifier:"In progress").buttons["Login"].tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Habits"].tap()
        snapshot("0Habits")
        tabBarsQuery.buttons["Dailies"].tap()
        snapshot("1Dailies")
        
    }
    
    func loginUser() {
        
    }
    
}
