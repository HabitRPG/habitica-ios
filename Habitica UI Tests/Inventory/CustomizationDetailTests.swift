//
//  CustomizationDetailTests.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 14.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import Nimble
import Habitica_Models

class CustomizationDetailTests: HabiticaAppTests {
    let url = "/user/avatar"
    
    override func setUp() {
        super.setUp()
        stubData["user"] = stubFileResponse(name: "user")
    }
    
    private func testListCustomization(category: String, label: String) {
        app.launch(withStubs: stubData, toUrl: url)
        app.staticTexts[category].tap()
        app.cells[label].tap()
        expectExists(app.cells[label + ", selected"])
    }

    func testListShirts() {
        var userData = loadFile(name: "user")
        var dict = (userData["preferences"] as! Dictionary<String, Any>)
        dict["shirt"] = "black" as AnyObject
        userData["preferences"] = dict as AnyObject
        stubData["user"]?.responses.append(stubDictionaryResponse(dictionary: userData).responses.first!)
        testListCustomization(category: "Shirt", label: "shirt black")
    }
    
    func testListSkins() {
        var userData = loadFile(name: "user")
        var dict = (userData["preferences"] as! Dictionary<String, Any>)
        dict["skin"] = "915533" as AnyObject
        userData["preferences"] = dict as AnyObject
        stubData["user"]?.responses.append(stubDictionaryResponse(dictionary: userData).responses.first!)
        testListCustomization(category: "Skin", label: "skin 915533")
    }
    
    func testListHairColors() {
        var userData = loadFile(name: "user")
        var dict = (userData["preferences"] as! Dictionary<String, Any>)
        dict["hair"] = ["color": "1"] as AnyObject
        userData["preferences"] = dict as AnyObject
        stubData["user"]?.responses.append(stubDictionaryResponse(dictionary: userData).responses.first!)
        testListCustomization(category: "Hair Color", label: "hair brown")
    }
    
    func testListBangs() {
        var userData = loadFile(name: "user")
        var dict = (userData["preferences"] as! Dictionary<String, Any>)
        dict["hair"] = ["bangs": "1"] as AnyObject
        userData["preferences"] = dict as AnyObject
        stubData["user"]?.responses.append(stubDictionaryResponse(dictionary: userData).responses.first!)
        testListCustomization(category: "Bangs", label: "hair 1")
    }
    
    func testListGlasses() {
        stubData["user/equip/pet/Dragon-Desert"] = CallStub(responses: [
            HabiticaAppTests.wrapResponse(string: "{\"gear\": {\"equipped\": {\"eyewear\": \"}}"),
            HabiticaAppTests.wrapResponse(string: "{\"currentPet\": \"\"}")
        ])
        testListCustomization(category: "Glasses", label: "Black Standard Eyeglasses")
    }
    
    func testListWheelchairs() {
        var userData = loadFile(name: "user")
        var dict = (userData["preferences"] as! Dictionary<String, Any>)
        dict["chair"] = "green" as AnyObject
        userData["preferences"] = dict as AnyObject
        stubData["user"]?.responses.append(stubDictionaryResponse(dictionary: userData).responses.first!)
        testListCustomization(category: "Wheelchair", label: "chair green")
    }
    
    func testListBackgrounds() {
        var userData = loadFile(name: "user")
        var dict = (userData["preferences"] as! Dictionary<String, Any>)
        dict["background"] = "violet" as AnyObject
        userData["preferences"] = dict as AnyObject
        stubData["user"]?.responses.append(stubDictionaryResponse(dictionary: userData).responses.first!)
        testListCustomization(category: "Background", label: "background violet")
    }
    
}
