//
//  MainMenuTests.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 18.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation

class MainMenuTests: HabiticaAppTests {
    
    private let url = "/menu"
    
    override func setUp() {
        super.setUp()
        stubData["user"] = stubFileResponse(name: "user")
    }
    
    func testShowsMenuItems() {
        app.launch(withStubs: stubData, toUrl: url)
        
        let table = app.tables
        expectExists(table.staticTexts["Achievements"])
        expectExists(table.staticTexts["Market"])
        expectExists(table.staticTexts["Items"])
        expectExists(table.staticTexts["Purchase Gems"])
        expectExists(table.staticTexts["Subscription"])
        expectExists(table.staticTexts["News"])
        expectExists(table.staticTexts["Support"])
        expectExists(table.staticTexts["About"])
    }
    
    func testAllItemsTappable() throws {
        app.launch(withStubs: stubData, toUrl: url)
        
        let table = app.tables
        for item in table.cells.allElementsBoundByIndex {
            item.tap()
            if app.navigationBars.buttons["Done"].exists {
                app.navigationBars.buttons["Done"].tap()
            } else {
                app.navigationBars.buttons["Back"].tap()
            }
        }
    }
}
