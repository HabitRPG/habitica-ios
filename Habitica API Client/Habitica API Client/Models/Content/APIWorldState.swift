//
//  APIWorldState.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIWorldState: WorldStateProtocol, Codable {
    public var worldBoss: QuestStateProtocol?
    
    enum CodingKeys: String, CodingKey {
        case worldBoss
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        worldBoss = try? values.decode(APIQuestState.self, forKey: .worldBoss)
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
