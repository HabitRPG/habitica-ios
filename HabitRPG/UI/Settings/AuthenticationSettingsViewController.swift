//
//  AuthenticationSettingsViewController.swift
//  Habitica
//
//  Created by Phillip on 20.10.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class AuthenticationSettingsViewController: BaseSettingsViewController {
    
    private var configRepository = ConfigRepository()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if configRepository.bool(variable: .enableChangeUsername) && user?.flags?.verifiedUsername != true {
                return 5
            } else {
                return 4
            }
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
        var cellName = "Cell"
        var cellTitle = ""
        var cellTitleColor = UIColor.black
        var cellDetailText: String? = nil
        var confirmOffset = 0
        if configRepository.bool(variable: .enableChangeUsername) && user?.flags?.verifiedUsername != true {
            confirmOffset = 1
        }
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                if configRepository.bool(variable: .enableChangeUsername) {
                    cellTitle = L10n.username
                } else {
                    cellTitle = NSLocalizedString("Login Name", comment: "")
                }
                cellDetailText = user?.authentication?.local?.username
            } else if indexPath.item == 1 && confirmOffset > 0 {
                cellName = "ButtonCell"
                cellTitle = L10n.confirmUsername
                cellTitleColor = UIColor.green50()
            } else if indexPath.item == 1 + confirmOffset {
                cellTitle = L10n.email
                cellDetailText = user?.authentication?.local?.email
            } else if indexPath.item == 2 + confirmOffset {
                cellName = "ButtonCell"
                cellTitle = NSLocalizedString("Change Password", comment: "")
            } else if indexPath.item == 3 + confirmOffset {
                cellTitle = NSLocalizedString("Login Methods", comment: "")
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
                cellDetailText = loginMethods.joined(separator: ", ")
            }
        } else {
            cellTitleColor = UIColor.red50()
            cellName = "ButtonCell"
            if indexPath.item == 0 {
                cellTitle = NSLocalizedString("Reset Account", comment: "")
            } else {
                cellTitle = NSLocalizedString("Delete Account", comment: "")
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath)
        let textLabel = cell.viewWithTag(1) as? UILabel
        textLabel?.text = cellTitle
        textLabel?.textColor = cellTitleColor
        if let text = cellDetailText {
            cell.detailTextLabel?.text = text
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var confirmOffset = 0
        if configRepository.bool(variable: .enableChangeUsername) && user?.flags?.verifiedUsername != true {
            confirmOffset = 1
        }
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                showLoginNameChangeAlert()
            } else if indexPath.item == 1 && confirmOffset > 0 {
                showConfirmUsernameAlert()
            } else if indexPath.item == 1 + confirmOffset {
                showEmailChangeAlert()
            } else if indexPath.item == 2 + confirmOffset {
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
        var title = NSLocalizedString("Change Login Name", comment: "")
        var placeholder = NSLocalizedString("New Login Name", comment: "")
        if configRepository.bool(variable: .enableChangeUsername) {
            title = NSLocalizedString("Change Username", comment: "")
            placeholder = NSLocalizedString("New Username", comment: "")
        }
        let alertController = HabiticaAlertController(title: title)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let loginNameTextField = UITextField()
        loginNameTextField.placeholder = placeholder
        loginNameTextField.borderStyle = .roundedRect
        loginNameTextField.autocapitalizationType = .none
        loginNameTextField.spellCheckingType = .no
        loginNameTextField.text = user?.authentication?.local?.username
        stackView.addArrangedSubview(loginNameTextField)
        let passwordTextField = UITextField()
        if !configRepository.bool(variable: .enableChangeUsername) {
            passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
            passwordTextField.isSecureTextEntry = true
            passwordTextField.borderStyle = .roundedRect
            stackView.addArrangedSubview(passwordTextField)
        }
        alertController.contentView = stackView
        
        alertController.addCancelAction()
        alertController.addAction(title: NSLocalizedString("Change", comment: ""), isMainAction: true) {[weak self] _ in
            if self?.configRepository.bool(variable: .enableChangeUsername) == true {
                if let username = loginNameTextField.text {
                    self?.userRepository.updateUsername(newUsername: username).observeCompleted {}
                }
            } else {
                if let username = loginNameTextField.text, let password = passwordTextField.text {
                    self?.userRepository.updateUsername(newUsername: username, password: password).observeCompleted {}
                }
            }
        }
        alertController.show()
    }
    
    private func showPasswordChangeAlert() {
        let alertController = HabiticaAlertController(title: NSLocalizedString("Change Password", comment: ""))
        
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
    
    private func showConfirmUsernameAlert() {
        let alertController = HabiticaAlertController(title: L10n.Settings.confirmUsernamePrompt)
        alertController.addCancelAction()
        alertController.addAction(title: L10n.confirm, isMainAction: true) {[weak self] _ in
            if let username = self?.user?.authentication?.local?.username {
                self?.userRepository.updateUsername(newUsername: username).observeCompleted {}
            }
        }
        alertController.show()
    }
}
