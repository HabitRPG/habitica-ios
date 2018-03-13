//
//  RealmWorldState.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmWorldState: Object, WorldStateProtocol {
    @objc dynamic var worldBoss: QuestStateProtocol? {
        get {
            return realmWorldBoss
        }
        set {
            if let newWorldBoss = newValue as? RealmQuestState {
                realmWorldBoss = newWorldBoss
            } else if let newWorldBoss = newValue {
                realmWorldBoss = RealmQuestState(newWorldBoss)
            }
        }
    }
    @objc dynamic var realmWorldBoss: RealmQuestState?
    
    
    convenience init(_ state: WorldStateProtocol) {
        self.init()
        worldBoss = state.worldBoss
    }
    
}
