//
//  UserLocalRepository.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
import RealmSwift

public class UserLocalRepository: BaseLocalRepository {
    public func save(_ user: UserProtocol) {
        removeOldTags(userID: user.id, newTags: user.tags)
        removeOldMemberships(userID: user.id, newChallengeMemberships: user.challenges)
        if let realmUser = user as? RealmUser {
            save(object: realmUser)
            return
        }
        save(object: RealmUser(user), update: .modified)
        
        let userID = user.id ?? ""
        
        if user.party?.quest?.rsvpNeeded == true {
            let notification = createNotification(userID: userID, id: "quest-invite-\(userID)", type: .questInvite)
            if var notification = notification as? NotificationQuestInviteProtocol {
                notification.questKey = user.party?.quest?.key
            }
            if let notification = notification as? RealmNotification {
                save(object: notification, update: .modified)
            }
        } else {
            removeNotification("quest-invite-\(userID)")
        }
        if let inviteNotifications = getRealm()?.objects(RealmNotification.self).filter("id BEGINSWITH 'group-invite-\(userID)'"), inviteNotifications.count > 0 {
            try? getRealm()?.write { getRealm()?.delete(inviteNotifications) }
        }
        if user.invitations.count > 0 {
            let notifications = user.invitations.map { (invitation) -> RealmNotification? in
                let notification = createNotification(userID: userID, id: "group-invite-\(userID)-\(invitation.id ?? "")", type: .groupInvite)
                if var notification = notification as? NotificationGroupInviteProtocol {
                    notification.groupID = invitation.id
                    notification.groupName = invitation.name
                    notification.inviterID = invitation.inviterID
                    notification.isParty = invitation.isPartyInvitation
                    notification.isPublicGuild = invitation.isPublicGuild
                }
                return notification as? RealmNotification
            }
            save(objects: notifications.flatMap { $0 })
        }
    }
    
    public func save(_ userId: String, stats: StatsProtocol) {
        RealmUser.findBy(key: userId).take(first: 1).on(value: {[weak self] user in
            self?.updateCall { realm in
                let realmStats = RealmStats(id: userId, stats: stats)
                realm.add(realmStats, update: .modified)
                user?.stats = realmStats
            }
        }).start()
    }
    
    public func save(userID: String?, inAppRewards: [InAppRewardProtocol]) {
        save(objects: inAppRewards.map { (inAppReward) in
            if let realmInAppReward = inAppReward as? RealmInAppReward {
                return realmInAppReward
            }
            return RealmInAppReward(userID: userID, protocolObject: inAppReward)
        })
        removeOldInAppRewards(userID: userID, newInAppRewards: inAppRewards)
    }
    
    public func save(userID: String, messages: [InboxMessageProtocol]) {
        save(objects: messages.map { (messsage) in
            if let realmInboxMessage = messsage as? RealmInboxMessage {
                return realmInboxMessage
            }
            return RealmInboxMessage(userID: userID, inboxMessage: messsage)
        })
    }
    
    public func save(userID: String, conversations: [InboxConversationProtocol]) {
        save(objects: conversations.map { (conversation) in
            if let realmInboxConversation = conversation as? RealmInboxConversation {
                return realmInboxConversation
            }
            return RealmInboxConversation(userID: userID, inboxConversatin: conversation)
        })
    }
    
    public func save(userID: String, notifications: [NotificationProtocol]?) {
        save(objects: notifications?.map { (notification) in
            if let realmNotification = notification as? RealmNotification {
                return realmNotification
            }
            return RealmNotification(userID: userID, protocolObject: notification)
        })
        removeOldNotifications(userID: userID, newNotifications: notifications)
    }
    
    private func removeOldInAppRewards(userID: String?, newInAppRewards: [InAppRewardProtocol]) {
        let oldRewards = getRealm()?.objects(RealmInAppReward.self).filter("userID == '\(userID ?? "")'")
        var rewardsToRemove = [RealmInAppReward]()
        oldRewards?.forEach({ (reward) in
            if !newInAppRewards.contains(where: { (newReward) -> Bool in
                return newReward.key == reward.key
            }) {
                rewardsToRemove.append(reward)
            }
        })
        if rewardsToRemove.isEmpty == false {
            updateCall { realm in
                realm.delete(rewardsToRemove)
            }
        }
    }
    
