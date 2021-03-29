//
//  APISpecialItem.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 08.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class APISpecialItem: SpecialItemProtocol, Decodable {
    var isSubscriberItem: Bool = false
    var key: String?
    var text: String?
    var notes: String?
    var value: Float = 0
    var itemType: String?
    var target: String?
    var immediateUse: Bool = false
    var silent: Bool = false
    var eventStart: Date?
    var eventEnd: Date?
    
    enum CodingKeys: String, CodingKey {
        case key
        case text
        case notes
        case value
        case target
        case immediateUse
        case silent
        case event
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try? values.decode(String.self, forKey: .key)
        text = try? values.decode(String.self, forKey: .text)
        notes = try? values.decode(String.self, forKey: .notes)
        value = (try? values.decode(Float.self, forKey: .key)) ?? 0
        target = try? values.decode(String.self, forKey: .target)
        immediateUse = (try? values.decode(Bool.self, forKey: .immediateUse)) ?? false
        silent = (try? values.decode(Bool.self, forKey: .silent)) ?? false
        itemType = ItemType.special.rawValue
        let event = try? values.decode(APIEvent.self, forKey: .event)
        eventStart = event?.start
        eventEnd = event?.end
    }
}
