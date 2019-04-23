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
    dynamic var id: String?
    dynamic var name: String?
    dynamic var notes: String?
    dynamic var summary: String?
    dynamic var official: Bool = false
    dynamic var prize: Int = 0
    dynamic var shortName: String?
    dynamic var updatedAt: Date?
    dynamic var leaderID: String?
    dynamic var leaderName: String?
    dynamic var groupID: String?
    dynamic var groupName: String?
    dynamic var groupPrivacy: String?
    dynamic var memberCount: Int = 0
    dynamic var createdAt: Date?
    dynamic var categories: [ChallengeCategoryProtocol] {
        get {
            return realmCategories.map({ (ownedCustomization) -> ChallengeCategoryProtocol in
                return ownedCustomization
            })
        }
        set {
            realmCategories.removeAll()
            newValue.forEach { (category) in
                if let realmCategory = category as? RealmChallengeCategory {
                    realmCategories.append(realmCategory)
                } else {
                    realmCategories.append(RealmChallengeCategory(category))
                }
            }
        }
    }
    var realmCategories = List<RealmChallengeCategory>()
    var tasksOrder: [String: [String]] = [:]
    var habits: [TaskProtocol] {
        let predicate = NSPredicate(format: "ownerID == %@ && type == 'habit'", id ?? "")
        return (try? Realm().objects(RealmTask.self).filter(predicate).map({ (task) -> TaskProtocol in
            return task
        })) ?? []
    }
    var dailies: [TaskProtocol] {
        return (try? Realm().objects(RealmTask.self).filter("ownerID == %@ && type == 'daily'", id ?? "").map({ (task) -> TaskProtocol in
            return task
        })) ?? []
    }
    var todos: [TaskProtocol] {
        return (try? Realm().objects(RealmTask.self).filter("ownerID == %@ && type == 'todo'", id ?? "").map({ (task) -> TaskProtocol in
            return task
        })) ?? []
    }
    var rewards: [TaskProtocol] {
        return (try? Realm().objects(RealmTask.self).filter("ownerID == %@ && type == 'reward'", id ?? "").map({ (task) -> TaskProtocol in
            return task
        })) ?? []
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["categories", "habits", "dailies", "todos", "rewards", "tasksOrder"]
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
    }
}
