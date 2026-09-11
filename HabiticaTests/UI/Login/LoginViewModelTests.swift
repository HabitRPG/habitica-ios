//
//  LoginViewModelTests.swift
//  Habitica
//
//  Created by Phillip Thelen on 29/12/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import XCTest
@testable import Habitica

class LoginViewModelTests: XCTestCase {

    var viewModel = LoginViewModel()

    override func setUp() {
        super.setUp()
        viewModel = LoginViewModel()
    }

    func testCanSubmitUsernameRequiresAcceptedTermsAndValidUsername() {
        XCTAssertFalse(viewModel.canSubmitUsername)

        viewModel.acceptedTerms = true
        XCTAssertFalse(viewModel.canSubmitUsername)

        viewModel.usernameValid = false
        XCTAssertFalse(viewModel.canSubmitUsername)

        viewModel.usernameValid = true
        XCTAssertTrue(viewModel.canSubmitUsername)

        viewModel.acceptedTerms = false
        XCTAssertFalse(viewModel.canSubmitUsername)
    }

    func testVerifyUsernameResetsStateForEmptyUsername() {
        viewModel.usernameValid = true
        viewModel.usernameIssues = ["taken"]
        viewModel.username = ""

        viewModel.verifyUsername()

        XCTAssertNil(viewModel.usernameValid)
        XCTAssertEqual(viewModel.usernameIssues, [])
    }

    func testPrefillUsernameDoesNothingForInvalidEmail() {
        viewModel.email = "not-an-email"
        viewModel.username = ""

        viewModel.prefillUsername()

        XCTAssertEqual(viewModel.username, "")
    }

    func testInitialState() {
        XCTAssertFalse(viewModel.showUsernameView)
        XCTAssertFalse(viewModel.acceptedTerms)
        XCTAssertFalse(viewModel.needsEmailField)
        XCTAssertNil(viewModel.usernameValid)
        XCTAssertEqual(viewModel.usernameIssues, [])
    }
}

class LoginViewModelJWTTests: XCTestCase {

    func testDecodeJWTTokenExtractsPayloadClaims() {
        let jwt = "header.eyJlbWFpbCI6ICJ0ZXN0QGV4YW1wbGUuY29tIiwgInN1YiI6ICIxMjM0NTY3ODkwIn0.signature"

        let payload = decode(jwtToken: jwt)

        XCTAssertEqual(payload["email"] as? String, "test@example.com")
        XCTAssertEqual(payload["sub"] as? String, "1234567890")
    }

    func testDecodeJWTTokenReturnsEmptyDictionaryForInvalidPayload() {
        let jwt = "header.not-valid-base64!!!.signature"

        let payload = decode(jwtToken: jwt)

        XCTAssertTrue(payload.isEmpty)
    }

    func testIsValidEmailFunction() {
        XCTAssertTrue(isValidEmail(email: "test@example.com"))
        XCTAssertFalse(isValidEmail(email: "not-an-email"))
        XCTAssertFalse(isValidEmail(email: nil))
    }
}
