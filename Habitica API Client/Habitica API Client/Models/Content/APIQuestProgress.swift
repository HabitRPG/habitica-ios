//
//  File.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestProgress: QuestProgressProtocol, Codable {
    var health: Float = 0
    var rage: Float = 0
    var up: Float = 0
    
    enum CodingKeys: String, CodingKey {
        case health = "hp"
        case rage
        case up
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        health = (try? values.decode(Float.self, forKey: .health)) ?? 0
        rage = (try? values.decode(Float.self, forKey: .rage)) ?? 0
        up = (try? values.decode(Float.self, forKey: .up)) ?? 0
    }
}
