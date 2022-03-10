//
//  HabiticaAppTests.swift
//  HabiticaTests
//
//  Created by Phillip Thelen on 09.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest

class HabiticaAppTests: XCTestCase {
    var app = XCUIApplication()
    
    var stubData = [String: String]()
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false
        app.launchArguments.append("UI_TESTING")
        app.launchEnvironment["userid"] = "MOCK"
        app.launchEnvironment["apikey"] = "MOCK"
    }

    private func wrapResponse(string: String) -> String {
        return "{\"data\": \(string)}"
    }
    
    func stubFileResponse(name: String) -> String {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return wrapResponse(string: String(data: data, encoding: .utf8)!)
    }
    
    func stubEmptyListResponse() -> String {
        return wrapResponse(string: "[]")
    }
    func stubEmptyObjectResponse() -> String {
        return wrapResponse(string: "{}")
    }
}
