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
        expectExists(table.staticTexts[L10n.Titles.achievements])
        expectExists(table.staticTexts[L10n.Locations.market])
        expectExists(table.staticTexts[L10n.Titles.items])
        expectExists(table.staticTexts[L10n.Menu.gems])
        expectExists(table.staticTexts[L10n.Menu.subscription])
        expectExists(table.staticTexts[L10n.Titles.news])
        expectExists(table.staticTexts[L10n.Menu.helpAbout])
        expectExists(table.staticTexts[L10n.Titles.about])
    }
}
