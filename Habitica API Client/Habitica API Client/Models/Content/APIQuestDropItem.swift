//
//  APIQuestDropItems.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestDropItem: QuestDropItemProtocol, Decodable {
    var type: String?
    var key: String?
    var text: String?
    var onlyOwner: Bool = false
    var count: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case type
        case key
        case text
        case onlyOwner
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try? values.decode(String.self, forKey: .type)
        key = try? values.decode(String.self, forKey: .key)
        text = try? values.decode(String.self, forKey: .text)
        onlyOwner = (try? values.decode(Bool.self, forKey: .onlyOwner)) ?? false
    }
}
