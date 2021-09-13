//
//  UserManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 26.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
import Habitica_Database
import PopupDialog
#if !targetEnvironment(macCatalyst)
import FirebaseAnalytics
#endif

@objc
class UserManager: NSObject {
    
    @objc public static let shared = UserManager()
    
    private let userRepository = UserRepository()
    private let taskRepository = TaskRepository()
    private let disposable = CompositeDisposable()
    private let configRepository = ConfigRepository()
    
    private weak var faintViewController: FaintViewController?
    private weak var classSelectionViewController: ClassSelectionViewController?
    private var lastClassSelectionDisplayed: Date?
    private var lastQuestCompletionDisplayed: Date?
    weak var yesterdailiesDialog: YesterdailiesDialogView?
    
    private var tutorialSteps = [String: Bool]()
        
    private func getYesterday() -> Date? {
        let today = Date()
        return Calendar.current.date(byAdding: .day, value: -1, to: today)
    }
    
    func beginListening() {
        disposable.add(userRepository.getUser()
            .throttle(1, on: QueueScheduler.main)
            .on(value: {[weak self]user in
                self?.onUserUpdated(user: user)
            }).filter({[weak self] (user) -> Bool in
                return user.needsCron && self?.yesterdailiesDialog == nil
            }).flatMap(.latest, {[weak self] user in
                return self?.taskRepository.retrieveTasks(dueOnDay: self?.getYesterday()).skipNil()
                    .map({ tasks in
                        return tasks.filter({ task in
                            return task.isDue && !task.completed
                        })
                    }).withLatest(from: SignalProducer<UserProtocol, Never>(value: user)) ?? Signal<([TaskProtocol], UserProtocol), Never>.empty
            }).on(value: {[weak self] (tasks, user) in
                var uncompletedTaskCount = 0
                for task in tasks {
                    if task.type == "daily" && !task.completed {
                        uncompletedTaskCount += 1
                    }
                }
                
                if !user.needsCron {
                    return
                }
                
                var eventProperties = [AnyHashable: Any]()
                eventProperties["eventAction"] = "show cron"
                eventProperties["eventCategory"] = "behaviour"
                eventProperties["event"] = "event"
                eventProperties["task count"] = uncompletedTaskCount
                HabiticaAnalytics.shared.log("show cron", withEventProperties: eventProperties)
                
                if uncompletedTaskCount == 0 {
                    self?.userRepository.runCron(checklistItems: [], tasks: [])
                    return
                }
                
                let viewController = YesterdailiesDialogView()
                viewController.tasks = tasks
                let popup = PopupDialog(viewController: viewController)
                if var topController = UIApplication.shared.findKeyWindow()?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    if let controller = topController as? MainTabBarController {
                        controller.present(popup, animated: true) {
                        }
                        self?.yesterdailiesDialog = viewController
                    }
                }
            })
            .on(failed: { error in
                logger.log(error)
            })
            .start())
        disposable.add(taskRepository.getReminders()
            .debounce(2, on: QueueScheduler.main)
            .on(value: {[weak self](reminders, changes) in
            if let changes = changes {
                self?.updateReminderNotifications(reminders: reminders, changes: changes)
            }
        }).start())
    }
    
    private func onUserUpdated(user: UserProtocol) {
        if !user.isValid {
            return
        }
        SoundManager.shared.currentTheme = SoundTheme(rawValue: user.preferences?.sound ?? "") ?? SoundTheme.none
        
        tutorialSteps = [:]
        user.flags?.tutorials.forEach({ (tutorial) in
            if let key = tutorial.key {
                tutorialSteps[key] = tutorial.wasSeen
            }
        })
        
        faintViewController = checkFainting(user: user)
        
        _ = checkClassSelection(user: user)
        
        handleQuestCompletion(user)
        
        userRepository.registerPushDevice(user: user).observeCompleted {}
        setTimezoneOffset(user)

        if user.flags?.verifiedUsername == false {
            if var topController = UIApplication.shared.findKeyWindow()?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if let controller = topController as? MainTabBarController {
                    let verifyViewController = StoryboardScene.User.verifyUsernameModalViewController.instantiate()
                    verifyViewController.modalTransitionStyle = .crossDissolve
                    verifyViewController.modalPresentationStyle = .overCurrentContext
                    controller.present(verifyViewController, animated: true, completion: nil)
                }
            }
        }
        #if !targetEnvironment(macCatalyst)
        Analytics.setUserProperty(user.isSubscribed ? "true" : "false", forName: "is_subscribed")
        Analytics.setUserProperty(user.party?.id != nil ? "true" : "false", forName: "has_party")
        Analytics.setUserProperty("\(user.loginIncentives)", forName: "checkin_count")
        #endif
    }
    
    private func handleQuestCompletion(_ user: UserProtocol) {
        if let questKey = user.party?.quest?.completed, !questKey.isEmpty {
            if let lastCompletion = lastQuestCompletionDisplayed, lastCompletion.timeIntervalSinceNow > -5000 {
                return
            }
            lastQuestCompletionDisplayed = Date()
            let completionView = QuestCompletedAlertController(questKey: questKey)
            completionView.show()
            userRepository.updateUser(key: "party.quest.completed", value: "").observeCompleted {}
        }
    }
    
    private func checkFainting(user: UserProtocol) -> FaintViewController? {
        if user.stats != nil && (user.stats?.health ?? 0) <= 0.0 && faintViewController == nil {
            let faintView = FaintViewController()
            faintView.show()
            return faintView
        }
        return faintViewController
    }
    
    private func checkClassSelection(user: UserProtocol) -> Bool {
        if user.flags?.classSelected == false && user.preferences?.disableClasses == false && (user.stats?.level ?? 0) >= 10 {
            if let lastSelection = lastClassSelectionDisplayed, lastSelection.timeIntervalSinceNow > -300 {
                return false
            }
            if classSelectionViewController == nil {
                let classSelectionController = StoryboardScene.Settings.classSelectionNavigationController.instantiate()
                if var topController = UIApplication.shared.findKeyWindow()?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    classSelectionController.modalTransitionStyle = .crossDissolve
                    classSelectionController.modalPresentationStyle = .overCurrentContext
                    topController.present(classSelectionController, animated: true) {
                    }
                    lastClassSelectionDisplayed = Date()
                    return true
                }
            }
        }
        return false
    }
    
    @objc
    func shouldDisplayTutorialStep(key: String) -> Bool {
        return !(tutorialSteps[key] ?? true)
    }
    
    @objc
    func markTutorialAsSeen(type: String, key: String) {
        disposable.add(userRepository.updateUser(key: "flags.tutorial.\(type).\(key)", value: true).observeCompleted {})
    }
    
    private func updateReminderNotifications(reminders: [ReminderProtocol], changes: ReactiveChangeset) {
        removeAllReminderNotifications(reminders: reminders)
    }
    private func removeAllReminderNotifications(reminders: [ReminderProtocol]) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            var toCancel = [String]()
            for request in requests where request.identifier.starts(with: "task") {
                toCancel.append(request.identifier)
            }
            notificationCenter.removePendingNotificationRequests(withIdentifiers: toCancel)
            DispatchQueue.main.async {
                for reminder in reminders {
                    self.scheduleNotifications(reminder: reminder)
                }
            }
        })
    }
    
    private func scheduleNotifications(reminder: ReminderProtocol) {
        guard let task = reminder.task else {
            return
        }
        if reminder.id == nil || reminder.id?.isEmpty == true {
            return
        }
        if task.type == TaskType.daily {
            let calendar = Calendar(identifier: .gregorian)
            for day in 0...6 {
                if day == 0 && task.completed {
                    continue
                }
                let checkedDate = Date(timeIntervalSinceNow: TimeInterval(day * 86400))
                if (task.isDue && day == 0) || task.dueOn(date: checkedDate, calendar: calendar) {
                    scheduleForDay(reminder: reminder, date: checkedDate, atTime: reminder.time)
                }
            }
        } else if task.type == TaskType.todo, let time = reminder.time {
            if time > Date() {
                scheduleForDay(reminder: reminder, date: task.duedate ?? time, atTime: time)
            }
        }
    }
    
    private func scheduleForDay(reminder: ReminderProtocol, date: Date, atTime: Date? = nil) {
        var fireDate = date
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        if let atTime = atTime {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: atTime)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            components.timeZone = TimeZone.current
            if let newDate = calendar.date(from: components) {
                fireDate = newDate
            }
        }
        
        if fireDate < Date() {
            return
        }
        
        let taskText = reminder.task?.text?.unicodeEmoji
        
        let content = UNMutableNotificationContent()
        content.body = taskText ?? ""
        content.sound = UNNotificationSound.default
        if let taskID = reminder.task?.id, let taskType = reminder.task?.type {
            content.userInfo = [
                "ID": reminder.id ?? "",
                "taskID": taskID,
                "taskType": taskType
            ]
        } else {
            content.userInfo = [ "ID": reminder.id ?? "" ]
        }
        content.categoryIdentifier = "taskCompletion"
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "task\(reminder.id ?? "")-\(components.month ?? 0)\(components.day ?? 0)", content: content, trigger: trigger)
        logger.log("⏰ Notification \(request.identifier) for \(reminder.task?.text ?? "") at \(fireDate)")
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                logger.log("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    private func setTimezoneOffset(_ user: UserProtocol) {
        let offset = -(NSTimeZone.local.secondsFromGMT() / 60)
        if user.preferences?.timezoneOffset != offset {
            userRepository.updateUser(key: "preferences.timezoneOffset", value: offset).observeCompleted {
                
            }
        }
    }
}
