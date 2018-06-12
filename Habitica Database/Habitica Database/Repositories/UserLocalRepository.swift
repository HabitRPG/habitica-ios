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

public class UserLocalRepository: BaseLocalRepository {
    public func save(_ user: UserProtocol) {
        if let realmUser = user as? RealmUser {
            save(object: realmUser)
            return
        }
        save(object: RealmUser(user))
    }
    
    public func save(_ userId: String, stats: StatsProtocol) {
        RealmUser.findBy(key: userId).take(first: 1).on(value: {[weak self] user in
            try? self?.getRealm()?.write {
                let realmStats = RealmStats(id: userId, stats: stats)
                self?.getRealm()?.add(realmStats, update: true)
                user?.stats = realmStats
            }
        }).start()
    }
    
    public func save(userID: String?, inAppRewards: [InAppRewardProtocol]) {
        save(objects:inAppRewards.map { (inAppReward) in
            if let realmInAppReward = inAppReward as? RealmInAppReward {
                return realmInAppReward
            }
            return RealmInAppReward(userID: userID, protocolObject: inAppReward)
        })
        removeOldInAppRewards(userID: userID, newInAppRewards: inAppRewards)
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
        if rewardsToRemove.count > 0 {
            let realm = getRealm()
            try? realm?.write {
                realm?.delete(rewardsToRemove)
            }
        }
    }
    
    public func getUser(_ id: String) -> SignalProducer<UserProtocol, ReactiveSwiftRealmError> {
        return RealmUser.findBy(query: "id == '\(id)'").reactive().map({ (users, changes) -> UserProtocol? in
            return users.first
        }).skipNil()
    }
    
    public func hasUserData(id: String) -> Bool {
        return getRealm()?.object(ofType: RealmUser.self, forPrimaryKey: id) != nil
    }
    
    public func save(userID: String?, skillResponse: SkillResponseProtocol) {
        let tags = getRealm()?.objects(RealmTag.self)
        if let task = skillResponse.task {
            save(object: RealmTask(userID: userID, taskProtocol: task, tags: tags))
        }
        if let newUser = skillResponse.user {
            save(newUser)
        }
    }
    
    public func toggleSleep(_ userID: String) {
        if let user = getRealm()?.object(ofType: RealmUser.self, forPrimaryKey: userID) {
            try? getRealm()?.write {
                user.preferences?.sleep = !(user.preferences?.sleep ?? false)
            }
        }
    }
    
    public func updateUser(id: String, balanceDiff: Float) {
        if let user = getRealm()?.object(ofType: RealmUser.self, forPrimaryKey: id) {
            try? getRealm()?.write {
                user.balance = user.balance + balanceDiff
            }
        }
    }
    
    public func updateUser(id: String, updateUser: UserProtocol) {
        if let user = getRealm()?.object(ofType: RealmUser.self, forPrimaryKey: id) {
            mergeUsers(oldUser: user, newUser: updateUser)
        }
    }
    
    public func updateUser(id: String, userItems: UserItemsProtocol) {
        let realm = getRealm()
        try? realm?.write {
            realm?.add(RealmUserItems(id: id, userItems: userItems), update: true)
        }
    }
    
    public func updateUser(id: String, buyResponse: BuyResponseProtocol) {
        let realm = getRealm()
        if let existingUser = realm?.object(ofType: RealmUser.self, forPrimaryKey: id) {
            try? realm?.write {
                if let stats = existingUser.stats {
                    stats.health = buyResponse.health ?? stats.health
                    stats.experience = buyResponse.experience ?? stats.experience
                    stats.mana = buyResponse.mana ?? stats.mana
                    stats.level = buyResponse.level ?? stats.level
                    stats.gold = buyResponse.gold ?? stats.gold
                    stats.points = buyResponse.attributePoints ?? stats.points
                    stats.strength = buyResponse.strength ?? stats.strength
                    stats.intelligence = buyResponse.intelligence ?? stats.intelligence
                    stats.constitution = buyResponse.constitution ?? stats.constitution
                    stats.perception = buyResponse.perception ?? stats.perception
                    if let newBuffs = buyResponse.buffs {
                        let realmBuffs = RealmBuff(id: id, buff: newBuffs)
                        realm?.add(realmBuffs, update: true)
                        stats.buffs = realmBuffs
                    }
                }
                if let outfit = buyResponse.items?.gear?.equipped {
                    let realmOutfit = RealmOutfit(id: id, type: "equipped", outfit: outfit)
                    realm?.add(realmOutfit, update: true)
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
        guard let realm = getRealm() else {
            return
        }
        let ownedItem = realm.object(ofType: RealmOwnedItem.self, forPrimaryKey: "\(userID)\(key)special")
        try? realm.write {
            ownedItem?.numberOwned -= 1
        }
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
        guard let realm = getRealm() else {
            return
        }
        try? realm.write {
            if newUser.balance >= 0 {
                oldUser.balance = newUser.balance
            }
            if let newItems = newUser.items {
                realm.add(RealmUserItems(id: oldUser.id, userItems: newItems), update: true)
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
                realm.add(RealmStats(id: oldUser.id, stats: newStats), update: true)
            }
            if let newProfile = newUser.profile {
                realm.add(RealmProfile(id: oldUser.id, profile: newProfile), update: true)
            }
            if let newContributor = newUser.contributor {
                realm.add(RealmContributor(id: oldUser.id, contributor: newContributor), update: true)
            }
            if let newFlags = newUser.flags {
                realm.add(RealmFlags(id: oldUser.id, flags: newFlags), update: true)
            }
            if let newInbox = newUser.inbox {
                realm.add(RealmInbox(id: oldUser.id, inboxProtocol: newInbox), update: true)
            }
            if let newPreferences = newUser.preferences {
                realm.add(RealmPreferences(id: oldUser.id, preferences: newPreferences), update: true)
            }
            if let newPurchaseed = newUser.purchased {
                realm.add(RealmPurchased(userID: oldUser.id, protocolObject: newPurchaseed), update: true)
            }
        }
    }
}
