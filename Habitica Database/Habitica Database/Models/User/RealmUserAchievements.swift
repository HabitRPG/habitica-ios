//
//  RealmUserAchievements.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 23.06.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmUserAchievements: BaseModel, UserAchievementsProtocol {
    @objc dynamic var userID: String?

    var quests: [AchievementProtocol] {
        get {
            return realmQuests.map({ (achievement) -> RealmAchievement in
                return achievement
            })
        }
        set {
            realmQuests.removeAll()
            newValue.forEach { (achievement) in
                if let realmAchievement = achievement as? RealmAchievement {
                    realmQuests.append(realmAchievement)
                } else {
                    realmQuests.append(RealmAchievement(userID: userID, protocolObject: achievement))
                }
            }
        }
    }
    var realmQuests = List<RealmAchievement>()
    var challenges: [AchievementProtocol] {
        get {
            return realmChallenges.map({ (achievement) -> RealmAchievement in
                return achievement
            })
        }
        set {
            realmChallenges.removeAll()
            newValue.forEach { (achievement) in
                if let realmAchievement = achievement as? RealmAchievement {
                    realmChallenges.append(realmAchievement)
                } else {
                    realmChallenges.append(RealmAchievement(userID: userID, protocolObject: achievement))
                }
            }
        }
    }
    var realmChallenges = List<RealmAchievement>()
    var streak: Int = 0
    var createdTask: Bool = false
    var completedTask: Bool = false
    var hatchedPet: Bool = false
    var fedPet: Bool = false
    var purchasedEquipment: Bool = false
    
    override static func primaryKey() -> String {
        return "userID"
    }

    override static func ignoredProperties() -> [String] {
        return ["quests"]
    }
    
    convenience init(userID: String?, protocolObject: UserAchievementsProtocol) {
        self.init()
        self.userID = userID
        createdTask = protocolObject.createdTask
        completedTask = protocolObject.completedTask
        hatchedPet = protocolObject.hatchedPet
        fedPet = protocolObject.fedPet
        purchasedEquipment = protocolObject.purchasedEquipment
        streak = protocolObject.streak
        quests = protocolObject.quests
        challenges = protocolObject.challenges
    }
}
