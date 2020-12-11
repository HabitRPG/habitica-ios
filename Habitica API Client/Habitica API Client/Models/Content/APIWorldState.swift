//
//  APIWorldState.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

private class CurrentEvent: Decodable {
    var event: String?
    var promo: String?
    var start: Date?
    var end: Date?
    
    enum CodingKeys: String, CodingKey {
        case event
        case promo
        case start
        case end
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        event = try? values.decode(String.self, forKey: .event)
        promo = try? values.decode(String.self, forKey: .promo)
        start = try? values.decode(Date.self, forKey: .start)
        end = try? values.decode(Date.self, forKey: .end)
    }
}

public class APIWorldState: WorldStateProtocol, Decodable {
    public var worldBoss: QuestStateProtocol?
    public var currentEventKey: String?
    public var currentEventPromo: String?
    public var currentEventStartDate: Date?
    public var currentEventEndDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case worldBoss
        case currentEvent
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        worldBoss = try? values.decode(APIQuestState.self, forKey: .worldBoss)
        if let event = try? values.decode(CurrentEvent.self, forKey: .currentEvent) {
            currentEventKey = event.event
            currentEventPromo = event.promo
            currentEventStartDate = event.start
            currentEventEndDate = event.end
        }
    }
}
