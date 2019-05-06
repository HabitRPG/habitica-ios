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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.Titles.authentication
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if user?.flags?.verifiedUsername != true {
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
            return L10n.Settings.authentication
        } else {
            return L10n.Settings.dangerZone
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellName = "Cell"
        var cellTitle = ""
        var cellTitleColor = ThemeService.shared.theme.primaryTextColor
        var cellDetailText: String?
        var confirmOffset = 0
        if user?.flags?.verifiedUsername != true {
            confirmOffset = 1
        }
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                cellTitle = L10n.username
                cellDetailText = user?.username
            } else if indexPath.item == 1 && confirmOffset > 0 {
                cellName = "ButtonCell"
                cellTitle = L10n.confirmUsername
                cellTitleColor = ThemeService.shared.theme.successColor
            } else if indexPath.item == 1 + confirmOffset {
                cellTitle = L10n.email
                cellDetailText = user?.authentication?.local?.email
            } else if indexPath.item == 2 + confirmOffset {
                cellName = "ButtonCell"
                cellTitle = L10n.Settings.changePassword
            } else if indexPath.item == 3 + confirmOffset {
                cellTitle = L10n.Settings.loginMethods
                var loginMethods = [String]()
                if user?.authentication?.local?.email != nil {
                    loginMethods.append(L10n.Settings.local)
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
                cellTitle = L10n.Settings.resetAccount
            } else {
                cellTitle = L10n.Settings.deleteAccount
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath)
        let textLabel = cell.viewWithTag(1) as? UILabel
        textLabel?.text = cellTitle
        textLabel?.textColor = cellTitleColor
        if let text = cellDetailText {
            cell.detailTextLabel?.text = text
            cell.detailTextLabel?.textColor = ThemeService.shared.theme.secondaryTextColor
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var confirmOffset = 0
        if user?.flags?.verifiedUsername != true {
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
        let alertController = HabiticaAlertController(title: L10n.Settings.deleteAccount)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let textView = UITextView()
        textView.text = L10n.Settings.deleteAccountDescription
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = UIColor.gray100()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        stackView.addArrangedSubview(textView)
        let textField = UITextField()
        textField.placeholder = L10n.password
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.borderStyle = .roundedRect
        stackView.addArrangedSubview(textField)
        alertController.contentView = stackView
        
        alertController.addCancelAction()
        alertController.addAction(title: L10n.Settings.deleteAccount, style: .destructive, isMainAction: true) {[weak self] _ in
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
        let alertController = HabiticaAlertController(title: L10n.Settings.resetAccount)
        
        let textView = UITextView()
        textView.text = L10n.Settings.resetAccountDescription
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = UIColor.gray100()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        alertController.contentView = textView
        
        alertController.addCancelAction()
        alertController.addAction(title: L10n.Settings.resetAccount, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.userRepository.resetAccount().observeCompleted {}
        }
        alertController.show()
    }
    
    private func showEmailChangeAlert() {
        let alertController = HabiticaAlertController(title: L10n.Settings.changeEmail)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let emailTextField = UITextField()
        emailTextField.placeholder = L10n.Settings.newEmail
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.spellCheckingType = .no
        emailTextField.text = user?.authentication?.local?.email
        stackView.addArrangedSubview(emailTextField)
        let passwordTextField = UITextField()
        passwordTextField.placeholder = L10n.password
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        stackView.addArrangedSubview(passwordTextField)
        alertController.contentView = stackView
        
        alertController.addCancelAction()
        alertController.addAction(title: L10n.change, isMainAction: true) {[weak self] _ in
            if let email = emailTextField.text, let password = passwordTextField.text {
                self?.userRepository.updateEmail(newEmail: email, password: password).observeCompleted {}
            }
        }
        alertController.show()
    }
    
    private func showLoginNameChangeAlert() {
        let title = L10n.Settings.changeUsername
        let placeholder = L10n.Settings.newUsername
        let alertController = HabiticaAlertController(title: title)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let loginNameTextField = UITextField()
        loginNameTextField.placeholder = placeholder
        loginNameTextField.borderStyle = .roundedRect
        loginNameTextField.autocapitalizationType = .none
        loginNameTextField.spellCheckingType = .no
        loginNameTextField.text = user?.username
        stackView.addArrangedSubview(loginNameTextField)
        alertController.contentView = stackView
        
        alertController.addCancelAction()
        alertController.addAction(title: L10n.change, isMainAction: true) {[weak self] _ in
            if let username = loginNameTextField.text {
                self?.userRepository.updateUsername(newUsername: username).observeCompleted {}
            }
        }
        alertController.show()
    }
    
    private func showPasswordChangeAlert() {
        let alertController = HabiticaAlertController(title: L10n.Settings.changePassword)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let oldPasswordTextField = UITextField()
        oldPasswordTextField.placeholder = L10n.Settings.oldPassword
        oldPasswordTextField.borderStyle = .roundedRect
        oldPasswordTextField.isSecureTextEntry = true
        stackView.addArrangedSubview(oldPasswordTextField)
        let newPasswordTextField = UITextField()
        newPasswordTextField.placeholder = L10n.Settings.newPassword
        newPasswordTextField.borderStyle = .roundedRect
        newPasswordTextField.isSecureTextEntry = true
        stackView.addArrangedSubview(newPasswordTextField)
        let confirmTextField = UITextField()
        confirmTextField.placeholder = L10n.Settings.confirmNewPassword
        confirmTextField.borderStyle = .roundedRect
        confirmTextField.isSecureTextEntry = true
        stackView.addArrangedSubview(confirmTextField)
        alertController.contentView = stackView
        
        alertController.addCancelAction()
        alertController.addAction(title: L10n.change, isMainAction: true) {[weak self] _ in
            if let newPassword = newPasswordTextField.text, let password = oldPasswordTextField.text, let confirmPassword = confirmTextField.text {
                self?.userRepository.updatePassword(newPassword: newPassword, password: password, confirmPassword: confirmPassword).observeCompleted {}
            }
        }
        alertController.show()
    }
    
    private func showConfirmUsernameAlert() {
        let alertController = HabiticaAlertController(title: L10n.Settings.confirmUsernamePrompt, message: L10n.Settings.confirmUsernameDescription)
        alertController.addCancelAction()
        alertController.addAction(title: L10n.confirm, isMainAction: true) {[weak self] _ in
            if let username = self?.user?.username {
                self?.userRepository.updateUsername(newUsername: username).observeCompleted {}
            }
        }
        alertController.show()
    }
}
