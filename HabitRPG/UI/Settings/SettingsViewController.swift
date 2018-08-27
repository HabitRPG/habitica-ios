//
//  SettingsViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 03.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka
import MRProgress
import ReactiveSwift
import Habitica_Models

enum SettingsTags {
    static let dailyReminder = "dailyReminder"
    static let dailyReminderTime = "dailyReminderTime"
    static let displayNotificationsBadge = "displayNotificationsBadge"
    static let customDayStart = "customDayStart"
    static let disableAllNotifications = "disableAllNotifications"
    static let disablePrivateMessages = "disablePrivateMessages"
    static let themeColor = "themeColor"
    static let soundTheme = "soundTheme"
    static let changeClass = "changeClass"
}

enum ThemeName: String {
    case defaultTheme = "Default"
    case blue = "Blue"
    case teal = "Teal"
    case green = "Green"
    case yellow = "Yellow"
    case orange = "Orange"
    case red = "Red"
    case maroon = "Maroon"
    
    var themeClass: Theme {
        switch self {
        case .defaultTheme:
            return DefaultTheme()
        case .blue:
            return BlueTheme()
        case .teal:
            return TealTheme()
        case .green:
            return GreenTheme()
        case .yellow:
            return YellowTheme()
        case .orange:
            return OrangeTheme()
        case .red:
            return RedTheme()
        case .maroon:
            return MaroonTheme()
        }
    }
    
    static var allNames: [ThemeName] {
        return [
            .defaultTheme,
            .blue,
            .teal,
            .green,
            .yellow,
            .orange,
            .red,
            .maroon
        ]
    }
}

class SettingsViewController: FormViewController, Themeable {
    
