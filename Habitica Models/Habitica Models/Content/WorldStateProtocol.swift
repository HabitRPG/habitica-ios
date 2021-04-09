//
//  WorldState.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol WorldStateProtocol {
    var worldBoss: QuestStateProtocol? { get set }
    var npcImageSuffix: String? { get set }
    var currentEvent: WorldStateEventProtocol? { get set }
    var events: [WorldStateEventProtocol] { get set }
}

public extension WorldStateProtocol {
    
    var seasonalShopEvent: WorldStateEventProtocol? {
        for event in events where event.gear {
            return event
        }
        return nil
    }
    
    var isSeasonalShopOpen: Bool {
        if let end = seasonalShopEvent?.end {
            return end > Date()
        }
        return false
    }
}

public protocol WorldStateEventProtocol {
    var eventKey: String? { get set }
    var start: Date? { get set }
    var end: Date? { get set }
    var promo: String? { get set }
    var npcImageSuffix: String? { get set }
    var aprilFools: String? { get set }
    var gear: Bool { get set }
}
