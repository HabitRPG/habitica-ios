//
//  CustomizationDetailTests.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 14.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import XCTest
import Nimble
import Habitica_Models

class CustomizationDetailTests: HabiticaAppTests {
    let url = "/user/avatar"

    override func setUp() {
        super.setUp()
        stubData["user"] = stubFileResponse(name: "user")
    }

    private func listsCustomizations(category: String, prefix: String) {
        app.launch(withStubs: stubData, toUrl: url)
        expectExists(app.staticTexts[category], timeout: 15)
        app.staticTexts[category].tap()

        let options = app.cells.matching(NSPredicate(format: "label BEGINSWITH %@", prefix))
        expect(options.firstMatch.waitForExistence(timeout: 15)).to(beTrue())
        expect(options.count).to(beGreaterThan(1))
    }

    func testListShirts() {
        listsCustomizations(category: "Shirt", prefix: "shirt ")
    }

    func testListSkins() {
        listsCustomizations(category: "Skin", prefix: "skin ")
    }

    func testListHairColors() {
        listsCustomizations(category: "Hair Color", prefix: "hair ")
    }

    func testListBangs() {
        listsCustomizations(category: "Bangs", prefix: "hair ")
    }

    func testListWheelchairs() {
        listsCustomizations(category: "Wheelchair", prefix: "chair ")
    }

    func testListBackgrounds() {
        listsCustomizations(category: "Background", prefix: "background ")
    }
}
