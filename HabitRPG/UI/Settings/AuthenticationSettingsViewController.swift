//
//  AuthenticationSettingsViewController.swift
//  Habitica
//
//  Created by Phillip on 20.10.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class AuthenticationSettingsViewController: BaseSettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Authentication", comment: "")
        } else {
            return NSLocalizedString("Danger Zone", comment: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.textColor = UIColor.black
            if indexPath.item == 0 {
                cell.textLabel?.text = NSLocalizedString("Login Name", comment: "")
                cell.detailTextLabel?.text = user?.authentication?.local?.username
            } else if indexPath.item == 1 {
                cell.textLabel?.text = NSLocalizedString("E-Mail", comment: "")
                cell.detailTextLabel?.text = user?.authentication?.local?.email
            } else if indexPath.item == 2 {
                cell.textLabel?.text = NSLocalizedString("Change Password", comment: "")
                cell.detailTextLabel?.text = nil
            } else if indexPath.item == 3 {
                cell.textLabel?.text = NSLocalizedString("Login Methods", comment: "")
                var loginMethods = [String]()
                if user?.authentication?.local?.email != nil {
                    loginMethods.append(NSLocalizedString("Local", comment: ""))
                }
                /*if user?.facebookID != nil {
                    loginMethods.append("Facebook")
                }
                if user?.googleID != nil {
                    loginMethods.append("Google")
                }*/
                cell.detailTextLabel?.text = loginMethods.joined(separator: ", ")
            }
        } else {
            cell.textLabel?.textColor = UIColor.red50()
            if indexPath.item == 0 {
                cell.textLabel?.text = NSLocalizedString("Reset Account", comment: "")
                cell.detailTextLabel?.text = nil
            } else {
                cell.textLabel?.text = NSLocalizedString("Delete Account", comment: "")
                cell.detailTextLabel?.text = nil
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                showLoginNameChangeAlert()
            } else if indexPath.item == 1 {
                showEmailChangeAlert()
            } else if indexPath.item == 2 {
                showPasswordChangeAlert()
            }
        } else if indexPath.section == 1 {
            if indexPath.item == 0 {
                showResetAccountAlert()
            } else {
                showDeleteAccountAlert()
            }
        }
    }
    
    private func showDeleteAccountAlert() {
        let alertController = HabiticaAlertController(title: NSLocalizedString("Delete Account", comment: ""))
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let textView = UITextView()
        textView.text = NSLocalizedString("Are you sure? This will delete your account forever, and it can never be restored! You will need to register a new account to use Habitica again. Banked or spent Gems will not be refunded. If you're absolutely certain, type your password into the text box below.", comment: "")
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = UIColor.gray100()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        stackView.addArrangedSubview(textView)
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Password", comment: "")
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.borderStyle = .roundedRect
        stackView.addArrangedSubview(textField)
        alertController.contentView = stackView
        
        alertController.addCancelAction()
        alertController.addAction(title: NSLocalizedString("Delete Account", comment: ""), style: .destructive, isMainAction: true) {[weak self] _ in
            self?.userRepository.deleteAccount(password: textField.text ?? "").observeValues({ response in
                if response.statusCode == 200 {
                    let storyboard = UIStoryboard(name: "Intro", bundle: nil)
                    let navigationController = storyboard.instantiateViewController(withIdentifier: "LoginTableViewController")
                    self?.present(navigationController, animated: true, completion: nil)
                } else if response.statusCode == 401 {
                    let alertView = HabiticaAlertController(title: L10n.Settings.wrongPassword)
                    alertView.addCloseAction()
                    alertView.show()
                }
            })
        }
        alertController.show()
    }
    
    private func showResetAccountAlert() {
        let alertController = HabiticaAlertController(title: NSLocalizedString("Reset Account", comment: ""))
        
        let textView = UITextView()
        textView.text = NSLocalizedString("WARNING! This resets many parts of your account. This is highly discouraged, but some people find it useful in the beginning after playing with the site for a short time.\n\nYou will lose all your levels, gold, and experience points. All your tasks (except those from challenges) will be deleted permanently and you will lose all of their historical data. You will lose all your equipment but you will be able to buy it all back, including all limited edition equipment or subscriber Mystery items that you already own (you will need to be in the correct class to re-buy class-specific gear). You will keep your current class and your pets and mounts. You might prefer to use an Orb of Rebirth instead, which is a much safer option and which will preserve your tasks and equipment.", comment: "")
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = UIColor.gray100()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        alertController.contentView = textView
        
        alertController.addCancelAction()
        alertController.addAction(title: NSLocalizedString("Reset Account", comment: ""), style: .destructive, isMainAction: true) {[weak self] _ in
            self?.userRepository.resetAccount().observeCompleted {}
        }
        alertController.show()
    }
    
    private func showEmailChangeAlert() {
        let alertController = HabiticaAlertController(title: NSLocalizedString("Change Email", comment: ""))
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let emailTextField = UITextField()
        emailTextField.placeholder = NSLocalizedString("New Email", comment: "")
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.spellCheckingType = .no
        emailTextField.text = user?.authentication?.local?.email
        stackView.addArrangedSubview(emailTextField)
        let passwordTextField = UITextField()
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        stackView.addArrangedSubview(passwordTextField)
        alertController.contentView = stackView
        
        alertController.addCancelAction()
        alertController.addAction(title: NSLocalizedString("Change", comment: ""), isMainAction: true) {[weak self] _ in
            if let email = emailTextField.text, let password = passwordTextField.text {
                self?.userRepository.updateEmail(newEmail: email, password: password).observeCompleted {}
            }
        }
        alertController.show()
    }
    
    private func showLoginNameChangeAlert() {
        let alertController = HabiticaAlertController(title: NSLocalizedString("Change Login Name", comment: ""))
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let loginNameTextField = UITextField()
        loginNameTextField.placeholder = NSLocalizedString("New Login Name", comment: "")
        loginNameTextField.borderStyle = .roundedRect
        loginNameTextField.autocapitalizationType = .none
        loginNameTextField.spellCheckingType = .no
        loginNameTextField.text = user?.authentication?.local?.username
        stackView.addArrangedSubview(loginNameTextField)
        let passwordTextField = UITextField()
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        stackView.addArrangedSubview(passwordTextField)
        alertController.contentView = stackView
        
        alertController.addCancelAction()
        alertController.addAction(title: NSLocalizedString("Change", comment: ""), isMainAction: true) {[weak self] _ in
            if let username = loginNameTextField.text, let password = passwordTextField.text {
                self?.userRepository.updateUsername(newUsername: username, password: password).observeCompleted {}
            }
        }
        alertController.show()
    }
    
    private func showPasswordChangeAlert() {
        let alertController = HabiticaAlertController(title: NSLocalizedString("Change Login Name", comment: ""))
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let oldPasswordTextField = UITextField()
        oldPasswordTextField.placeholder = NSLocalizedString("Old Password", comment: "")
        oldPasswordTextField.borderStyle = .roundedRect
        oldPasswordTextField.isSecureTextEntry = true
        stackView.addArrangedSubview(oldPasswordTextField)
        let newPasswordTextField = UITextField()
        newPasswordTextField.placeholder = NSLocalizedString("New Password", comment: "")
        newPasswordTextField.borderStyle = .roundedRect
        newPasswordTextField.isSecureTextEntry = true
        stackView.addArrangedSubview(newPasswordTextField)
        let confirmTextField = UITextField()
        confirmTextField.placeholder = NSLocalizedString("Confirm New Password", comment: "")
        confirmTextField.borderStyle = .roundedRect
        confirmTextField.isSecureTextEntry = true
        stackView.addArrangedSubview(confirmTextField)
        alertController.contentView = stackView
        
        alertController.addCancelAction()
        alertController.addAction(title: NSLocalizedString("Change", comment: ""), isMainAction: true) {[weak self] _ in
            if let newPassword = newPasswordTextField.text, let password = oldPasswordTextField.text, let confirmPassword = confirmTextField.text {
                self?.userRepository.updatePassword(newPassword: newPassword, password: password, confirmPassword: confirmPassword).observeCompleted {}
            }
        }
        alertController.show()
    }
}
