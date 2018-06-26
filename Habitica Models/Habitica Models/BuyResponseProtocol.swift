//
//  BuyResponseProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 04.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

public protocol BuyResponseProtocol {
    
    var health: Float? { get set }
    var experience: Float? { get set }
    var mana: Float? { get set }
    var level: Int? { get set }
    var gold: Float? { get set }
    
    var strength: Int? { get set }
    var intelligence: Int? { get set }
    var constitution: Int? { get set }
    var perception: Int? { get set }
    
    var buffs: BuffProtocol? { get set }
    var items: UserItemsProtocol? { get set }
    
    var attributePoints: Int? { get set }
    
    var armoire: ArmoireResponseProtocol? { get set }
}
