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
        expectExists(collection.staticTexts["Bear Cub"])
        expectExists(collection.scroll(toFindCellWithId: "Hedgehog 1 of 10"))
        expectExists(collection.scroll(toFindCellWithId: "Confection Cactus 1 of 1"))
        expectExists(collection.scroll(toFindCellWithId: "Phoenix-Base 1 of 1"))
    }
    
    func testCountsOwnedPets() {
        app.launch(withStubs: stubData, toUrl: url)
        let collection = app.collectionViews.firstMatch
        expectExists(collection.staticTexts["11/53"])
        expectExists(collection.scroll(toFindCellWithId: "Falcon 1 of 10"))
        expectExists(collection.staticTexts["1/10"])
    }
    
    func testOpensPetDetail() {
        app.launch(withStubs: stubData, toUrl: url)
        let collection = app.collectionViews
        expectExists(collection.staticTexts["Dragon"])
        collection.staticTexts["Dragon"].tap()
        expectExists(collection.cells["Skeleton Dragon, Raised 10%"])
    }
    
    func testListingMounts() {
        app.launch(withStubs: stubData, toUrl: url)
        app.segmentedControls.buttons["Mounts"].tap()
        let collection = app.collectionViews.firstMatch
        expectExists(collection.staticTexts["Bear Cub"])
        expectExists(collection.scroll(toFindCellWithId: "Caterpillar 1 of 10"))
        expectExists(collection.scroll(toFindCellWithId: "Phoenix-Base 1 of 1"))
    }
    
    func testCountsOwnedMounts() {
        app.launch(withStubs: stubData, toUrl: url)
        app.segmentedControls.buttons["Mounts"].tap()
        let collection = app.collectionViews
        expectExists(collection.staticTexts["7/53"])
    }
    
    func testOpensMountDetail() {
        app.launch(withStubs: stubData, toUrl: url)
        let collection = app.collectionViews
        expectExists(collection.staticTexts["Lion Cub"])
        collection.staticTexts["Lion Cub"].tap()
        expectExists(collection.cells["White Lion, Owned"])
    }
}
