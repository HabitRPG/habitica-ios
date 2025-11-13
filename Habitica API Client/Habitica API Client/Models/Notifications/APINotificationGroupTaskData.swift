//
//  APINotificationGroupTaskData.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import Foundation
import Habitica_Models

class APINotificationGroupTaskData: Decodable {
    var message: String?
    var groupId: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case groupId
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try? values.decode(String.self, forKey: .message)
        groupId = try? values.decode(String.self, forKey: .groupId)
    }
}
