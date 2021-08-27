//
//  APILoginIncentiveData.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 28.07.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APILoginIncentiveData: Decodable {
    var message: String?
    var rewardKey: [String]
    var rewardText: String?
    var nextRewardAt: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case message
        case rewardKey
        case rewardText
        case nextRewardAt
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try? values.decode(String.self, forKey: .message)
        rewardKey = (try? values.decode([String].self, forKey: .rewardKey)) ?? []
        rewardText = try? values.decode(String.self, forKey: .rewardText)
        nextRewardAt = (try? values.decode(Int.self, forKey: .nextRewardAt)) ?? 0
    }
}
