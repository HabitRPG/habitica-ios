//
//  MountDetailTests.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 11.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest
import Habitica_Models

class MountDetailTests: HabiticaAppTests {

    private let url = "/inventory/stable/mounts/Fox"
    
    override func setUp() {
        super.setUp()
        stubData["user"] = stubFileResponse(name: "user")
        stubData["user/equip/pet/Fox-Base"] = CallStub(responses: [
            HabiticaAppTests.wrapResponse(string: "{\"currentPet\": \"Fox-Base\"}"),
            HabiticaAppTests.wrapResponse(string: "{\"currentPet\": \"\"}")
        ])
    }

    func testListingMounts() {
        app.launch(withStubs: stubData, toUrl: url)
        
        let collection = app.collectionViews.firstMatch
        expectExists(collection.cells["Red Fox"])
        expectExists(collection.cells["White Fox"])
        expectExists(collection.cells["Unknown Mount"])
    }

    func testEquippingMount() {
        app.launch(withStubs: stubData, toUrl: url)
        
        let collection = app.collectionViews.firstMatch
        collection.cells["Base Fox"].tap()
        app.sheets["Base Fox"].buttons["Equip"].tap()
        sleep(1)
        collection.cells["Base Fox"].tap()
        app.sheets["Base Fox"].buttons["Unequip"].tap()
        collection.cells["Base Fox"].tap()
        expectExists(app.sheets["Base Fox"].buttons["Equip"])
    }
}
