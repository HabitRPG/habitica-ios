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
import AuthenticationServices
import Habitica_Models

class LoginViewModel: ObservableObject {
    weak var viewController: LoginTableViewController?
    private let userRepository = UserRepository()
    
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    @Published var showLoadingIndicator: Bool = false
    @Published var showUsernameView = false
    @Published var usernameValid: Bool?
    @Published var acceptedTerms: Bool = false

    private var socialLoginMethod: String?
    private var socialLoginAccessToken: String?

    private let googleLoginButtonPressedProperty = MutableProperty(())
    func googleLoginButtonPressed() {
        guard let authorizationEndpoint = URL(string: "https://accounts.google.com/o/oauth2/v2/auth") else {
            return
        }
        guard let tokenEndpoint = URL(string: "https://www.googleapis.com/oauth2/v4/token") else {
            return
        }
        guard let redirectUrl = URL(string: Secrets.googleRedirectUrl) else {
            return
        }
        let configuration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint, tokenEndpoint: tokenEndpoint)

        let request = OIDAuthorizationRequest.init(configuration: configuration,
                                                   clientId: Secrets.googleClient,
                                                   scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail],
                                                   redirectURL: redirectUrl,
                                                   responseType: OIDResponseTypeCode,
                                                   additionalParameters: nil)

        // performs authentication request
        if let appDelegate = UIApplication.shared.delegate as? HabiticaAppDelegate {
            guard let viewController = self.viewController else {
                return
            }
            appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: viewController, callback: {[weak self] (authState, _) in
                if authState != nil {
                    self?.socialLoginMethod = "google"
                    self?.socialLoginAccessToken = authState?.lastTokenResponse?.accessToken
                    self?.userRepository.login(userID: "", network: "google", accessToken: self?.socialLoginAccessToken ?? "", allowRegister: false)
                        .observeValues { response in
                            if response?.newUser == true {
                                self?.prefillUsername()
                                self?.showUsernameView = true
                            } else {
                                self?.onSuccessfulLogin(false)
                            }
                        }
                }
            })
        }
    }
    
    private let appleLoginButtonPressedProperty = MutableProperty(())
    func appleLoginButtonPressed() {
        guard let viewController = self.viewController else {
            return
        }
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = viewController
        authorizationController.presentationContextProvider = viewController
        authorizationController.performRequests()
    }
    
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        guard let viewController = self.viewController else {
            return
        }
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = viewController
        authorizationController.presentationContextProvider = viewController
        authorizationController.performRequests()
    }
    
    func performAppleLogin(identityToken: String, name: String) {
        socialLoginMethod = "apple"
        socialLoginAccessToken = identityToken
        userRepository.loginApple(identityToken: identityToken, name: name, allowRegister: false).observeResult {[weak self] (result) in
            switch result {
            case .success(let response):
                if response?.newUser == true {
                    self?.prefillUsername()
                    self?.showUsernameView = true
                } else {
                    self?.onSuccessfulLogin(false)
                }
            case .failure:
                self?.viewController?.showError(L10n.Login.authenticationError)
            }
        }
    }

    func onSuccessfulLogin(_ isNewUser: Bool) {
        userRepository.retrieveUser()
            .combineLatest(with: userRepository.retrieveGroupPlans())
            .observeCompleted {[weak self] in
                self?.viewController?.showNextViewController(segueName: isNewUser ? "SetupSegue" : "MainSegue")
        }
    }
    
    func verifyUsername() {
        userRepository.verifyUsername(username).observeResult { result in
            switch result {
            case .success(let response):
                if response?.isUsable == true {
                    self.usernameValid = true
                } else {
                    self.usernameValid = false
                }
            }
        }
    }
    
    func beginRegistration() {
        self.showLoadingIndicator = true
        userRepository.checkEmail(email).observeResult({ result in
            switch result {
            case .success(let response):
                if response?.valid == true {
                    self.prefillUsername()
                    self.showUsernameView = true
                } else {
                    self.showLoadingIndicator = false
                    self.viewController?.showError(L10n.Login.emailInvalid)
                }
            case .failure:
                self.showLoadingIndicator = false
                self.viewController?.showError(L10n.Login.authenticationError)
            }
        })
    }
    
    func completeRegistration() {
        self.showLoadingIndicator = true
        let responseSignal: Signal<LoginResponseProtocol?, Never>
        if socialLoginMethod == "apple" {
            responseSignal = userRepository.loginApple(identityToken: socialLoginAccessToken ?? "", name: "", allowRegister: true)
        } else if socialLoginMethod == "google" {
            responseSignal = userRepository.login(userID: "", network: "google", accessToken: socialLoginAccessToken ?? "", allowRegister: true)
        } else {
            responseSignal = userRepository.register(username: username, password: password, confirmPassword: password, email: email)
        }
        responseSignal.observeResult { result in
                switch result {
                case .success(let response):
                    self.onSuccessfulLogin(response?.newUser ?? true)
                case .failure:
                    self.showLoadingIndicator = false
                    self.viewController?.showError(L10n.Login.authenticationError)
                }
            }
    }
    
    func login() {
        self.showLoadingIndicator = true
        userRepository.login(username: email, password: password)
            .observeResult { result in
                self.showLoadingIndicator = false
                switch result {
                case .success(let response):
                    self.onSuccessfulLogin(response?.newUser ?? false)
                case .failure:
                    self.showLoadingIndicator = false
                    self.viewController?.showError(L10n.Login.authenticationError)
                }
            }
    }
    
    func prefillUsername() {
        if email.isValidEmail() {
            username = String(email.split(separator: "@").first ?? "")
        }
    }
}

func isValidEmail(email: String?) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}
