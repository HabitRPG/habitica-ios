//
//  XCUIApplication-Extensions.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 09.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest
import Habitica_Models

extension XCUIApplication {
    func launch(withStubs stubData: [String: CallStub]?, toUrl: String? = nil) {
        if let stubData = stubData {
            launchEnvironment["STUB_DATA"] = String(data: try! JSONEncoder().encode(stubData), encoding: .utf8)
        }
        if let  url = toUrl {
            launchEnvironment["TARGET_URL"] = url
        }
        launch()
    }
}
