//
//  ItemListViewController.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 10.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest
import Nimble

class ItemListTests: HabiticaAppTests {

    let url = "/inventory/items"
    
    override func setUp() {
        super.setUp()
        stubData["user"] = stubFileResponse(name: "user")
    }

    func testListItems() {
        app.launch(withStubs: stubData, toUrl: url)
        let tablesQuery = app.tables
        expect(tablesQuery.staticTexts["Bear Cub"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["Basic Cake"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["Red"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["Seafoam"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["The Basi-List"].waitForExistence(timeout: 2)).to(beTrue())
    }
    
    func testHasAllSections() {
        app.launch(withStubs: stubData, toUrl: url)
        let tablesQuery = app.tables
        expect(tablesQuery.otherElements.staticTexts["Eggs"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.otherElements.staticTexts["Food"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.otherElements.staticTexts["Hatching Potions"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.otherElements.staticTexts["Special Items"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.otherElements.staticTexts["Quests"].waitForExistence(timeout: 2)).to(beTrue())
    }
    
    func testHasMarketFooter() {
        app.launch(withStubs: stubData, toUrl: url)
        let tablesQuery = app.tables
        let MAX_SCROLLS = 15
        var count = 0
        while !tablesQuery.buttons["Open Shop"].exists && count < MAX_SCROLLS {
            app.swipeUp(velocity: .fast)
            count += 1
        }
        expect(tablesQuery.buttons["Open Shop"].waitForExistence(timeout: 2)).to(beTrue())
    }
}
