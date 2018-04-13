//
//  ItemProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public enum ItemType: String {
    case egg
    case food
    case hatchingPotion
    case quest
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
        if itemType == ItemType.egg.rawValue {
            return "Pet_Egg_\(key ?? "")"
        } else if itemType == ItemType.food.rawValue {
            return "Pet_Food_\(key ?? "")"
        } else if itemType == ItemType.hatchingPotion.rawValue {
            return "Pet_HatchingPotion_\(key ?? "")"
        } else if itemType == ItemType.quest.rawValue {
            return "inventory_quest_scroll_\(key ?? "")"
        }
        return ""
    }
}
