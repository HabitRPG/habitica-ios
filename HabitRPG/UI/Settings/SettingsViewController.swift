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
import ColorPickerRow

enum SettingsTags {
    static let authentication = "authentication"
    static let dailyReminder = "dailyReminder"
    static let dailyReminderTime = "dailyReminderTime"
    static let displayNotificationsBadge = "displayNotificationsBadge"
    static let customDayStart = "customDayStart"
    static let disableAllNotifications = "disableAllNotifications"
    static let pushNotifications = "pushNotifications"
    static let disableAllEmails = "disableAllEmails"
    static let emailNotifications = "emailNotifications"
    static let disablePrivateMessages = "disablePrivateMessages"
    static let themeColor = "themeColor"
    static let customColor = "customColor"
    static let themeMode = "themeMode"
    static let appIcon = "appIcon"
    static let soundTheme = "soundTheme"
    static let changeClass = "changeClass"
    static let server = "server"
    static let searchableUsername = "searchableUsername"
    static let appLanguage = "appLanguage"
    static let initialAppScreen = "initialAppScreen"
    static let initialTaskBoard = "initialTaskBoard"
}

private let pushNotificationsMapping = [
    L10n.Settings.PushNotifications.giftedGems: "giftedGems",
    L10n.Settings.PushNotifications.giftedSubscription: "giftedSubscription",
    L10n.Settings.PushNotifications.receivedPm: "newPM",
    L10n.Settings.PushNotifications.wonChallenge: "wonChallenge",
    L10n.Settings.PushNotifications.invitedQuest: "invitedQuest",
    L10n.Settings.PushNotifications.invitedParty: "invitedParty",
    L10n.Settings.PushNotifications.invitedGuid: "invitedGuild",
    L10n.Settings.PushNotifications.importantAnnouncement: "majorUpdates",
    L10n.Settings.PushNotifications.questBegun: "questStarted",
    L10n.Settings.PushNotifications.partyActivity: "partyActivity",
    L10n.Settings.PushNotifications.mentionParty: "mentionParty",
    L10n.Settings.PushNotifications.mentionJoinedGuild: "mentionJoinedGuild",
    L10n.Settings.PushNotifications.mentionUnjoinedGuild: "mentionUnjoinedGuild"
]

private let emailNotificationsMapping = [
    L10n.Settings.PushNotifications.giftedGems: "giftedGems",
    L10n.Settings.PushNotifications.giftedSubscription: "giftedSubscription",
    L10n.Settings.PushNotifications.receivedPm: "newPM",
    L10n.Settings.PushNotifications.wonChallenge: "wonChallenge",
    L10n.Settings.PushNotifications.invitedQuest: "invitedQuest",
    L10n.Settings.PushNotifications.invitedParty: "invitedParty",
    L10n.Settings.PushNotifications.invitedGuid: "invitedGuild",
    L10n.Settings.PushNotifications.importantAnnouncement: "majorUpdates",
    L10n.Settings.PushNotifications.questBegun: "questStarted",
    L10n.Settings.EmailNotifications.bannedGroup: "kickedGroup"
]

// swiftlint:disable:next type_body_length
class SettingsViewController: FormViewController, Themeable {
    
    private let userRepository = UserRepository()
    private let contentRepository = ContentRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    private let configRepository = ConfigRepository.shared
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var user: UserProtocol?
    private var isSettingUserData = false
    
