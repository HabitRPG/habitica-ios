//
//  RealmQuestBoss.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmQuestBoss: Object, QuestBossProtocol {
    @objc dynamic var key: String?
    @objc dynamic var name: String?
    @objc dynamic var health: Int = 0
    @objc dynamic var strength: Float = 0
    @objc dynamic var defense: Float = 0
    var rage: QuestBossRageProtocol? {
        get {
            return realmRage
        }
        set {
            if let newRage = newValue as? RealmQuestBossRage {
                realmRage = newRage
                return
            }
            if let newRage = newValue {
                realmRage = RealmQuestBossRage(key: key, protocolObject: newRage)
            }
        }
    }
    @objc dynamic var realmRage: RealmQuestBossRage?
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    convenience init(key: String?, questBoss: QuestBossProtocol) {
        self.init()
        self.key = key
        name = questBoss.name
        health = questBoss.health
        strength = questBoss.strength
        defense = questBoss.defense
        rage = questBoss.rage
    }
    
}
