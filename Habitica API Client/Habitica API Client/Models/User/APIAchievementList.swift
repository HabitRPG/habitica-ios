//
//  APIAchievementList.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

private class AchievementCategory: Decodable {
    var achievements: [String: APIAchievement] = [:]
}

public class APIAchievementList: Decodable, AchievementListProtocol {
    public var achievements: [AchievementProtocol]
    
    enum CodingKeys: String, CodingKey {
        case basic
        case seasonal
        case special
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        achievements = []
        try? values.decode(AchievementCategory.self, forKey: .basic).achievements.forEach({ (key, achievement) in
            achievement.key = key
            achievements.append(achievement)
        })
        try? values.decode(AchievementCategory.self, forKey: .seasonal).achievements.forEach({ (key, achievement) in
            achievement.key = key
            achievements.append(achievement)
        })
        try? values.decode(AchievementCategory.self, forKey: .special).achievements.forEach({ (key, achievement) in
            achievement.key = key
            achievements.append(achievement)
        })
    }
}
