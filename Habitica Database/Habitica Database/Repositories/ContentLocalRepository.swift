//
//  ContentLocalRepository.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

public class ContentLocalRepository: BaseLocalRepository {
    
    public func save(_ content: ContentProtocol) {
        save(objects: content.spells?.map({ (spell) in
            return RealmSpell(spell)
        }))
        save(objects: content.food?.map({ (food) in
            return RealmFood(food)
        }))
        save(objects: content.eggs?.map({ (egg) in
            return RealmEgg(egg)
        }))
        save(objects: content.hatchingPotions?.map({ (hatchingPotion) in
            return RealmHatchingPotion(hatchingPotion)
        }))
    }
    
}
