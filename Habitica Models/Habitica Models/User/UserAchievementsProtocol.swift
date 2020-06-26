//
//  UserAchievementsProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 23.06.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol UserAchievementsProtocol: BaseModelProtocol {
    var isValid: Bool { get }
    
    var quests: [AchievementProtocol]? { get set }
    var streak: Int { get set }
    var createdTask: Bool { get set }
    var completedTask: Bool { get set }
    var hatchedPet: Bool { get set }
    var fedPet: Bool { get set }
    var purchasedEquipment: Bool { get set }

}

public extension UserAchievementsProtocol {
    var onboardingAchievements: [String: Bool] {
        return [
            "createdTask": createdTask,
            "completedTask": completedTask,
            "hatchedPet": hatchedPet,
            "fedPet": fedPet,
            "purchasedEquipment": purchasedEquipment
        ]
    }

    var hasCompletedOnboarding: Bool {
        let onboarding = onboardingAchievements
        return onboarding.filter { $0.value }.count == onboarding.count
    }
}
