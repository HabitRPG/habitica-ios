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

class LoginTableViewController: UIViewController {
    
    public var isRootViewController = false
    
    @IBOutlet weak var authTypeButton: UIBarButtonItem!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRepeatTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonBackground: UIView!
    @IBOutlet weak var onePasswordButton: UIButton!
    
    @IBOutlet weak var emailFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var emailFieldTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var passwordRepeatFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var passwordRepeatFieldTopSpacing: NSLayoutConstraint!
    
    private let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.backgroundColor = .clear
        
        authTypeButton.target = self
        authTypeButton.action = #selector(authTypeButtonTapped)
        usernameTextField.addTarget(self, action: #selector(usernameTextFieldChanged(textField:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(emailTextFieldChanged(textField:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldChanged(textField:)), for: .editingChanged)
        passwordRepeatTextField.addTarget(self, action: #selector(passwordRepeatTextFieldChanged(textField:)), for: .editingChanged)
        
        bindViewModel()
        self.viewModel.setAuthType(authType: LoginViewAuthType.Login)
        self.viewModel.inputs.onePassword(
            isAvailable: OnePasswordExtension.shared().isAppExtensionAvailable()
        )
        
        if self.isRootViewController {
            UIApplication.shared.setStatusBarHidden(true, with: .fade)
        }
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
            } else {
                self.hideField(fieldHeightConstraint: self.emailFieldHeight, spacingHeightConstraint:self.emailFieldTopSpacing)
            }
        }
        self.viewModel.outputs.passwordRepeatFieldVisibility.observeValues { (value) in
            if (value) {
                self.showField(fieldHeightConstraint: self.passwordRepeatFieldHeight, spacingHeightConstraint:self.passwordRepeatFieldTopSpacing)
            } else {
                self.hideField(fieldHeightConstraint: self.passwordRepeatFieldHeight, spacingHeightConstraint:self.passwordRepeatFieldTopSpacing)
            }
        }
        self.onePasswordButton.reactive.isHidden <~ self.viewModel.outputs.onePasswordButtonHidden
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
    
    func passwordRepeatTextFieldChanged(textField: UITextField) {
        self.viewModel.inputs.passwordRepeatChanged(passwordRepeat: textField.text)
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
}
