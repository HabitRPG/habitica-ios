//
//  LoginViewModelTests.swift
//  Habitica
//
//  Created by Phillip Thelen on 29/12/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import XCTest
@testable import Habitica
@testable import ReactiveCocoa
@testable import ReactiveSwift
@testable import Result

class LoginViewModelTests: HabiticaTests {
    
    var viewModel = LoginViewModel()
    
    private let isFormValidObserver = TestObserver<Bool, NoError>()
    private let emailVisibilityObserver = TestObserver<Bool, NoError>()
    private let passwordRepeatVisibilityObserver = TestObserver<Bool, NoError>()
    private let loginButtonTitleObserver = TestObserver<String, NoError>()
    private let usernameFieldTitleObserver = TestObserver<String, NoError>()
    private let authTypeButtonTitleObserver = TestObserver<String, NoError>()
    private let onePasswordHiddenObserver = TestObserver<Bool, NoError>()
    
    override func setUp() {
        super.setUp()
        self.viewModel = LoginViewModel()
        
        self.viewModel.outputs.isFormValid.observe(self.isFormValidObserver.observer)
        self.viewModel.outputs.emailFieldVisibility.observe(self.emailVisibilityObserver.observer)
        self.viewModel.outputs.passwordRepeatFieldVisibility.observe(self.passwordRepeatVisibilityObserver.observer)
        self.viewModel.outputs.loginButtonTitle.observe(self.loginButtonTitleObserver.observer)
        self.viewModel.outputs.usernameFieldTitle.observe(self.usernameFieldTitleObserver.observer)
        self.viewModel.outputs.authTypeButtonTitle.observe(self.authTypeButtonTitleObserver.observer)
        self.viewModel.outputs.onePasswordButtonHidden.observe(self.onePasswordHiddenObserver.observer)
    }
    
    func testShowsEmptyLoginForm() {
        self.viewModel.inputs.setAuthType(authType: LoginViewAuthType.login)
        self.isFormValidObserver.assertLastValue(value: false)
        self.emailVisibilityObserver.assertLastValue(value: false)
        self.passwordRepeatVisibilityObserver.assertLastValue(value: false)
    }
    
    func testShowsEmptyRegisterForm() {
        self.viewModel.inputs.setAuthType(authType: LoginViewAuthType.register)
        self.isFormValidObserver.assertLastValue(value: false)
        self.emailVisibilityObserver.assertLastValue(value: true)
        self.passwordRepeatVisibilityObserver.assertLastValue(value: true)
    }
    
    func testValidatesLoginForm() {
        self.viewModel.inputs.setAuthType(authType: LoginViewAuthType.login)
        self.isFormValidObserver.assertLastValue(value: false)
        self.viewModel.inputs.usernameChanged(username: "test")
        self.viewModel.inputs.passwordChanged(password: "test")
        
        self.isFormValidObserver.assertLastValue(value: true)
    }
    
    func testValidatesRegisterForm() {
        self.viewModel.inputs.setAuthType(authType: LoginViewAuthType.register)
        self.isFormValidObserver.assertLastValue(value: false)
        self.viewModel.inputs.usernameChanged(username: "test")
        self.viewModel.inputs.emailChanged(email: "test@test.com")
        self.viewModel.inputs.passwordChanged(password: "test")
        self.viewModel.inputs.passwordRepeatChanged(passwordRepeat: "test")
        
        self.isFormValidObserver.assertLastValue(value: true)
    }
    
    func testInvalidatesRegisterFormNonmatchingPasswords() {
        self.viewModel.inputs.setAuthType(authType: LoginViewAuthType.register)
        self.isFormValidObserver.assertLastValue(value: false)
        self.viewModel.inputs.usernameChanged(username: "test")
        self.viewModel.inputs.emailChanged(email: "test@test.com")
        self.viewModel.inputs.passwordChanged(password: "test")
        self.viewModel.inputs.passwordRepeatChanged(passwordRepeat: "test2")
        
        self.isFormValidObserver.assertLastValue(value: false)
    }
    
    func testOnePasswordButtonVisibility() {
        self.viewModel.inputs.setAuthType(authType: .login)
        self.viewModel.inputs.onePassword(isAvailable: true)
        self.onePasswordHiddenObserver.assertLastValue(value: false)
        self.viewModel.inputs.onePassword(isAvailable: false)
        self.onePasswordHiddenObserver.assertLastValue(value: true)
    }
}