    private func removeOldTags(userID: String?, newTags: [TagProtocol]) {
        let oldTags = getRealm()?.objects(RealmTag.self).filter("userID == '\(userID ?? "")'")
        var tagsToRemove = [RealmTag]()
        oldTags?.forEach({ (tag) in
            if !newTags.contains(where: { (newTag) -> Bool in
                return newTag.id == tag.id
            }) {
                tagsToRemove.append(tag)
            }
        })
        if tagsToRemove.isEmpty == false {
            updateCall { realm in
                realm.delete(tagsToRemove)
            }
        }
    }
    
    private func removeOldMemberships(userID: String?, newChallengeMemberships: [ChallengeMembershipProtocol]) {
        let oldChallengeMemberships = getRealm()?.objects(RealmChallengeMembership.self).filter("userID == '\(userID ?? "")'")
        var membershipsToRemove = [Object]()
        oldChallengeMemberships?.forEach({ (membership) in
            if !newChallengeMemberships.contains(where: { (newMembership) -> Bool in
                return newMembership.challengeID == membership.challengeID
            }) {
                membershipsToRemove.append(membership)
            }
        })
        if membershipsToRemove.isEmpty == false {
            updateCall { realm in
                realm.delete(membershipsToRemove)
            }
        }
    }
    
    private func removeOldNotifications(userID: String?, newNotifications: [NotificationProtocol]?) {
        let oldNotifications = getRealm()?.objects(RealmNotification.self).filter("userID == '\(userID ?? "")' && !(id CONTAINS '-invite-')")
        var notificationsToRemove = [Object]()
        oldNotifications?.forEach({ (notification) in
            if newNotifications?.contains(where: { (newNotification) -> Bool in
                return newNotification.id == notification.id
            }) != true {
                notificationsToRemove.append(notification)
            }
        })
        if notificationsToRemove.isEmpty == false {
            updateCall { realm in
                realm.delete(notificationsToRemove)
            }
        }
    }
    
    private func removeNotification(_ id: String) {
        let realm = getRealm()
        if let notification = realm?.objects(RealmNotification.self).filter("id == '\(id)'").first {
            realm?.refresh()
            try? realm?.write {
                realm?.delete(notification)
            }
        }
    }
    
    public func getUser(_ id: String) -> SignalProducer<UserProtocol, ReactiveSwiftRealmError> {
        return RealmUser.findBy(query: "id == '\(id)'").reactive().map({ (users, _) -> UserProtocol? in
            return users.first
        }).skipNil()
    }
    
    public func hasUserData(id: String) -> Bool {
        return getRealm()?.object(ofType: RealmUser.self, forPrimaryKey: id) != nil
    }
    
    public func save(userID: String?, skillResponse: SkillResponseProtocol) {
        let tags = getRealm()?.objects(RealmTag.self)
        if let task = skillResponse.task {
            if let oldTask = getRealm()?.object(ofType: RealmTask.self, forPrimaryKey: task.id) {
                task.order = oldTask.order
            }
            save(object: RealmTask(ownerID: userID, taskProtocol: task, tags: tags))
        }
        if let newUser = skillResponse.user {
            save(newUser)
        }
    }
    
    public func toggleSleep(_ userID: String) {
        if let user = getRealm()?.object(ofType: RealmUser.self, forPrimaryKey: userID) {
            updateCall { _ in
                user.preferences?.sleep = !(user.preferences?.sleep ?? false)
            }
        }
    }
    
    public func updateUser(id: String, balanceDiff: Float) {
        if let user = getRealm()?.object(ofType: RealmUser.self, forPrimaryKey: id) {
            updateCall { _ in
                user.balance += balanceDiff
            }
        }
    }
    
    public func updateUser(id: String, updateUser: UserProtocol) {
        if let user = getRealm()?.object(ofType: RealmUser.self, forPrimaryKey: id) {
            mergeUsers(oldUser: user, newUser: updateUser)
        }
    }
    
