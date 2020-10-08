//
//  APIUserParty.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 01.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIUserParty: UserPartyProtocol, Decodable {
    var id: String?
    var order: String?
    var orderAscending: Bool = false
    var quest: QuestStateProtocol?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case otherId = "id"
        case order
        case orderAscending
        case quest
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String.self, forKey: .id)
        if id == nil && id?.isEmpty == true {
            id = try? values.decode(String.self, forKey: .otherId)
        }
        order = try? values.decode(String.self, forKey: .order)
        orderAscending = (try? values.decode(Bool.self, forKey: .orderAscending)) ?? false
        quest = try? values.decode(APIQuestState.self, forKey: .quest)
    }
}
