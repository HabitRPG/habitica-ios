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
import CRToast

class LoginTableViewController: UIViewController, UITextFieldDelegate {

    public var isRootViewController = false

    @IBOutlet weak private var authTypeButton: UIBarButtonItem!
    @IBOutlet weak private var usernameTextField: UITextField!
    @IBOutlet weak private var emailTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!
    @IBOutlet weak private var passwordRepeatTextField: UITextField!
    @IBOutlet weak private var loginButton: UIButton!
    @IBOutlet weak private var loginButtonBackground: UIView!
    @IBOutlet weak private var onePasswordButton: UIButton!
    @IBOutlet weak private var googleLoginButton: UIButton!
    @IBOutlet weak private var facebookLoginButton: UIButton!

    @IBOutlet weak private var emailFieldHeight: NSLayoutConstraint!
    @IBOutlet weak private var emailFieldTopSpacing: NSLayoutConstraint!
    @IBOutlet weak private var passwordRepeatFieldHeight: NSLayoutConstraint!
    @IBOutlet weak private var passwordRepeatFieldTopSpacing: NSLayoutConstraint!
    @IBOutlet weak private var loginActivityIndicator: UIActivityIndicatorView!

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
        facebookLoginButton.addTarget(self, action: #selector(facebookLoginButtonPressed), for: .touchUpInside)

        onePasswordButton.addTarget(self, action: #selector(onePasswordButtonPressed), for: .touchUpInside)

        bindViewModel()
        self.viewModel.setAuthType(authType: LoginViewAuthType.login)
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
        setupButtons()
        setupFieldVisibility()
        setupReturnTypes()
        setupTextInput()
        setupOnePassword()

        self.viewModel.outputs.usernameFieldTitle.observeValues {[weak self] value in
            self?.usernameTextField.placeholder = value
        }

        self.viewModel.outputs.showError
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] message in
                self?.present(UIAlertController.genericError(message: message), animated: true, completion: nil)
        }

        self.viewModel.outputs.showNextViewController
        .observeValues {[weak self] segueName in
            guard let weakSelf = self else {
                return
            }
            if weakSelf.isRootViewController {
                weakSelf.performSegue(withIdentifier: segueName, sender: self)
            } else {
                weakSelf.dismiss(animated: true, completion:nil)
            }
        }
        self.viewModel.outputs.loadingIndicatorVisibility
        .observeValues {[weak self] isVisible in
            if isVisible {
                self?.loginActivityIndicator.startAnimating()
                UIView.animate(withDuration: 0.5, animations: {
                    self?.loginButton.alpha = 0
                    self?.loginActivityIndicator.alpha = 1
                })
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    self?.loginButton.alpha = 1
                    self?.loginActivityIndicator.alpha = 0
                }, completion: { (_) in
                    self?.loginActivityIndicator.stopAnimating()
                })
            }
        }
    }

    func setupButtons() {
        self.authTypeButton.reactive.title <~ self.viewModel.outputs.authTypeButtonTitle
        self.loginButton.reactive.title <~ self.viewModel.outputs.loginButtonTitle
        self.loginButton.reactive.isEnabled <~ self.viewModel.outputs.isFormValid
    }

    func setupFieldVisibility() {
        self.viewModel.outputs.emailFieldVisibility.observeValues {[weak self] value in
            guard let weakSelf = self else {
                return
            }
            if value {
                weakSelf.showField(fieldHeightConstraint: weakSelf.emailFieldHeight, spacingHeightConstraint:weakSelf.emailFieldTopSpacing)
                weakSelf.emailTextField.isEnabled = true
            } else {
                weakSelf.hideField(fieldHeightConstraint: weakSelf.emailFieldHeight, spacingHeightConstraint:weakSelf.emailFieldTopSpacing)
                weakSelf.emailTextField.isEnabled = false
            }
        }
        self.viewModel.outputs.passwordRepeatFieldVisibility.observeValues {[weak self] value in
            guard let weakSelf = self else {
                return
            }
            if value {
                weakSelf.showField(fieldHeightConstraint: weakSelf.passwordRepeatFieldHeight, spacingHeightConstraint:weakSelf.passwordRepeatFieldTopSpacing)
                weakSelf.passwordRepeatTextField.isEnabled = true
            } else {
                weakSelf.hideField(fieldHeightConstraint: weakSelf.passwordRepeatFieldHeight, spacingHeightConstraint:weakSelf.passwordRepeatFieldTopSpacing)
                weakSelf.passwordRepeatTextField.isEnabled = false
            }
        }
    }

    func setupReturnTypes() {
        self.viewModel.outputs.passwordFieldReturnButtonIsDone.observeValues {[weak self] value in
            if value {
                self?.passwordTextField.returnKeyType = .done
            } else {
                self?.passwordTextField.returnKeyType = .next
            }
        }

        self.viewModel.outputs.passwordRepeatFieldReturnButtonIsDone.observeValues {[weak self] value in
            if value {
                self?.passwordRepeatTextField.returnKeyType = .done
            } else {
                self?.passwordRepeatTextField.returnKeyType = .next
            }
        }
    }

    func setupTextInput() {
        self.usernameTextField.reactive.text <~ self.viewModel.outputs.usernameText
        self.emailTextField.reactive.text <~ self.viewModel.outputs.emailText
        self.passwordTextField.reactive.text <~ self.viewModel.outputs.passwordText
        self.passwordRepeatTextField.reactive.text <~ self.viewModel.outputs.passwordRepeatText
    }

    func setupOnePassword() {
        self.onePasswordButton.reactive.isHidden <~ self.viewModel.outputs.onePasswordButtonHidden
        self.viewModel.outputs.onePasswordFindLogin.observeValues {[weak self] _ in
            OnePasswordExtension.shared().findLogin(forURLString: "https://habitica.com", for: self!, sender: self?.onePasswordButton, completion: { (data, _) in
                guard let loginData = data else {
                    return
                }
                let username = loginData[AppExtensionUsernameKey] as? String ?? ""
                let password = loginData[AppExtensionPasswordKey] as? String ?? ""

                self?.viewModel.onePasswordFoundLogin(username: username, password: password)
            })

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
        fieldHeightConstraint.constant = 44
        spacingHeightConstraint.constant = 12
        UIView.animate(withDuration: 0.3) {
            self.view .layoutIfNeeded()
        }
    }

    func hideField(fieldHeightConstraint: NSLayoutConstraint, spacingHeightConstraint: NSLayoutConstraint) {
        fieldHeightConstraint.constant = 0
        spacingHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view .layoutIfNeeded()
        }
    }

    func loginButtonPressed() {
        self.viewModel.inputs.loginButtonPressed()
    }

    func googleLoginButtonPressed() {
        self.viewModel.inputs.googleLoginButtonPressed()
    }

    func onePasswordButtonPressed() {
        self.viewModel.inputs.onePasswordTapped()
    }

    func facebookLoginButtonPressed() {
        self.viewModel.inputs.facebookLoginButtonPressed()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            guard let next = textField.superview?.superview?.viewWithTag(textField.tag+1) as? UITextField else {
                return false
            }
            if next.isEnabled {
                next.becomeFirstResponder()
            } else {
                let _ = self.textFieldShouldReturn(next)
            }
        } else if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        return true
    }
}
