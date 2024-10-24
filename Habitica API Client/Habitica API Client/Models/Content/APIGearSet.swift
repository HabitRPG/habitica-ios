//
//  APIGearSet.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.10.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIGearSet: GearSetProtocol, Codable {
    public var key: String?
    public var text: String?
    public var start: Date?
    public var end: Date?
    
    enum CodingKeys: String, CodingKey {
        case key
        case text
        case start
        case end
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try? values.decode(String.self, forKey: .key)
        text = try? values.decode(String.self, forKey: .text)
        start = try? values.decode(Date.self, forKey: .start)
        end = try? values.decode(Date.self, forKey: .end)
    }
}
