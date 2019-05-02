//
//  LoginViewModel.swift
//  Habitica
//
//  Created by Phillip Thelen on 25/12/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import ReactiveCocoa
import ReactiveSwift
import AppAuth
import Keys
import FBSDKLoginKit

enum LoginViewAuthType {
    case none
    case login
    case register
}

private struct AuthValues {
    var authType: LoginViewAuthType = LoginViewAuthType.none
    var email: String?
    var username: String?
    var password: String?
    var passwordRepeat: String?
}

protocol  LoginViewModelInputs {
    func authTypeChanged()
    func setAuthType(authType: LoginViewAuthType)

    func emailChanged(email: String?)
    func usernameChanged(username: String?)
    func passwordChanged(password: String?)
    func passwordRepeatChanged(passwordRepeat: String?)

    func onePassword(isAvailable: Bool)
    func onePasswordTapped()

    func loginButtonPressed()
    func googleLoginButtonPressed()
    func facebookLoginButtonPressed()

    func onSuccessfulLogin()

    func setViewController(viewController: LoginTableViewController)
}

protocol LoginViewModelOutputs {

    var authTypeButtonTitle: Signal<String, Never> { get }
    var usernameFieldTitle: Signal<String, Never> { get }
    var loginButtonTitle: Signal<String, Never> { get }
    var isFormValid: Signal<Bool, Never> { get }

    var emailFieldVisibility: Signal<Bool, Never> { get }
    var passwordRepeatFieldVisibility: Signal<Bool, Never> { get }
    var passwordFieldReturnButtonIsDone: Signal<Bool, Never> { get }
    var passwordRepeatFieldReturnButtonIsDone: Signal<Bool, Never> { get }

    var onePasswordButtonHidden: Signal<Bool, Never> { get }
    var onePasswordFindLogin: Signal<(), Never> { get }

    var emailText: Signal<String, Never> { get }
    var usernameText: Signal<String, Never> { get }
    var passwordText: Signal<String, Never> { get }
    var passwordRepeatText: Signal<String, Never> { get }

    var showError: Signal<String, Never> { get }
    var showNextViewController: Signal<String, Never> { get }
    
    var formVisibility: Signal<Bool, Never> { get }
    var beginButtonsVisibility: Signal<Bool, Never> { get }
    var backButtonVisibility: Signal<Bool, Never> { get }
    var backgroundScrolledToTop: Signal<Bool, Never> { get }

    var loadingIndicatorVisibility: Signal<Bool, Never> { get }
    
