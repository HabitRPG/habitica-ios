//
//  SettingsViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 03.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Eureka
import ReactiveSwift
import Habitica_Models

enum SettingsTags {
    static let myAccount = "myAccount"
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
    static let manuallyRestartDay = "manuallyRestartDay"
}

// swiftlint:disable:next type_body_length
class SettingsViewController: FormViewController, Themeable {
    
    private let userRepository = UserRepository()
    private let taskRepository = TaskRepository()
    private let contentRepository = ContentRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    private let configRepository = ConfigRepository.shared
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var user: UserProtocol?
    private var isSettingUserData = false
    
    private let groupPlanSection = Section(L10n.Groups.groupPlanSettings) { section in
        section.hidden = true
        section.footer = HeaderFooterView(title: L10n.Groups.copySharedTasksDescription)
    }
    
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
        
        disposable.inner.add(userRepository.retrieveGroupPlans().observeCompleted {})
        disposable.inner.add(userRepository.getGroupPlans().on(value: {[weak self] plans in
            if plans.value.isEmpty {
                self?.groupPlanSection.hidden = Condition(booleanLiteral: true)
            } else {
                self?.groupPlanSection.hidden = Condition(booleanLiteral: false)
                self?.groupPlanSection.removeAll()
                if let section = self?.groupPlanSection {
                    for plan in plans.value {
                        section <<< SwitchRow { row in
                            row.title = L10n.Groups.copySharedTasks
                            row.cellStyle = UITableViewCell.CellStyle.subtitle
                            row.value = self?.user?.preferences?.tasks?.mirrorGroupTasks?.contains(plan.id ?? "") == true
                            row.updateCell()
                        }.cellUpdate({ cell, row in
                            cell.detailTextLabel?.text = plan.name
                        }).onChange({ row in
                            guard let id = plan.id else {
                                return
                            }
                            var currentSetting = self?.user?.preferences?.tasks?.mirrorGroupTasks ?? []
                            if row.value == true && !currentSetting.contains(id) {
                                currentSetting.append(id)
                                self?.userRepository.updateUser(key: "preferences.tasks.mirrorGroupTasks", value: currentSetting)
                                    .flatMap(.latest, { _ in
                                        self?.taskRepository.retrieveTasks() ?? Signal.empty
                                    })
                                    .observeCompleted {}
                            } else if row.value == false, let index = currentSetting.firstIndex(of: id) {
                                currentSetting.remove(at: index)
                                self?.userRepository.updateUser(key: "preferences.tasks.mirrorGroupTasks", value: currentSetting)
                                    .flatMap(.latest, { _ in
                                        self?.taskRepository.retrieveTasks() ?? Signal.empty
                                    })
                                    .observeCompleted {}
                            }
                        })
                    }
                }
            }
            self?.groupPlanSection.evaluateHidden()
        }).start())
        
        LabelRow.defaultCellUpdate = { cell, _ in
            cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
            cell.detailTextLabel?.textColor = ThemeService.shared.theme.ternaryTextColor
            cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        }
        ButtonRow.defaultCellUpdate = { cell, _ in
            cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
            cell.tintColor = ThemeService.shared.theme.tintColor
            cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        }
        TimeRow.defaultCellUpdate = { cell, _ in
            cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
            cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
            cell.tintColor = ThemeService.shared.theme.tintColor
            cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        }
        TimePickerRow.defaultCellUpdate = { cell, _ in
            cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
            cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
            cell.tintColor = ThemeService.shared.theme.tintColor
            cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        }
        SwitchRow.defaultCellUpdate = { cell, _ in
            cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
            cell.tintColor = ThemeService.shared.theme.tintColor
            cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        }
        
