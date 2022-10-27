//
//  AccountSettingsViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.11.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import UIKit
import Eureka
import ReactiveSwift
import Habitica_Models

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
            if user.isValid {
                self?.user = user
                self?.setUser(user)
            }
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
    
    //MARK: - Build Info Section
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
                if self?.user?.isValid != true {
                    return
                }
                cell.detailTextLabel?.text = self?.user?.authentication?.local?.email ?? L10n.Settings.notSet
                
                if self?.user?.authentication?.local?.email == nil {
                    let label = UILabel()
                    label.text = L10n.Settings.addEmail
                    label.textColor = ThemeService.shared.theme.ternaryTextColor
                    label.font = .systemFont(ofSize: 17)
                    label.sizeToFit()
                    cell.accessoryView = label
                } else {
                    cell.accessoryView = nil
                }
            }.onCellSelection { _, _ in
                self.showEmailChangeAlert()
            }
        }
    }
    
    //MARK: - Build LoginMethods Section
    func buildLoginMethodsSection() {
        form +++ Section(L10n.Settings.loginMethods)
        <<< LabelRow { row in
            row.title = L10n.Settings.password
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                if self?.user?.isValid != true {
                    return
                }
                cell.detailTextLabel?.text = self?.user?.authentication?.hasLocalAuth == true ? "ᐧᐧᐧᐧᐧᐧᐧᐧᐧᐧ" : L10n.Settings.notSet
                let label = UILabel()
                if self?.user?.authentication?.hasLocalAuth == true {
                    label.text = L10n.Settings.change
                } else {
                    label.text = L10n.Settings.addPassword
                }
                label.textColor = ThemeService.shared.theme.ternaryTextColor
                label.font = .systemFont(ofSize: 17)
                label.sizeToFit()
                cell.accessoryView = label
            }.onCellSelection { _, _ in
                if self.user?.authentication?.hasLocalAuth == true {
                    self.showPasswordChangeAlert()
                } else {
                    self.showAddLocalAuthAlert(title: L10n.Settings.addPassword)
                }
            }
        }
        <<< LabelRow { row in
            row.title = "Google"
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                if self?.user?.isValid != true {
                    return
                }
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
                if self?.user?.isValid != true {
                    return
                }
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
                if self?.user?.isValid != true {
                    return
                }
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
    
    //MARK: - Build Profile Section
    func buildPublicProfileSection() {
        form +++ Section(L10n.Settings.publicProfile)
        <<< LabelRow { row in
            row.title = L10n.displayName
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                if self?.user?.isValid != true {
                    return
                }
                cell.detailTextLabel?.text = self?.user?.profile?.name
            }.onCellSelection { _, _ in
                self.showEditAlert(title: L10n.Settings.changeDisplayName, name: L10n.displayName, value: self.user?.profile?.name, path: "profile.name")
            }
        }
        <<< LabelRow { row in
            row.title = L10n.aboutText
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                if self?.user?.isValid != true {
                    return
                }
                cell.detailTextLabel?.text = self?.user?.profile?.blurb
            }.onCellSelection { _, _ in
                self.showEditAlert(title: L10n.Settings.changeAboutMessage, name: L10n.aboutText, value: self.user?.profile?.blurb, path: "profile.blurb")
            }
        }
        <<< LabelRow { row in
            row.title = L10n.photoUrl
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                if self?.user?.isValid != true {
                    return
                }
                cell.detailTextLabel?.text = self?.user?.profile?.photoUrl
            }.onCellSelection { _, _ in
                self.showEditAlert(title: L10n.Settings.changePhotoUrl, name: L10n.photoUrl, value: self.user?.profile?.photoUrl, path: "profile.url")
            }
        }
    }
    
    //MARK: - Build API Section
    func buildApiSection() {
        form +++ Section(L10n.Settings.api)
        <<< LabelRow { row in
            row.title = L10n.userID
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                if self?.user?.isValid != true {
                    return
                }
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
    
    //MARK: - Build Danger Section
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
        if !user.isValid {
            self.user = nil
            return
        }
        isSettingUserData = true
        if user.authentication?.hasFacebookAuth == true {
            form.rowBy(tag: "facebookRow")?.hidden = false
        } else {
            form.rowBy(tag: "facebookRow")?.hidden = true
        }
        form.rowBy(tag: "facebookRow")?.evaluateHidden()
        isSettingUserData = false
        self.tableView.reloadData()
        form.allRows.forEach { row in
            row.updateCell()
        }
    }

    private func copyToClipboard(_ name: String, value: String?) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = value
        ToastManager.show(text: L10n.copiedToClipboard, color: .blue)
    }
    
    private func showEditAlert(title: String, name: String, value: String?, path: String) {
        let controller = EditingFormViewController()
        controller.formTitle = title
        controller.fields.append(EditingTextField(key: "value", title: name, type: .name, value: value))
        controller.onSave = {[weak self] values in
            if let value = values["value"] {
                self?.userRepository.updateUser(key: path, value: value).observeCompleted {}
            }
        }
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
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
            if let password = textField.text {
                self?.deleteAccount(password: password)
            }
        }
        alertController.onKeyboardChange = { isVisible in
            textView.isHidden = isVisible
        }
        alertController.show()
    }

    private func deleteAccount(password: String) {
        userRepository.deleteAccount(password: password).observeValues({[weak self] response in
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
        let controller = EditingFormViewController()
        controller.formTitle = L10n.Settings.changeEmail
        controller.fields.append(EditingTextField(key: "email", title: L10n.email, type: .email, value: user?.authentication?.local?.email))
        if user?.authentication?.hasLocalAuth == true {
            controller.fields.append(EditingTextField(key: "password", title: L10n.password, type: .password))
        }
        controller.onSave = {[weak self] values in
            if let email = values["email"] {
                self?.userRepository.updateEmail(newEmail: email, password: values["password"] ?? "").observeCompleted {
                    ToastManager.show(text: L10n.Settings.updatedEmail, color: .green)
                }
            }
        }
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    private func showLoginNameChangeAlert() {
        let controller = EditingFormViewController()
        controller.formTitle = L10n.Settings.changeUsername
        controller.fields.append(EditingTextField(key: "username", title: L10n.username, type: .name, value: user?.username))
        controller.onSave = {[weak self] values in
            if let username = values["username"] {
                self?.userRepository.updateUsername(newUsername: username).observeCompleted {}
            }
        }
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    private func showPasswordChangeAlert() {
        let controller = EditingFormViewController()
        controller.formTitle = L10n.Settings.changePassword
        controller.fields.append(EditingTextField(key: "oldPassword", title: L10n.Settings.oldPassword, type: .password))
        controller.fields.append(EditingTextField(key: "password", title: L10n.Settings.newPassword, type: .password))
        controller.fields.append(EditingTextField(key: "passwordRepeat", title: L10n.Settings.confirmNewPassword, type: .password))

        controller.onCrossValidation = { values in
            var errors = [String: String]()
            if values["password"] != values["passwordRepeat"] {
                errors["passwordRepeat"] = L10n.Errors.passwordNotMatching
            }
            return errors
        }
        
        controller.onSave = {[weak self] values in
            if let oldPassword = values["oldPassword"], let password = values["password"], let passwordRepeat = values["passwordRepeat"] {
                self?.userRepository.updatePassword(newPassword: password, password: oldPassword, confirmPassword: passwordRepeat).observeCompleted {
                    ToastManager.show(text: L10n.Settings.updatedPassword, color: .green)
                }
            }
        }
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    private func showAddLocalAuthAlert(title: String) {
        let hasEmail = user?.authentication?.local?.email != nil
        let controller = EditingFormViewController()
        controller.formTitle = title
        if !hasEmail {
            controller.fields.append(EditingTextField(key: "email", title: L10n.Settings.email, type: .email))
        }
        controller.fields.append(EditingTextField(key: "password", title: L10n.Settings.newPassword, type: .password))
        controller.fields.append(EditingTextField(key: "passwordRepeat", title: L10n.Settings.confirmNewPassword, type: .password))

        controller.onCrossValidation = { values in
            var errors = [String: String]()
            if values["password"] != values["passwordRepeat"] {
                errors["passwordRepeat"] = L10n.Errors.passwordNotMatching
            }
            return errors
        }
        
        controller.onSave = {[weak self] values in
            if let email = values["email"] ?? self?.user?.authentication?.local?.email, let password = values["password"], let passwordRepeat = values["passwordRepeat"] {
                self?.userRepository.register(username: self?.user?.username ?? "", password: password, confirmPassword: passwordRepeat, email: email).observeResult { result in
                    switch result {
                    case .success:
                        self?.userRepository.retrieveUser().observeValues { user in
                            if user?.authentication?.local?.email != nil {
                                ToastManager.show(text: L10n.Settings.addedLocalAuth, color: .green)
                            }
                        }
                    case .failure:
                        return
                    }
                }
            }
        }
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
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
