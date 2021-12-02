//
//  AccountSettingsViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.11.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka
import ReactiveSwift
import Habitica_Models
import UIKit

class AccountSettingsViewController: FormViewController, Themeable, UITextFieldDelegate {
    
    let userRepository = UserRepository()
    private let contentRepository = ContentRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    private let configRepository = ConfigRepository.shared
    
    private var user: UserProtocol?
    private var isSettingUserData = false
    
    override func viewDidLoad() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.cellLayoutMarginsFollowReadableWidth = false
        super.viewDidLoad()
        navigationItem.title = L10n.Titles.settings
        setupForm()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
            self?.setUser(user)
        }).start())
        
        LabelRow.defaultCellUpdate = { cell, _ in
            cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
            cell.detailTextLabel?.textColor = ThemeService.shared.theme.ternaryTextColor
            cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        }
        ButtonRow.defaultCellUpdate = { cell, _ in
            cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
            cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        }
        TimeRow.defaultCellUpdate = { cell, _ in
            cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
        }
        
        ThemeService.shared.addThemeable(themable: self, applyImmediately: true)
    }
    
    func applyTheme(theme: Theme) {
        tableView.backgroundColor = theme.contentBackgroundColor
        tableView.reloadData()
    }
    
    func setupForm() {
        buildAccountInfoSection()
        buildLoginMethodsSection()
        buildPublicProfileSection()
        buildApiSection()
        buildDangerSection()
    }
    
    func buildAccountInfoSection() {
        form +++ Section(L10n.Settings.accountInfo)
        <<< LabelRow { row in
            row.title = L10n.username
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                cell.detailTextLabel?.text = self?.user?.authentication?.local?.username ?? L10n.Settings.notSet
            }.onCellSelection { _, _ in
                self.showLoginNameChangeAlert()
            }
        }
        <<< LabelRow { row in
            row.title = L10n.Settings.email
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                cell.detailTextLabel?.text = self?.user?.authentication?.local?.email ?? L10n.Settings.notSet
            }.onCellSelection { _, _ in
                self.showEmailChangeAlert()
            }
        }
    }
    
    func buildLoginMethodsSection() {
        form +++ Section(L10n.Settings.loginMethods)
        <<< LabelRow { row in
            row.title = L10n.Settings.password
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                cell.detailTextLabel?.text = self?.user?.authentication?.local?.email != nil ? "ᐧᐧᐧᐧᐧᐧᐧᐧᐧᐧ" : L10n.Settings.notSet
                let label = UILabel()
                if self?.user?.authentication?.hasLocalAuth == true {
                    label.text = L10n.Settings.changePassword
                } else {
                    label.text = L10n.Settings.addPassword
                }
                label.textColor = ThemeService.shared.theme.ternaryTextColor
                label.font = .systemFont(ofSize: 17)
                cell.accessoryView = label
            }.onCellSelection { _, _ in
                self.showPasswordChangeAlert()
            }
        }
        <<< LabelRow { row in
            row.title = "Google"
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                self?.configureSocialCell(cell: cell, email: self?.user?.authentication?.google?.emails.first, isConnected: self?.user?.authentication?.hasGoogleAuth)
            }
            row.onCellSelection { _, _ in
                if self.user?.authentication?.hasGoogleAuth == true {
                    self.disconnectSocial("google")
                } else {
                    self.googleLoginButtonPressed()
                }
            }
        }
        <<< LabelRow("facebookRow") { row in
            row.title = "Facebook"
            row.cellStyle = .subtitle
            row.hidden = true
            row.cellUpdate {[weak self] cell, _ in
                self?.configureSocialCell(cell: cell, email: self?.user?.authentication?.facebook?.emails.first, isConnected: self?.user?.authentication?.hasFacebookAuth)
            }
            row.onCellSelection { _, _ in
                if self.user?.authentication?.hasFacebookAuth == true {
                    self.disconnectSocial("facebook")
                }
            }
        }
        <<< LabelRow { row in
            row.title = "Apple"
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                self?.configureSocialCell(cell: cell, email: self?.user?.authentication?.apple?.emails.first, isConnected: self?.user?.authentication?.hasAppleAuth)
            }
            row.onCellSelection { _, _ in
                if self.user?.authentication?.hasAppleAuth == true {
                    self.disconnectSocial("apple")
                } else {
                    self.appleLoginButtonPressed()
                }
            }
        }
    }
    
    func buildPublicProfileSection() {
        form +++ Section(L10n.Settings.publicProfile)
        <<< LabelRow { row in
            row.title = L10n.displayName
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                cell.detailTextLabel?.text = self?.user?.profile?.name
            }.onCellSelection { _, _ in
                self.showEditAlert(title: L10n.Settings.changeDisplayName, message: "", value: self.user?.profile?.name, path: "profile.name")
            }
        }
        <<< LabelRow { row in
            row.title = L10n.aboutText
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                cell.detailTextLabel?.text = self?.user?.profile?.blurb
            }.onCellSelection { _, _ in
                self.showEditAlert(title: L10n.Settings.changeAboutMessage, message: "", value: self.user?.profile?.blurb, path: "profile.blurb")
            }
        }
        <<< LabelRow { row in
            row.title = L10n.photoUrl
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                cell.detailTextLabel?.text = self?.user?.profile?.photoUrl
            }.onCellSelection { _, _ in
                self.showEditAlert(title: L10n.Settings.changePhotoUrl, message: "", value: self.user?.profile?.photoUrl, path: "profile.url")
            }
        }
    }
    
    func buildApiSection() {
        form +++ Section(L10n.Settings.api)
        <<< LabelRow { row in
            row.title = L10n.userID
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                cell.detailTextLabel?.text = self?.user?.id
            }.onCellSelection { _, _ in
                self.copyToClipboard(L10n.userID, value: self.user?.id)
            }
        }
        <<< LabelRow { row in
            row.title = L10n.apiKey
            row.cellStyle = .subtitle
            row.cellUpdate { cell, _ in
                cell.detailTextLabel?.text = L10n.Settings.apiDisclaimer
            }.onCellSelection { _, _ in
                self.copyToClipboard(L10n.apiKey, value: AuthenticationManager.shared.currentUserKey)
            }
        }
            <<< ButtonRow { row in
                row.title = L10n.Settings.fixCharacterValues
                row.presentationMode = .segueName(segueName: StoryboardSegue.Settings.fixValuesSegue.rawValue, onDismiss: nil)
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.textLabel?.textAlignment = .natural
                    cell.accessoryType = .disclosureIndicator
                })
            }
        }
    
    func buildDangerSection() {
        form +++ Section(L10n.Settings.dangerZone)
        <<< ButtonRow { row in
            row.title = L10n.Settings.resetAccount
            row.cellUpdate({ (cell, _) in
                cell.textLabel?.textColor = UIColor.red50
            }).onCellSelection({ (_, _) in
                self.showResetAccountAlert()
            })
        }
        <<< ButtonRow { row in
            row.title = L10n.Settings.deleteAccount
            row.cellUpdate({ (cell, _) in
                cell.textLabel?.textColor = UIColor.red50
            }).onCellSelection({ (_, _) in
                self.showDeleteAccountAlert()
            })
        }
    }
    
    @IBAction func unwindToListSave(_ segue: UIStoryboardSegue) {
    }

