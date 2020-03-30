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
                if let email = user?.authentication?.local?.email {
                    cellDetailText = email
                } else {
                    cellDetailText = "No Email set"
                }
            } else if indexPath.item == 2 + confirmOffset {
                cellName = "ButtonCell"
                if user?.authentication?.local?.email != nil {
                    cellTitle = L10n.Settings.changePassword
                } else {
                    cellTitle = L10n.Settings.addEmailAndPassword
                }
            } else if indexPath.item == 3 + confirmOffset {
                cellTitle = L10n.Settings.loginMethods
                var loginMethods = [String]()
                if user?.authentication?.hasLocalAuth == true {
                    loginMethods.append(L10n.Settings.local)
                }
                if user?.authentication?.facebookID != nil {
                    loginMethods.append("Facebook")
                }
                if user?.authentication?.googleID != nil {
                    loginMethods.append("Google")
                }
                if user?.authentication?.appleID != nil {
                    loginMethods.append("Apple")
                }
                cellDetailText = loginMethods.joined(separator: ", ")
            }
        } else {
            cellTitleColor = UIColor.red50
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
                if (user?.authentication?.hasLocalAuth == true) {
                    showPasswordChangeAlert()
                } else {
                    showAddLocalAuthAlert()
                }
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
        if user?.authentication?.local?.email != nil {
            textView.text = L10n.Settings.deleteAccountDescription
        } else {
            textView.text = L10n.Settings.deleteAccountDescriptionSocial
        }
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = ThemeService.shared.theme.secondaryTextColor
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        stackView.addArrangedSubview(textView)
        let textField = UITextField()
        if user?.authentication?.local?.email != nil {
            textField.attributedPlaceholder = NSAttributedString(string: L10n.password, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        }
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.borderStyle = .roundedRect
        textField.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
        textField.textColor = ThemeService.shared.theme.primaryTextColor
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
        textView.textColor = ThemeService.shared.theme.secondaryTextColor
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        alertController.contentView = textView
        
        alertController.addCancelAction()
        alertController.addAction(title: L10n.Settings.resetAccount, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.userRepository.resetAccount().observeCompleted {}
        }
        alertController.show()
    }
    
    private func showEmailChangeAlert() {
        if user?.authentication?.local?.email == nil {
            return
        }
        let alertController = HabiticaAlertController(title: L10n.Settings.changeEmail)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let emailTextField = UITextField()
        emailTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.newEmail, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.spellCheckingType = .no
        emailTextField.text = user?.authentication?.local?.email
        emailTextField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        emailTextField.textColor = ThemeService.shared.theme.primaryTextColor
        stackView.addArrangedSubview(emailTextField)
        let passwordTextField = UITextField()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: L10n.password, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        passwordTextField.textColor = ThemeService.shared.theme.primaryTextColor
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
        loginNameTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        loginNameTextField.borderStyle = .roundedRect
        loginNameTextField.autocapitalizationType = .none
        loginNameTextField.spellCheckingType = .no
        loginNameTextField.text = user?.username
        loginNameTextField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        loginNameTextField.textColor = ThemeService.shared.theme.primaryTextColor
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
        oldPasswordTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.oldPassword, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        oldPasswordTextField.borderStyle = .roundedRect
        oldPasswordTextField.isSecureTextEntry = true
        oldPasswordTextField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        oldPasswordTextField.textColor = ThemeService.shared.theme.primaryTextColor
        stackView.addArrangedSubview(oldPasswordTextField)
        let newPasswordTextField = UITextField()
        newPasswordTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.newPassword, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        newPasswordTextField.borderStyle = .roundedRect
        newPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        newPasswordTextField.textColor = ThemeService.shared.theme.primaryTextColor
        stackView.addArrangedSubview(newPasswordTextField)
        let confirmTextField = UITextField()
        confirmTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.confirmNewPassword, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        confirmTextField.borderStyle = .roundedRect
        confirmTextField.isSecureTextEntry = true
        confirmTextField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        confirmTextField.textColor = ThemeService.shared.theme.primaryTextColor
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
    
    private func showAddLocalAuthAlert() {
        let alertController = HabiticaAlertController(title: L10n.Settings.addEmailAndPassword)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let emailTextField = UITextField()
        emailTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.newEmail, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        emailTextField.textColor = ThemeService.shared.theme.primaryTextColor
        stackView.addArrangedSubview(emailTextField)
        let passwordTextField = UITextField()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.newPassword, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        passwordTextField.textColor = ThemeService.shared.theme.primaryTextColor
        stackView.addArrangedSubview(passwordTextField)
        let confirmTextField = UITextField()
        confirmTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.confirmNewPassword, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        confirmTextField.borderStyle = .roundedRect
        confirmTextField.isSecureTextEntry = true
        confirmTextField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        confirmTextField.textColor = ThemeService.shared.theme.primaryTextColor
        stackView.addArrangedSubview(confirmTextField)
        alertController.contentView = stackView
        
        let errorView = UILabel()
        errorView.textColor = ThemeService.shared.theme.errorColor
        errorView.numberOfLines = 0
        errorView.isHidden = true
        stackView.addArrangedSubview(errorView)
        
        let loadingView = UIActivityIndicatorView()
        loadingView.color = ThemeService.shared.theme.tintColor
        loadingView.isHidden = true
        stackView.addArrangedSubview(loadingView)
        
        alertController.addCancelAction()
        alertController.addAction(title: L10n.add, isMainAction: true, closeOnTap: false) {[weak self] _ in
            errorView.isHidden = true
            if let password = passwordTextField.text, let email = emailTextField.text, let confirmPassword = confirmTextField.text {
                if (password != confirmPassword || password.count < 8) {
                    errorView.text = L10n.Login.passwordConfirmError
                    errorView.isHidden = false
                    return
                }
                if (email.count == 0) {
                    errorView.text = L10n.Login.emailInvalid
                    errorView.isHidden = false
                    return
                }
                loadingView.isHidden = false
                loadingView.startAnimating()
                emailTextField.resignFirstResponder()
                passwordTextField.resignFirstResponder()
                confirmTextField.resignFirstResponder()
                self?.userRepository.register(username: self?.user?.username ?? "", password: password, confirmPassword: confirmPassword, email: email).observeResult { result in
                    loadingView.isHidden = true
                    switch result {
                    case .success:
                        alertController.dismiss(animated: true, completion: nil)
                        self?.userRepository.retrieveUser().observeValues { user in
                            if user?.authentication?.local?.email != nil {
                                ToastManager.show(text: L10n.Settings.addedLocalAuth, color: .green)
                            }
                            self?.tableView.reloadData()
                        }
                    case .failure:
                        errorView.text = L10n.Login.registerError
                        errorView.isHidden = false
                    }
                }
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
