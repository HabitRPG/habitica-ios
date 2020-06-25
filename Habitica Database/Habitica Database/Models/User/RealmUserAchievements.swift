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

class RealmUserAchievements: Object, UserAchievementsProtocol {
    @objc dynamic var userID: String?

    var quests: [AchievementProtocol]?
    var streak: Int = 0
    var createdTask: Bool = false
    var completedTask: Bool = false
    var hatchedPet: Bool = false
    var fedPet: Bool = false
    var purchasedEquipment: Bool = false
    
    override static func primaryKey() -> String {
        return "userID"
    }
    
    var isValid: Bool {
        return !isInvalidated
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
    }
}
