//
//  Habitica_UI_Tests.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 09.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest

class Habitica_UI_Tests: XCTestCase {

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
