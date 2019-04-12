//
//  Habitica_Snapshots.swift
//  Habitica Snapshots
//
//  Created by Phillip Thelen on 11.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import XCTest

class Habitica_Snapshots: XCTestCase {

    override func setUp() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        snapshot("01Intro")
    }

}
