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
import AppAuth
import Keys
import FBSDKLoginKit

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
    func passwordDoneEditing()
    func passwordRepeatChanged(passwordRepeat: String?)
    func passwordRepeatDoneEditing()

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
    
    var onePasswordButtonHidden: Signal<Bool, NoError> { get }
    var onePasswordFindLogin: Signal<(), NoError> { get }
    
    var emailText: Signal<String, NoError> { get }
    var usernameText: Signal<String, NoError> { get }
    var passwordText: Signal<String, NoError> { get }
    var passwordRepeatText: Signal<String, NoError> { get }

    
    var showError: Signal<String, NoError> { get }
    var showNextViewController: Signal<String, NoError> { get }
    
    var loadingIndicatorVisibility: Signal<Bool, NoError> { get }
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {
    
    init() {
        let authValues = Signal.combineLatest(
            self.authTypeProperty.signal.skipNil(),
            Signal.merge(self.emailChangedProperty.signal, self.prefillEmailProperty.signal),
            Signal.merge(self.usernameChangedProperty.signal, self.prefillUsernameProperty.signal),
            Signal.merge(self.passwordChangedProperty.signal, self.prefillPasswordProperty.signal),
            Signal.merge(self.passwordRepeatChangedProperty.signal, self.prefillPasswordRepeatProperty.signal)
        )
        
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
        self.passwordFieldReturnButtonIsDone = isRegistering.map({ value -> Bool in
            return !value
        });
        
        self.isFormValid = authValues.map(isValid)
        
        self.emailChangedProperty.value = ""
        self.usernameChangedProperty.value = ""
        self.passwordChangedProperty.value = ""
        self.passwordRepeatChangedProperty.value = ""
        
        self.usernameText = self.prefillUsernameProperty.signal
        self.emailText = self.prefillEmailProperty.signal
        self.passwordText = self.prefillPasswordProperty.signal
        self.passwordRepeatText = self.prefillPasswordRepeatProperty.signal
        
        self.onePasswordButtonHidden = self.onePasswordAvailable.signal.map { value in
            return !value
        }
        self.onePasswordFindLogin = self.onePasswordTappedProperty.signal
        
        let (showNextViewControllerSignal, showNextViewControllerObserver) = Signal<(), NoError>.pipe()
        self.showNextViewControllerObserver = showNextViewControllerObserver
        self.showNextViewController = Signal.merge(
            showNextViewControllerSignal,
            self.onSuccessfulLoginProperty.signal
            ).combineLatest(with: self.authTypeProperty.signal)
        .map({ (_, authType) -> String in
            if authType == .Login {
                return "MainSegue"
            } else {
                return "SetupSegue"
            }
        })
        (self.showError, self.showErrorObserver) = Signal.pipe()
        
        (self.loadingIndicatorVisibility, self.loadingIndicatorVisibilityObserver) = Signal<Bool, NoError>.pipe()
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
    
    private let emailChangedProperty = MutableProperty<String>("")
    func emailChanged(email: String?) {
        if email != nil {
            self.emailChangedProperty.value = email!
        }
    }

    private let usernameChangedProperty = MutableProperty<String>("")
    func usernameChanged(username: String?) {
        if username != nil {
            self.usernameChangedProperty.value = username!
        }
    }
    
    private let passwordChangedProperty = MutableProperty<String>("")
    func passwordChanged(password: String?) {
        if password != nil {
            self.passwordChangedProperty.value = password!
        }
    }
    
    private let passwordDoneEditingProperty = MutableProperty(())
    func passwordDoneEditing() {
        self.passwordDoneEditingProperty.value = ()
    }
    
    private let passwordRepeatChangedProperty = MutableProperty<String>("")
    func passwordRepeatChanged(passwordRepeat: String?) {
        if passwordRepeat != nil {
            self.passwordRepeatChangedProperty.value = passwordRepeat!
        }
    }
    
    private let passwordRepeatDoneEditingProperty = MutableProperty(())
    func passwordRepeatDoneEditing() {
        self.passwordRepeatDoneEditingProperty.value = ()
    }
    
    private let onePasswordAvailable = MutableProperty<Bool>(false)
    func onePassword(isAvailable: Bool) {
        self.onePasswordAvailable.value = isAvailable;
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
    
    func loginButtonPressed() {
        if isValid(authType: self.authTypeProperty.value!, email: self.emailChangedProperty.value, username: self.usernameChangedProperty.value, password: self.passwordChangedProperty.value, passwordRepeat: self.passwordRepeatChangedProperty.value) {
            self.loadingIndicatorVisibilityObserver.send(value: true)
            if self.authTypeProperty.value == .Login {
                self.sharedManager?.loginUser(self.usernameChangedProperty.value, withPassword: self.passwordChangedProperty.value, onSuccess: {
                    self.onSuccessfulLogin()
                }, onError: {
                    self.loadingIndicatorVisibilityObserver.send(value: false)
                    self.showErrorObserver.send(value: "Invalid username or password".localized)
                })
            } else {
                self.sharedManager?.registerUser(self.usernameChangedProperty.value, withPassword: self.passwordChangedProperty.value, withEmail: self.emailChangedProperty.value, onSuccess: { 
                    self.onSuccessfulLogin()
                }, onError: {
                    self.loadingIndicatorVisibilityObserver.send(value: false)
                })
            }
        }
    }
    
    private let googleLoginButtonPressedProperty = MutableProperty(())
    func googleLoginButtonPressed() {
        let authorizationEndpoint = NSURL(string: "https://accounts.google.com/o/oauth2/v2/auth")
        let tokenEndpoint = NSURL(string: "https://www.googleapis.com/oauth2/v4/token")
        
        let configuration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint as! URL, tokenEndpoint: tokenEndpoint as! URL)
        let keys = HabiticaKeys();
        
        let request = OIDAuthorizationRequest.init(configuration: configuration, clientId: keys.googleClient, scopes:[OIDScopeOpenID, OIDScopeProfile], redirectURL: NSURL(string: keys.googleRedirectUrl) as! URL, responseType: OIDResponseTypeCode, additionalParameters: nil)
        
        // performs authentication request
        let appDelegate = UIApplication.shared.delegate as! HRPGAppDelegate
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting:self.viewController!, callback: {[weak self] (authState, error) in
            if (authState != nil) {
                self?.sharedManager?.loginUserSocial("", withNetwork: "google", withAccessToken: authState?.lastTokenResponse?.accessToken, onSuccess: { 
                    self?.onSuccessfulLogin()
                }, onError: {
                  self?.showErrorObserver.send(value: "There was an error with the authentication. Try again later")
                })
            }
        })
    }
    
    private let onSuccessfulLoginProperty = MutableProperty(())
    func onSuccessfulLogin() {
        self.sharedManager?.setCredentials()
        self.sharedManager?.fetchUser({[weak self] _ in
            self?.onSuccessfulLoginProperty.value = ()
        }, onError: {[weak self] _ in
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
                }, onError: {
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
    internal var onePasswordButtonHidden: Signal<Bool, NoError>
    internal var showError: Signal<String, NoError>
    internal var showNextViewController: Signal<String, NoError>
    internal var loadingIndicatorVisibility: Signal<Bool, NoError>
    internal var onePasswordFindLogin: Signal<(), NoError>
    
    internal var emailText: Signal<String, NoError>
    internal var usernameText: Signal<String, NoError>
    internal var passwordText: Signal<String, NoError>
    internal var passwordRepeatText: Signal<String, NoError>
    
    private var showNextViewControllerObserver: Observer<(), NoError>
    private var showErrorObserver: Observer<String, NoError>
    private var loadingIndicatorVisibilityObserver: Observer<Bool, NoError>

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
