//
//  AchievementProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol AchievementProtocol {
    var key: String? { get set }
    var title: String? { get set }
    var text: String? { get set }
    var icon: String? { get set }
    var category: String? { get set }
    var earned: Bool { get set }
    var index: Int { get set }
    var optionalCount: Int { get set }
}

public extension AchievementProtocol {
    var isQuestAchievement: Bool {
        return category == "quests"
    }
}
