//
//  QuestDropItemProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 18.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol QuestDropItemProtocol {
    var type: String? { get set }
    var key: String? { get set }
    var text: String? { get set }
    var onlyOwner: Bool { get set }
    var count: Int { get set }
}

public extension QuestDropItemProtocol {
    var imageName: String {
        switch type {
        case "quests":
            return "inventory_quest_scroll_\(key ?? "")"
        case "eggs":
            return "pet_Egg_\(key ?? "")"
        case "food":
            return "Pet_Food_\(key ?? "")"
        case "hatchingPotions":
            return "Pet_HatchingPotion_\(key ?? "")"
        default:
            return "shop_\(key ?? "")"
        }
    }
}
