//
//  RealmUser.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

@objc
class RealmUser: Object, UserProtocol {

    
    @objc dynamic var id: String?
    @objc dynamic var balance: Float = 0
    var tasksOrder: [String: [String]] = [:]
    var stats: StatsProtocol? {
        get {
            return realmStats
        }
        set {
            if let newStats = newValue as? RealmStats {
                realmStats = newStats
                return
            }
            if let stats = newValue {
                realmStats = RealmStats(stats)
            }
        }
    }
    @objc dynamic var realmStats: RealmStats?
    
    var flags: FlagsProtocol? {
        get {
            return realmFlags
        }
        set {
            if let newFlags = newValue as? RealmFlags {
                realmFlags = newFlags
                return
            }
            if let newFlags = newValue {
                realmFlags = RealmFlags(newFlags)
            }
        }
    }
    @objc dynamic var realmFlags: RealmFlags?
    
    var preferences: PreferencesProtocol? {
        get {
            return realmPreferences
        }
        set {
            if let newPreferences = newValue as? RealmPreferences {
                realmPreferences = newPreferences
                return
            }
            if let newPreferences = newValue {
                realmPreferences = RealmPreferences(newPreferences)
            }
        }
    }
    @objc dynamic var realmPreferences: RealmPreferences?
    
    var profile: ProfileProtocol? {
        get {
            return realmProfile
        }
        set {
            if let newProfile = newValue as? RealmProfile {
                realmProfile = newProfile
                return
            }
            if let profile = newValue {
                realmProfile = RealmProfile(profile)
            }
        }
    }
    @objc dynamic var realmProfile: RealmProfile?
    
    var contributor: ContributorProtocol? {
        get {
            return realmContributor
        }
        set {
            if let newContributor = newValue as? RealmContributor {
                realmContributor = newContributor
                return
            }
            if let newContributor = newValue {
                realmContributor = RealmContributor(newContributor)
            }
        }
    }
    @objc dynamic var realmContributor: RealmContributor?
    var items: UserItemsProtocol? {
        get {
            return realmItems
        }
        set {
            if let newItems = newValue as? RealmUserItems {
                realmItems = newItems
                return
            }
            if let newItems = newValue {
                realmItems = RealmUserItems(newItems)
            }
        }
    }
    @objc dynamic var realmItems: RealmUserItems?
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["flags", "preferences", "stats", "profile", "contributor", "tasksOrder", "items"]
    }
    
    convenience init(_ user: UserProtocol) {
        self.init()
        id = user.id
        stats = user.stats
        flags = user.flags
        preferences = user.preferences
        profile = user.profile
        contributor = user.contributor
        balance = user.balance
        items = user.items
    }
}
