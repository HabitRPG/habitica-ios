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
    
    func testSheetDisplay() {
        app.launch(withStubs: stubData, toUrl: url)

        let collection = app.collectionViews.firstMatch
        collection.cells.firstElement(withPrefix: "Skeleton Dragon").tap()
        expectExists(app.staticTexts["Skeleton Dragon"], timeout: 10)
        expectExists(app.buttons["Equip"], timeout: 10)
        expectNotExists(app.buttons["Feed"])
        app.otherElements["dismiss popup"].tap()

        collection.cells.firstElement(withPrefix: "Shade Dragon").tap()
        expectExists(app.staticTexts["Shade Dragon"], timeout: 10)
        expectExists(app.buttons["Equip"], timeout: 10)
        expectExists(app.buttons["Feed"], timeout: 10)
    }
}
