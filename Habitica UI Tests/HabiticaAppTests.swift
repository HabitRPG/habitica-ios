//
//  HabiticaAppTests.swift
//  HabiticaTests
//
//  Created by Phillip Thelen on 09.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest
import Habitica_Models

class HabiticaAppTests: XCTestCase {
    static let contentStub = stubFileResponse(name: "content")
    static let worldStateStub = stubFileResponse(name: "world-state")
    
    var app = XCUIApplication()
    
    var stubData = [String: CallStub]()
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false
        app.launchArguments.append("UI_TESTING")
        app.launchEnvironment["userid"] = "MOCK"
        app.launchEnvironment["apikey"] = "MOCK"
    }
    
    override func setUp() {
        super.setUp()
        stubData = [
            "user": HabiticaAppTests.stubEmptyListResponse(),
            "tasks/user": HabiticaAppTests.stubEmptyListResponse(),
            "inbox/conversations": HabiticaAppTests.stubEmptyListResponse(),
            //"content": HabiticaAppTests.contentStub,
            "world-state": HabiticaAppTests.worldStateStub
        ]
    }

    static func wrapResponse(string: String) -> String {
        return "{\"data\": \(string)}"
    }
    
    static func stubFileResponse(name: String) -> CallStub {
        let bundle = Bundle(for: self)
        let url = bundle.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return CallStub(response: wrapResponse(string: String(data: data, encoding: .utf8)!))
    }
    
    static func stubEmptyListResponse() -> CallStub {
        return CallStub(response: wrapResponse(string: "[]"))
    }
    static func stubEmptyObjectResponse() -> CallStub {
        return CallStub(response: wrapResponse(string: "{}"))
    }
    
    static func stubResponse(string: String) -> CallStub {
        return CallStub(response: wrapResponse(string: string))
    }
    
    static func stubDictionaryResponse(dictionary: [String: AnyObject]) -> CallStub {
        return CallStub(response: HabiticaAppTests.wrapResponse(string: String(data: try! JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed), encoding: .utf8)!))
    }
    
    func stubFileResponse(name: String) -> CallStub {
        return HabiticaAppTests.stubFileResponse(name: name)
    }
    
    func stubEmptyListResponse() -> CallStub {
        return HabiticaAppTests.stubEmptyListResponse()
    }
    func stubEmptyObjectResponse() -> CallStub {
        return HabiticaAppTests.stubEmptyObjectResponse()
    }
    
    func stubResponse(string: String) -> CallStub {
        return HabiticaAppTests.stubResponse(string: string)
    }
    
    func stubDictionaryResponse(dictionary: [String: AnyObject]) -> CallStub {
        return HabiticaAppTests.stubDictionaryResponse(dictionary: dictionary)
    }
    
    func loadFile(name: String) -> Dictionary<String, AnyObject> {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url, options: .mappedIfSafe)
        let jsonResult = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        return jsonResult as! Dictionary<String, AnyObject>
    }
}
