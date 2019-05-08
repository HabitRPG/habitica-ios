//
//  MainTabBarController.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
#if DEBUG
import FLEX
#endif

class MainTabBarController: UITabBarController, Themeable {
    
    private let userRepository = UserRepository()
    private let taskRepository = TaskRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    @objc public var selectedTags = [String]()
    
    private var dueDailiesCount = 0
    private var dueToDosCount = 0
    private var tutorialDailyCount = 0
    private var tutorialToDoCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDailyIcon()
        
        tabBar.items?[0].title = L10n.Tasks.habits
        tabBar.items?[1].title = L10n.Tasks.dailies
        tabBar.items?[2].title = L10n.Tasks.todos
        tabBar.items?[3].title = L10n.Tasks.rewards
        tabBar.items?[4].title = L10n.menu
        
        fetchData()
        
        #if DEBUG
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(showDebugMenu))
        swipe.direction = .up
        swipe.delaysTouchesBegan = true
        swipe.numberOfTouchesRequired = 1
        tabBar.addGestureRecognizer(swipe)
        #endif
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
    }
    
    private func setupDailyIcon() {
        let calendarImage = #imageLiteral(resourceName: "tabbar_dailies")
        UIGraphicsBeginImageContextWithOptions(CGSize(width: calendarImage.size.width, height: calendarImage.size.height), false, 0)
        calendarImage.draw(in: CGRect(x: 0, y: 0, width: calendarImage.size.width, height: calendarImage.size.height))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let dateString = dateFormatter.string(from: Date()) as NSString
        let style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        style?.alignment = .left
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .paragraphStyle: style ?? NSParagraphStyle.default
        ]
        let size = dateString.size(withAttributes: textAttributes)
        let offset = (calendarImage.size.width - size.width) / 2
        dateString.draw(in: CGRect(x: offset + 1, y: 13, width: 20, height: 20), withAttributes: textAttributes)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.tabBar.items?[1].image = resultImage
    }
    
    private func fetchData() {
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            var badgeCount = 0
            // swiftlint:disable:next empty_count
            if let count = user.inbox?.numberNewMessages, count > 0 {
                badgeCount += count
            }
            if user.flags?.hasNewStuff == true {
                badgeCount += 1
            }
            if let partyID = user.party?.id {
                if user.hasNewMessages.first(where: { (newMessages) -> Bool in
                    return newMessages.id == partyID
                })?.hasNewMessages == true {
                    badgeCount += 1
                }
                
            }
            self?.setBadgeCount(index: 4, count: badgeCount)
            
            if let tutorials = user.flags?.tutorials {
                self?.updateTutorialSteps(tutorials)
            }
        }).start())
        disposable.inner.add(taskRepository.getDueTasks().on(value: {[weak self] tasks in
            self?.dueDailiesCount = 0
            self?.dueToDosCount = 0
            let calendar = Calendar(identifier: .gregorian)
            let today = Date()
            for task in tasks.value where !task.completed {
                if task.type == TaskType.daily {
                    self?.dueDailiesCount += 1
                } else if task.type == TaskType.todo, let duedate = task.duedate {
                    if duedate < today || calendar.isDate(today, inSameDayAs: duedate) {
                        self?.dueToDosCount += 1
                    }
                }
            }
            self?.updateDailyBadge()
            self?.updateToDoBadge()
            self?.updateAppBadge()
        }).start())
    }
    
    private func updateTutorialSteps(_ tutorials: [TutorialStepProtocol]) {
        for tutorial in tutorials {
            if tutorial.key == "habits" {
                self.setBadgeCount(index: 0, count: tutorial.wasSeen ? 0 : 1)
            }
            if tutorial.key == "dailies" {
                self.tutorialDailyCount = tutorial.wasSeen ? 0 : 1
                self.updateDailyBadge()
            }
            if tutorial.key == "todos" {
                self.tutorialToDoCount = tutorial.wasSeen ? 0 : 1
                self.updateToDoBadge()
            }
            if tutorial.key == "rewards" {
                self.setBadgeCount(index: 3, count: tutorial.wasSeen ? 0 : 1)
            }
        }
    }
    
    private func updateDailyBadge() {
        setBadgeCount(index: 1, count: dueDailiesCount + tutorialDailyCount)
    }
    
    private func updateToDoBadge() {
        setBadgeCount(index: 2, count: dueToDosCount + tutorialToDoCount)
    }
    
    private func setBadgeCount(index: Int, count: Int) {
        let item = tabBar.items?[index]
        // swiftlint:disable:next empty_count
        if count > 0 {
            item?.badgeValue = "\(count)"
        } else {
            item?.badgeValue = nil
        }
    }
    
    private func updateAppBadge() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "appBadgeActive") == true {
            UIApplication.shared.applicationIconBadgeNumber = dueDailiesCount + dueToDosCount
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    #if DEBUG
    @objc
    private func showDebugMenu(_ recognizer: UISwipeGestureRecognizer) {
        if recognizer.state = .recognizer {
            FLEXManager.sharedManager.showExplorer()
        }
    }
    #endif
}