    override func viewDidLoad() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.cellLayoutMarginsFollowReadableWidth = false
        super.viewDidLoad()
        navigationItem.title = L10n.Titles.settings
        doneButton.title = L10n.done
        setupForm()
        loadSettingsFromUserDefaults()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
            self?.setUser(user)
        }).start())
        
        ButtonRow.defaultCellUpdate = { cell, _ in
            cell.tintColor = ThemeService.shared.theme.tintColor
        }
        TimeRow.defaultCellUpdate = { cell, _ in
            cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
        }
        
        ThemeService.shared.addThemeable(themable: self, applyImmediately: true)
    }
    
    func applyTheme(theme: Theme) {
        tableView.backgroundColor = theme.windowBackgroundColor
        tableView.reloadData()
    }
    
    private func setupForm() {
        setupUserSection()
        setupSettingsSections()
        form +++ Section(L10n.Settings.maintenance)
            <<< ButtonRow { row in
                row.title = L10n.Settings.clearCache
                row.onCellSelection({[weak self] (_, _) in
                    let progressView = MRProgressOverlayView.showOverlayAdded(to: self?.view, animated: true)
                    progressView?.setTintColor(ThemeService.shared.theme.tintColor)
                    self?.contentRepository.clearDatabase()
                    self?.contentRepository.retrieveContent(force: true).withLatest(from: self?.userRepository.retrieveUser() ?? Signal.empty)
                        .observeCompleted {
                            progressView?.dismiss(true)
                    }
                })
            }
            <<< ButtonRow { row in
                row.title = L10n.Settings.reloadContent
                }.onCellSelection({[weak self] (_, _) in
                    let progressView = MRProgressOverlayView.showOverlayAdded(to: self?.view, animated: true)
                    progressView?.tintColor = ThemeService.shared.theme.tintColor
                    self?.contentRepository.retrieveContent(force: true).observeCompleted {
                        progressView?.dismiss(true)
                    }
                })
            <<< AlertRow<LabeledFormValue<String>>(SettingsTags.server) { row in
                row.title = L10n.Settings.server
                #if !targetEnvironment(simulator)
                row.hidden = true
                #endif
                row.options = Servers.allServers.map({ (server) -> LabeledFormValue<String> in
                    return LabeledFormValue(value: server.rawValue, label: server.niceName)
                })
                if let server = Servers(rawValue: UserDefaults().string(forKey: "chosenServer") ?? "") {
                    row.value = LabeledFormValue(value: server.rawValue, label: server.niceName)
                }
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.textLabel?.textAlignment = .natural
                })
                row.onChange({ (row) in
                    UserDefaults().set(row.value?.value, forKey: "chosenServer")
                    let appDelegate = UIApplication.shared.delegate as? HabiticaAppDelegate
                    appDelegate?.updateServer()
                })
        }
    }
    
    private func setupUserSection() {
        form +++ Section(L10n.Settings.user)
            <<< ButtonRow { row in
                row.title = L10n.Settings.profile
                row.presentationMode = .segueName(segueName: StoryboardSegue.Settings.profileSegue.rawValue, onDismiss: nil)
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.textLabel?.textAlignment = .natural
                    cell.accessoryType = .disclosureIndicator
                })
            }
            <<< ButtonRow(SettingsTags.authentication) { row in
                row.title = L10n.Settings.authentication
                row.presentationMode = .segueName(segueName: StoryboardSegue.Settings.authenticationSegue.rawValue, onDismiss: nil)
                row.cellStyle = UITableViewCell.CellStyle.subtitle
                row.cellUpdate({[weak self] (cell, _) in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.textLabel?.textAlignment = .natural
                    cell.accessoryType = .disclosureIndicator
                    if self?.user?.isValid == true && self?.user?.flags?.verifiedUsername == false {
                        cell.detailTextLabel?.text = L10n.Settings.usernameNotConfirmed
                        cell.detailTextLabel?.textColor = UIColor.red50
                    } else {
                        cell.detailTextLabel?.text = nil
                    }
                })
            }
            <<< ButtonRow { row in
                row.title = L10n.Settings.api
                row.presentationMode = .segueName(segueName: StoryboardSegue.Settings.apiSegue.rawValue, onDismiss: nil)
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.textLabel?.textAlignment = .natural
                    cell.accessoryType = .disclosureIndicator
                })
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
            <<< ButtonRow(SettingsTags.changeClass) { row in
                row.title = L10n.Settings.changeClass
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                }).onCellSelection({[weak self] (_, _) in
                    self?.classSelectionButtonTapped()
                })
            }
            <<< ButtonRow { row in
                row.title = L10n.Settings.logOut
                row.cellSetup({ (cell, _) in
                    cell.tintColor = UIColor.red50
                }).onCellSelection({ (_, _) in
                    self.userRepository.logoutAccount()
                    self.contentRepository.retrieveContent(force: true).observeCompleted {}
                    self.navigationController?.dismiss(animated: true, completion: nil)
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                })
        }
    }
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func setupSettingsSections() {
        form +++ Section(L10n.Settings.reminder)
            <<< SwitchRow(SettingsTags.dailyReminder) { row in
                row.title = L10n.Settings.dailyReminder
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                }.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true {
                        return
                    }
                    let defaults = UserDefaults()
                    defaults.set(row.value ?? false, forKey: "dailyReminderActive")
                    if let appDelegate = UIApplication.shared.delegate as? HabiticaAppDelegate {
                        appDelegate.rescheduleDailyReminder()
                    }
                })
            <<< TimeRow(SettingsTags.dailyReminderTime) { row in
                row.title = L10n.Settings.everyDay
                row.hidden = Condition.function([SettingsTags.dailyReminder], { (form) -> Bool in
                    return (form.rowBy(tag: SettingsTags.dailyReminder) as? SwitchRow)?.value == false
                })
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                }.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true {
                        return
                    }
                    let defaults = UserDefaults()
                    defaults.set(row.value, forKey: "dailyReminderTime")
                    if let appDelegate = UIApplication.shared.delegate as? HabiticaAppDelegate {
                        appDelegate.rescheduleDailyReminder()
                    }
                })
            +++ Section(L10n.Settings.notificationBadge)
            <<< SwitchRow(SettingsTags.displayNotificationsBadge) { row in
                row.title = L10n.Settings.displayNotificationBadge
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                }.onChange({[weak self] (row) in
                if self?.isSettingUserData == true {
                    return
                }
                    let defaults = UserDefaults()
                    defaults.set(row.value ?? false, forKey: "appBadgeActive")
                })
            +++ Section(L10n.Settings.dayStart)
            <<< TimeRow(SettingsTags.customDayStart) { row in
                row.title = L10n.Settings.customDayStart
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                }.onCellHighlightChanged({[weak self] (_, row) in
                if self?.isSettingUserData == true {
                    return
                }
                    if let date = row.value {
                        let calendar = Calendar.current
                        let hour = calendar.component(.hour, from: date)
                        if hour == self?.user?.preferences?.dayStart {
                            return
                        }
                        self?.userRepository.updateDayStartTime(hour).observeCompleted {}
                    }
                })
            +++ Section(L10n.Settings.mentions) { section in
                section.hidden = true
            }
            <<< AlertRow<LabeledFormValue<Bool>>(SettingsTags.searchableUsername) { row in
                row.title = L10n.Settings.searchableUsername
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                row.options = [LabeledFormValue(value: true, label: L10n.Settings.searchableEverywhere),
                               LabeledFormValue(value: false, label: L10n.Settings.searchablePrivateSpaces)
                ]
                row.selectorTitle = row.title
                row.onChange({[weak self] (row) in
                    if row.value?.value == self?.user?.preferences?.searchableUsername {
                        return
                    }
                    if let value = row.value {
                        self?.userRepository.updateUser(key: "preferences.searchableUsername", value: value.value).observeCompleted {}
                    }
                })
            }
            +++ Section(L10n.Settings.social)
            <<< SwitchRow(SettingsTags.disableAllNotifications) { row in
                row.title = L10n.Settings.disableAllNotifications
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                row.onChange({[weak self] (row) in
                if self?.isSettingUserData == true {
                    return
                }
                    if row.value == self?.user?.preferences?.pushNotifications?.unsubscribeFromAll {
                        return
                    }
                    if let value = row.value {
                        self?.userRepository.updateUser(key: "preferences.pushNotifications.unsubscribeFromAll", value: value).observeCompleted {}
                    }
                })
            }
            <<< MultipleSelectorRow<String>(SettingsTags.pushNotifications) { row in
                row.title = L10n.Settings.PushNotifications.title
                row.options = [L10n.Settings.PushNotifications.receivedPm,
                L10n.Settings.PushNotifications.wonChallenge,
                L10n.Settings.PushNotifications.giftedGems,
                L10n.Settings.PushNotifications.giftedSubscription,
                L10n.Settings.PushNotifications.invitedParty,
                L10n.Settings.PushNotifications.invitedGuid,
                L10n.Settings.PushNotifications.invitedQuest,
                L10n.Settings.PushNotifications.questBegun,
                L10n.Settings.PushNotifications.importantAnnouncement,
                L10n.Settings.PushNotifications.partyActivity,
                L10n.Settings.PushNotifications.mentionParty,
                L10n.Settings.PushNotifications.mentionJoinedGuild,
                L10n.Settings.PushNotifications.mentionUnjoinedGuild
                ]
                row.disabled = Condition.function([SettingsTags.disableAllNotifications], { (form) -> Bool in
                    return (form.rowBy(tag: SettingsTags.disableAllNotifications) as? SwitchRow)?.value == true
                })
                row.cellUpdate { (cell, _) in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                row.onPresent({ (_, to) in
                    to.selectableRowCellUpdate = { cell, _ in
                        cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    }
                })
                row.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true { return }
                    var updateDict = [String: Encodable]()
                    for (key, value) in pushNotificationsMapping {
                        updateDict["preferences.pushNotifications.\(value)"] = row.value?.contains(key)
                    }
                    self?.userRepository.updateUser(updateDict).observeCompleted {}
                })
            }
            <<< SwitchRow(SettingsTags.disableAllEmails) { row in
                row.title = L10n.Settings.disableAllEmails
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                row.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true {
                        return
                    }
                    if row.value == self?.user?.preferences?.emailNotifications?.unsubscribeFromAll {
                        return
                    }
                    if let value = row.value {
                        self?.userRepository.updateUser(key: "preferences.emailNotifications.unsubscribeFromAll", value: value).observeCompleted {}
                    }
                })
            }
            <<< MultipleSelectorRow<String>(SettingsTags.emailNotifications) { row in
                row.title = L10n.Settings.EmailNotifications.title
                row.options = [L10n.Settings.PushNotifications.receivedPm,
                L10n.Settings.PushNotifications.wonChallenge,
                L10n.Settings.PushNotifications.giftedGems,
                L10n.Settings.PushNotifications.giftedSubscription,
                L10n.Settings.PushNotifications.invitedParty,
                L10n.Settings.PushNotifications.invitedGuid,
                L10n.Settings.PushNotifications.invitedQuest,
                L10n.Settings.PushNotifications.questBegun,
                L10n.Settings.PushNotifications.importantAnnouncement,
                L10n.Settings.EmailNotifications.bannedGroup]
                row.disabled = Condition.function([SettingsTags.disableAllEmails], { (form) -> Bool in
                    return (form.rowBy(tag: SettingsTags.disableAllEmails) as? SwitchRow)?.value == true
                })
                row.cellUpdate { (cell, _) in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                row.onPresent({ (_, to) in
                    to.selectableRowCellUpdate = { cell, _ in
                        cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    }
                })
                row.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true { return }
                    var updateDict = [String: Encodable]()
                    for (key, value) in emailNotificationsMapping {
                        updateDict["preferences.emailNotifications.\(value)"] = row.value?.contains(key)
                    }
                    self?.userRepository.updateUser(updateDict).observeCompleted {}
                })
            }
            <<< SwitchRow(SettingsTags.disablePrivateMessages) { row in
                row.title = L10n.Settings.disablePm
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                row.onChange({[weak self] (row) in
                    if row.value == self?.user?.inbox?.optOut {
                        return
                    }
                    if let value = row.value {
                        if self?.isSettingUserData == true {
                            return
                        }
                        self?.userRepository.updateUser(key: "inbox.optOut", value: value).observeCompleted {}
                    }
                })
        }
        let section = Section(L10n.Settings.preferences)
            <<< PushRow<LabeledFormValue<Int>>(SettingsTags.appLanguage) { row in
                row.title = L10n.Settings.language
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                row.options = AppLanguage.allLanguages().map({ language -> LabeledFormValue<Int> in
                    return LabeledFormValue(value: language.rawValue, label: language.name)
                })
                let language = LanguageHandler.getAppLanguage()
                row.value = LabeledFormValue(value: language.rawValue, label: language.name)
                row.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true {
                        return
                    }
                    if let value = row.value?.value, let newLanguage = AppLanguage(rawValue: value) {
                        self?.update(language: newLanguage)
                    }
                })
                row.onPresent({ (_, to) in
                    to.selectableRowCellUpdate = { cell, _ in
                        cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    }
                })
            }
            <<< PushRow<LabeledFormValue<String>>(SettingsTags.initialAppScreen) { row in
                row.title = L10n.Settings.launchScreen
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                row.options = InitialScreens.allScreens.map({ screen -> LabeledFormValue<String> in
                    return LabeledFormValue(value: screen.rawValue, label: screen.niceName)
                })
                
                let screen = InitialScreens(rawValue: UserDefaults().string(forKey: "initialScreenURL") ?? "") ?? InitialScreens.habits
                row.value = LabeledFormValue(value: screen.rawValue, label: screen.niceName)
                row.onChange({ (row) in
                    UserDefaults().set(row.value?.value, forKey: "initialScreenURL")
                })
                row.onPresent({ (_, to) in
                    to.selectableRowCellUpdate = { cell, _ in
                        cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    }
                })
            }
            <<< PushRow<LabeledFormValue<String>>(SettingsTags.soundTheme) { row in
                row.title = L10n.Settings.soundTheme
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                row.options = SoundTheme.allThemes.map({ (theme) -> LabeledFormValue<String> in
                    return LabeledFormValue(value: theme.rawValue, label: theme.niceName)
                })
                row.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true {
                        return
                    }
                    if let newTheme = SoundTheme(rawValue: row.value?.value ?? "") {
                        SoundManager.shared.currentTheme = newTheme
                    }
                    if let value = row.value?.value {
                        self?.userRepository.updateUser(key: "preferences.sound", value: value).observeCompleted {}
                    }
                })
                row.onPresent({ (_, to) in
                    to.selectableRowCellUpdate = { cell, _ in
                        cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    }
                })
            }
            <<< PushRow<LabeledFormValue<String>>(SettingsTags.themeColor) { row in
                row.title = L10n.Settings.themeColor
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                row.options = ThemeName.allNames.map({ (theme) -> LabeledFormValue<String> in
                    return LabeledFormValue(value: theme.rawValue, label: theme.niceName)
                })
                let defaults = UserDefaults.standard
                if let theme = ThemeName.allNames.first(where: { (theme) -> Bool in
                    return theme.rawValue == defaults.string(forKey: "theme") ?? ThemeName.defaultTheme.rawValue
                }) {
                    row.value = LabeledFormValue(value: theme.rawValue, label: theme.niceName)
                }
                row.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true {
                        return
                    }
                    if let newTheme = ThemeName(rawValue: row.value?.value ?? "") {
                        ThemeService.shared.theme = newTheme.themeClass
                        let defaults = UserDefaults.standard
                        defaults.set(newTheme.rawValue, forKey: "theme")
                    }
                })
                row.onPresent({ (_, to) in
                    to.selectableRowCellUpdate = { cell, _ in
                        cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    }
                })
            }
            <<< InlineColorPickerRow(SettingsTags.customColor) { row in
                row.title = "Custom Theme Color"
                let defaults = UserDefaults.standard
                row.value = UIColor(defaults.string(forKey: "customColor") ?? UIColor.purple200.hexString())
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                }
                row.hidden = Condition.function([SettingsTags.themeColor], { (form) -> Bool in
                    return (form.rowBy(tag: SettingsTags.themeColor) as? PushRow<LabeledFormValue<String>>)?.value?.value != "custom"
                })
                row.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true {
                        return
                    }
                    guard let color = row.value else {
                        return
                    }
                    let defaults = UserDefaults.standard
                    if let newTheme = ThemeName(rawValue: defaults.string(forKey: "theme") ?? "") {
                        defaults.set(color.hexString(), forKey: "customColor")
                        ThemeService.shared.theme = newTheme.themeClass
                    }
                })
            }
        <<< PushRow<LabeledFormValue<String>>(SettingsTags.themeMode) { row in
            row.title = L10n.Settings.themeMode
            row.cellUpdate { cell, _ in
                cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                cell.tintColor = ThemeService.shared.theme.tintColor
            }
            row.options = ThemeMode.allModes.map({ (theme) -> LabeledFormValue<String> in
                return LabeledFormValue(value: theme.rawValue, label: theme.niceName)
            })
            let defaults = UserDefaults.standard
            if let theme = ThemeMode.allModes.first(where: { (theme) -> Bool in
                return theme.rawValue == defaults.string(forKey: "themeMode") ?? ThemeMode.allModes.first?.rawValue
            }) {
                row.value = LabeledFormValue(value: theme.rawValue, label: theme.niceName)
            }
            row.onChange({[weak self] (row) in
                if self?.isSettingUserData == true {
                    return
                }
                if let newTheme = ThemeMode(rawValue: row.value?.value ?? "") {
                    let defaults = UserDefaults.standard
                    defaults.set(newTheme.rawValue, forKey: "themeMode")
                    ThemeService.shared.updateDarkMode()
                }
            })
            row.onPresent({ (_, to) in
                to.selectableRowCellUpdate = { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                }
            })
        }
        form +++ section
        section <<< PushRow<String>(SettingsTags.appIcon) { row in
            row.title = L10n.Settings.appIcon
            row.cellUpdate { cell, _ in
                cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                cell.tintColor = ThemeService.shared.theme.tintColor
            }
            row.options = AppIconName.allNames.map({ (name) -> String in
                return name.rawValue
            })
            row.value = UIApplication.shared.alternateIconName ?? AppIconName.defaultTheme.rawValue
            row.onPresent({ (_, to) in
                to.selectableRowCellUpdate = { cell, row in
                    let filename = AppIconName(rawValue: row.title ?? "")?.fileName ?? "Purple"
                    cell.height = { 68 }
                    cell.imageView?.cornerRadius = 12
                    cell.imageView?.contentMode = .center
                    cell.imageView?.image = UIImage(named: filename)
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.contentView.layoutMargins = UIEdgeInsets(top: 4, left: cell.layoutMargins.left, bottom: 4, right: cell.layoutMargins.right)
                }
            })
            row.onChange({[weak self] (row) in
                if self?.isSettingUserData == true {
                    return
                }
                if let newAppIcon = AppIconName(rawValue: row.value ?? "") {
                    DispatchQueue.main.async {
                        UIApplication.shared.setAlternateIconName(newAppIcon.fileName) { (error) in
                            if let error = error {
                                logger.log("error: \(error)", level: .error)
                            }
                        }
                    }
                }
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
        isSettingUserData = true
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        components.hour = user.preferences?.dayStart ?? 0
        components.minute = 0
        components.second = 0
        let timeRow = (form.rowBy(tag: SettingsTags.customDayStart) as? TimeRow)
        timeRow?.value = calendar.date(from: components)
        timeRow?.updateCell()
        
        let searchableUsernameRow = (form.rowBy(tag: SettingsTags.searchableUsername) as? AlertRow<LabeledFormValue<Bool>>)
        searchableUsernameRow?.value = user.preferences?.searchableUsername == true ? LabeledFormValue(value: true, label: L10n.Settings.searchableEverywhere) : LabeledFormValue(value: false, label: L10n.Settings.searchablePrivateSpaces)
        searchableUsernameRow?.updateCell()
        
        let disableNotificationsRow = (form.rowBy(tag: SettingsTags.disableAllNotifications) as? SwitchRow)
        disableNotificationsRow?.value = user.preferences?.pushNotifications?.unsubscribeFromAll
        disableNotificationsRow?.updateCell()
        
        let pushNotificationsRow = (form.rowBy(tag: SettingsTags.pushNotifications) as? MultipleSelectorRow<String>)
        pushNotificationsRow?.value = getPushNotificationSet(forUser: user)
        
        let disableEmailsRow = (form.rowBy(tag: SettingsTags.disableAllEmails) as? SwitchRow)
        disableEmailsRow?.value = user.preferences?.pushNotifications?.unsubscribeFromAll
        disableEmailsRow?.updateCell()
        
        let emailNotificationsRow = (form.rowBy(tag: SettingsTags.emailNotifications) as? MultipleSelectorRow<String>)
        emailNotificationsRow?.value = getEmailNotificationSet(forUser: user)
        
        let disablePMRow = (form.rowBy(tag: SettingsTags.disablePrivateMessages) as? SwitchRow)
        disablePMRow?.value = user.inbox?.optOut
        disablePMRow?.updateCell()
        
        if let theme = SoundTheme.allThemes.first(where: { (theme) -> Bool in
            return theme == user.preferences?.sound ?? SoundTheme.none.rawValue
        }) {
            (form.rowBy(tag: SettingsTags.soundTheme) as? PushRow<LabeledFormValue<String>>)?.value = LabeledFormValue(value: theme.rawValue, label: theme.niceName)
        }
        
        let authenticationRow = form.rowBy(tag: SettingsTags.authentication)
        tableView.beginUpdates()
        authenticationRow?.updateCell()
        tableView.endUpdates()
        
        if let classRow = form.rowBy(tag: SettingsTags.changeClass) as? ButtonRow {
            if (user.stats?.level ?? 0) < 10 {
                classRow.hidden = true
            } else {
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
            classRow.evaluateHidden()
        }
        
        #if !targetEnvironment(simulator)
        if user.contributor?.admin == true {
            let serverRow = (form.rowBy(tag: SettingsTags.server) as? AlertRow<LabeledFormValue<String>>)
            serverRow?.hidden = false
            let themeRow = (form.rowBy(tag: SettingsTags.themeColor) as? PushRow<LabeledFormValue<String>>)
            let customTheme = ThemeName.custom
            themeRow?.options?.append(LabeledFormValue(value: customTheme.rawValue, label: customTheme.niceName))
            themeRow?.updateCell()
            serverRow?.evaluateHidden()
        }
        #endif
        isSettingUserData = false
    }
    
    private func getPushNotificationSet(forUser user: UserProtocol) -> Set<String> {
        var pushNotifications = Set<String>()
        guard let notificationPreferences = user.preferences?.pushNotifications else {
            return pushNotifications
        }
        if notificationPreferences.giftedGems {
            pushNotifications.insert(L10n.Settings.PushNotifications.giftedGems)
        }
        if notificationPreferences.giftedSubscription {
            pushNotifications.insert(L10n.Settings.PushNotifications.giftedSubscription)
        }
        if notificationPreferences.hasNewPM {
            pushNotifications.insert(L10n.Settings.PushNotifications.receivedPm)
        }
        if notificationPreferences.invitedGuild {
            pushNotifications.insert(L10n.Settings.PushNotifications.invitedGuid)
        }
        if notificationPreferences.invitedParty {
            pushNotifications.insert(L10n.Settings.PushNotifications.invitedParty)
        }
        if notificationPreferences.invitedQuest {
            pushNotifications.insert(L10n.Settings.PushNotifications.invitedQuest)
        }
        if notificationPreferences.questStarted {
            pushNotifications.insert(L10n.Settings.PushNotifications.questBegun)
        }
        if notificationPreferences.majorUpdates {
            pushNotifications.insert(L10n.Settings.PushNotifications.importantAnnouncement)
        }
        if notificationPreferences.wonChallenge {
            pushNotifications.insert(L10n.Settings.PushNotifications.wonChallenge)
        }
        if notificationPreferences.partyActivity {
            pushNotifications.insert(L10n.Settings.PushNotifications.partyActivity)
        }
        if notificationPreferences.mentionParty {
            pushNotifications.insert(L10n.Settings.PushNotifications.mentionParty)
        }
        if notificationPreferences.mentionJoinedGuild {
            pushNotifications.insert(L10n.Settings.PushNotifications.mentionJoinedGuild)
        }
        if notificationPreferences.mentionUnjoinedGuild {
            pushNotifications.insert(L10n.Settings.PushNotifications.mentionUnjoinedGuild)
        }
        return pushNotifications
    }
    
    private func getEmailNotificationSet(forUser user: UserProtocol) -> Set<String> {
        var pushNotifications = Set<String>()
        guard let notificationPreferences = user.preferences?.emailNotifications else {
            return pushNotifications
        }
        if notificationPreferences.giftedGems {
            pushNotifications.insert(L10n.Settings.PushNotifications.giftedGems)
        }
        if notificationPreferences.giftedSubscription {
            pushNotifications.insert(L10n.Settings.PushNotifications.giftedSubscription)
        }
        if notificationPreferences.hasNewPM {
            pushNotifications.insert(L10n.Settings.PushNotifications.receivedPm)
        }
        if notificationPreferences.invitedGuild {
            pushNotifications.insert(L10n.Settings.PushNotifications.invitedGuid)
        }
        if notificationPreferences.invitedParty {
            pushNotifications.insert(L10n.Settings.PushNotifications.invitedParty)
        }
        if notificationPreferences.invitedQuest {
            pushNotifications.insert(L10n.Settings.PushNotifications.invitedQuest)
        }
        if notificationPreferences.questStarted {
            pushNotifications.insert(L10n.Settings.PushNotifications.questBegun)
        }
        if notificationPreferences.majorUpdates {
            pushNotifications.insert(L10n.Settings.PushNotifications.importantAnnouncement)
        }
        if notificationPreferences.wonChallenge {
            pushNotifications.insert(L10n.Settings.PushNotifications.wonChallenge)
        }
        if notificationPreferences.kickedGroup {
            pushNotifications.insert(L10n.Settings.EmailNotifications.bannedGroup)
        }
        return pushNotifications
    }
    
    private func classSelectionButtonTapped() {
        guard let user = self.user else {
            assertionFailure("Attempting to change class but there is no user!"); return
        }
        if user.canChooseClassForFree == true {
            if user.needsToChooseClass {
                showClassSelectionViewController()
            } else {
                enableClassSystemAndShowClassSelection()
            }
        } else {
            let alertController = HabiticaAlertController(title: L10n.Settings.areYouSure, message: L10n.Settings.changeClassDisclaimer)
            alertController.addAction(title: L10n.Settings.changeClass) {[weak self] _ in
                self?.showClassSelectionViewController()
            }
            alertController.addCancelAction()
            alertController.show()
        }
    }
    
    private func enableClassSystemAndShowClassSelection() {
        disposable.inner.add(userRepository.selectClass(nil)
                .observe(on: UIScheduler())
                .observeCompleted { [weak self] in
                    self?.showClassSelectionViewController()
            }
        )
    }
    
    private func showClassSelectionViewController() {
        let viewController = StoryboardScene.Settings.classSelectionNavigationController.instantiate()
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }
    
    private func update(language: AppLanguage) {
        let progressView = MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        progressView?.tintColor = ThemeService.shared.theme.tintColor

        let defaults = UserDefaults.standard
        defaults.set(language.rawValue, forKey: "ChosenLanguage")
        LanguageHandler.setAppLanguage(language)
        self.userRepository.updateUser(key: "preferences.language", value: language.code)
            .flatMap(.latest, {[weak self] _ in
                return self?.contentRepository.retrieveContent(force: true) ?? Signal.empty
            })
            .observeCompleted {[weak self] in
                progressView?.dismiss(true)
                self?.relaunchMainApp()
        }
    }
    
    private func relaunchMainApp() {
        dismiss(animated: true, completion: {
            UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
        })
    }
}
