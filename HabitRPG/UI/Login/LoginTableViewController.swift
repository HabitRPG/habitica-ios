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
    
    @IBOutlet weak var authTypeButton: UIBarButtonItem!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRepeatTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonBackground: UIView!
    @IBOutlet weak var onePasswordButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
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
        facebookLoginButton.addTarget(self, action: #selector(facebookLoginButtonPressed), for: .touchUpInside)
        
        onePasswordButton.addTarget(self, action: #selector(onePasswordButtonPressed), for: .touchUpInside)

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
        self.viewModel.outputs.usernameFieldTitle.observeValues {[weak self] value in
            self?.usernameTextField.placeholder = value
        }
        self.loginButton.reactive.title <~ self.viewModel.outputs.loginButtonTitle
        self.loginButton.reactive.isEnabled <~ self.viewModel.outputs.isFormValid
        
        self.usernameTextField.reactive.text <~ self.viewModel.outputs.usernameText
        self.emailTextField.reactive.text <~ self.viewModel.outputs.emailText
        self.passwordTextField.reactive.text <~ self.viewModel.outputs.passwordText
        self.passwordRepeatTextField.reactive.text <~ self.viewModel.outputs.passwordRepeatText
        
        self.viewModel.outputs.emailFieldVisibility.observeValues {[weak self] value in
            if value {
                self?.showField(fieldHeightConstraint: (self?.emailFieldHeight)!, spacingHeightConstraint:(self?.emailFieldTopSpacing)!)
                self?.emailTextField.isEnabled = true
            } else {
                self?.hideField(fieldHeightConstraint: (self?.emailFieldHeight)!, spacingHeightConstraint:(self?.emailFieldTopSpacing)!)
                self?.emailTextField.isEnabled = false
            }
        }
        self.viewModel.outputs.passwordRepeatFieldVisibility.observeValues {[weak self] value in
            if value {
                self?.showField(fieldHeightConstraint: (self?.passwordRepeatFieldHeight)!, spacingHeightConstraint:(self?.passwordRepeatFieldTopSpacing)!)
                self?.passwordRepeatTextField.isEnabled = true
            } else {
                self?.hideField(fieldHeightConstraint: (self?.passwordRepeatFieldHeight)!, spacingHeightConstraint:(self?.passwordRepeatFieldTopSpacing)!)
                self?.passwordRepeatTextField.isEnabled = false
            }
        }
        
        self.viewModel.outputs.passwordFieldReturnButtonIsDone.observeValues{[weak self] value in
            if value {
                self?.passwordTextField.returnKeyType = .done
            } else {
                self?.passwordTextField.returnKeyType = .next
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
        
        self.viewModel.outputs.onePasswordFindLogin.observeValues {[weak self] _ in
            OnePasswordExtension.shared().findLogin(forURLString: "https://habitica.com", for: self!, sender: self?.onePasswordButton, completion: { (data, error) in
                guard let loginData = data else {
                    return
                }
                let username = loginData[AppExtensionUsernameKey] ?? ""
                let password = loginData[AppExtensionPasswordKey] ?? ""
                
                self?.viewModel.onePasswordFoundLogin(username: username as! String, password: password as! String)
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
        self.viewModel.inputs.loginButtonPressed()
    }
    
    func googleLoginButtonPressed() {
        self.viewModel.inputs.googleLoginButtonPressed()
    }
    
    func facebookLoginButtonPressed() {
        self.viewModel.inputs.facebookLoginButtonPressed()
    }
    
    func onePasswordButtonPressed() {
        self.viewModel.inputs.onePasswordTapped()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            guard let next = textField.superview?.superview?.viewWithTag(textField.tag+1) as? UITextField else {
                return false
            }
            if (next.isEnabled) {
                next.becomeFirstResponder()
            } else {
                let _ = self.textFieldShouldReturn(next)
            }
        } else if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        return true;
    }
}
