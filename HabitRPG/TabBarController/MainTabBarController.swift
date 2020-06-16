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
import FirebaseAnalytics
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
    
    var badges = [Int: PaddedView]()

    override func viewDidLoad() {
        super.viewDidLoad()
                
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
        tabBar.tintColor = theme.tintColor
        tabBar.items?.forEach({
            $0.badgeColor = theme.badgeColor
            if theme.badgeColor.isLight() {
                $0.setBadgeTextAttributes([.foregroundColor: UIColor.gray50], for: .normal)
            } else {
                $0.setBadgeTextAttributes([.foregroundColor: UIColor.gray700], for: .normal)
            }
        })
        if theme.isDark {
            tabBar.tintColor = theme.tintColor
            tabBar.backgroundColor = theme.windowBackgroundColor
            tabBar.barTintColor = .clear
            tabBar.barStyle = .blackOpaque
        } else {
            tabBar.tintColor = theme.tintColor
            tabBar.barTintColor = theme.contentBackgroundColor
            tabBar.backgroundColor = .clear
            tabBar.barStyle = .default
        }
        
        if #available(iOS 13.0, *) {
            if ThemeService.shared.themeMode == "dark" {
                self.overrideUserInterfaceStyle = .dark
            } else if ThemeService.shared.themeMode == "light" {
                self.overrideUserInterfaceStyle = .light
            } else {
                self.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutBadges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentingViewController?.willMove(toParent: nil)
        presentingViewController?.removeFromParent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutBadges()
    }
    
    private func layoutBadges() {
        for entry in badges {
            let frame = frameForTab(atIndex: entry.key)
            let size = entry.value.intrinsicContentSize
            let width = max(size.height, size.width)
            // Find the edge of the icon and then center the badge there
            entry.value.frame = CGRect(x: frame.origin.x + (frame.size.width/2) + 15 - (width/2), y: frame.origin.y + 4, width: width, height: size.height)
            entry.value.cornerRadius = size.height / 2
        }
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
                setBadgeCount(index: 0, count: tutorial.wasSeen ? 0 : 1)
            }
            if tutorial.key == "dailies" {
                tutorialDailyCount = tutorial.wasSeen ? 0 : 1
                updateDailyBadge()
            }
            if tutorial.key == "todos" {
                tutorialToDoCount = tutorial.wasSeen ? 0 : 1
                updateToDoBadge()
            }
            if tutorial.key == "rewards" {
                setBadgeCount(index: 3, count: tutorial.wasSeen ? 0 : 1)
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
        var badge = PaddedView()
        if let oldBadge = badges[index] {
            badge = oldBadge
        } else {
            badges[index] = badge
            badge.verticalPadding = 2
            badge.horizontalPadding = 6
            let label = UILabel()
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            badge.containedView = label
        }
        badge.backgroundColor = .gray50
        if let label = badge.containedView as? UILabel {
            label.text = "\(count)"
        }
        // swiftlint:disable:next empty_count
        badge.isHidden = count == 0
        tabBar.addSubview(badge)
        layoutBadges()
    }
    
    private func frameForTab(atIndex index: Int) -> CGRect {
        var frames = tabBar.subviews.compactMap { (view: UIView) -> CGRect? in
            if let view = view as? UIControl {
                return view.frame
            }
            return nil
        }
        frames.sort { $0.origin.x < $1.origin.x }
        if frames.count > index {
            return frames[index]
        }
        return frames.last ?? CGRect.zero
    }
    
    private func updateAppBadge() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "appBadgeActive") == true {
            UIApplication.shared.applicationIconBadgeNumber = dueDailiesCount + dueToDosCount
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            ThemeService.shared.updateInterfaceStyle(newStyle: traitCollection.userInterfaceStyle)
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

class MainTabBar: UITabBar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        guard let window = UIApplication.shared.keyWindow else {
            return sizeThatFits
        }
        if #available(iOS 11.0, *) {
            if window.safeAreaInsets.bottom > 0 {
                sizeThatFits.height = 42 + window.safeAreaInsets.bottom
            }
        }
        return sizeThatFits
    }
}
