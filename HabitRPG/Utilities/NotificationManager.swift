//
//  NotificationManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.06.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
#if !targetEnvironment(macCatalyst)
import FirebaseAnalytics
#endif

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
            case .achievementPartyUp,
                 .achievementPartyOn,
                .achievementBeastMaster,
                .achievementTriadBingo,
                .achievementGuildJoined,
                .achievementMountMaster,
                .achievementInvitedFriend,
                .achievementChallengeJoined,
                HabiticaNotificationType.achievementOnboardingComplete,
                HabiticaNotificationType.achievementAllYourBase,
                 HabiticaNotificationType.achievementBackToBasics,
                 HabiticaNotificationType.achievementJustAddWater,
                 HabiticaNotificationType.achievementLostMasterclasser,
                 HabiticaNotificationType.achievementMindOverMatter,
                 HabiticaNotificationType.achievementDustDevil,
                 HabiticaNotificationType.achievementAridAuthority,
                 HabiticaNotificationType.achievementMonsterMagus,
                 HabiticaNotificationType.achievementUndeadUndertaker,
                 HabiticaNotificationType.achievementPrimedForPainting,
                 HabiticaNotificationType.achievementPearlyPro,
                 HabiticaNotificationType.achievementTickledPink,
                 HabiticaNotificationType.achievementRosyOutlook,
                 HabiticaNotificationType.achievementBugBonanza,
                 HabiticaNotificationType.achievementBareNecessities,
                 HabiticaNotificationType.achievementFreshwaterFriends,
                 HabiticaNotificationType.achievementGoodAsGold,
                 HabiticaNotificationType.achievementAllThatGlitters,
                 HabiticaNotificationType.achievementBoneCollector,
                 HabiticaNotificationType.achievementSkeletonCrew:
                notificationDisplayed = NotificationManager.displayAchievement(notification: notification, isOnboarding: false, isLastOnboardingAchievement: false)
            case HabiticaNotificationType.achievementGeneric:
                notificationDisplayed = NotificationManager.displayAchievement(notification: notification, isOnboarding: true, isLastOnboardingAchievement: notifications.contains {
                    return $0.type == HabiticaNotificationType.achievementOnboardingComplete
                })
            case HabiticaNotificationType.loginIncentive:
                notificationDisplayed = NotificationManager.displayLoginIncentive(notification: notification)
            case HabiticaNotificationType.firstDrop:
                notificationDisplayed = NotificationManager.displayFirstDrop(notification: notification)
            default:
                notificationDisplayed = false
            }
            
            if notificationDisplayed == true {
                NotificationManager.seenNotifications.insert(notification.id)
            }
        }
        return notifications.filter {
            return !seenNotifications.contains($0.id)
        }
    }
    
    static func displayFirstDrop(notification: NotificationProtocol) -> Bool {
        guard let firstDropNotification = notification as? NotificationFirstDropProtocol else {
            return true
        }
        userRepository.retrieveUser().observeCompleted {}
        userRepository.readNotification(notification: notification).observeCompleted {}
        let alert = HabiticaAlertController(title: L10n.firstDropTitle)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        let iconStackView = UIStackView()
        iconStackView.axis = .horizontal
        iconStackView.spacing = 16
        let eggView = NetworkImageView()
        eggView.setImagewith(name: "Pet_Egg_\(firstDropNotification.egg ?? "")")
        eggView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        eggView.cornerRadius = 4
        eggView.contentMode = .center
        iconStackView.addArrangedSubview(eggView)
        eggView.addWidthConstraint(width: 80)
        let potionView = NetworkImageView()
        potionView.setImagewith(name: "Pet_HatchingPotion_\(firstDropNotification.hatchingPotion ?? "")")
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                RouterHandler.shared.handle(urlString: "/inventory/items")
            }
        }
        alert.addCloseAction()
        alert.enqueue()
        return true
    }
    
    static func displayAchievement(notification: NotificationProtocol, isOnboarding: Bool, isLastOnboardingAchievement: Bool) -> Bool {
        userRepository.retrieveUser().observeCompleted {}
        userRepository.readNotification(notification: notification).observeCompleted {}
        #if !targetEnvironment(macCatalyst)
        if isOnboarding {
            Analytics.logEvent(notification.achievementKey ?? "", parameters: nil)
        }
        if notification.type == HabiticaNotificationType.achievementOnboardingComplete {
            Analytics.logEvent(notification.type.rawValue, parameters: nil)
            Analytics.setUserProperty("true", forName: "completedOnboarding")
        }
        #endif
        let alert = AchievementAlertController()
        alert.setNotification(notification: notification, isOnboarding: isOnboarding, isLastOnboardingAchievement: isLastOnboardingAchievement)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // add a slight delay to make sure that any running VC transitions are done
            alert.enqueue()
        }
        return true
    }
    
    static func displayLoginIncentive(notification: NotificationProtocol) -> Bool {
        guard let loginIncentiveNotification = notification as? NotificationLoginIncentiveProtocol else {
            return false
        }
        let nextRewardAt = loginIncentiveNotification.nextRewardAt
        if let reward = loginIncentiveNotification.rewardKey.first {
            userRepository.retrieveUser().observeCompleted {}
            var imageName = reward
            if imageName.contains("armor") {
                imageName = "slim_\(imageName)"
            }
            let alert = ImageOverlayView(imageName: imageName,
                                         title: loginIncentiveNotification.message,
                                         message: nil)
            let mutableString = NSMutableAttributedString(string: L10n.checkinPrizeEarned(loginIncentiveNotification.rewardText ?? ""))
            mutableString.append(NSAttributedString(string: "\n\n"))
            mutableString.append(NSAttributedString(string: L10n.nextPrizeAtXCheckins(nextRewardAt), attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ]))
            alert.attributedMessage = mutableString
            alert.addAction(title: L10n.seeYouTomorrow, isMainAction: true)
            alert.arrangeMessageLast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                alert.show()
            }
        } else {
            ToastManager.show(toast: ToastView(title: loginIncentiveNotification.message ?? "", subtitle: L10n.nextCheckinPrizeXDays(nextRewardAt), background: .blue))
        }
        userRepository.readNotification(notification: notification).observeCompleted {}
        return true
    }
}
