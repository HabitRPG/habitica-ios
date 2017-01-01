//
//  LoginTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 25/12/2016.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import FBSDKLoginKit
import CRToast

class LoginTableViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    public var isRootViewController = false
    
    @IBOutlet weak var authTypeButton: UIBarButtonItem!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRepeatTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonBackground: UIView!
    @IBOutlet weak var onePasswordButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    @IBOutlet weak var emailFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var emailFieldTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var passwordRepeatFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var passwordRepeatFieldTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    private let viewModel = LoginViewModel()
    private var sharedManager: HRPGManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.shared.delegate as? HRPGAppDelegate
        self.sharedManager = delegate?.sharedManager
        self.viewModel.inputs.setSharedManager(sharedManager: self.sharedManager)
        self.viewModel.inputs.setViewController(viewController: self)
        
        self.configureNavigationBar()
        
        authTypeButton.target = self
        authTypeButton.action = #selector(authTypeButtonTapped)
        usernameTextField.addTarget(self, action: #selector(usernameTextFieldChanged(textField:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(emailTextFieldChanged(textField:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldChanged(textField:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldChanged(textField:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDoneEditing(textField:)), for: .editingDidEnd)
        passwordRepeatTextField.addTarget(self, action: #selector(passwordRepeatTextFieldChanged(textField:)), for: .editingChanged)
        passwordRepeatTextField.addTarget(self, action: #selector(passwordRepeatTextFieldDoneEditing(textField:)), for: .editingDidEnd)
        
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(googleLoginButtonPressed), for: .touchUpInside)

        bindViewModel()
        self.viewModel.setAuthType(authType: LoginViewAuthType.Login)
        self.viewModel.inputs.onePassword(
            isAvailable: OnePasswordExtension.shared().isAppExtensionAvailable()
        )
    }
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.backgroundColor = .clear
    }

    func bindViewModel() {
        self.authTypeButton.reactive.title <~ self.viewModel.outputs.authTypeButtonTitle
        self.viewModel.outputs.usernameFieldTitle.observeValues { value in
            self.usernameTextField.placeholder = value
        }
        self.loginButton.reactive.title <~ self.viewModel.outputs.loginButtonTitle
        self.loginButton.reactive.isEnabled <~ self.viewModel.outputs.isFormValid
        
        self.viewModel.outputs.emailFieldVisibility.observeValues { (value) in
            if (value) {
                self.showField(fieldHeightConstraint: self.emailFieldHeight, spacingHeightConstraint:self.emailFieldTopSpacing)
                self.emailTextField.isEnabled = true
            } else {
                self.hideField(fieldHeightConstraint: self.emailFieldHeight, spacingHeightConstraint:self.emailFieldTopSpacing)
                self.emailTextField.isEnabled = false
            }
        }
        self.viewModel.outputs.passwordRepeatFieldVisibility.observeValues { (value) in
            if (value) {
                self.showField(fieldHeightConstraint: self.passwordRepeatFieldHeight, spacingHeightConstraint:self.passwordRepeatFieldTopSpacing)
                self.passwordRepeatTextField.isEnabled = true
            } else {
                self.hideField(fieldHeightConstraint: self.passwordRepeatFieldHeight, spacingHeightConstraint:self.passwordRepeatFieldTopSpacing)
                self.passwordRepeatTextField.isEnabled = false
            }
        }
        self.onePasswordButton.reactive.isHidden <~ self.viewModel.outputs.onePasswordButtonHidden
    
        self.viewModel.outputs.showError
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] message in
                self?.present(UIAlertController.genericError(message: message), animated: true, completion: nil)
        }
        
        self.viewModel.outputs.showNextViewController
        .observeValues {[weak self] segueName in
            if (self?.isRootViewController)! {
                self?.performSegue(withIdentifier: segueName, sender: self)
            } else {
                self?.dismiss(animated: true, completion:nil)
            }
        }
        self.viewModel.outputs.loadingIndicatorVisibility
        .observeValues { isVisible in
            if isVisible {
                self.loginActivityIndicator.startAnimating()
                UIView.animate(withDuration: 0.5, animations: { 
                    self.loginButton.alpha = 0
                    self.loginActivityIndicator.alpha = 1
                })
            } else {
                UIView.animate(withDuration: 0.5, animations: { 
                    self.loginButton.alpha = 1
                    self.loginActivityIndicator.alpha = 0
                }, completion: { (_) in
                    self.loginActivityIndicator.stopAnimating()
                })
            }
        }
    }

    func authTypeButtonTapped() {
        self.viewModel.inputs.authTypeChanged()
    }
    
    func usernameTextFieldChanged(textField: UITextField) {
        self.viewModel.inputs.usernameChanged(username: textField.text)
    }
    
    func emailTextFieldChanged(textField: UITextField) {
        self.viewModel.inputs.emailChanged(email: textField.text)
    }
    
    func passwordTextFieldChanged(textField: UITextField) {
        self.viewModel.inputs.passwordChanged(password: textField.text)
    }
    func passwordTextFieldDoneEditing(textField: UITextField) {
        self.viewModel.inputs.passwordDoneEditing()
    }
    
    func passwordRepeatTextFieldChanged(textField: UITextField) {
        self.viewModel.inputs.passwordRepeatChanged(passwordRepeat: textField.text)
    }
    func passwordRepeatTextFieldDoneEditing(textField: UITextField) {
        self.viewModel.inputs.passwordRepeatDoneEditing()
    }
    
    func showField(fieldHeightConstraint: NSLayoutConstraint, spacingHeightConstraint: NSLayoutConstraint) {
        fieldHeightConstraint.constant = 44;
        spacingHeightConstraint.constant = 12;
        UIView.animate(withDuration: 0.3) {
            self.view .layoutIfNeeded()
        }
    }
    
    func hideField(fieldHeightConstraint: NSLayoutConstraint, spacingHeightConstraint: NSLayoutConstraint) {
        fieldHeightConstraint.constant = 0;
        spacingHeightConstraint.constant = 0;
        UIView.animate(withDuration: 0.3) {
            self.view .layoutIfNeeded()
        }
    }
    
    func loginButtonPressed() {
        self.viewModel.loginButtonPressed()
    }
    
    func googleLoginButtonPressed() {
        self.viewModel.googleLoginButtonPressed()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (error != nil) {
            self.present(UIAlertController.genericError(message: "There was an error with the authentication. Try again later", title: "Authentication Error"), animated: true, completion: nil)
        } else if (!result.isCancelled) {
            self.sharedManager?.loginUserSocial(FBSDKAccessToken.current().userID, withNetwork: "facebook", withAccessToken: FBSDKAccessToken.current().tokenString, onSuccess: { 
                
            }, onError: { 
                
            })
        }
    }
        
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
}
