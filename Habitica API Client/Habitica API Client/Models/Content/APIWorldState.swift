//
//  APIWorldState.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIWorldStateEvent: WorldStateEventProtocol, Decodable {
    public var eventKey: String?
    public var promo: String?
    public var start: Date?
    public var end: Date?
    public var npcImageSuffix: String?
    public var aprilFools: String?
    public var gear: Bool
    
    enum CodingKeys: String, CodingKey {
        case event
        case promo
        case start
        case end
        case npcImageSuffix
        case aprilFools
        case gear
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        eventKey = try? values.decode(String.self, forKey: .event)
        promo = try? values.decode(String.self, forKey: .promo)
        start = try? values.decode(Date.self, forKey: .start)
        end = try? values.decode(Date.self, forKey: .end)
        npcImageSuffix = try? values.decode(String.self, forKey: .npcImageSuffix)
        aprilFools = try? values.decode(String.self, forKey: .aprilFools)
        gear = (try? values.decode(Bool.self, forKey: .gear)) ?? false
    }
}

public class APIWorldState: WorldStateProtocol, Decodable {
    public var worldBoss: QuestStateProtocol?
    public var npcImageSuffix: String?
    public var currentEvent: WorldStateEventProtocol?
    public var events: [WorldStateEventProtocol]
    
    enum CodingKeys: String, CodingKey {
        case worldBoss
        case npcImageSuffix
        case currentEvent
        case currentEventList
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        worldBoss = try? values.decode(APIQuestState.self, forKey: .worldBoss)
        npcImageSuffix = try? values.decode(String.self, forKey: .npcImageSuffix)
        currentEvent = try? values.decode(APIWorldStateEvent.self, forKey: .currentEvent)
        events = (try? values.decode([APIWorldStateEvent].self, forKey: .currentEventList)) ?? []
    }
}
