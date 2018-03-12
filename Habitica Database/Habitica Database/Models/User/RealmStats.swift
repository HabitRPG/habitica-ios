//
//  RealmStats.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

@objc
class RealmStats: Object, StatsProtocol {
    @objc dynamic var health: Float = 0
    @objc dynamic var maxHealth: Float = 0
    @objc dynamic var mana: Float = 0
    @objc dynamic var maxMana: Float = 0
    @objc dynamic var experience: Float = 0
    @objc dynamic var toNextLevel: Float = 0
    @objc dynamic var level: Int = 0
    @objc dynamic var strength: Int = 0
    @objc dynamic var intelligence: Int = 0
    @objc dynamic var constitution: Int = 0
    @objc dynamic var perception: Int = 0
    @objc dynamic var points: Int = 0
    @objc dynamic var habitClass: String?
    @objc dynamic var gold: Float = 0
    
    convenience init(_ stats: StatsProtocol) {
        self.init()
        health = stats.health
        maxHealth = stats.maxHealth
        mana = stats.mana
        maxMana = stats.maxMana
        experience = stats.experience
        toNextLevel = stats.toNextLevel
        level = stats.level
        strength = stats.strength
        intelligence = stats.intelligence
        constitution = stats.constitution
        perception = stats.perception
        points = stats.points
        habitClass = stats.habitClass
        gold = stats.gold
    }
}
