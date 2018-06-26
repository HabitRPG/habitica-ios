//
//  APIQuestDrop.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestDrop: QuestDropProtocol, Decodable {
    var gold: Int = 0
    var experience: Int = 0
    var unlock: String?
    var items: [QuestDropItemProtocol]
    
    enum CodingKeys: String, CodingKey {
        case gold = "gp"
        case experience = "exp"
        case unlock
        case items
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gold = (try? values.decode(Int.self, forKey: .gold)) ?? 0
        experience = (try? values.decode(Int.self, forKey: .experience)) ?? 0
        unlock = try? values.decode(String.self, forKey: .unlock)
        items = (try? values.decode([APIQuestDropItem].self, forKey: .items)) ?? []
    }
}
