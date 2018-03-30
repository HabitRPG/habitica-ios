//
//  APIQuestState.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APIQuestState: QuestStateProtocol, Codable {
    var active: Bool = false
    var key: String?
    var progress: QuestProgressProtocol?
    
    enum CodingKeys: String, CodingKey {
        case active
        case key
        case progress
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        active = (try? values.decode(Bool.self, forKey: .active)) ?? false
        key = try? values.decode(String.self, forKey: .key)
        progress = try? values.decode(APIQuestProgress.self, forKey: .progress)
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
