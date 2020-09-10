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
    var start: Date?
    var end: Date?
}

public class APIWorldState: WorldStateProtocol, Codable {
    public var worldBoss: QuestStateProtocol?
    public var currentEventKey: String?
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
            currentEventStartDate = event.start
            currentEventEndDate = event.end
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
