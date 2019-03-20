//
//  APIGroup.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 29.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

private struct LeaderObject: Decodable {
    var id: String?
}

public class APIGroup: GroupProtocol, Codable {
    public var id: String?
    public var name: String?
    public var groupDescription: String?
    public var summary: String?
    public var type: String?
    public var memberCount: Int = 0
    public var privacy: String?
    public var balance: Float = 0
    public var leaderID: String?
    public var leaderOnlyChallenges: Bool = false
    public var quest: QuestStateProtocol?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case groupDescription = "description"
        case summary
        case type
        case memberCount
        case privacy
        case balance
        case leader
        case leaderOnlyChallenges = "leaderOnly"
        case quest
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String.self, forKey: .id)
        name = try? values.decode(String.self, forKey: .name)
        groupDescription = try? values.decode(String.self, forKey: .groupDescription)
        summary = try? values.decode(String.self, forKey: .summary)
        type = try? values.decode(String.self, forKey: .type)
        memberCount = (try? values.decode(Int.self, forKey: .memberCount)) ?? 0
        privacy = try? values.decode(String.self, forKey: .privacy)
        balance = (try? values.decode(Float.self, forKey: .balance)) ?? 0
        leaderID = try? values.decode(String.self, forKey: .leader)
        if leaderID == nil {
            let leader = try? values.decode(LeaderObject.self, forKey: .leader)
            leaderID = leader?.id
        }
        leaderOnlyChallenges = (try? values.decode([String: Bool].self, forKey: .leaderOnlyChallenges).first(where: { (key, _) -> Bool in
            return key == "challenges"
        })?.value == true) ?? false
        quest = try? values.decode(APIQuestState.self, forKey: .quest)
    }
    
    public init(_ group: GroupProtocol) {
        id = group.id
        name = group.name
        groupDescription = group.groupDescription
        summary = group.summary
        privacy = group.privacy
        type = group.type
        leaderID = group.leaderID
        leaderOnlyChallenges = group.leaderOnlyChallenges
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(name, forKey: .name)
        try? container.encode(groupDescription, forKey: .groupDescription)
        try? container.encode(summary, forKey: .summary)
        try? container.encode(privacy, forKey: .privacy)
        try? container.encode(type, forKey: .type)
        if let leaderID = self.leaderID {
            try? container.encode(leaderID, forKey: .leader)
        }
        try? container.encode(["challenges": leaderOnlyChallenges], forKey: .leaderOnlyChallenges)
    }
}
