//
//  PetDetailTests.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 11.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest
import Habitica_Models

class PetDetailTests: HabiticaAppTests {

    private let url = "/inventory/stable/pets/Dragon"
    
    override func setUp() {
        super.setUp()
        stubData["user"] = stubFileResponse(name: "user")
        stubData["user/equip/pet/Dragon-Desert"] = CallStub(responses: [
            HabiticaAppTests.wrapResponse(string: "{\"currentPet\": \"Dragon-Desert\"}"),
            HabiticaAppTests.wrapResponse(string: "{\"currentPet\": \"\"}")
        ])
    }

    func testListingPets() {
        app.launch(withStubs: stubData, toUrl: url)
        
        let collection = app.collectionViews.firstMatch
        expectExists(collection.cells["Golden Dragon, Raised 26%"])
        expectExists(collection.cells["Skeleton Dragon, Mount Owned"])
        expectExists(collection.cells["Unknown Pet"])
    }
    
    func testEquippingPet() {
        app.launch(withStubs: stubData, toUrl: url)
        
        let collection = app.collectionViews.firstMatch
        collection.cells["Desert Dragon, Mount Owned"].tap()
        app.sheets["Desert Dragon"].buttons["Equip"].tap()
        collection.cells["Desert Dragon, Mount Owned"].tap()
        sleep(1)
        app.sheets["Desert Dragon"].buttons["Unequip"].tap()
        collection.cells["Desert Dragon, Mount Owned"].tap()
        expectExists(app.sheets["Desert Dragon"].buttons["Equip"])
    }
    
    func testSheetDisplay() {
        app.launch(withStubs: stubData, toUrl: url)
        
        let collection = app.collectionViews.firstMatch
        collection.cells["Skeleton Dragon, Mount Owned"].tap()
        expectExists(app.sheets["Skeleton Dragon"].buttons["Equip"])
        expectNotExists(app.sheets["Skeleton Dragon"].buttons["Feed"])
        app.sheets["Skeleton Dragon"].buttons["Cancel"].tap()
        
        collection.cells["Shade Dragon, Raised 62%"].tap()
        expectExists(app.sheets["Shade Dragon"].buttons["Equip"])
        expectExists(app.sheets["Shade Dragon"].buttons["Feed"])
    }
}