private func setUser(_ user: UserProtocol) {
    isSettingUserData = true
    if user.authentication?.hasFacebookAuth == true {
        form.rowBy(tag: "facebookRow")?.hidden = false
    } else {
        form.rowBy(tag: "facebookRow")?.hidden = true
    }
    form.rowBy(tag: "facebookRow")?.evaluateHidden()
    self.tableView.reloadData()
    isSettingUserData = false
}

    private func copyToClipboard(_ name: String, value: String?) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = value
        ToastManager.show(text: L10n.copiedToClipboard, color: .blue)
    }
    
    private func showEditAlert(title: String, message: String, value: String?, path: String) {
        let alertController = HabiticaAlertController(title: title, message: message)
        let textField = PaddedTextField()
        configureTextField(textField)
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.text = value
        textField.delegate = self
        textField.addHeightConstraint(height: 50)
        alertController.contentView = textField
        alertController.addAction(title: L10n.change, isMainAction: true) {[weak self] _ in
            if textField.text != value {
                self?.userRepository.updateUser(key: path, value: textField.text).observeCompleted {}
            }
        }
        alertController.addCancelAction()
        alertController.show()
    }
    
    private func showDeleteAccountAlert() {
        let alertController = HabiticaAlertController(title: L10n.Settings.deleteAccount)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        let textView = UITextView()
        if user?.authentication?.local?.email != nil {
            textView.text = L10n.Settings.deleteAccountDescription
        } else {
            textView.text = L10n.Settings.deleteAccountDescriptionSocial
        }
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = ThemeService.shared.theme.ternaryTextColor
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.isSelectable = false
        textView.textAlignment = .center
        textView.addHeightConstraint(height: 150)
        textView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        stackView.addArrangedSubview(textView)
        let textField = PaddedTextField()
        if user?.authentication?.local?.email != nil {
            textField.attributedPlaceholder = NSAttributedString(string: L10n.password, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        }
        configureTextField(textField)
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.delegate = self
        stackView.addArrangedSubview(textField)
        alertController.contentView = stackView
        
        alertController.buttonAxis = .horizontal
        alertController.addCancelAction()
        alertController.addAction(title: L10n.Settings.deleteAccount, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.userRepository.deleteAccount(password: textField.text ?? "").observeValues({ response in
                if response.statusCode == 200 {
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                } else if response.statusCode == 401 {
                    let alertView = HabiticaAlertController(title: L10n.Settings.wrongPassword)
                    alertView.addCloseAction()
                    alertView.show()
                }
            })
        }
        alertController.onKeyboardChange = { isVisible in
            textView.isHidden = isVisible
        }
        alertController.show()
    }

    private func showResetAccountAlert() {
        let alertController = HabiticaAlertController(title: L10n.Settings.resetAccount)
        
        let textView = UITextView()
        textView.text = L10n.Settings.resetAccountDescription
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = ThemeService.shared.theme.ternaryTextColor
        textView.isEditable = false
        textView.isSelectable = false
        textView.textAlignment = .center
        textView.addHeightConstraint(height: 350)
        textView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        alertController.contentView = textView
        
        alertController.addAction(title: L10n.Settings.resetAccount, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.userRepository.resetAccount().observeCompleted {}
        }
        alertController.addCancelAction()
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
        let emailTextField = PaddedTextField()
        emailTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.newEmail, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        configureTextField(emailTextField)
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.spellCheckingType = .no
        emailTextField.text = user?.authentication?.local?.email
        emailTextField.addHeightConstraint(height: 50)
        stackView.addArrangedSubview(emailTextField)
        let passwordTextField = PaddedTextField()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.password, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        configureTextField(passwordTextField)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        stackView.addArrangedSubview(passwordTextField)
        alertController.contentView = stackView
        
        alertController.addAction(title: L10n.change, isMainAction: true) {[weak self] _ in
            if let email = emailTextField.text, let password = passwordTextField.text {
                self?.userRepository.updateEmail(newEmail: email, password: password).observeCompleted {}
            }
        }
        alertController.addCancelAction()
        alertController.show()
    }

    private func showLoginNameChangeAlert() {
        let title = L10n.Settings.changeUsername
        let alertController = HabiticaAlertController(title: title)
        let loginNameTextField = PaddedTextField()
        loginNameTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.newUsername, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        configureTextField(loginNameTextField)
        loginNameTextField.autocapitalizationType = .none
        loginNameTextField.spellCheckingType = .no
        loginNameTextField.text = user?.username
        loginNameTextField.delegate = self
        loginNameTextField.addHeightConstraint(height: 50)
        alertController.contentView = loginNameTextField
        
        alertController.addAction(title: L10n.change, isMainAction: true) {[weak self] _ in
            if let username = loginNameTextField.text {
                self?.userRepository.updateUsername(newUsername: username).observeCompleted {}
            }
        }
        alertController.addCancelAction()
        alertController.show()
    }

    private func showPasswordChangeAlert() {
        let alertController = HabiticaAlertController(title: L10n.Settings.changePassword)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let oldPasswordTextField = PaddedTextField()
        oldPasswordTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.oldPassword, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        configureTextField(oldPasswordTextField)
        oldPasswordTextField.isSecureTextEntry = true
        stackView.addArrangedSubview(oldPasswordTextField)
        let newPasswordTextField = PaddedTextField()
        newPasswordTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.newPassword, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        configureTextField(newPasswordTextField)
        newPasswordTextField.isSecureTextEntry = true
        stackView.addArrangedSubview(newPasswordTextField)
        let confirmTextField = PaddedTextField()
        confirmTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.confirmNewPassword, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        configureTextField(confirmTextField)
        confirmTextField.isSecureTextEntry = true
        confirmTextField.delegate = self
        stackView.addArrangedSubview(confirmTextField)
        alertController.contentView = stackView
        
        alertController.addAction(title: L10n.change, isMainAction: true) {[weak self] _ in
            if let newPassword = newPasswordTextField.text, let password = oldPasswordTextField.text, let confirmPassword = confirmTextField.text {
                self?.userRepository.updatePassword(newPassword: newPassword, password: password, confirmPassword: confirmPassword).observeCompleted {}
            }
        }
        alertController.addCancelAction()
        alertController.show()
    }

    private func showAddLocalAuthAlert() {
        let alertController = HabiticaAlertController(title: L10n.Settings.addEmailAndPassword)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let emailTextField = PaddedTextField()
        emailTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.newEmail, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        configureTextField(emailTextField)
        emailTextField.keyboardType = .emailAddress
        stackView.addArrangedSubview(emailTextField)
        let passwordTextField = PaddedTextField()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.newPassword, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        configureTextField(passwordTextField)
        passwordTextField.isSecureTextEntry = true
        stackView.addArrangedSubview(passwordTextField)
        let confirmTextField = PaddedTextField()
        confirmTextField.attributedPlaceholder = NSAttributedString(string: L10n.Settings.confirmNewPassword, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        configureTextField(confirmTextField)
        confirmTextField.isSecureTextEntry = true
        confirmTextField.delegate = self
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
        
        alertController.addAction(title: L10n.add, isMainAction: true, closeOnTap: false) {[weak self] _ in
            errorView.isHidden = true
            if let password = passwordTextField.text, let email = emailTextField.text, let confirmPassword = confirmTextField.text {
                if password != confirmPassword || password.count < 8 {
                    errorView.text = L10n.Login.passwordConfirmError
                    errorView.isHidden = false
                    return
                }
                if email.isEmpty {
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
        alertController.addCancelAction()
        alertController.show()
    }

    private func showConfirmUsernameAlert() {
        let alertController = HabiticaAlertController(title: L10n.Settings.confirmUsernamePrompt, message: L10n.Settings.confirmUsernameDescription)
        alertController.addAction(title: L10n.confirm, isMainAction: true) {[weak self] _ in
            if let username = self?.user?.username {
                self?.userRepository.updateUsername(newUsername: username).observeCompleted {}
            }
        }
        alertController.addCancelAction()
        alertController.show()
    }

    private func configureTextField(_ textField: PaddedTextField) {
        textField.borderStyle = .none
        textField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        textField.borderColor = ThemeService.shared.theme.offsetBackgroundColor
        textField.borderWidth = 1
        textField.cornerRadius = 8
        textField.textInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        textField.textColor = ThemeService.shared.theme.secondaryTextColor
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
