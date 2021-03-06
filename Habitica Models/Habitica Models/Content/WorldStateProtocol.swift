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

public protocol WorldStateEventProtocol {
    var eventKey: String? { get set }
    var start: Date? { get set }
    var end: Date? { get set }
    var promo: String? { get set }
    var npcImageSuffix: String? { get set }
}
