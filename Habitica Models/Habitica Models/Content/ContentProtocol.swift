//
//  ContentProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol ContentProtocol {
    var food: [FoodProtocol]? { get set }
    var eggs: [EggProtocol]? { get set }
    var hatchingPotions: [HatchingPotionProtocol]? { get set }
    var gear: [GearProtocol]? { get set }
    var spells: [SpellProtocol]? { get set }
    var quests: [QuestProtocol]? { get set }
}
