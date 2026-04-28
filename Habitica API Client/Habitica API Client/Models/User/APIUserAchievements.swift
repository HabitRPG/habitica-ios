//
//  APIUserAchievements.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 23.06.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

struct QuestAchievement {
    let key: String
    let count: Int
}

class APIUserAchievements: UserAchievementsProtocol, Decodable {
    
    var isValid: Bool = true
    var isManaged: Bool = false
    
    var quests: [AchievementProtocol]
    var challenges: [AchievementProtocol]
    var streak: Int = 0
    var createdTask: Bool = false
    var completedTask: Bool = false
    var hatchedPet: Bool = false
    var fedPet: Bool = false
    var purchasedEquipment: Bool = false
    var rebirths: Int = 0
    var rebirthLevel: Int = 0

    enum CodingKeys: String, CodingKey {
        case quests
        case challenges
        case streak
        case createdTask
        case completedTask
        case hatchedPet
        case fedPet
        case purchasedEquipment
        case rebirths
        case rebirthLevel
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdTask = (try? values.decode(Bool.self, forKey: .createdTask)) ?? false
        completedTask = (try? values.decode(Bool.self, forKey: .completedTask)) ?? false
        hatchedPet = (try? values.decode(Bool.self, forKey: .hatchedPet)) ?? false
        fedPet = (try? values.decode(Bool.self, forKey: .fedPet)) ?? false
        purchasedEquipment = (try? values.decode(Bool.self, forKey: .purchasedEquipment)) ?? false
        streak = (try? values.decode(Int.self, forKey: .streak)) ?? 0
        rebirths = (try? values.decode(Int.self, forKey: .rebirths)) ?? 0
        rebirthLevel = (try? values.decode(Int.self, forKey: .rebirthLevel)) ?? 0
        quests = []
        challenges = []
        var combinedQuests = [QuestAchievement]()
        if let userQuests = try? values.decode([String: Int].self, forKey: .quests), !userQuests.isEmpty {
            userQuests.forEach { quest in
                combinedQuests.append(QuestAchievement(key: quest.key, count: quest.value))
            }
        }
        if let stringCodedQuests = (try? values.decode([String: String].self, forKey: .quests))?.mapValues({ stringValue in
            return Int(stringValue) ?? 0
        }), !stringCodedQuests.isEmpty {
            stringCodedQuests.forEach { quest in
                combinedQuests.append(QuestAchievement(key: quest.key, count: quest.value))
            }
        }
        
        var index = 0
        combinedQuests.forEach({ quest in
            let achievement = APIAchievement()
            achievement.key = quest.key
            achievement.earned = true
            achievement.optionalCount = quest.count
            achievement.category = "quests"
            achievement.index = index
            quests.append(achievement)
            index += 1
        })
        index = 0
        let userChallenges = try? values.decode([String].self, forKey: .challenges)
        userChallenges?.forEach({ key in
            let achievement = APIAchievement()
            achievement.key = key
            achievement.title = key
            achievement.earned = true
            achievement.category = "challenges"
            achievement.index = index
            challenges.append(achievement)
            index += 1
        })
    }
}