    public func updateUser(id: String, userItems: UserItemsProtocol) {
        updateCall { realm in
            realm.add(RealmUserItems(id: id, userItems: userItems), update: .modified)
        }
    }
    
    public func updateUser(id: String, price: Int, buyResponse: BuyResponseProtocol) {
        let realm = getRealm()
        if let existingUser = realm?.object(ofType: RealmUser.self, forPrimaryKey: id) {
            updateCall { _ in
                if let stats = existingUser.stats {
                    stats.health = buyResponse.health ?? stats.health
                    stats.experience = buyResponse.experience ?? stats.experience
                    stats.mana = buyResponse.mana ?? stats.mana
                    stats.level = buyResponse.level ?? stats.level
                    stats.gold = buyResponse.gold ?? (stats.gold - Float(price))
                    stats.points = buyResponse.attributePoints ?? stats.points
                    stats.strength = buyResponse.strength ?? stats.strength
                    stats.intelligence = buyResponse.intelligence ?? stats.intelligence
                    stats.constitution = buyResponse.constitution ?? stats.constitution
                    stats.perception = buyResponse.perception ?? stats.perception
                    if let newBuffs = buyResponse.buffs {
                        let realmBuffs = RealmBuff(id: id, buff: newBuffs)
                        realm?.add(realmBuffs, update: .modified)
                        stats.buffs = realmBuffs
                    }
                }
                if let outfit = buyResponse.items?.gear?.equipped {
                    let realmOutfit = RealmOutfit(id: id, type: "equipped", outfit: outfit)
                    realm?.add(realmOutfit, update: .modified)
                    existingUser.items?.gear?.equipped = realmOutfit
                }
            }
        }
    }
    
    public func getUserStyleWithOutfitFor(class habiticaClass: HabiticaClass, userID: String) -> SignalProducer<UserStyleProtocol, ReactiveSwiftRealmError> {
        return RealmUser.findBy(key: userID).map({ (user) -> UserStyleProtocol in
            let userStyle = RealmUserStyle()
            userStyle.items = RealmUserItems()
            userStyle.items?.gear = RealmUserGear()
            let outfit = self.outfitFor(class: habiticaClass)
            userStyle.items?.gear?.equipped = outfit
            userStyle.items?.gear?.costume = outfit
            userStyle.preferences = user?.preferences
            userStyle.stats = user?.stats
            return userStyle
        })
    }
    
    public func getInAppRewards(userID: String) -> SignalProducer<ReactiveResults<[InAppRewardProtocol]>, ReactiveSwiftRealmError> {
        return RealmInAppReward.findBy(query: "userID == '\(userID)'").reactive().map({ (value, changeset) -> ReactiveResults<[InAppRewardProtocol]> in
            return (value.map({ (reward) -> InAppRewardProtocol in return reward }), changeset)
        })
    }
    
    public func getTags(userID: String) -> SignalProducer<ReactiveResults<[TagProtocol]>, ReactiveSwiftRealmError> {
        return RealmTag.findBy(query: "userID == '\(userID)'").sorted(key: "order").reactive().map({ (value, changeset) -> ReactiveResults<[TagProtocol]> in
            return (value.map({ (tag) -> TagProtocol in return tag }), changeset)
        })
    }
    
    public func usedTransformationItem(userID: String, key: String) {
        let realm = getRealm()
        let ownedItem = realm?.object(ofType: RealmOwnedItem.self, forPrimaryKey: "\(userID)\(key)special")
        updateCall { _ in
            ownedItem?.numberOwned -= 1
        }
    }
    
    public func getNotifications(userID: String) -> SignalProducer<ReactiveResults<[NotificationProtocol]>, ReactiveSwiftRealmError> {
        return RealmNotification.findBy(query: "userID == '\(userID)' && realmType != ''").sorted(key: "priority").reactive().map({ (value, changeset) -> ReactiveResults<[NotificationProtocol]> in
            return (value.map({ (notification) -> NotificationProtocol in return notification }), changeset)
        })
    }
    
