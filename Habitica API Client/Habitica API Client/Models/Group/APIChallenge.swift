//
//  APIChallenge.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

private struct LeaderHelper: Decodable {
    let profile: [String: String]
    let id: String
}

public class APIChallenge: ChallengeProtocol, Decodable {
    public var id: String?
    public var name: String?
    public var notes: String?
    public var summary: String?
    public var official: Bool
    public var prize: Int = 0
    public var shortName: String?
    public var updatedAt: Date?
    public var leaderID: String?
    public var leaderName: String?
    public var memberCount: Int = 0
    public var createdAt: Date?
    public var categories: [ChallengeCategoryProtocol]
    public var habits: [TaskProtocol] = []
    public var dailies: [TaskProtocol] = []
    public var todos: [TaskProtocol] = []
    public var rewards: [TaskProtocol] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case notes = "description"
        case summary
        case official
        case prize
        case shortName
        case updatedAt
        case createdAt
        case leader
        case memberCount
        case categories
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(String.self, forKey: .id)
        name = try? values.decode(String.self, forKey: .name)
        notes = try? values.decode(String.self, forKey: .notes)
        summary = try? values.decode(String.self, forKey: .summary)
        official = (try? values.decode(Bool.self, forKey: .official)) ?? false
        prize = (try? values.decode(Int.self, forKey: .prize)) ?? 0
        shortName = try? values.decode(String.self, forKey: .shortName)
        updatedAt = try? values.decode(Date.self, forKey: .updatedAt)
        if let leader = try? values.decode(LeaderHelper.self, forKey: .leader) {
            leaderID = leader.id
            leaderName = leader.profile["name"]
        }
        createdAt = try? values.decode(Date.self, forKey: .createdAt)
        memberCount = (try? values.decode(Int.self, forKey: .memberCount)) ?? 0
        categories = (try? values.decode([APIChallengeCategory].self, forKey: .categories)) ?? []
    }
}
