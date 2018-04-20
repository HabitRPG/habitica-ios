//
//  ContentProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol ContentProtocol {
    var food: [FoodProtocol]? { get set }
    var eggs: [EggProtocol]? { get set }
    var hatchingPotions: [HatchingPotionProtocol]? { get set }
    var gear: [GearProtocol]? { get set }
    var skills: [SkillProtocol]? { get set }
    var quests: [QuestProtocol]? { get set }
    var faq: [FAQEntryProtocol]? { get set }
    var pets: [PetProtocol]? { get set }
    var mounts: [MountProtocol]? { get set }
    var customizations: [CustomizationProtocol] { get set }
}