    private let userRepository = UserRepository()
    private let contentRepository = ContentRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    private var user: UserProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
        loadSettingsFromUserDefaults()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
            self?.setUser(user)
        }).start())
        
        ThemeService.shared.addThemeable(themable: self, applyImmediately: true)
    }
    
    func applyTheme(theme: Theme) {
        tableView.reloadData()
    }
    
    private func setupForm() {
        setupUserSection()
        setupSettingsSections()
        form +++ Section(L10n.Settings.maintenance)
            <<< ButtonRow { row in
                row.title = L10n.Settings.clearCache
                row.cellSetup({ (cell, _) in
                    cell.tintColor = ThemeService.shared.theme.tintColor
                })
                }.onCellSelection({ (_, _) in
                    let progressView = MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
                    progressView?.setTintColor(ThemeService.shared.theme.tintColor)
                    self.contentRepository.clearDatabase()
                    self.contentRepository.retrieveContent().withLatest(from: self.userRepository.retrieveUser())
                        .observeCompleted {
                            progressView?.dismiss(true)
                    }
                })
            <<< ButtonRow { row in
                row.title = L10n.Settings.reloadContent
                row.cellSetup({ (cell, _) in
                    cell.tintColor = ThemeService.shared.theme.tintColor
                })
                }.onCellSelection({ (_, _) in
                    let progressView = MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
                    progressView?.tintColor = ThemeService.shared.theme.tintColor
                    self.contentRepository.retrieveContent().observeCompleted {
                        progressView?.dismiss(true)
                    }
                })
    }
    
    private func setupUserSection() {
        form +++ Section(L10n.Settings.user)
            <<< ButtonRow { row in
                row.title = L10n.Settings.profile
                row.presentationMode = .segueName(segueName: StoryboardSegue.Settings.profileSegue.rawValue, onDismiss: nil)
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = UIColor.black
                    cell.textLabel?.textAlignment = .natural
                    cell.accessoryType = .disclosureIndicator
                })
            }
            <<< ButtonRow { row in
                row.title = L10n.Settings.authentication
                row.presentationMode = .segueName(segueName: StoryboardSegue.Settings.authenticationSegue.rawValue, onDismiss: nil)
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = UIColor.black
                    cell.textLabel?.textAlignment = .natural
                    cell.accessoryType = .disclosureIndicator
                })
            }
            <<< ButtonRow { row in
                row.title = L10n.Settings.api
                row.presentationMode = .segueName(segueName: StoryboardSegue.Settings.apiSegue.rawValue, onDismiss: nil)
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = UIColor.black
                    cell.textLabel?.textAlignment = .natural
                    cell.accessoryType = .disclosureIndicator
                })
            }
            <<< ButtonRow { row in
                row.title = L10n.Settings.fixCharacterValues
                row.presentationMode = .segueName(segueName: StoryboardSegue.Settings.fixValuesSegue.rawValue, onDismiss: nil)
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = UIColor.black
                    cell.textLabel?.textAlignment = .natural
                    cell.accessoryType = .disclosureIndicator
                })
            }
            <<< ButtonRow(SettingsTags.changeClass) { row in
                row.title = L10n.Settings.changeClass
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = UIColor.black
                }).onCellSelection({[weak self] (_, _) in
                    self?.classSelectionButtonTapped()
                })
            }
            <<< ButtonRow { row in
                row.title = L10n.Settings.logOut
                row.cellSetup({ (cell, _) in
                    cell.tintColor = UIColor.red50()
                }).onCellSelection({ (_, _) in
                    self.userRepository.logoutAccount()
                    let loginViewController = StoryboardScene.Intro.loginTableViewController.instantiate()
                    self.present(loginViewController, animated: true, completion: nil)
                })
        }
    }
    
    private func setupSettingsSections() {
        form +++ Section(L10n.Settings.reminder)
            <<< SwitchRow(SettingsTags.dailyReminder) { row in
                row.title = L10n.Settings.dailyReminder
                }.onChange({ (row) in
                    let defaults = UserDefaults()
                    defaults.set(row.value ?? false, forKey: "dailyReminderActive")
                    if let appDelegate = UIApplication.shared.delegate as? HRPGAppDelegate {
                        appDelegate.swiftAppDelegate.rescheduleDailyReminder()
                    }
                })
            <<< TimeRow(SettingsTags.dailyReminderTime) { row in
                row.title = L10n.Settings.everyDay
                row.hidden = Condition.function([SettingsTags.dailyReminder], { (form) -> Bool in
                    return (form.rowBy(tag: SettingsTags.dailyReminder) as? SwitchRow)?.value == false
                })
                }.onChange({ (row) in
                    let defaults = UserDefaults()
                    defaults.set(row.value, forKey: "dailyReminderTime")
                    if let appDelegate = UIApplication.shared.delegate as? HRPGAppDelegate {
                        appDelegate.swiftAppDelegate.rescheduleDailyReminder()
                    }
                })
            +++ Section(L10n.Settings.notificationBadge)
            <<< SwitchRow(SettingsTags.displayNotificationsBadge) { row in
                row.title = L10n.Settings.displayNotificationBadge
                }.onChange({ (row) in
                    let defaults = UserDefaults()
                    defaults.set(row.value ?? false, forKey: "appBadgeActive")
                })
            +++ Section(L10n.Settings.dayStart)
            <<< TimeRow(SettingsTags.customDayStart) { row in
                row.title = L10n.Settings.customDayStart
                }.onCellHighlightChanged({ (_, row) in
                    if let date = row.value {
                        let calendar = Calendar.current
                        let hour = calendar.component(.hour, from: date)
                        if hour == self.user?.preferences?.dayStart {
                            return
                        }
                        self.userRepository.updateDayStartTime(hour).observeCompleted {}
                    }
                })
            +++ Section(L10n.Settings.social)
            <<< SwitchRow(SettingsTags.disableAllNotifications) { row in
                row.title = L10n.Settings.disableAllNotifications
                row.onChange({ (row) in
                    if row.value == self.user?.preferences?.pushNotifications?.unsubscribeFromAll {
                        return
                    }
                    if let value = row.value {
                        self.userRepository.updateUser(key: "preferences.pushNotifications.unsubscribeFromAll", value: value).observeCompleted {}
                    }
                })
            }
            <<< SwitchRow(SettingsTags.disablePrivateMessages) { row in
                row.title = L10n.Settings.disablePm
                row.onChange({ (row) in
                    if row.value == self.user?.inbox?.optOut {
                        return
                    }
                    if let value = row.value {
                        self.userRepository.updateUser(key: "inbox.optOut", value: value).observeCompleted {}
                    }
                })
        }
        +++ Section(L10n.Settings.preferences)
            <<< PushRow<LabeledFormValue<String>>(SettingsTags.soundTheme) { row in
                row.title = L10n.Settings.soundTheme
                row.options = SoundTheme.allThemes.map({ (theme) -> LabeledFormValue<String> in
                    return LabeledFormValue(value: theme.rawValue, label: theme.niceName)
                })
                row.onChange({ (row) in
                    if let newTheme = SoundTheme(rawValue: row.value?.value ?? "") {
                        SoundManager.shared.currentTheme = newTheme
                    }
                    if let value = row.value?.value {
                        self.userRepository.updateUser(key: "preferences.sound", value: value).observeCompleted {}
                    }
                })
            }
            <<< PushRow<String>(SettingsTags.themeColor) { row in
                row.title = L10n.Settings.themeColor
                row.options = ThemeName.allNames.map({ (name) -> String in
                    return name.rawValue
                })
                let defaults = UserDefaults.standard
                row.value = defaults.string(forKey: "theme") ?? ThemeName.defaultTheme.rawValue
                row.onChange({ (row) in
                    if let newTheme = ThemeName(rawValue: row.value ?? "")?.themeClass {
                        ThemeService.shared.theme = newTheme
                    }
                    let defaults = UserDefaults.standard
                    defaults.set(row.value, forKey: "theme")
                })
        }
    }
    
    private func loadSettingsFromUserDefaults() {
        let defaults = UserDefaults()
        (form.rowBy(tag: SettingsTags.dailyReminder) as? SwitchRow)?.value = defaults.bool(forKey: "dailyReminderActive")
        (form.rowBy(tag: SettingsTags.dailyReminderTime) as? TimeRow)?.value = defaults.value(forKey: "dailyReminderTime") as? Date
        (form.rowBy(tag: SettingsTags.displayNotificationsBadge) as? SwitchRow)?.value = defaults.bool(forKey: "appBadgeActive")
    }
    
    private func setUser(_ user: UserProtocol) {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        components.hour = user.preferences?.dayStart ?? 0
        components.minute = 0
        components.second = 0
        let timeRow = (form.rowBy(tag: SettingsTags.customDayStart) as? TimeRow)
        timeRow?.value = calendar.date(from: components)
        timeRow?.updateCell()
        
        let disableNotificationsRow = (form.rowBy(tag: SettingsTags.disableAllNotifications) as? SwitchRow)
        disableNotificationsRow?.value = user.preferences?.pushNotifications?.unsubscribeFromAll
        disableNotificationsRow?.updateCell()
        let disablePMRow = (form.rowBy(tag: SettingsTags.disablePrivateMessages) as? SwitchRow)
        disablePMRow?.value = user.inbox?.optOut
        disablePMRow?.updateCell()
        
        if let theme = SoundTheme.allThemes.first(where: { (theme) -> Bool in
            return theme == user.preferences?.sound ?? SoundTheme.none.rawValue
        }) {
            (form.rowBy(tag: SettingsTags.soundTheme) as? PushRow<LabeledFormValue<String>>)?.value = LabeledFormValue(value: theme.rawValue, label: theme.niceName)
        }
        
        if let classRow = form.rowBy(tag: SettingsTags.changeClass) as? ButtonRow {
            if (user.stats?.level ?? 0) < 10 {
                classRow.hidden = true
                return
            }
            classRow.hidden = false
            if !user.canChooseClassForFree {
                classRow.title = L10n.Settings.changeClass
            } else if user.needsToChooseClass {
                classRow.title = L10n.Settings.selectClass
            } else {
                classRow.title = L10n.Settings.enableClassSystem
            }
            classRow.updateCell()
        }
    }
    
    private func classSelectionButtonTapped() {
        if user?.canChooseClassForFree == true {
            showClassSelectionViewController()
        } else {
            let alertController = HabiticaAlertController(title: L10n.Settings.areYouSure, message: L10n.Settings.changeClassDisclaimer)
            alertController.addCancelAction()
            alertController.addAction(title: L10n.Settings.changeClass) {[weak self] _ in
                self?.showClassSelectionViewController()
            }
            alertController.show()
        }
    }
    
    private func showClassSelectionViewController() {
        let viewController = StoryboardScene.Settings.classSelectionNavigationController.instantiate()
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }
}
