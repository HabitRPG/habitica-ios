//
//  XCUIApplication-Extensions.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 09.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    func launch(withStubs stubData: [String: String]?) {
        if let stubData = stubData {
            launchEnvironment["STUB_DATA"] = String(data: try! JSONEncoder().encode(stubData), encoding: .utf8)
        }
        
        launch()
    }
}
