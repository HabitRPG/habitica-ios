//
//  Habitica_Snapshots.swift
//  Habitica Snapshots
//
//  Created by Phillip Thelen on 11.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import XCTest
import KeychainAccess

class Habitica_Snapshots: XCTestCase {

    override func setUp() {
        let app = XCUIApplication()
        setupSnapshot(app)
        let keychain = Keychain(server: "https://habitica.com", protocolType: .https)
            .accessibility(.afterFirstUnlock)
        
        let defaults = UserDefaults.standard
        app.launch()
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        snapshot("Habits")
        
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Dailies"].tap()
        sleep(2)
        snapshot("Dailies")
        tabBarsQuery.buttons["To-Dos"].tap()
        sleep(2)
        snapshot("T-Dos")
        tabBarsQuery.buttons["Menu"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Stable"]/*[[".cells.staticTexts[\"Stable\"]",".staticTexts[\"Stable\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(5)
        snapshot("Stable")
        app.navigationBars["Stable"].buttons["Back"].tap()
        tablesQuery.staticTexts["Party"].tap()
        app.navigationBars["Items"].buttons["Back"].tap()
        
        
        app.scrollViews.otherElements.scrollViews.otherElements.staticTexts["Dilatory Distress, Part 2: Creatures of the Crevasse"].tap()
        app.navigationBars["Quest"].buttons["Party"].tap()
        sleep(2)
        snapshot("Quest")
        
        let ourPartyElementsQuery = XCUIApplication().scrollViews.otherElements.scrollViews.otherElements.containing(.staticText, identifier:"Our Party")
        let element = ourPartyElementsQuery.children(matching: .other).element(boundBy: 1)
        element.children(matching: .other).element.swipeUp()
        element.swipeUp()
        ourPartyElementsQuery.children(matching: .other).element(boundBy: 3).children(matching: .other).element(boundBy: 1).swipeUp()
        sleep(5)
        snapshot("Members")
    }

}
