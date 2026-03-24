//
//  NotificationManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.06.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import SwiftUI

class NotificationManager {
    private static var seenNotifications = Set<String>()
    private static let configRepository = ConfigRepository.shared
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
                .achievementOnboardingComplete,
                .achievementAllYourBase,
                 .achievementBackToBasics,
                 .achievementJustAddWater,
                 .achievementLostMasterclasser,
                 .achievementMindOverMatter,
                 .achievementDustDevil,
                 .achievementAridAuthority,
                 .achievementMonsterMagus,
                 .achievementUndeadUndertaker,
                 .achievementPrimedForPainting,
                 .achievementPearlyPro,
                 .achievementTickledPink,
                 .achievementRosyOutlook,
                 .achievementBugBonanza,
                 .achievementBareNecessities,
                 .achievementFreshwaterFriends,
                 .achievementGoodAsGold,
                 .achievementAllThatGlitters,
                 .achievementBoneCollector,
                 .achievementSkeletonCrew:
                notificationDisplayed = NotificationManager.displayAchievement(notification: notification, isOnboarding: false, isLastOnboardingAchievement: false)
            case HabiticaNotificationType.achievementGeneric:
                notificationDisplayed = NotificationManager.displayAchievement(notification: notification, isOnboarding: true, isLastOnboardingAchievement: notifications.contains {
                    return $0.type == HabiticaNotificationType.achievementOnboardingComplete
                })
            case HabiticaNotificationType.rebirthEnabled:
                notificationDisplayed = NotificationManager.displayAchievement(notification: notification, isOnboarding: false, isLastOnboardingAchievement: false)
            case HabiticaNotificationType.rebirthAchievement:
                notificationDisplayed = NotificationManager.displayRebirthAchievement(notification: notification)
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
        userRepository.retrieveUser(forced: true).observeCompleted {}
        userRepository.readNotification(notification: notification).observeCompleted {}
        let viewC = HostingBottomSheetController(rootView: FirstDropSheet(eggKey: firstDropNotification.egg ?? "", potionKey: firstDropNotification.hatchingPotion ?? ""), prefersGrabberVisible: false)
        viewC.show()
        return true
    }
    
    func setNotification(notification: NotificationProtocol) {

    }
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    static func displayAchievement(notification: NotificationProtocol, isOnboarding: Bool, isLastOnboardingAchievement: Bool) -> Bool {
        if isOnboarding && UserDefaults.standard.bool(forKey: "isInSetup") {
            if let key = notification.achievementKey {
                var pending = UserDefaults.standard.stringArray(forKey: "pendingOnboardingAchievements") ?? []
                if !pending.contains(key) {
                    pending.append(key)
                    UserDefaults.standard.set(pending, forKey: "pendingOnboardingAchievements")
                }
            }
            userRepository.readNotification(notification: notification).observeCompleted {}
            return true
        }

        userRepository.retrieveUser(forced: true).observeCompleted {}
        userRepository.readNotification(notification: notification).observeCompleted {}
        
        var key = notification.type.rawValue
        if notification.type == HabiticaNotificationType.achievementGeneric {
            key = notification.achievementKey ?? ""
        }
        var text: String = ""
        var description: String = ""
        var imageKey: String = ""
        switch key {
        case HabiticaNotificationType.achievementPartyUp.rawValue:
            text = L10n.partyUpTitle
            description = L10n.partyUpDescription
            imageKey = "partyUp"
        case HabiticaNotificationType.achievementPartyOn.rawValue:
            text = L10n.partyOnTitle
            description = L10n.partyOnDescription
            imageKey = "partyOn"
        case HabiticaNotificationType.achievementBeastMaster.rawValue:
            text = L10n.beastMasterTitle
            description = L10n.beastMasterDescription
            imageKey = "rat"
        case HabiticaNotificationType.achievementMountMaster.rawValue:
            text = L10n.mountMasterTitle
            description = L10n.mountMasterDescription
            imageKey = "wolf"
        case HabiticaNotificationType.achievementTriadBingo.rawValue:
            text = L10n.triadBingoTitle
            description = L10n.triadBingoDescription
            imageKey = "triadbingo"
        case HabiticaNotificationType.achievementGuildJoined.rawValue:
            text = L10n.guildJoinedTitle
            description = L10n.guildJoinedDescription
            imageKey = "guild"
        case HabiticaNotificationType.achievementChallengeJoined.rawValue:
            text = L10n.challengeJoinedTitle
            description = L10n.challengeJoinedDescription
            imageKey = "challenge"
            
        case HabiticaNotificationType.achievementAllYourBase.rawValue,
             HabiticaNotificationType.achievementBackToBasics.rawValue,
             HabiticaNotificationType.achievementJustAddWater.rawValue,
             HabiticaNotificationType.achievementLostMasterclasser.rawValue,
             HabiticaNotificationType.achievementMindOverMatter.rawValue,
             HabiticaNotificationType.achievementDustDevil.rawValue,
             HabiticaNotificationType.achievementAridAuthority.rawValue,
             HabiticaNotificationType.achievementMonsterMagus.rawValue,
             HabiticaNotificationType.achievementUndeadUndertaker.rawValue,
             HabiticaNotificationType.achievementPrimedForPainting.rawValue,
             HabiticaNotificationType.achievementPearlyPro.rawValue,
             HabiticaNotificationType.achievementTickledPink.rawValue,
             HabiticaNotificationType.achievementRosyOutlook.rawValue,
             HabiticaNotificationType.achievementBugBonanza.rawValue,
             HabiticaNotificationType.achievementBareNecessities.rawValue,
             HabiticaNotificationType.achievementFreshwaterFriends.rawValue,
             HabiticaNotificationType.achievementGoodAsGold.rawValue,
             HabiticaNotificationType.achievementAllThatGlitters.rawValue,
             HabiticaNotificationType.achievementBoneCollector.rawValue,
             HabiticaNotificationType.achievementSkeletonCrew.rawValue:
            text = notification.achievementMessage ?? ""
            description = notification.achievementModalText ?? ""
            imageKey = notification.achievementKey ?? ""
            
        case HabiticaNotificationType.achievementInvitedFriend.rawValue:
            text = L10n.invitedFriendTitle
            description = L10n.invitedFriendDescription
            imageKey = "friends"
        case "createdTask":
            text = L10n.createdTaskTitle
            description = L10n.createdTaskDescription
            imageKey = "createdTask"
        case "completedTask":
            text = L10n.completedTaskTitle
            description = L10n.completedTaskDescription
            imageKey = "completedTask"
        case "hatchedPet":
            text = L10n.hatchedPetTitle
            description = L10n.hatchedPetDescription
            imageKey = "hatchedPet"
        case "fedPet":
            text = L10n.fedPetTitle
            description = L10n.fedPetDescription
            imageKey = "fedPet"
        case "purchasedEquipment":
            text = L10n.purchasedEquipmentTitle
            description = L10n.purchasedEquipmentDescription
            imageKey = "purchasedEquipment"
        case HabiticaNotificationType.achievementOnboardingComplete.rawValue:
            text = L10n.onboardingCompleteAchievementTitle
            description = L10n.onboardingCompleteDescription
            imageKey = "onboardingComplete"
        default:
            break
        }
        
        if notification.type == HabiticaNotificationType.achievementOnboardingComplete {
            HabiticaAnalytics.shared.setUserProperty(key: "completedOnboarding", value: "true")
            let viewC = HostingBottomSheetController(rootView: OnboardingCompletedSheet(), prefersGrabberVisible: false)
            viewC.show()
            return true
        }
        if isLastOnboardingAchievement {
            
        } else {
            let viewC = HostingBottomSheetController(rootView: AchievementReceivedSheet(key: imageKey,
                                                                                        isOnboarding: isOnboarding,
                                                                                        text: Text(text),
                                                                                        description: Text(description)),
                                                     prefersGrabberVisible: false)
            viewC.show()
        }
        return true
    }

    static func displayRebirthAchievement(notification: NotificationProtocol) -> Bool {
        userRepository.readNotification(notification: notification).observeCompleted {}
        userRepository.retrieveUser(forced: true).observeValues { user in
            DispatchQueue.main.async {
                let alert = AchievementAlertController()
                alert.title = L10n.youGotAchievement
                alert.setRebirthAchievement(user: user)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    alert.enqueue()
                }
            }
        }
        return true
    }

    static func displayLoginIncentive(notification: NotificationProtocol) -> Bool {
        guard let loginIncentiveNotification = notification as? NotificationLoginIncentiveProtocol else {
            return true
        }
        let nextRewardAt = loginIncentiveNotification.nextRewardAt
        userRepository.retrieveUser(forced: true).observeValues { user in
            if !loginIncentiveNotification.rewardKey.isEmpty {
                var nextRewardIn = 0
                if let loginIncentives = user?.loginIncentives {
                    nextRewardIn = nextRewardAt - loginIncentives
                }
                let viewC = HostingBottomSheetController(rootView: LoginIncentiveSheet(rewards: loginIncentiveNotification.rewardKey,
                                                                                       text: loginIncentiveNotification.rewardText ?? "",
                                                                                       nextUnlockIn: nextRewardIn), prefersGrabberVisible: false)
                viewC.show()
            } else {
                if let loginIncentives = user?.loginIncentives {
                    let nextRewardIn = nextRewardAt - loginIncentives
                    ToastManager.show(toast: ToastView(title: loginIncentiveNotification.message ?? "", subtitle: L10n.nextCheckinPrizeInXDays(nextRewardIn), background: .blue))
                } else {
                    ToastManager.show(toast: ToastView(title: loginIncentiveNotification.message ?? "", subtitle: L10n.nextCheckinPrizeXDays(nextRewardAt), background: .blue))
                }
            }
        }
        userRepository.readNotification(notification: notification).observeCompleted {}
        return true
    }

    static func showPendingOnboardingAchievement(key: String) {
        var pending = UserDefaults.standard.stringArray(forKey: "pendingOnboardingAchievements") ?? []
        guard pending.contains(key) else {
            return
        }

        pending.removeAll { $0 == key }
        UserDefaults.standard.set(pending, forKey: "pendingOnboardingAchievements")

        var text = ""
        var description = ""
        switch key {
        case "createdTask":
            text = L10n.createdTaskTitle
            description = L10n.createdTaskDescription
        case "completedTask":
            text = L10n.completedTaskTitle
            description = L10n.completedTaskDescription
        case "hatchedPet":
            text = L10n.hatchedPetTitle
            description = L10n.hatchedPetDescription
        case "fedPet":
            text = L10n.fedPetTitle
            description = L10n.fedPetDescription
        case "purchasedEquipment":
            text = L10n.purchasedEquipmentTitle
            description = L10n.purchasedEquipmentDescription
        default:
            return
        }

        let viewC = HostingBottomSheetController(rootView: AchievementReceivedSheet(key: key,
                                                                                    isOnboarding: true,
                                                                                    text: Text(text),
                                                                                    description: Text(description)),
                                                 prefersGrabberVisible: false)
        viewC.show()
    }
}
