//
//  WorldState.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol WorldStateProtocol: BaseModelProtocol {
    var worldBoss: QuestStateProtocol? { get set }
    var npcImageSuffix: String? { get set }
    var currentEvent: WorldStateEventProtocol? { get set }
    var events: [WorldStateEventProtocol] { get set }
}

public extension WorldStateProtocol {
    
    var seasonalShopEvent: WorldStateEventProtocol? {
        for event in events where event.gear || event.season != nil {
            return event
        }
        return nil
    }
    
    var isSeasonalShopOpen: Bool {
        return true
    }
    
    var currentSeason: String? {
        return seasonalShopEvent?.season
    }
}

@objc
public protocol WorldStateEventProtocol {
    var eventKey: String? { get set }
    var start: Date? { get set }
    var end: Date? { get set }
    var promo: String? { get set }
    var npcImageSuffix: String? { get set }
    var aprilFools: String? { get set }
    var gear: Bool { get set }
    var season: String? { get set }
}
