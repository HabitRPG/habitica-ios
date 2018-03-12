//
//  APIQuest.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuest: QuestProtocol, Codable {
    var completion: String?
    var category: String?
    var boss: QuestBossProtocol?
    var collect: [QuestCollectProtocol]?
    var key: String?
    var text: String?
    var notes: String?
    var value: Float = 0
    
    enum CodingKeys: String, CodingKey {
        case key
        case text
        case notes
        case boss
        case collect
        case value
        case completion
        case category
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try? values.decode(String.self, forKey: .key)
        text = try? values.decode(String.self, forKey: .text)
        notes = try? values.decode(String.self, forKey: .notes)
        value = (try? values.decode(Float.self, forKey: .value)) ?? 0
        boss = try? values.decode(APIQuestBoss.self, forKey: .boss)
        collect = try? values.decode([String: APIQuestCollect].self, forKey: .collect).map({ (key, questCollect) in
            questCollect.key = key
            return questCollect
        })
        completion = try? values.decode(String.self, forKey: .completion)
        category = try? values.decode(String.self, forKey: .category)
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
}
