//
//  Habitica_Snapshots.swift
//  Habitica Snapshots
//
//  Created by Phillip on 31.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import XCTest

class Habitica_Snapshots: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
    }
    
}
