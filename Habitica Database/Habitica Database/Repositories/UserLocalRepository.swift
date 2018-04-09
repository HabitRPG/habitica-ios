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
    
    private func mergeUsers(oldUser: UserProtocol, newUser: UserProtocol) {
        if let newItems = newUser.items {
            oldUser.items = newItems
        }
        if let newStats = newUser.stats {
            oldUser.stats = newStats
        }
        if let newProfile = newUser.profile {
            oldUser.profile = newProfile
        }
    }
}
