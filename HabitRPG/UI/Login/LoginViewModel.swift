//
//  LoginViewModel.swift
//  Habitica
//
//  Created by Phillip Thelen on 25/12/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import ReactiveCocoa
import ReactiveSwift
import Result
import AppAuth
import Keys
import FBSDKLoginKit

enum LoginViewAuthType {
    case none
    case login
    case register
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

    func setSharedManager(sharedManager: HRPGManager?)
    func setViewController(viewController: LoginTableViewController)
}

protocol LoginViewModelOutputs {

    var authTypeButtonTitle: Signal<String, NoError> { get }
    var usernameFieldTitle: Signal<String, NoError> { get }
    var loginButtonTitle: Signal<String, NoError> { get }
    var isFormValid: Signal<Bool, NoError> { get }

    var emailFieldVisibility: Signal<Bool, NoError> { get }
    var passwordRepeatFieldVisibility: Signal<Bool, NoError> { get }
    var passwordFieldReturnButtonIsDone: Signal<Bool, NoError> { get }
    var passwordRepeatFieldReturnButtonIsDone: Signal<Bool, NoError> { get }

    var onePasswordButtonHidden: Signal<Bool, NoError> { get }
    var onePasswordFindLogin: Signal<(), NoError> { get }

    var emailText: Signal<String, NoError> { get }
    var usernameText: Signal<String, NoError> { get }
    var passwordText: Signal<String, NoError> { get }
    var passwordRepeatText: Signal<String, NoError> { get }

    var showError: Signal<String, NoError> { get }
    var showNextViewController: Signal<String, NoError> { get }
    
    var formVisibility: Signal<Bool, NoError> { get }
    var beginButtonsVisibility: Signal<Bool, NoError> { get }
    var backButtonVisibility: Signal<Bool, NoError> { get }
    var backgroundScrolledToTop: Signal<Bool, NoError> { get }

    var loadingIndicatorVisibility: Signal<Bool, NoError> { get }
    
