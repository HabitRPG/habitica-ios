//
//  RealmUserStyle.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmUserStyle: Object, UserStyleProtocol {
    @objc dynamic var id: String?
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
                realmItems = RealmUserItems(id: id, userItems: newItems)
            }
        }
    }
    @objc dynamic var realmItems: RealmUserItems?
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
                realmPreferences = RealmPreferences(id: id, preferences: newPreferences)
            }
        }
    }
    @objc dynamic var realmPreferences: RealmPreferences?
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
                realmStats = RealmStats(id: id, stats: stats)
            }
        }
    }
    @objc dynamic var realmStats: RealmStats?
    
    var isValid: Bool {
        return !isInvalidated
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["preferences", "stats", "items"]
    }
    
    convenience init(messageID: String?, userStyleProtocol: UserStyleProtocol) {
        self.init()
        id = messageID
        items = userStyleProtocol.items
        preferences = userStyleProtocol.preferences
        stats = userStyleProtocol.stats
    }
    
}
