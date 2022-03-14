//
//  TavernTests.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 10.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest
import Nimble

class TavernTests: HabiticaAppTests {

    let url = "/tavern"
    
    override func setUp() {
        super.setUp()
        stubData["user"] = stubFileResponse(name: "user")
        stubData["user/sleep"] = stubEmptyObjectResponse()
    }

    func testShowsTavern() {
        let app = self.app
        app.launch(withStubs: stubData, toUrl: url)
        
        expect(app.buttons["Resume Damage"].waitForExistence(timeout: 2)).to(beTrue())
        expect(app.buttons["View Community Guidelines"].waitForExistence(timeout: 2)).to(beTrue())
        expect(app.buttons["View FAQ"].waitForExistence(timeout: 2)).to(beTrue())
        expect(app.buttons["Report a Bug"].waitForExistence(timeout: 2)).to(beTrue())
    }
    
    func testSleep() {
        let app = self.app
        app.launch(withStubs: stubData, toUrl: url)
        
        app.buttons["Resume Damage"].tap()
        expect(app.buttons["Pause Damage"].waitForExistence(timeout: 3)).to(beTrue())
        app.buttons["Pause Damage"].tap()
        expect(app.buttons["Resume Damage"].waitForExistence(timeout: 3)).to(beTrue())
    }
    
    func testCollapsesSections() {
        let app = self.app
        app.launch(withStubs: stubData, toUrl: url)
        expect(app.buttons["Resume Damage"].waitForExistence(timeout: 2)).to(beTrue())
        app.staticTexts["Check into Inn"].tap()
        expect(app.buttons["Resume Damage"].exists).to(beFalse())
        app.staticTexts["Check into Inn"].tap()
        expect(app.buttons["Resume Damage"].exists).to(beTrue())
    }
}
