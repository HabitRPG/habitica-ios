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
    var name: String?
    var health: Int = 0
    var strength: Float = 0
    var defense: Float = 0
    
    convenience init(_ questBoss: QuestBossProtocol) {
        self.init()
        name = questBoss.name
        health = questBoss.health
        strength = questBoss.strength
        defense = questBoss.defense
    }
    
}