    var currentAuthType: LoginViewAuthType { get }
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {

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

        self.authValuesProperty = Property(initial: nil, then: authValues.map { $0 })

        self.authTypeButtonTitle = self.authTypeProperty.signal.map { value -> String? in
            switch value {
            case .login:
                return "Register".localized
            case .register:
                return "Login".localized
            case .none:
                return nil
            }
        }.skipNil()

        self.loginButtonTitle = self.authTypeProperty.signal.map { value -> String? in
            switch value {
            case .login:
                return "Login".localized
            case .register:
                return "Register".localized
            case .none:
                return nil
            }
        }.skipNil()

        self.usernameFieldTitle = self.authTypeProperty.signal.map { value -> String? in
            switch value {
            case .login:
                return "Email / Username".localized
            case .register:
                return "Username".localized
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
        self.passwordRepeatFieldReturnButtonIsDone = isRegistering.map({ value -> Bool in
            return value
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

        let (showNextViewControllerSignal, showNextViewControllerObserver) = Signal<(), NoError>.pipe()
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

        (self.loadingIndicatorVisibility, self.loadingIndicatorVisibilityObserver) = Signal<Bool, NoError>.pipe()
        
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

    //swiftlint:disable large_tuple
    private let authValuesProperty: Property<(authType: LoginViewAuthType, email: String, username: String, password: String, passwordRepeat: String)?>
    func loginButtonPressed() {
        guard let (authType, email, username, password, passwordRepeat) = self.authValuesProperty.value else {
            return
        }

        if isValid(authType: authType,
                   email: email,
                   username: username,
                   password: password,
                   passwordRepeat: passwordRepeat) {
            self.loadingIndicatorVisibilityObserver.send(value: true)
            let authValues = self.authValuesProperty.value
            if self.authTypeProperty.value == .login {
                self.sharedManager?.loginUser(authValues?.username, withPassword: authValues?.password, onSuccess: {
                    self.onSuccessfulLogin()
                }, onError: {
                    self.loadingIndicatorVisibilityObserver.send(value: false)
                    self.showErrorObserver.send(value: "Invalid username or password".localized)
                })
            } else {
                self.sharedManager?.registerUser(authValues?.username, withPassword: authValues?.password, withEmail: authValues?.password, onSuccess: {
                    self.onSuccessfulLogin()
                }, onError: { errorMessage in
                    self.loadingIndicatorVisibilityObserver.send(value: false)
                    if let message = errorMessage {
                        self.showErrorObserver.send(value: message)
                    }
                })
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
                    self?.sharedManager?.loginUserSocial("", withNetwork: "google", withAccessToken: authState?.lastTokenResponse?.accessToken, onSuccess: {
                        self?.onSuccessfulLogin()
                    }, onError: { _ in
                        self?.showErrorObserver.send(value: "There was an error with the authentication. Try again later")
                    })
                }
            })
        }
    }

    private let onSuccessfulLoginProperty = MutableProperty(())
    func onSuccessfulLogin() {
        self.sharedManager?.setCredentials()
        self.sharedManager?.fetchUser({[weak self] in
            self?.sharedManager?.fetchWorldState({
                self?.onSuccessfulLoginProperty.value = ()

            }, onError: {
                self?.onSuccessfulLoginProperty.value = ()
            })
        }, onError: {[weak self] in
            self?.onSuccessfulLoginProperty.value = ()
        })
    }

    private let facebookLoginButtonPressedProperty = MutableProperty(())
    func facebookLoginButtonPressed() {
        let fbManager = FBSDKLoginManager()
        fbManager.logIn(withReadPermissions: ["public_profile", "email"], from: viewController) { [weak self] (result, error) in
            if error != nil || result?.isCancelled == true {
                // If there is an error or the user cancelled login

            } else if let userId = result?.token.userID, let token = result?.token.tokenString {
                self?.sharedManager?.loginUserSocial(userId, withNetwork: "facebook", withAccessToken: token, onSuccess: {
                    self?.onSuccessfulLogin()
                }, onError: { _ in
                    self?.showErrorObserver.send(value: "There was an error with the authentication. Try again later")
                })
            }
        }
    }

    private var sharedManager: HRPGManager?
    func setSharedManager(sharedManager: HRPGManager?) {
        self.sharedManager = sharedManager
    }

    private weak var viewController: LoginTableViewController?
    func setViewController(viewController: LoginTableViewController) {
        self.viewController = viewController
    }

    internal var authTypeButtonTitle: Signal<String, NoError>
    internal var loginButtonTitle: Signal<String, NoError>
    internal var usernameFieldTitle: Signal<String, NoError>
    internal var isFormValid: Signal<Bool, NoError>
    internal var emailFieldVisibility: Signal<Bool, NoError>
    internal var passwordRepeatFieldVisibility: Signal<Bool, NoError>
    internal var passwordFieldReturnButtonIsDone: Signal<Bool, NoError>
    internal var passwordRepeatFieldReturnButtonIsDone: Signal<Bool, NoError>
    internal var onePasswordButtonHidden: Signal<Bool, NoError>
    internal var showError: Signal<String, NoError>
    internal var showNextViewController: Signal<String, NoError>
    internal var loadingIndicatorVisibility: Signal<Bool, NoError>
    internal var onePasswordFindLogin: Signal<(), NoError>
    
    internal var formVisibility: Signal<Bool, NoError>
    internal var beginButtonsVisibility: Signal<Bool, NoError>
    internal var backButtonVisibility: Signal<Bool, NoError>
    var backgroundScrolledToTop: Signal<Bool, NoError>

    internal var emailText: Signal<String, NoError>
    internal var usernameText: Signal<String, NoError>
    internal var passwordText: Signal<String, NoError>
    internal var passwordRepeatText: Signal<String, NoError>

    private var showNextViewControllerObserver: Signal<(), NoError>.Observer
    private var showErrorObserver: Signal<String, NoError>.Observer
    private var loadingIndicatorVisibilityObserver: Signal<Bool, NoError>.Observer

    internal var inputs: LoginViewModelInputs { return self }
    internal var outputs: LoginViewModelOutputs { return self }
    
    var currentAuthType: LoginViewAuthType {
            return authTypeProperty.value
    }
}

func isValid(authType: LoginViewAuthType, email: String, username: String, password: String, passwordRepeat: String) -> Bool {

    if username.isEmpty || password.isEmpty {
        return false
    }

    if authType == .register {
        if !isValidEmail(email: email) {
            return false
        }

        if !password.isEmpty && password != passwordRepeat {
            return false
        }
    }

    return true
}

func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}
