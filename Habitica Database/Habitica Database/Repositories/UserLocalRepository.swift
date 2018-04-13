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
        RealmUser.findBy(key: userId).take(first: 1).on(value: {user in
            try? self.getRealm()?.write {
                user?.stats = stats
            }
        }).start()
    }
    
    public func getUser(_ id: String) -> SignalProducer<UserProtocol, ReactiveSwiftRealmError> {
        return RealmUser.findBy(query: "id == '\(id)'").reactive().map({ (users, changes) -> UserProtocol? in
            return users.first
        }).skipNil()
    }
    
    public func hasUserData(id: String) -> Bool {
        return getRealm()?.object(ofType: RealmUser.self, forPrimaryKey: id) != nil
    }
    
    public func save(_ skillResponse: SkillResponseProtocol) {
        let tags = getRealm()?.objects(RealmTag.self)
        if let task = skillResponse.task {
            save(object: RealmTask(task, tags: tags))
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
    
    private func mergeUsers(oldUser: UserProtocol, newUser: UserProtocol) {
        guard let realm = getRealm() else {
            return
        }
        try? realm.write {
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
                realm.add(RealmFlags(id: oldUser.id, flags: newFlags))
            }
            if let newInbox = newUser.inbox {
                realm.add(RealmInbox(id: oldUser.id, inboxProtocol: newInbox))
            }
        }
    }
}
