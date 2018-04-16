//
//  ItemsProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol UserItemsProtocol {
    var gear: UserGearProtocol? { get set }
    var currentMount: String? { get set }
    var currentPet: String? { get set }
    
    var ownedQuests: [OwnedItemProtocol] { get set }
    var ownedFood: [OwnedItemProtocol] { get set }
    var ownedHatchingPotions: [OwnedItemProtocol] { get set }
    var ownedEggs: [OwnedItemProtocol] { get set }
    
    var ownedPets: [OwnedPetProtocol] { get set }
    var ownedMounts: [OwnedMountProtocol] { get set }
}
