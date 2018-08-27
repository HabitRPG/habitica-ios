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
import Result
import Habitica_Database
import PopupDialog

@objc
class UserManager: NSObject {
    
    @objc public static let shared = UserManager()
    
    private let userRepository = UserRepository()
    private let taskRepository = TaskRepository()
    private let disposable = CompositeDisposable()
    
    private weak var faintViewController: FaintViewController?
    private weak var classSelectionViewController: ClassSelectionViewController?
    weak var yesterdailiesDialog: YesterdailiesDialogView?
    
    private var tutorialSteps = [String: Bool]()
    
    private var userLevel: Int?
    
    func beginListening() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
        disposable.add(userRepository.getUser()
            .throttle(1, on: QueueScheduler.main)
            .on(value: {[weak self]user in
                self?.onUserUpdated(user: user)
            }).filter({[weak self] (user) -> Bool in
                return user.needsCron && self?.yesterdailiesDialog == nil
            }).flatMap(.latest, {[weak self] user in
                return self?.taskRepository.retrieveTasks(dueOnDay: yesterday).skipNil()
                    .map({ tasks in
                        return tasks.filter({ task in
                            return task.isDue && !task.completed
                        })
                    }).withLatest(from: SignalProducer<UserProtocol, NoError>(value: user)) ?? Signal<([TaskProtocol], UserProtocol), NoError>.empty
            }).on(value: { (tasks, user) in
                var hasUncompletedDailies = false
                for task in tasks {
                    if task.type == "daily" && !task.completed {
                        hasUncompletedDailies = true
                        break
                    }
                }
                
                if !user.needsCron {
                    return
                }
                let viewController = YesterdailiesDialogView()
                if !hasUncompletedDailies {
                    self.userRepository.runCron(tasks: []).observeCompleted {}
                    return
                }
                viewController.tasks = tasks
                let popup = PopupDialog(viewController: viewController)
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    if let controller = topController as? MainTabBarController {
                        controller.present(popup, animated: true) {
                        }
                        self.yesterdailiesDialog = viewController
                    }
                }
            }).start())
        disposable.add(taskRepository.getReminders().on(value: {[weak self](reminders, changes) in
            if let changes = changes {
                self?.updateReminderNotifications(reminders: reminders, changes: changes)
            }
        }).start())
    }
    
    private func onUserUpdated(user: UserProtocol) {
        SoundManager.shared.currentTheme = SoundTheme(rawValue: user.preferences?.sound ?? "") ?? SoundTheme.none
        
        tutorialSteps = [:]
        user.flags?.tutorials.forEach({ (tutorial) in
            if let key = tutorial.key {
                tutorialSteps[key] = tutorial.wasSeen
            }
        })
        
        faintViewController = checkFainting(user: user)
        
        let wasShown = checkClassSelection(user: user)
        
        if !wasShown, let userLevel = self.userLevel {
            if userLevel < (user.stats?.level ?? 0) {
                let levelUpView = LevelUpOverlayView(avatar: user)
                levelUpView.show()
                SoundManager.shared.play(effect: .levelUp)
            }
        }
        self.userLevel = user.stats?.level ?? 0
        
        userRepository.registerPushDevice(user: user).observeCompleted {}
        setTimezoneOffset(user)
    }
    
    private func checkFainting(user: UserProtocol) -> FaintViewController? {
        if (user.stats?.health ?? 0) <= 0.0 && faintViewController == nil {
            let faintView = FaintViewController()
            faintView.show()
            return faintView
        }
        return faintViewController
    }
    
    private func checkClassSelection(user: UserProtocol) -> Bool {
        if user.flags?.classSelected == false && user.preferences?.disableClasses == false && (user.stats?.level ?? 0) >= 10 {
            if self.classSelectionViewController == nil {
                let classSelectionController = StoryboardScene.Settings.classSelectionNavigationController.instantiate()
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    classSelectionController.modalTransitionStyle = .crossDissolve
                    classSelectionController.modalPresentationStyle = .overCurrentContext
                    topController.present(classSelectionController, animated: true) {
                    }
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
        if changes.deleted.count == 0 && changes.inserted.count == 0 {
            let sharedApplication = UIApplication.shared
            let existingNotifications = sharedApplication.scheduledLocalNotifications ?? []
            for index in changes.updated {
                let notificationsForReminder = existingNotifications.filter { (notification) -> Bool in
                    return (notification.userInfo?["ID"] as? String ?? "") == reminders[index].id
                }
                scheduleNotifications(reminder: reminders[index], existingNotifications: notificationsForReminder)
            }
        } else {
            removeAllReminderNotifications()
            for reminder in reminders {
                scheduleNotifications(reminder: reminder)
            }
        }
    }
    
    private func removeAllReminderNotifications() {
        let sharedApplication = UIApplication.shared
        for notification in (sharedApplication.scheduledLocalNotifications ?? []) where notification.userInfo?["ID"] != nil {
            sharedApplication.cancelLocalNotification(notification)
        }
    }
    
    private func removeReminderNotifications(ids: [String]) {
        let sharedApplication = UIApplication.shared
        for notification in (sharedApplication.scheduledLocalNotifications ?? []) {
            if let reminderID = notification.userInfo?["ID"] as? String, reminderID.count > 0 {
                if ids.contains(reminderID) {
                    sharedApplication.cancelLocalNotification(notification)
                }
            }
        }
    }
    
    private func scheduleNotifications(reminder: ReminderProtocol, existingNotifications: [UILocalNotification] = []) {
        guard let task = reminder.task else {
            return
        }
        if task.completed || reminder.id == nil || reminder.id == "" {
            return
        }
        var newNotifications = [UILocalNotification?]()
        if task.type == TaskType.daily {
            for day in 0...6 {
                let checkedDate = Date(timeIntervalSinceNow: TimeInterval(day * 86400))
                if task.dueOn(date: checkedDate) {
                    newNotifications.append(scheduleForDay(reminder: reminder, date: checkedDate, atTime: reminder.time, existingNotifications: existingNotifications))
                }
            }
        } else if task.type == TaskType.todo, let time = reminder.time {
            if time > Date() {
                newNotifications.append(scheduleForDay(reminder: reminder, date: time))
            }
        }
        let sharedApplication = UIApplication.shared
        existingNotifications.forEach { (oldNotification) in
            if !newNotifications.contains(oldNotification) {
                sharedApplication.cancelLocalNotification(oldNotification)
            }
        }
    }
    
    private func scheduleForDay(reminder: ReminderProtocol, date: Date, atTime: Date? = nil, existingNotifications: [UILocalNotification] = []) -> UILocalNotification? {
        var fireDate = date
        if let atTime = atTime {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: atTime)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            components.timeZone = TimeZone.current
            if let newDate = calendar.date(from: components) {
                fireDate = newDate
            }
        }
        
        if fireDate < Date() {
            return nil
        }
        
        if let notification = existingNotifications.first(where: { (notification) -> Bool in
            return notification.fireDate == fireDate && notification.alertBody == reminder.task?.text
        }) {
            return notification
        }
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = fireDate
        localNotification.alertBody = reminder.task?.text
        localNotification.timeZone = TimeZone.current
        if let taskID = reminder.task?.id, let taskType = reminder.task?.type {
            localNotification.userInfo = [
                "ID": reminder.id ?? "",
                "taskID": taskID,
                "taskType": taskType
            ]
        } else {
            localNotification.userInfo = [ "ID": reminder.id ?? "" ]
        }
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.category = "completeCategory"
        UIApplication.shared.scheduleLocalNotification(localNotification)
        print("Scheduled Notification for task", reminder.task?.text ?? "", " at time ", fireDate)
        return localNotification
    }
    
    private func setTimezoneOffset(_ user: UserProtocol) {
        let offset = -(NSTimeZone.local.secondsFromGMT() / 60)
        if user.preferences?.timezoneOffset != offset {
            userRepository.updateUser(key: "preferences.timezoneOffset", value: offset).observeCompleted {
                
            }
        }
    }
}
