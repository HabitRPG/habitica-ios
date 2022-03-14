//
//  SkillTableViewController.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 10.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest
import Nimble

class SkillTests: HabiticaAppTests {

    private let url = "/user/skills"
    
    override func setUp() {
        super.setUp()
        stubData["user"] = stubFileResponse(name: "user")
    }
    
    func testListsMageSkills() throws {
        app.launch(withStubs: stubData, toUrl: url)
        
        let tablesQuery = app.tables
        expect(tablesQuery.staticTexts["Burst of Flames"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["Earthquake"].waitForExistence(timeout: 2)).to(beTrue())
    }

    func testListWarriorSkills() throws {
        var userData = loadFile(name: "user")
        var statsDict = (userData["stats"] as! Dictionary<String, Any>)
        statsDict["class"] = "warrior" as AnyObject
        userData["stats"] = statsDict as AnyObject
        stubData["user"] = stubDictionaryResponse(dictionary: userData)
        app.launch(withStubs: stubData, toUrl: url)
        
        let tablesQuery = app.tables
        expect(tablesQuery.staticTexts["Brutal Smash"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["Defensive Stance"].waitForExistence(timeout: 2)).to(beTrue())
    }
    
    func testHealerSkills() throws {
        var userData = loadFile(name: "user")
        var statsDict = (userData["stats"] as! Dictionary<String, Any>)
        statsDict["class"] = "healer" as AnyObject
        userData["stats"] = statsDict as AnyObject
        stubData["user"] = stubDictionaryResponse(dictionary: userData)
        app.launch(withStubs: stubData, toUrl: url)
        
        let tablesQuery = app.tables
        expect(tablesQuery.staticTexts["Healing Light"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["Searing Brightness"].waitForExistence(timeout: 2)).to(beTrue())
    }
    
    func testListRogueSkills() throws {
        var userData = loadFile(name: "user")
        var statsDict = (userData["stats"] as! Dictionary<String, Any>)
        statsDict["class"] = "rogue" as AnyObject
        userData["stats"] = statsDict as AnyObject
        stubData["user"] = stubDictionaryResponse(dictionary: userData)
        app.launch(withStubs: stubData, toUrl: url)
        
        let tablesQuery = app.tables
        expect(tablesQuery.staticTexts["Pickpocket"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["Backstab"].waitForExistence(timeout: 2)).to(beTrue())
    }
    
    func testSkillsLockedLevel() throws {
        var userData = loadFile(name: "user")
        var statsDict = (userData["stats"] as! Dictionary<String, Any>)
        statsDict["lvl"] = 12 as AnyObject
        userData["stats"] = statsDict as AnyObject
        stubData["user"] = stubDictionaryResponse(dictionary: userData)
        app.launch(withStubs: stubData, toUrl: url)
        
        let tablesQuery = app.tables
        expect(tablesQuery.staticTexts["Burst of Flames"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["Ethereal Surge"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["Earthquake"].exists).to(beFalse())
        expect(tablesQuery.staticTexts["Unlocks at level 13"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["Unlocks at level 14"].waitForExistence(timeout: 2)).to(beTrue())
    }
    
    func testSkillsLockedUnder10() throws {
        var userData = loadFile(name: "user")
        var statsDict = (userData["stats"] as! Dictionary<String, Any>)
        statsDict["lvl"] = 9 as AnyObject
        userData["stats"] = statsDict as AnyObject
        stubData["user"] = stubDictionaryResponse(dictionary: userData)
        app.launch(withStubs: stubData, toUrl: url)
        
        let tablesQuery = app.tables
        expect(tablesQuery.staticTexts["Unlocks after selecting a class"].waitForExistence(timeout: 2)).to(beTrue())
    }
    
    func testSkillsLockedDisabled() throws {
        var userData = loadFile(name: "user")
        var statsDict = (userData["stats"] as! Dictionary<String, Any>)
        statsDict["lvl"] = 9 as AnyObject
        userData["stats"] = statsDict as AnyObject
        stubData["user"] = stubDictionaryResponse(dictionary: userData)
        app.launch(withStubs: stubData, toUrl: url)
        
        let tablesQuery = app.tables
        expect(tablesQuery.staticTexts["Unlocks after selecting a class"].waitForExistence(timeout: 2)).to(beTrue())
    }
    
    func testListTransformationItems() throws {
        app.launch(withStubs: stubData, toUrl: url)
        
        let tablesQuery = app.tables
        expect(tablesQuery.staticTexts["Seafoam"].waitForExistence(timeout: 2)).to(beTrue())
        expect(tablesQuery.staticTexts["Spooky Sparkles"].waitForExistence(timeout: 2)).to(beTrue())
    }
}
