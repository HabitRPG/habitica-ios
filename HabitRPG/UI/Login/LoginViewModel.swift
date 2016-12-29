//
//  LoginViewModel.swift
//  Habitica
//
//  Created by Phillip Thelen on 25/12/2016.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

import ReactiveCocoa
import ReactiveSwift
import Result

enum LoginViewAuthType {
    case Login
    case Register
}

protocol  LoginViewModelInputs {
    func authTypeChanged()
    func setAuthType(authType: LoginViewAuthType)
    
    func emailChanged(email: String?)
    func usernameChanged(username: String?)
    func passwordChanged(password: String?)
    func passwordRepeatChanged(passwordRepeat: String?)
    
    func onePassword(isAvailable: Bool)
}

protocol LoginViewModelOutputs {
    
    var authTypeButtonTitle: Signal<String, NoError> { get }
    var usernameFieldTitle: Signal<String, NoError> { get }
    var loginButtonTitle: Signal<String, NoError> { get }
    var isFormValid: Signal<Bool, NoError> { get }
    
    var emailFieldVisibility: Signal<Bool, NoError> { get }
    var passwordRepeatFieldVisibility: Signal<Bool, NoError> { get }
    
    var onePasswordButtonHidden: Signal<Bool, NoError> { get }
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {
    
    init() {
        self.authTypeButtonTitle = self.authTypeProperty.signal.skipNil().map { value in
            switch value {
            case .Login:
                return "Register".localized
            case .Register:
                return "Login".localized
            }
        }
        
        self.loginButtonTitle = self.authTypeProperty.signal.skipNil().map { value in
            switch value {
            case .Login:
                return "Login".localized
            case .Register:
                return "Register".localized
            }
        }
        
        self.usernameFieldTitle = self.authTypeProperty.signal.skipNil().map { value in
            switch value {
            case .Login:
                return "Email / Username".localized
            case .Register:
                return "Username".localized
            }
        }
        
        let isRegistering = self.authTypeProperty.signal.skipNil().map { value -> Bool in
            switch value {
            case .Login:
                return false
            case .Register:
                return true
            }
        }
        
        self.emailFieldVisibility = isRegistering;
        self.passwordRepeatFieldVisibility = isRegistering;
        
        self.isFormValid = Signal.combineLatest(
            self.authTypeProperty.signal.skipNil(),
            self.emailChangedProperty.signal.skipNil(),
            self.usernameChangedProperty.signal.skipNil(),
            self.passwordChangedProperty.signal.skipNil(),
            self.passwordRepeatChangedProperty.signal.skipNil()
        ).map(isValid)
        
        self.emailChangedProperty.value = ""
        self.usernameChangedProperty.value = ""
        self.passwordChangedProperty.value = ""
        self.passwordRepeatChangedProperty.value = ""
        
        self.onePasswordButtonHidden = self.onePasswordAvailable.signal.map { value in
            return !value
        }
    }
    
    private let authTypeProperty = MutableProperty<LoginViewAuthType?>(nil)
    internal func authTypeChanged() {
        if (authTypeProperty.value == LoginViewAuthType.Login) {
            authTypeProperty.value = LoginViewAuthType.Register
        } else {
            authTypeProperty.value = LoginViewAuthType.Login
        }
    }
    
    func setAuthType(authType: LoginViewAuthType) {
        self.authTypeProperty.value = authType
    }
    
    private let emailChangedProperty = MutableProperty<String?>(nil)
    func emailChanged(email: String?) {
        self.emailChangedProperty.value = email
    }

    private let usernameChangedProperty = MutableProperty<String?>(nil)
    func usernameChanged(username: String?) {
        self.usernameChangedProperty.value = username
    }
    
    private let passwordChangedProperty = MutableProperty<String?>(nil)
    func passwordChanged(password: String?) {
        self.passwordChangedProperty.value = password
    }
    
    private let passwordRepeatChangedProperty = MutableProperty<String?>(nil)
    func passwordRepeatChanged(passwordRepeat: String?) {
        self.passwordRepeatChangedProperty.value = passwordRepeat
    }
    
    private let onePasswordAvailable = MutableProperty<Bool>(false)
    func onePassword(isAvailable: Bool) {
        self.onePasswordAvailable.value = isAvailable;
    }

    
    internal var authTypeButtonTitle: Signal<String, NoError>
    internal var loginButtonTitle: Signal<String, NoError>
    internal var usernameFieldTitle: Signal<String, NoError>
    internal var isFormValid: Signal<Bool, NoError>
    internal var emailFieldVisibility: Signal<Bool, NoError>
    internal var passwordRepeatFieldVisibility: Signal<Bool, NoError>
    internal var onePasswordButtonHidden: Signal<Bool, NoError>
    
    internal var inputs: LoginViewModelInputs { return self }
    internal var outputs: LoginViewModelOutputs { return self }
}

func isValid(authType: LoginViewAuthType, email: String, username: String, password: String, passwordRepeat: String) -> Bool {
    
    if (username.characters.isEmpty || password.characters.isEmpty) {
        return false
    }
    
    if (authType == .Register) {
        if (!isValidEmail(email: email)) {
            return false
        }
        
        if (!password.characters.isEmpty && password != passwordRepeat) {
            return false
        }
    }
    
    return true
}

func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}
