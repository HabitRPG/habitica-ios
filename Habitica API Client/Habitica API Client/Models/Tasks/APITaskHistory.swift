//
//  APITaskHistory.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APITaskHistory: Decodable, TaskHistoryProtocol {
    var taskID: String?
    var timestamp: Date?
    var value: Float = 0
    var scoredUp: Bool = false
    var scoredDown: Bool = false
    var isValid: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case date
        case value
        case scoredUp
        case scoredDown
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = Date(timeIntervalSince1970: ((try? values.decode(Double.self, forKey: .date)) ?? 0)/1000)
        value = (try? values.decode(Float.self, forKey: .value)) ?? 0
        scoredUp = (try? values.decode(Bool.self, forKey: .scoredUp)) ?? false
        scoredDown = (try? values.decode(Bool.self, forKey: .scoredDown)) ?? false
    }
}
