//
//  APINotificationCardReceivedData.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 17.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import Foundation

class CardReceivedSenderData: Decodable {
    var id: String
    var name: String
}

class APINotificationCardReceivedData: Decodable {
    var card: String?
    var sender: CardReceivedSenderData?
    
    enum CodingKeys: String, CodingKey {
        case card
        case from
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        card = try? values.decode(String.self, forKey: .card)
        sender = try? values.decode(CardReceivedSenderData.self, forKey: .from)
    }
}