    var currentAuthType: LoginViewAuthType { get }
    var arePasswordsSame: Signal<Bool, Never> { get }
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {
    
    private let userRepository = UserRepository()

    //swiftlint:disable function_body_length
    //swiftlint:disable cyclomatic_complexity
    init() {
        let authValues = Signal.combineLatest(
            self.authTypeProperty.signal,
            Signal.merge(self.emailChangedProperty.signal, self.prefillEmailProperty.signal),
            Signal.merge(self.usernameChangedProperty.signal, self.prefillUsernameProperty.signal),
            Signal.merge(self.passwordChangedProperty.signal, self.prefillPasswordProperty.signal),
            Signal.merge(self.passwordRepeatChangedProperty.signal, self.prefillPasswordRepeatProperty.signal)
        )

        self.authValuesProperty = Property<AuthValues?>(initial: AuthValues(), then: authValues.map {
            return AuthValues(authType: $0.0, email: $0.1, username: $0.2, password: $0.3, passwordRepeat: $0.4)
        })

        self.authTypeButtonTitle = self.authTypeProperty.signal.map { value -> String? in
            switch value {
            case .login:
                return L10n.Login.register
            case .register:
                return L10n.Login.login
            case .none:
                return nil
            }
        }.skipNil()

        self.loginButtonTitle = self.authTypeProperty.signal.map { value -> String? in
            switch value {
            case .login:
                return L10n.Login.login
            case .register:
                return L10n.Login.register
            case .none:
                return nil
            }
        }.skipNil()

        self.usernameFieldTitle = self.authTypeProperty.signal.map { value -> String? in
            switch value {
            case .login:
                return L10n.Login.emailUsername
            case .register:
                return L10n.username
            case .none:
                return nil
            }
        }.skipNil()

        let isRegistering = self.authTypeProperty.signal.map { value -> Bool? in
            switch value {
            case .login:
                return false
            case .register:
                return true
            case .none:
                return nil
            }
        }.skipNil()

        self.emailFieldVisibility = isRegistering
        self.passwordRepeatFieldVisibility = isRegistering
        self.passwordFieldReturnButtonIsDone = isRegistering.map({ value -> Bool in
            return !value
        })
        self.passwordRepeatFieldReturnButtonIsDone = isRegistering

        self.arePasswordsSame = Signal.combineLatest(passwordChangedProperty.signal, passwordRepeatChangedProperty.signal).map({ (password, passwordRepeat) -> Bool in
            return password == passwordRepeat
        })
        
        self.isFormValid = authValues.map(isValid)

        self.emailChangedProperty.value = ""
        self.usernameChangedProperty.value = ""
        self.passwordChangedProperty.value = ""
        self.passwordRepeatChangedProperty.value = ""

        self.usernameText = self.prefillUsernameProperty.signal
        self.emailText = self.prefillEmailProperty.signal
        self.passwordText = self.prefillPasswordProperty.signal
        self.passwordRepeatText = self.prefillPasswordRepeatProperty.signal

        self.onePasswordButtonHidden = self.onePasswordAvailable.signal
            .combineLatest(with: self.authTypeProperty.signal)
            .map { (isAvailable, authType) in
            return !isAvailable || authType == .none
        }
        self.onePasswordFindLogin = self.onePasswordTappedProperty.signal

        let (showNextViewControllerSignal, showNextViewControllerObserver) = Signal<(), Never>.pipe()
        self.showNextViewControllerObserver = showNextViewControllerObserver
        self.showNextViewController = Signal.merge(
            showNextViewControllerSignal,
            self.onSuccessfulLoginProperty.signal
            ).combineLatest(with: self.authTypeProperty.signal)
        .map({ (_, authType) -> String in
            if authType == .login {
                return "MainSegue"
            } else {
                return "SetupSegue"
            }
        })
        (self.showError, self.showErrorObserver) = Signal.pipe()

        (self.loadingIndicatorVisibility, self.loadingIndicatorVisibilityObserver) = Signal<Bool, Never>.pipe()
        
        self.formVisibility = self.authTypeProperty.signal.map({ (authType) -> Bool in
            return authType != .none
        })
        self.beginButtonsVisibility = self.authTypeProperty.signal.map({ (authType) -> Bool in
            return authType == .none
        })
        self.backButtonVisibility = self.authTypeProperty.signal.map({ (authType) -> Bool in
            return authType != .none
        })
        self.backgroundScrolledToTop = self.authTypeProperty.signal.map({ (authType) -> Bool in
            return authType != .none
        })
    }

    func setDefaultValues() {

    }

    private let authTypeProperty = MutableProperty<LoginViewAuthType>(LoginViewAuthType.none)
    internal func authTypeChanged() {
        if authTypeProperty.value == LoginViewAuthType.login {
            authTypeProperty.value = LoginViewAuthType.register
        } else {
            authTypeProperty.value = LoginViewAuthType.login
        }
    }

    func setAuthType(authType: LoginViewAuthType) {
        self.authTypeProperty.value = authType
    }

    private let emailChangedProperty = MutableProperty<String>("")
    func emailChanged(email: String?) {
        if email != nil {
            self.emailChangedProperty.value = email ?? ""
        }
    }

    private let usernameChangedProperty = MutableProperty<String>("")
    func usernameChanged(username: String?) {
        if username != nil {
            self.usernameChangedProperty.value = username ?? ""
        }
    }

    private let passwordChangedProperty = MutableProperty<String>("")
    func passwordChanged(password: String?) {
        if password != nil {
            self.passwordChangedProperty.value = password ?? ""
        }
    }

    private let passwordRepeatChangedProperty = MutableProperty<String>("")
    func passwordRepeatChanged(passwordRepeat: String?) {
        if passwordRepeat != nil {
            self.passwordRepeatChangedProperty.value = passwordRepeat ?? ""
        }
    }

    private let onePasswordAvailable = MutableProperty<Bool>(false)
    func onePassword(isAvailable: Bool) {
        self.onePasswordAvailable.value = isAvailable
    }

    private let onePasswordTappedProperty = MutableProperty(())
    func onePasswordTapped() {
        self.onePasswordTappedProperty.value = ()
    }

    private let prefillUsernameProperty = MutableProperty<String>("")
    private let prefillEmailProperty = MutableProperty<String>("")
    private let prefillPasswordProperty = MutableProperty<String>("")
    private let prefillPasswordRepeatProperty = MutableProperty<String>("")
    public func onePasswordFoundLogin(username: String, password: String) {
        self.prefillUsernameProperty.value = username
        self.prefillPasswordProperty.value = password
        self.prefillPasswordRepeatProperty.value = password
    }

    private let authValuesProperty: Property<AuthValues?>
    func loginButtonPressed() {
        guard let authValues = self.authValuesProperty.value else {
            return
        }

        if isValid(authType: authValues.authType,
                   email: authValues.email,
                   username: authValues.username,
                   password: authValues.password,
                   passwordRepeat: authValues.passwordRepeat) {
            self.loadingIndicatorVisibilityObserver.send(value: true)
            if authValues.authType == .login {
                userRepository.login(username: authValues.username ?? "", password: authValues.password ?? "").observeValues { loginResult in
                    if loginResult != nil {
                        self.onSuccessfulLogin()
                    } else {
                        self.loadingIndicatorVisibilityObserver.send(value: false)
                    }
                }
            } else {
                userRepository.register(username: authValues.username ?? "",
                                        password: authValues.password ?? "",
                                        confirmPassword: authValues.passwordRepeat ?? "",
                                        email: authValues.email ?? "").observeValues { loginResult in
                    if loginResult != nil {
                        self.onSuccessfulLogin()
                    } else {
                        self.loadingIndicatorVisibilityObserver.send(value: false)
                    }
                }
            }
        } else {
            if authValues.authType == .register && authValues.password != authValues.passwordRepeat {
                showErrorObserver.send(value: L10n.Login.passwordConfirmError)
            }
        }
    }

    private let googleLoginButtonPressedProperty = MutableProperty(())
    func googleLoginButtonPressed() {
        guard let authorizationEndpoint = URL(string: "https://accounts.google.com/o/oauth2/v2/auth") else {
            return
        }
        guard let tokenEndpoint = URL(string: "https://www.googleapis.com/oauth2/v4/token") else {
            return
        }
        let keys = HabiticaKeys()
        guard let redirectUrl = URL(string: keys.googleRedirectUrl) else {
            return
        }
        let configuration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint, tokenEndpoint: tokenEndpoint)

        let request = OIDAuthorizationRequest.init(configuration: configuration,
                                                   clientId: keys.googleClient,
                                                   scopes: [OIDScopeOpenID, OIDScopeProfile],
                                                   redirectURL: redirectUrl,
                                                   responseType: OIDResponseTypeCode,
                                                   additionalParameters: nil)

        // performs authentication request
        if let appDelegate = UIApplication.shared.delegate as? HRPGAppDelegate {
            guard let viewController = self.viewController else {
                return
            }
            appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: viewController, callback: {[weak self] (authState, _) in
                if authState != nil {
                    self?.userRepository.login(userID: "", network: "google", accessToken: authState?.lastTokenResponse?.accessToken ?? "").observeResult { (result) in
                        switch result {
                        case .success:
                            self?.onSuccessfulLogin()
                        case .failure:
                            self?.showErrorObserver.send(value: L10n.Login.authenticationError)
                        }
                    }
                }
            })
        }
    }

    private let onSuccessfulLoginProperty = MutableProperty(())
    func onSuccessfulLogin() {
        userRepository.retrieveUser().observeCompleted {[weak self] in
            self?.onSuccessfulLoginProperty.value = ()
        }
    }

    private let facebookLoginButtonPressedProperty = MutableProperty(())
    func facebookLoginButtonPressed() {
        let fbManager = LoginManager()
        fbManager.logIn(permissions: ["public_profile", "email"], from: viewController) { [weak self] (result, error) in
            if error != nil || result?.isCancelled == true {
                // If there is an error or the user cancelled login

            } else if let userId = result?.token?.userID, let token = result?.token?.tokenString {
                self?.userRepository.login(userID: userId, network: "facebook", accessToken: token).observeResult { (result) in
                    switch result {
                    case .success:
                        self?.onSuccessfulLogin()
                    case .failure:
                        self?.showErrorObserver.send(value: L10n.Login.authenticationError)
                    }
                }
            }
        }
    }

    private weak var viewController: LoginTableViewController?
    func setViewController(viewController: LoginTableViewController) {
        self.viewController = viewController
    }

    internal var authTypeButtonTitle: Signal<String, Never>
    internal var loginButtonTitle: Signal<String, Never>
    internal var usernameFieldTitle: Signal<String, Never>
    internal var isFormValid: Signal<Bool, Never>
    internal var emailFieldVisibility: Signal<Bool, Never>
    internal var passwordRepeatFieldVisibility: Signal<Bool, Never>
    internal var passwordFieldReturnButtonIsDone: Signal<Bool, Never>
    internal var passwordRepeatFieldReturnButtonIsDone: Signal<Bool, Never>
    internal var onePasswordButtonHidden: Signal<Bool, Never>
    internal var showError: Signal<String, Never>
    internal var showNextViewController: Signal<String, Never>
    internal var loadingIndicatorVisibility: Signal<Bool, Never>
    internal var onePasswordFindLogin: Signal<(), Never>
    internal var arePasswordsSame: Signal<Bool, Never>
    
    internal var formVisibility: Signal<Bool, Never>
    internal var beginButtonsVisibility: Signal<Bool, Never>
    internal var backButtonVisibility: Signal<Bool, Never>
    var backgroundScrolledToTop: Signal<Bool, Never>

    internal var emailText: Signal<String, Never>
    internal var usernameText: Signal<String, Never>
    internal var passwordText: Signal<String, Never>
    internal var passwordRepeatText: Signal<String, Never>

    private var showNextViewControllerObserver: Signal<(), Never>.Observer
    private var showErrorObserver: Signal<String, Never>.Observer
    private var loadingIndicatorVisibilityObserver: Signal<Bool, Never>.Observer

    internal var inputs: LoginViewModelInputs { return self }
    internal var outputs: LoginViewModelOutputs { return self }
    
    var currentAuthType: LoginViewAuthType {
            return authTypeProperty.value
    }
}

func isValid(authType: LoginViewAuthType, email: String?, username: String?, password: String?, passwordRepeat: String?) -> Bool {

    if username?.isEmpty != false || password?.isEmpty != false {
        return false
    }

    if authType == .register {
        if !isValidEmail(email: email) {
            return false
        }

        if password?.isEmpty != true && password != passwordRepeat {
            return false
        }
    }

    return true
}

func isValidEmail(email: String?) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}