        ThemeService.shared.addThemeable(themable: self, applyImmediately: true)
    }
    
    func applyTheme(theme: Theme) {
        overrideUserInterfaceStyle = theme.isDark ? .dark : .light
        tableView.backgroundColor = theme.contentBackgroundColor
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = ThemeService.shared.theme.quadTextColor
    }
    
    private func setupForm() {
        setupUserSection()
        setupSettingsSections()
        form +++ Section(L10n.Settings.maintenance)
            <<< ButtonRow { row in
                row.title = L10n.Settings.clearCache
                row.onCellSelection({[weak self] (_, _) in
                    self?.contentRepository.clearDatabase()
                    self?.contentRepository.retrieveContent(force: true).withLatest(from: self?.userRepository.retrieveUser() ?? Signal.empty)
                        .observeCompleted {
                    }
                })
            }
            <<< ButtonRow { row in
                row.title = L10n.Settings.reloadContent
                }.onCellSelection({[weak self] (_, _) in
                    self?.contentRepository.retrieveContent(force: true)
                        .flatMap(.latest, { _ in
                            return self?.contentRepository.retrieveWorldState() ?? Signal.empty
                        })
                        .observeCompleted {
                    }
                })
        <<< ButtonRow(SettingsTags.manuallyRestartDay) { row in
            row.title = L10n.Settings.manuallyRestartDay
            }.onCellSelection({[weak self] (_, _) in
                self?.userRepository.runCron(checklistItems: [], tasks: [])
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
                    cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
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
            <<< ButtonRow(SettingsTags.myAccount) { row in
                row.title = L10n.Settings.myAccount
                row.presentationMode = .segueName(segueName: StoryboardSegue.Settings.accountSegue.rawValue, onDismiss: nil)
                row.cellStyle = UITableViewCell.CellStyle.subtitle
                row.cellUpdate({[weak self] (cell, _) in
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
            <<< ButtonRow(SettingsTags.changeClass) { row in
                row.title = L10n.Settings.changeClass
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textAlignment = .justified
                    cell.accessoryType = .disclosureIndicator
                }).onCellSelection({[weak self] (_, _) in
                    self?.classSelectionButtonTapped()
                })
            }
            <<< ButtonRow { row in
                row.title = L10n.Settings.logOut
                row.cellUpdate({ (cell, _) in
                    cell.textLabel?.textColor = UIColor.red50
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
            <<< TimePickerRow(SettingsTags.dailyReminderTime) { row in
                row.title = L10n.Settings.everyDay
                row.cellUpdate { cell, _ in
                    cell.textLabel?.text = L10n.Settings.everyDay
                }
                row.hidden = Condition.function([SettingsTags.dailyReminder], { (form) -> Bool in
                    return (form.rowBy(tag: SettingsTags.dailyReminder) as? SwitchRow)?.value == false
                })
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
                }.onChange({[weak self] (row) in
                if self?.isSettingUserData == true {
                    return
                }
                    let defaults = UserDefaults()
                    defaults.set(row.value ?? false, forKey: "appBadgeActive")
                })
        +++ Section(L10n.Settings.dayStartAdjustment) { section in
            section.footer = HeaderFooterView(title: L10n.Settings.customDayStartDescription)
        }
            <<< PushRow<LabeledFormValue<Int>>(SettingsTags.customDayStart) { row in
                row.title = L10n.Settings.adjustment
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                    cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
                }
                row.options = (0..<13).map(makeCDSValue)
                row.value = makeCDSValue(user?.preferences?.dayStart ?? 0)
                row.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true {
                        return
                    }
                    if row.value?.value == self?.user?.preferences?.dayStart {
                        return
                    }
                    
                    self?.userRepository.updateDayStartTime(row.value?.value ?? 0).observeCompleted {
                        let nextCron = self?.calculateNextCron(dayStart: self?.user?.preferences?.dayStart)
                        let dateFormatter = DateFormatter()
                        let format = "\(self?.user?.preferences?.dateFormat ?? "MM/dd/yyyy") @hh:mm a"
                        dateFormatter.dateFormat = format
                        ToastManager.show(text: L10n.Settings.nextCronRun(dateFormatter.string(from: nextCron ?? Date())), color: .green, duration: 4.0)
                    }
                })
                row.onPresent({ (_, to) in
                    to.enableDeselection = false
                    to.selectableRowCellUpdate = { cell, _ in
                        cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    }
                })
            }
            +++ Section(L10n.Settings.mentions) { section in
                section.hidden = true
            }
            <<< AlertRow<LabeledFormValue<Bool>>(SettingsTags.searchableUsername) { row in
                row.title = L10n.Settings.searchableUsername
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                    cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
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
            <<< MultipleSelectorRow<LabeledFormValue<String>>(SettingsTags.pushNotifications) { row in
                row.title = L10n.Settings.PushNotifications.title
                row.options = [LabeledFormValue(value: "newPM", label: L10n.Settings.PushNotifications.receivedPm),
                               LabeledFormValue(value: "wonChallenge", label: L10n.Settings.PushNotifications.wonChallenge),
                               LabeledFormValue(value: "giftedGems", label: L10n.Settings.PushNotifications.giftedGems),
                               LabeledFormValue(value: "giftedSubscription", label: L10n.Settings.PushNotifications.giftedSubscription),
                               LabeledFormValue(value: "invitedParty", label: L10n.Settings.PushNotifications.invitedParty),
                               LabeledFormValue(value: "invitedGuild", label: L10n.Settings.PushNotifications.invitedGuid),
                               LabeledFormValue(value: "invitedQuest", label: L10n.Settings.PushNotifications.invitedQuest),
                               LabeledFormValue(value: "questStarted", label: L10n.Settings.PushNotifications.questBegun),
                               LabeledFormValue(value: "majorUpdates", label: L10n.Settings.PushNotifications.importantAnnouncement),
                               LabeledFormValue(value: "partyActivity", label: L10n.Settings.PushNotifications.partyActivity),
                               LabeledFormValue(value: "mentionParty", label: L10n.Settings.PushNotifications.mentionParty),
                               LabeledFormValue(value: "mentionJoinedGuild", label: L10n.Settings.PushNotifications.mentionJoinedGuild),
                               LabeledFormValue(value: "mentionUnjoinedGuild", label: L10n.Settings.PushNotifications.mentionUnjoinedGuild)
                ]
                row.disabled = Condition.function([SettingsTags.disableAllNotifications], { (form) -> Bool in
                    return (form.rowBy(tag: SettingsTags.disableAllNotifications) as? SwitchRow)?.value == true
                })
                row.cellUpdate { (cell, _) in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                    cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
                }
                row.onPresent({ (_, to) in
                    to.selectableRowCellUpdate = { cell, _ in
                        cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    }
                })
                row.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true {
                        return
                    }
                    var updateDict = [String: Encodable]()
                    for option in row.options ?? [] {
                        updateDict["preferences.pushNotifications.\(option.value)"] = row.value?.contains(where: { selectedValue in
                            selectedValue.value == option.value
                        })
                    }
                    self?.userRepository.updateUser(updateDict).observeCompleted {}
                })
            }
            <<< SwitchRow(SettingsTags.disableAllEmails) { row in
                row.title = L10n.Settings.disableAllEmails
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
            <<< MultipleSelectorRow<LabeledFormValue<String>>(SettingsTags.emailNotifications) { row in
                row.title = L10n.Settings.EmailNotifications.title
                row.options = [LabeledFormValue(value: "newPM", label: L10n.Settings.PushNotifications.receivedPm),
                               LabeledFormValue(value: "wonChallenge", label: L10n.Settings.PushNotifications.wonChallenge),
                               LabeledFormValue(value: "giftedGems", label: L10n.Settings.PushNotifications.giftedGems),
                               LabeledFormValue(value: "giftedSubscription", label: L10n.Settings.PushNotifications.giftedSubscription),
                               LabeledFormValue(value: "invitedParty", label: L10n.Settings.PushNotifications.invitedParty),
                               LabeledFormValue(value: "invitedGuild", label: L10n.Settings.PushNotifications.invitedGuid),
                               LabeledFormValue(value: "invitedQuest", label: L10n.Settings.PushNotifications.invitedQuest),
                               LabeledFormValue(value: "questStarted", label: L10n.Settings.PushNotifications.questBegun),
                               LabeledFormValue(value: "majorUpdates", label: L10n.Settings.PushNotifications.importantAnnouncement),
                               LabeledFormValue(value: "kickedGroup", label: L10n.Settings.EmailNotifications.bannedGroup)]
                
                row.disabled = Condition.function([SettingsTags.disableAllEmails], { (form) -> Bool in
                    return (form.rowBy(tag: SettingsTags.disableAllEmails) as? SwitchRow)?.value == true
                })
                row.cellUpdate { (cell, _) in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                    cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
                }
                row.onPresent({ (_, to) in
                    to.selectableRowCellUpdate = { cell, _ in
                        cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    }
                })
                row.onChange({[weak self] (row) in
                    if self?.isSettingUserData == true {
                        return
                    }
                    var updateDict = [String: Encodable]()
                    for option in row.options ?? [] {
                        updateDict["preferences.emailNotifications.\(option.value)"] = row.value?.contains(where: { selectedValue in
                            selectedValue.value == option.value
                        })
                    }
                    self?.userRepository.updateUser(updateDict).observeCompleted {}
                })
            }
            <<< SwitchRow(SettingsTags.disablePrivateMessages) { row in
                row.title = L10n.Settings.disablePm
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
        +++ groupPlanSection
        let section = Section(L10n.Settings.preferences)
            <<< PushRow<LabeledFormValue<Int>>(SettingsTags.appLanguage) { row in
                row.title = L10n.Settings.language
                row.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                    cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                    cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
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
                    cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                    cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
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
                    cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                    cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
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
                    cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
                    cell.tintColor = ThemeService.shared.theme.tintColor
                    cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
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
        <<< PushRow<LabeledFormValue<String>>(SettingsTags.themeMode) { row in
            row.title = L10n.Settings.themeMode
            row.cellUpdate { cell, _ in
                cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
                cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
                cell.tintColor = ThemeService.shared.theme.tintColor
                cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
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
                cell.detailTextLabel?.textColor = ThemeService.shared.theme.quadTextColor
                cell.tintColor = ThemeService.shared.theme.tintColor
                cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
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
        isSettingUserData = true
        let defaults = UserDefaults()
        (form.rowBy(tag: SettingsTags.dailyReminder) as? SwitchRow)?.value = defaults.bool(forKey: "dailyReminderActive")
        (form.rowBy(tag: SettingsTags.dailyReminderTime) as? TimePickerRow)?.value = defaults.value(forKey: "dailyReminderTime") as? Date
        (form.rowBy(tag: SettingsTags.displayNotificationsBadge) as? SwitchRow)?.value = defaults.bool(forKey: "appBadgeActive")
        isSettingUserData = false
    }
    
    private func setUser(_ user: UserProtocol) {
        isSettingUserData = true
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        components.hour = user.preferences?.dayStart ?? 0
        components.minute = 0
        components.second = 0
        let timeRow = (form.rowBy(tag: SettingsTags.customDayStart) as? PushRow<LabeledFormValue<Int>>)
        timeRow?.value = makeCDSValue(user.preferences?.dayStart ?? 0)
        timeRow?.updateCell()
        
        let searchableUsernameRow = (form.rowBy(tag: SettingsTags.searchableUsername) as? AlertRow<LabeledFormValue<Bool>>)
        if user.preferences?.searchableUsername == true {
            searchableUsernameRow?.value = LabeledFormValue(value: true, label: L10n.Settings.searchableEverywhere)
        } else {
            searchableUsernameRow?.value = LabeledFormValue(value: false, label: L10n.Settings.searchablePrivateSpaces)
        }
        searchableUsernameRow?.updateCell()
        
        let disableNotificationsRow = (form.rowBy(tag: SettingsTags.disableAllNotifications) as? SwitchRow)
        disableNotificationsRow?.value = user.preferences?.pushNotifications?.unsubscribeFromAll
        disableNotificationsRow?.updateCell()
        
        let pushNotificationsRow = (form.rowBy(tag: SettingsTags.pushNotifications) as? MultipleSelectorRow<String>)
        pushNotificationsRow?.value = getPushNotificationSet(forUser: user)
        
        let disableEmailsRow = (form.rowBy(tag: SettingsTags.disableAllEmails) as? SwitchRow)
        disableEmailsRow?.value = user.preferences?.emailNotifications?.unsubscribeFromAll
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
        
        if let row = form.rowBy(tag: SettingsTags.manuallyRestartDay) {
            // Only show if no cron in last 24 hours
            row.hidden = Condition(booleanLiteral: ((user.lastCron?.timeIntervalSinceNow ?? 0) > -86400) || !configRepository.bool(variable: .enableCronButton))
            row.evaluateHidden()        }
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
        let defaults = UserDefaults.standard
        defaults.set(language.rawValue, forKey: "ChosenLanguage")
        LanguageHandler.setAppLanguage(language)
        self.userRepository.updateUser(key: "preferences.language", value: language.code)
            .flatMap(.latest, {[weak self] _ in
                return self?.contentRepository.retrieveContent(force: true) ?? Signal.empty
            })
            .observeCompleted {[weak self] in
                self?.relaunchMainApp()
        }
    }
    
    private func relaunchMainApp() {
        dismiss(animated: true, completion: {
            UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
        })
    }
    
    private func makeCDSValue(_ adjustment: Int) -> LabeledFormValue<Int> {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        let calendar = Calendar.current
        let now = Date()
        if let date = calendar.date(bySettingHour: adjustment, minute: 0, second: 0, of: now) {
            if adjustment == 0 {
                return LabeledFormValue(value: adjustment, label: "Default (\(timeFormatter.string(from: date)))")
            } else {
                return LabeledFormValue(value: adjustment, label: "+\(adjustment) hours (\(timeFormatter.string(from: date)))")
            }
        } else {
            return LabeledFormValue(value: adjustment, label: "+\(adjustment) (\(adjustment):00)")
        }
    }
    
    private func calculateNextCron(dayStart: Int?) -> Date {
        let date = Date()
        let currentHour = Calendar.current.component(.hour, from: date)
        let currentYear = Calendar.current.component(.year, from: date)
        let currentMonth = Calendar.current.component(.month, from: date)
        let currentDay = Calendar.current.component(.day, from: date)
        var day: Int
        if (currentHour >= dayStart ?? 0) {
            day = currentDay + 1
        } else {
            day = currentDay
        }
        let components = DateComponents(year: currentYear, month: currentMonth, day: day, hour: dayStart ?? 0, minute: 0, second: 0)
        let calendar = Calendar(identifier: Locale.current.calendar.identifier)
        return calendar.date(from: components) ?? Date()
    }
}
