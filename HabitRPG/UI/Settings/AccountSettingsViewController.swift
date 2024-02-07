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
import SwiftUI

// swiftlint:disable:next type_body_length
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
    
    // MARK: - Build Info Section
    func buildAccountInfoSection() {
        form +++ Section(L10n.Settings.accountInfo)
        <<< LabelRow { row in
            row.title = L10n.username
            row.cellStyle = .subtitle
            row.cellUpdate {[weak self] cell, _ in
                if self?.user?.isValid != true {
                    return
                }
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
    
    // MARK: - Build LoginMethods Section
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
    
    // MARK: - Build Profile Section
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
                self.showEditAlert(title: L10n.Settings.changePhotoUrl, name: L10n.photoUrl, value: self.user?.profile?.photoUrl, path: "profile.imageUrl")
            }
        }
    }
    
    // MARK: - Build API Section
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
    
    // MARK: - Build Danger Section
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
        let navController = UINavigationController()
        let controller = UIHostingController(rootView: DeleteAccountView(dismisser: {
            navController.dismiss()
        }, onDelete: {[weak self] password in
            navController.dismiss()
            self?.deleteAccount(password: password)
        }, onForgotPassword: {[weak self] in
            self?.forgotPasswordButtonPressed()
        }, isSocial: user?.authentication?.local?.email == nil))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissController))
        navController.setViewControllers([controller], animated: false)
        present(navController, animated: true)
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
        let navController = UINavigationController()
        let controller = UIHostingController(rootView: ResetAccountView(dismisser: {
            navController.dismiss()
        }, onReset: {[weak self] password in
            navController.dismiss()
            self?.userRepository.resetAccount(password: password).observeCompleted {}
        }, onForgotPassword: {[weak self] in
            self?.forgotPasswordButtonPressed()
        }, isSocial: user?.authentication?.local?.email == nil))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissController))
        navController.setViewControllers([controller], animated: false)
        present(navController, animated: true)
    }
    
    @objc
    func dismissController(_ view: UIView) {
        view.nearestNavigationController?.dismiss()
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
    
    func forgotPasswordButtonPressed() {
        let alertController = HabiticaAlertController(title: L10n.Login.emailPasswordLink)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let textView = UITextView()
        textView.text = L10n.Login.enterEmail
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = UIColor.gray100
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        stackView.addArrangedSubview(textView)
        let textField = UITextField()
        textField.placeholder = L10n.email
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        stackView.addArrangedSubview(textField)
        alertController.contentView = stackView
        
        alertController.addAction(title: L10n.send, isMainAction: true) { _ in
            self.userRepository.sendPasswordResetEmail(email: textField.text ?? "").observeCompleted {
                ToastManager.show(text: L10n.Login.resetPasswordResponse, color: .green, duration: 4.0)
            }
        }
        alertController.addCancelAction()
        alertController.show()
    }
}

struct ResetAccountView: View {
    let dismisser: () -> Void
    let onReset: (String) -> Void
    let onForgotPassword: () -> Void
    let isSocial: Bool
    @State var text: String = ""
    
    private func isValidInput() -> Bool {
        if isSocial {
            return text == "RESET"
        } else {
            return !text.isEmpty
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Settings.resetAccountConfirm).font(.headline)
                if isSocial {
                    Text(L10n.Settings.resetAccountDescriptionSocial).font(.body).foregroundColor(Color(ThemeService.shared.theme.secondaryTextColor))
                } else {
                    Text(L10n.Settings.resetAccountDescription).font(.body).foregroundColor(Color(ThemeService.shared.theme.secondaryTextColor))
                }
                if #available(iOS 15.0, *) {
                    TextField(text: $text, prompt: Text(L10n.password)) {
                        
                    }
                    .padding(12)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke().foregroundColor(Color(ThemeService.shared.theme.tableviewSeparatorColor)))
                } else {
                    TextField(text: $text) {
                        
                    }
                    .padding(12)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke().foregroundColor(Color(ThemeService.shared.theme.tableviewSeparatorColor)))
                }
                HabiticaButtonUI(label: Text(L10n.Settings.resetAccount), color: Color(isValidInput() ? ThemeService.shared.theme.errorColor : ThemeService.shared.theme.dimmedColor)) {
                    onReset(text)
                }
                Text(L10n.Login.forgotPassword)
                    .foregroundColor(Color(ThemeService.shared.theme.tintColor))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onTapGesture {
                        onForgotPassword()
                    }
                    .padding(16)
            }.padding(16)
        }
    }
}

struct DeleteAccountView: View {
    let dismisser: () -> Void
    let onDelete: (String) -> Void
    let onForgotPassword: () -> Void
    let isSocial: Bool
    @State var text: String = ""
    
    private func isValidInput() -> Bool {
        if isSocial {
            return text == "DELETE"
        } else {
            return !text.isEmpty
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Settings.deleteAccountConfirm).font(.headline)
                if isSocial {
                    Text(L10n.Settings.deleteAccountDescriptionSocial).font(.body).foregroundColor(Color(ThemeService.shared.theme.secondaryTextColor))
                } else {
                    Text(L10n.Settings.deleteAccountDescription).font(.body).foregroundColor(Color(ThemeService.shared.theme.secondaryTextColor))
                }
                if #available(iOS 15.0, *) {
                    TextField(text: $text, prompt: Text(L10n.password)) {
                    }
                    .padding(12)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke().foregroundColor(Color(ThemeService.shared.theme.tableviewSeparatorColor)))
                } else {
                    TextField(text: $text) {
                    }
                    .padding(12)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke().foregroundColor(Color(ThemeService.shared.theme.tableviewSeparatorColor)))
                }
                HabiticaButtonUI(label: Text(L10n.Settings.deleteAccount), color: Color(isValidInput() ? ThemeService.shared.theme.errorColor : ThemeService.shared.theme.dimmedColor)) {
                    onDelete(text)
                }
                Text(L10n.Login.forgotPassword)
                    .foregroundColor(Color(ThemeService.shared.theme.tintColor))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onTapGesture {
                        onForgotPassword()
                    }
                    .padding(16)
            }.padding(16)
        }
    }
}
