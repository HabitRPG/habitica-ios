//
//  StableOverviewTests.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 10.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest
import Nimble

class StableOverviewTests: HabiticaAppTests {

    private let url = "/inventory/stable"

    override func setUp() {
        super.setUp()
        stubData["user"] = stubFileResponse(name: "user")
    }

    func testListingPets() {
        app.launch(withStubs: stubData, toUrl: url)

        let collection = app.collectionViews.firstMatch
        expectExists(collection.staticTexts["Bear Cub"], timeout: 15)
        expectExists(withPrefix: "Cactus", in: collection.cells)
        expectExists(withPrefix: "Dragon", in: collection.cells)
    }

    func testOpensPetDetail() {
        app.launch(withStubs: stubData, toUrl: url)
        let collection = app.collectionViews.firstMatch
        expectExists(collection.staticTexts["Dragon"], timeout: 15)
        collection.staticTexts["Dragon"].tap()
        expectExists(withPrefix: "Skeleton Dragon", in: app.collectionViews.cells)
    }

    func testListingMounts() {
        app.launch(withStubs: stubData, toUrl: url)
        expectExists(app.segmentedControls.buttons["Mounts"], timeout: 15)
        app.segmentedControls.buttons["Mounts"].tap()
        let collection = app.collectionViews.firstMatch
        expectExists(collection.staticTexts["Bear"], timeout: 15)
        expectExists(withPrefix: "Cactus", in: collection.cells)
    }

    func testOpensMountDetail() {
        app.launch(withStubs: stubData, toUrl: url)
        let collection = app.collectionViews.firstMatch
        expectExists(collection.staticTexts["Lion Cub"], timeout: 15)
        collection.staticTexts["Lion Cub"].tap()
        expectExists(withPrefix: "White Lion", in: app.collectionViews.cells)
    }
}
