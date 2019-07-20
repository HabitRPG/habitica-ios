//
//  HabiticaResponse.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class HabiticaResponse<T: Decodable>: Decodable {
    public var success: Bool = false
    public var data: T?
    
    public var error: String?
    public var message: String?
    public var userV: Int?
    public var notifications: [NotificationProtocol]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case data
        case error
        case message
        case userV
        case notifications
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = (try? values.decode(Bool.self, forKey: .success)) ?? true
        data = try? values.decode(T.self, forKey: .data)
        error = try? values.decode(String.self, forKey: .error)
        message = try? values.decode(String.self, forKey: .message)
        userV = (try? values.decode(Int.self, forKey: .userV)) ?? 0
        notifications = try? values.decode([APINotification].self, forKey: .notifications)
    }
}