    public func getUnreadNotificationCount(userID: String) -> SignalProducer<Int, ReactiveSwiftRealmError> {
        return RealmNotification.findBy(query: "userID == '\(userID)' && realmType != '' && seen == false").reactive().map({ (value, changeset) -> Int in
            return value.count
        })
    }
    
    public func createNotification(userID: String, id: String, type: HabiticaNotificationType) -> NotificationProtocol {
        return RealmNotification(id, userID: userID, type: type)
    }
    
    public func getAchievements(userID: String) -> SignalProducer<ReactiveResults<[AchievementProtocol]>, ReactiveSwiftRealmError> {
        return RealmAchievement.findBy(query: "userID == '\(userID)'").sorted(key: "index").reactive().map({ (value, changeset) -> ReactiveResults<[AchievementProtocol]> in
            return (value.map({ (achievement) -> AchievementProtocol in return achievement }), changeset)
        })
    }
    
    public func save(userID: String, achievements: [AchievementProtocol]) {
        save(objects: achievements.map { (achievement) in
            if let realmAchievement = achievement as? RealmAchievement {
                return realmAchievement
            }
            return RealmAchievement(userID: userID, protocolObject: achievement)
        })
    }
    
    private func outfitFor(class habiticaClass: HabiticaClass) -> OutfitProtocol {
        let outfit = RealmOutfit()
        switch habiticaClass {
        case .warrior:
            outfit.armor = "armor_warrior_5"
            outfit.head = "head_warrior_5"
            outfit.shield = "shield_warrior_5"
            outfit.weapon = "weapon_warrior_6"
        case .mage:
            outfit.armor = "armor_wizard_5"
            outfit.head = "head_wizard_5"
            outfit.weapon = "weapon_wizard_6"
        case .healer:
            outfit.armor = "armor_healer_5"
            outfit.head = "head_healer_5"
            outfit.shield = "shield_healer_6"
            outfit.weapon = "weapon_healer_6"
        case .rogue:
            outfit.armor = "armor_rogue_5"
            outfit.head = "head_rogue_5"
            outfit.shield = "shield_rogue_6"
            outfit.weapon = "weapon_rogue_6"
        }
        return outfit
    }
    
    private func mergeUsers(oldUser: UserProtocol, newUser: UserProtocol) {
        updateCall { realm in
            if newUser.balance >= 0 {
                oldUser.balance = newUser.balance
            }
            if let newItems = newUser.items {
                realm.add(RealmUserItems(id: oldUser.id, userItems: newItems), update: .modified)
            }
            if let newStats = newUser.stats {
                if newStats.maxHealth == 0, let maxHealth = oldUser.stats?.maxHealth {
                    newStats.maxHealth = maxHealth
                }
                if newStats.maxMana == 0, let maxMana = oldUser.stats?.maxMana {
                    newStats.maxMana = maxMana
                }
                if newStats.toNextLevel == 0, let toNextLevel = oldUser.stats?.toNextLevel {
                    newStats.toNextLevel = toNextLevel
                }
                realm.add(RealmStats(id: oldUser.id, stats: newStats), update: .modified)
            }
            if let newProfile = newUser.profile {
                realm.add(RealmProfile(id: oldUser.id, profile: newProfile), update: .modified)
            }
            if let newContributor = newUser.contributor {
                realm.add(RealmContributor(id: oldUser.id, contributor: newContributor), update: .modified)
            }
            if let newFlags = newUser.flags {
                realm.add(RealmFlags(id: oldUser.id, flags: newFlags), update: .modified)
            }
            if let newInbox = newUser.inbox {
                realm.add(RealmInbox(id: oldUser.id, inboxProtocol: newInbox), update: .modified)
            }
            if let newPreferences = newUser.preferences {
                realm.add(RealmPreferences(id: oldUser.id, preferences: newPreferences), update: .modified)
            }
            if let newPurchaseed = newUser.purchased {
                realm.add(RealmPurchased(userID: oldUser.id, protocolObject: newPurchaseed), update: .modified)
            }
        }
    }
}
