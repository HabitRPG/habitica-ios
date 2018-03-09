//
//  APIStats.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIStats: StatsProtocol, Codable {
    var health: Float = 0
    var maxHealth: Float = 50
    var mana: Float = 0
    var maxMana: Float = 0
    var experience: Float = 0
    var toNextLevel: Float = 0
    var level: Int = 0
    var strength: Int = 0
    var intelligence: Int = 0
    var constitution: Int = 0
    var perception: Int = 0
    var points: Int = 0
    var habitClass: String?
    var gold: Float = 0
    
    enum CodingKeys: String, CodingKey {
        case health = "hp"
        case maxHealth = "maxHealth"
        case mana = "mp"
        case maxMana = "maxMP"
        case experience = "exp"
        case toNextLevel
        case level = "lvl"
        case strength = "str"
        case intelligence = "int"
        case constitution = "con"
        case perception = "per"
        case points
        case habitClass = "class"
        case gold = "gp"
    }
}
