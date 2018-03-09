//
//  StatsProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol StatsProtocol {
    var health: Float { get set }
    var maxHealth: Float { get set }
    var mana: Float { get set }
    var maxMana: Float { get set }
    var experience: Float { get set }
    var toNextLevel: Float { get set }
    var level: Int { get set }
    var strength: Int { get set }
    var intelligence: Int { get set }
    var constitution: Int { get set }
    var perception: Int { get set }
    var points: Int { get set }
    var habitClass: String? { get set }
    var gold: Float { get set }
}
