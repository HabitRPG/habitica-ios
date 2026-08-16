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
    let profile: [String: String]?
    let id: String

    enum CodingKeys: String, CodingKey {
        case profile
        case id
        case underscoreID = "_id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        profile = try? values.decode([String: String].self, forKey: .profile)
        id = try values.decodeIdentifier(primary: .id, fallback: .underscoreID)
    }
}

private struct GroupHelper: Decodable {
    let name: String?
    let id: String
    let privacy: String?

    enum CodingKeys: String, CodingKey {
        case name
        case id
        case underscoreID = "_id"
        case privacy
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try? values.decode(String.self, forKey: .name)
        privacy = try? values.decode(String.self, forKey: .privacy)
        id = try values.decodeIdentifier(primary: .id, fallback: .underscoreID)
    }
}

private extension KeyedDecodingContainer {
    func decodeIdentifier(primary: K, fallback: K) throws -> String {
        if let value = try? decode(String.self, forKey: primary) {
            return value
        }
        return try decode(String.self, forKey: fallback)
    }
}

public class APIChallenge: ChallengeProtocol, Codable {
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
    public var groupID: String?
    public var groupName: String?
    public var groupPrivacy: String?
    public var memberCount: Int = 0
    public var createdAt: Date?
    public var categories: [ChallengeCategoryProtocol]
    public var tasksOrder: [String: [String]]
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
        case group
        case memberCount
        case categories
        case tasksOrder
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
            leaderName = leader.profile?["name"]
        }
        if let group = try? values.decode(GroupHelper.self, forKey: .group) {
            groupID = group.id
            groupName = group.name
            groupPrivacy = group.privacy
        }
        createdAt = try? values.decode(Date.self, forKey: .createdAt)
        memberCount = (try? values.decode(Int.self, forKey: .memberCount)) ?? 0
        categories = (try? values.decode([APIChallengeCategory].self, forKey: .categories)) ?? []
        tasksOrder = (try? values.decode([String: [String]].self, forKey: .tasksOrder)) ?? [:]
    }
    
    public init(_ challenge: ChallengeProtocol) {
        id = challenge.id
        name = challenge.name
        shortName = challenge.shortName
        summary = challenge.summary
        notes = challenge.notes
        categories = challenge.categories
        prize = challenge.prize
        tasksOrder = challenge.tasksOrder
        official = challenge.official
        groupID = challenge.groupID
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(name, forKey: .name)
        try? container.encode(shortName, forKey: .shortName)
        try? container.encode(summary, forKey: .summary)
        try? container.encode(notes, forKey: .notes)
        try? container.encode(prize, forKey: .prize)
        try? container.encode(groupID, forKey: .group)
        try? container.encode(tasksOrder, forKey: .tasksOrder)
        try? container.encode(categories.map({ category in
            let api = APIChallengeCategory()
            api.slug = category.slug
            api.name = category.name ?? category.slug
            return api
        }), forKey: .categories)
        if let leaderID = self.leaderID {
            try? container.encode(leaderID, forKey: .leader)
        }
    }
}
