//
//  TestStats.swift
//  Habitica ModelsTests
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
@testable import Habitica_Models

class TestStats: StatsProtocol {
    var health: Float = 0
    var maxHealth: Float = 0
    var mana: Float = 0
    var maxMana: Float = 0
    var experience: Float = 0
    var toNextLevel: Float = 0
    var level: Int = 0
    var points: Int = 0
    var habitClass: String?
    var gold: Float = 0
    var buffs: BuffProtocol?
    var strength: Int = 0
    var intelligence: Int = 0
    var constitution: Int = 0
    var perception: Int = 0
}
