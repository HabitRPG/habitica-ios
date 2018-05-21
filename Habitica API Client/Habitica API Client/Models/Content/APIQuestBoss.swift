//
//  APIQuestBoss.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestBoss: QuestBossProtocol, Decodable {
    var name: String?
    var health: Int = 0
    var strength: Float = 0
    var defense: Float = 0
    var rage: QuestBossRageProtocol?
    
    enum CodingKeys: String, CodingKey {
        case name
        case health = "hp"
        case strength = "str"
        case defense = "def"
        case rage
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try? values.decode(String.self, forKey: .name)
        health = (try? values.decode(Int.self, forKey: .health)) ?? 0
        strength = (try? values.decode(Float.self, forKey: .strength)) ?? 0
        defense = (try? values.decode(Float.self, forKey: .defense)) ?? 0
        rage = try? values.decode(APIQuestBossRage.self, forKey: .rage)
    }
}
