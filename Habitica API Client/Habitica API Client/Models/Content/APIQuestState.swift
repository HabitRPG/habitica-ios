//
//  APIQuestState.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

public class APIQuestState: QuestStateProtocol, Codable {
    public var rsvpNeeded: Bool
    public var completed: String?
    public var active: Bool = false
    public var key: String?
    public var progress: QuestProgressProtocol?
    public var leaderID: String?
    public var members: [QuestParticipantProtocol]
    
    enum CodingKeys: String, CodingKey {
        case active
        case key
        case progress
        case rsvpNeeded = "RSVPNeeded"
        case completed
        case leaderID = "leader"
        case members
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        active = (try? values.decode(Bool.self, forKey: .active)) ?? false
        key = try? values.decode(String.self, forKey: .key)
        progress = try? values.decode(APIQuestProgress.self, forKey: .progress)
        rsvpNeeded = (try? values.decode(Bool.self, forKey: .rsvpNeeded)) ?? false
        completed = try? values.decode(String.self, forKey: .completed)
        leaderID = try? values.decode(String.self, forKey: .leaderID)
        members = (try? values.decode([String: Bool?].self, forKey: .members).map({ value -> QuestParticipantProtocol in
            return APIQuestParticipant(userID: value.key, response: value.value)
        })) ?? []
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
