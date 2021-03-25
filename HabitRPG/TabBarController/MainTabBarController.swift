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
    
    private var badges: [Int: PaddedView]? {
        get {
            return (tabBar as? MainTabBar)?.badges
        }
        set {
            if let badges = newValue {
                (tabBar as? MainTabBar)?.badges = badges
            }
        }
    }
        
    private var showAdventureGuideBadge = false {
        didSet {
            let badge = badges?[4]
            if showAdventureGuideBadge {
                if badge == nil || badge?.containedView is UILabel {
                    badge?.removeFromSuperview()
                    let newBadge = PaddedView()
                    badges?[4] = newBadge
                    newBadge.verticalPadding = 4
                    newBadge.horizontalPadding = 4
                    newBadge.backgroundColor = .yellow10
                    newBadge.containedView = UIImageView(image: Asset.adventureGuideStar.image)
                    newBadge.isUserInteractionEnabled = false
                    tabBar.addSubview(newBadge)
                    (tabBar as? MainTabBar)?.layoutBadges()
                } else {
                    return
                }
            } else {
                if !(badge?.containedView is UILabel) {
                    badge?.removeFromSuperview()
                    badges?.removeValue(forKey: 4)
                }
            }
        }
    }
    
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
        
        tabBar.items?[0].accessibilityLabel = L10n.Tasks.habits
        tabBar.items?[1].accessibilityLabel = L10n.Tasks.dailies
        tabBar.items?[2].accessibilityLabel = L10n.Tasks.todos
        tabBar.items?[3].accessibilityLabel = L10n.Tasks.rewards
        tabBar.items?[4].accessibilityLabel = L10n.menu

        ThemeService.shared.addThemeable(themable: self)
        if let mainTabBar = tabBar as? MainTabBar {
            ThemeService.shared.addThemeable(themable: mainTabBar)
        }
    }
    
    func applyTheme(theme: Theme) {
        if ThemeService.shared.themeMode == "dark" {
            self.overrideUserInterfaceStyle = .dark
        } else if ThemeService.shared.themeMode == "light" {
            self.overrideUserInterfaceStyle = .light
        } else {
            self.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentingViewController?.willMove(toParent: nil)
        presentingViewController?.removeFromParent()
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
            self?.showAdventureGuideBadge = user.achievements?.hasCompletedOnboarding != true
            self?.setBadgeCount(index: 4, count: badgeCount)
            
            if let tutorials = user.flags?.tutorials {
                self?.updateTutorialSteps(tutorials)
            }
            
            if user.flags?.welcomed != true {
                self?.userRepository.updateUser(key: "flags.welcomed", value: true).observeCompleted {}
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
        if index == 4 && showAdventureGuideBadge {
            return
        }
        let badge = badges?[index] ?? PaddedView()
        badges?[index] = badge
        if !(badge.containedView is UILabel) {
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
        badge.isUserInteractionEnabled = false
        tabBar.addSubview(badge)
        (tabBar as? MainTabBar)?.layoutBadges()
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
        ThemeService.shared.updateInterfaceStyle(newStyle: traitCollection.userInterfaceStyle)
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

class MainTabBar: UITabBar, Themeable {
    var badges = [Int: PaddedView]()

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        guard let window = UIApplication.shared.findKeyWindow() else {
            return sizeThatFits
        }
        if window.safeAreaInsets.bottom > 0 {
            sizeThatFits.height = 42 + window.safeAreaInsets.bottom
        }
        return sizeThatFits
    }
    
    func applyTheme(theme: Theme) {
        items?.forEach({
            $0.badgeColor = theme.badgeColor
            if theme.badgeColor.isLight() {
                $0.setBadgeTextAttributes([.foregroundColor: UIColor.gray50], for: .normal)
            } else {
                $0.setBadgeTextAttributes([.foregroundColor: UIColor.gray700], for: .normal)
            }
        })
        tintColor = theme.fixedTintColor
        barTintColor = theme.contentBackgroundColor
        backgroundColor = theme.contentBackgroundColor
        backgroundImage = UIImage.from(color: theme.contentBackgroundColor)
        shadowImage = UIImage.from(color: theme.contentBackgroundColor)
        barStyle = .black
        
        unselectedItemTintColor = theme.dimmedTextColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBadges()
    }
    
    func layoutBadges() {
        for entry in badges {
            let frame = frameForTab(atIndex: entry.key)
            let size = entry.value.intrinsicContentSize
            let width = max(size.height, size.width)
            // Find the edge of the icon and then center the badge there
            entry.value.frame = CGRect(x: frame.origin.x + (frame.size.width/2) + 15 - (width/2), y: frame.origin.y + 4, width: width, height: size.height)
            entry.value.cornerRadius = size.height / 2
        }
    }
    
    private func frameForTab(atIndex index: Int) -> CGRect {
        var frames = subviews.compactMap { (view: UIView) -> CGRect? in
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
}
