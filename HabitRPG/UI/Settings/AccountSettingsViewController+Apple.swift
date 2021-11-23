//
//  AccountSettingsViewController+Apple.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.11.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import AppAuth
import AuthenticationServices
import Keys
import ReactiveSwift

extension AccountSettingsViewController: ASAuthorizationControllerDelegate {
    
    func disconnectSocial(_ network: String) {
        let alertController = HabiticaAlertController(title: L10n.Settings.areYouSure)
        alertController.addAction(title: L10n.Settings.disconnect, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.userRepository.disconnectSocial(network).flatMap(.latest, { _ in
                return self?.userRepository.retrieveUser() ?? Signal.empty })
                .observeCompleted {}
        }
        alertController.addCancelAction()
        alertController.show()
    }
    
    func configureSocialCell(cell: UITableViewCell, email: String?, isConnected: Bool?) {
        cell.detailTextLabel?.text = email ?? L10n.Settings.notSet
        let label = UILabel()
        if isConnected == true {
            label.text = L10n.Settings.disconnect
            label.textColor = ThemeService.shared.theme.errorColor
        } else {
            label.text = L10n.Settings.connect
            label.textColor = ThemeService.shared.theme.ternaryTextColor
        }
        label.font = .systemFont(ofSize: 17)
        cell.accessoryView = label
    }
    
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
                                                   scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail],
                                                   redirectURL: redirectUrl,
                                                   responseType: OIDResponseTypeCode,
                                                   additionalParameters: nil)

        // performs authentication request
        if let appDelegate = UIApplication.shared.delegate as? HabiticaAppDelegate {
            appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self, callback: {[weak self] (authState, _) in
                if authState != nil {
                    self?.userRepository.login(userID: "", network: "google", accessToken: authState?.lastTokenResponse?.accessToken ?? "").observeResult { (result) in
                        switch result {
                        case .success:
                            self?.userRepository.retrieveUser().observeCompleted {}
                        case .failure:
                            ToastManager.show(text: L10n.Login.authenticationError, color: .red)
                        }
                    }
                }
            })
        }
    }
    
    func appleLoginButtonPressed() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let fullName = appleIDCredential.fullName
            
            var name = ""
            if let givenName = fullName?.givenName {
                name += givenName
            }
            if let familyName = fullName?.familyName {
                if !name.isEmpty {
                    name += " "
                }
                name += familyName
            }
            
            performAppleLogin(identityToken: String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8) ?? "", name: name)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
    
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func performAppleLogin(identityToken: String, name: String) {
        userRepository.loginApple(identityToken: identityToken, name: name).observeResult {[weak self] (result) in
            switch result {
            case .success:
                self?.userRepository.retrieveUser().observeCompleted {}
            case .failure:
                ToastManager.show(text: L10n.Login.authenticationError, color: .red)
            }
        }
    }
}

extension AccountSettingsViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window ?? UIWindow()
    }
}
