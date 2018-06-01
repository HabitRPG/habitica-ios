//
//  RealmChallenge.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 24.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmChallenge: Object, ChallengeProtocol {
    var id: String?
    var name: String?
    var notes: String?
    var summary: String?
    var official: Bool = false
    var prize: Int = 0
    var shortName: String?
    var updatedAt: Date?
    var leaderID: String?
    var leaderName: String?
    var groupID: String?
    var groupName: String?
    var groupPrivacy: String?
    var memberCount: Int = 0
    var createdAt: Date?
    var categories: [ChallengeCategoryProtocol] = []
    var habits: [TaskProtocol] = []
    var dailies: [TaskProtocol] = []
    var todos: [TaskProtocol] = []
    var rewards: [TaskProtocol] = []
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["categories", "habits", "dailies", "todos", "rewards"]
    }
    
    convenience init(_ protocolObject: ChallengeProtocol) {
        self.init()
        self.id = protocolObject.id
        name = protocolObject.name
        notes = protocolObject.notes
        summary = protocolObject.summary
        official = protocolObject.official
        prize = protocolObject.prize
        shortName = protocolObject.shortName
        updatedAt = protocolObject.updatedAt
        leaderID = protocolObject.leaderID
        groupID = protocolObject.groupID
        groupName = protocolObject.groupName
        groupPrivacy = protocolObject.groupPrivacy
        memberCount = protocolObject.memberCount
        createdAt = protocolObject.createdAt
        categories = protocolObject.categories
        habits = protocolObject.habits
        dailies = protocolObject.dailies
        todos = protocolObject.todos
        rewards = protocolObject.rewards
    }
}
