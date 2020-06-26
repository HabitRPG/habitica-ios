//
//  NotificationManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.06.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import FirebaseAnalytics

class NotificationManager {
    private static var seenNotifications = Set<String>()
    private static let configRepository = ConfigRepository()
    private static let userRepository = UserRepository()
    
    static func handle(notifications: [NotificationProtocol]) -> [NotificationProtocol] {
        notifications.filter { notification in
            return NotificationManager.seenNotifications.contains(notification.id) != true
        }.forEach { notification in
            var notificationDisplayed: Bool? = false
            switch notification.type {
            case HabiticaNotificationType.achievementPartyUp, HabiticaNotificationType.achievementPartyOn,
                HabiticaNotificationType.achievementBeastMaster,
                HabiticaNotificationType.achievementTriadBingo,
                HabiticaNotificationType.achievementGuildJoined,
                HabiticaNotificationType.achievementMountMaster,
                HabiticaNotificationType.achievementInvitedFriend,
                HabiticaNotificationType.achievementChallengeJoined,
                HabiticaNotificationType.achievementOnboardingComplete:
                notificationDisplayed = NotificationManager.displayAchievement(notification: notification, isOnboarding: false, isLastOnboardingAchievement: false)
            case HabiticaNotificationType.achievementGeneric:
                notificationDisplayed = NotificationManager.displayAchievement(notification: notification, isOnboarding: true, isLastOnboardingAchievement: notifications.contains {
                    return $0.type == HabiticaNotificationType.achievementOnboardingComplete
                })
            case HabiticaNotificationType.firstDrop:
                notificationDisplayed = NotificationManager.displayFirstDrop(notification: notification)
            default:
                notificationDisplayed = false
            }
            
            if notificationDisplayed == true {
                NotificationManager.seenNotifications.insert(notification.id)
            }
        }
        return notifications.filter { return !seenNotifications.contains($0.id) }
    }
    
    static func displayFirstDrop(notification: NotificationProtocol) -> Bool {
        guard let firstDropNotification = notification as? NotificationFirstDropProtocol else {
            return true
        }
        let alert = HabiticaAlertController(title: L10n.firstDropTitle)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        let iconStackView = UIStackView()
        iconStackView.axis = .horizontal
        iconStackView.spacing = 16
        let eggView = UIImageView()
        eggView.setImagewith(name: firstDropNotification.egg)
        eggView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        eggView.cornerRadius = 4
        eggView.contentMode = .center
        iconStackView.addArrangedSubview(eggView)
        eggView.addWidthConstraint(width: 80)
        let potionView = UIImageView()
        potionView.setImagewith(name: firstDropNotification.potion)
        potionView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        potionView.cornerRadius = 4
        potionView.contentMode = .center
        iconStackView.addArrangedSubview(potionView)
        potionView.addWidthConstraint(width: 80)
        stackView.addArrangedSubview(iconStackView)
        iconStackView.addHeightConstraint(height: 80)
        let firstLabel = UILabel()
        firstLabel.text = L10n.firstDropExplanation1
        firstLabel.textColor = ThemeService.shared.theme.ternaryTextColor
        firstLabel.font = .systemFont(ofSize: 14)
        firstLabel.textAlignment = .center
        firstLabel.numberOfLines = 0
        stackView.addArrangedSubview(firstLabel)
        let firstSize = firstLabel.sizeThatFits(CGSize(width: 240, height: 600))
        firstLabel.addHeightConstraint(height: firstSize.height)
        let secondLabel = UILabel()
        secondLabel.text = L10n.firstDropExplanation2
        secondLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        secondLabel.font = .systemFont(ofSize: 14)
        secondLabel.textAlignment = .center
        secondLabel.numberOfLines = 0
        stackView.addArrangedSubview(secondLabel)
        let size = secondLabel.sizeThatFits(CGSize(width: 240, height: 600))
        secondLabel.addHeightConstraint(height: size.height)
        
        alert.contentView = stackView
        alert.addAction(title: L10n.goToItems, isMainAction: true) { _ in
            RouterHandler.shared.handle(urlString: "/inventory/items")
        }
        alert.addCloseAction()
        alert.show()
        return true
    }
    
    static func displayAchievement(notification: NotificationProtocol, isOnboarding: Bool, isLastOnboardingAchievement: Bool) -> Bool {
        userRepository.readNotification(notification: notification).observeCompleted {
        }
        if !configRepository.bool(variable: .enableAdventureGuide) {
            if isOnboarding || notification.type == HabiticaNotificationType.achievementOnboardingComplete {
                return true
            }
        }
        if isOnboarding {
            Analytics.logEvent(notification.achievementKey ?? "", parameters: nil)
        }
        if notification.type == HabiticaNotificationType.achievementOnboardingComplete {
            Analytics.logEvent(notification.type.rawValue, parameters: nil)
            Analytics.setUserProperty("true", forName: "completedOnboarding")
        }
        let alert = AchievementAlertController()
        alert.setNotification(notification: notification, isOnboarding: isOnboarding, isLastOnboardingAchievement: isLastOnboardingAchievement)
        alert.show()
        return true
    }
}
