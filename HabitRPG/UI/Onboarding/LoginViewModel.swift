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

class LoginViewModel: ObservableObject {
    weak var viewController: LoginTableViewController?
    private let userRepository = UserRepository()
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    
    func register() {
        
    }
    
    func login() {
 
    }

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
                    self?.userRepository.login(userID: "", network: "google", accessToken: authState?.lastTokenResponse?.accessToken ?? "").observeResult { (result) in
                        switch result {
                        case .success(let response):
                            self?.onSuccessfulLogin(response?.newUser == true)
                        case .failure:
                            viewController.showError(L10n.Login.authenticationError)
                        }
                    }
                }
            })
        }
    }
    
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
        userRepository.loginApple(identityToken: identityToken, name: name).observeResult {[weak self] (result) in
            switch result {
            case .success(let response):
                self?.onSuccessfulLogin(response?.newUser == true)
            case .failure:
                self?.viewController?.showError(L10n.Login.authenticationError)
            }
        }
    }

    func onSuccessfulLogin(_ isNewUser: Bool) {
        userRepository.retrieveUser()
            .combineLatest(with: userRepository.retrieveGroupPlans())
            .observeCompleted {[weak self] in
                self?.viewController?.showNextViewController(segueName: "SetupSegue")
        }
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
