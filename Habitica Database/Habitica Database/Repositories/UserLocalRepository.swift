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
}
