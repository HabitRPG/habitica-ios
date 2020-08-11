//
//  APIBacker.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIBacker: BackerProtocol, Codable {
    var tier: Int = 0
    var npc: String?
    
    enum CodingKeys: String, CodingKey {
        case tier
        case npc
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tier = (try? values.decode(Int.self, forKey: .tier)) ?? 0
        npc = (try? values.decode(String.self, forKey: .npc))
    }

}
