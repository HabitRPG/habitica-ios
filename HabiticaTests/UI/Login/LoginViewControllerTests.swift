//
//  LoginViewControllerTests.swift
//  Habitica
//
//  Created by Phillip Thelen on 29/12/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import XCTest
@testable import Habitica
import UIKit

class LoginViewControllerTests: XCTestCase {

    var loginViewController: LoginTableViewController?

    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)

        self.loginViewController = UIStoryboard(name: "Intro", bundle: Bundle(identifier: Bundle.main.bundleIdentifier!))
            .instantiateViewController(withIdentifier: "LoginTableViewController") as? LoginTableViewController
        //need this to properly initialize view
        let _ = self.loginViewController?.view
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }

    func testLoadsLoginViewController() {
        XCTAssertNotNil(loginViewController)
    }

    func testConnectsOutlets() {
        XCTAssertNotNil(loginViewController?.backgroundScrollView)
    }

}
