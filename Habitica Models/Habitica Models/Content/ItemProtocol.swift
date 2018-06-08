//
//  ItemProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public enum ItemType: String {
    case eggs
    case food
    case hatchingPotions
    case quests
    case special
}

@objc
public protocol ItemProtocol {
    var key: String? { get set }
    var text: String? { get set }
    var notes: String? { get set }
    var value: Float { get set }
    var itemType: String? { get set }
}

public extension ItemProtocol {
    var imageName: String {
        if itemType == ItemType.eggs.rawValue {
            return "Pet_Egg_\(key ?? "")"
        } else if itemType == ItemType.food.rawValue {
            return "Pet_Food_\(key ?? "")"
        } else if itemType == ItemType.hatchingPotions.rawValue {
            return "Pet_HatchingPotion_\(key ?? "")"
        } else if itemType == ItemType.quests.rawValue {
            return "inventory_quest_scroll_\(key ?? "")"
        }
        return ""
    }
}
