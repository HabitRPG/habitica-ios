//
//  APIQuestBoss.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestBoss: QuestBossProtocol, Codable {
    var name: String?
    var health: Int = 0
    var strength: Float = 0
    var defense: Float = 0
    
    enum CodingKeys: String, CodingKey {
        case name
        case health = "hp"
        case strength = "str"
        case defense = "def"
    }
}
