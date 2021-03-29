//
//  ItemProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public enum ItemType: String, EquatableStringEnumProtocol {
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
    var isSubscriberItem: Bool { get set }
    var eventStart: Date? { get set }
    var eventEnd: Date? { get set }
}

public extension ItemProtocol {
    var imageName: String {
        if itemType == ItemType.eggs {
            return "Pet_Egg_\(key ?? "")"
        } else if itemType == ItemType.food {
            return "Pet_Food_\(key ?? "")"
        } else if itemType == ItemType.hatchingPotions {
            return "Pet_HatchingPotion_\(key ?? "")"
        } else if itemType == ItemType.quests {
            return "inventory_quest_scroll_\(key ?? "")"
        } else if itemType == ItemType.special {
            if key == "inventory_present" {
                let month = Calendar.current.component(.month, from: Date())
                return String(format: "inventory_present_%02d", month)
            } else {
                return "shop_\(key ?? "")"
            }
        }
        return ""
    }
    
    var isAvailable: Bool {
        guard let eventStart = eventStart, let eventEnd = eventEnd else {
            return true
        }
        let now = Date()
        return eventStart < now && now < eventEnd
    }
}
