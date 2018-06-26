//
//  RealmFood.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmFood: RealmItem, FoodProtocol {
    @objc dynamic var target: String?
    @objc dynamic var canDrop: Bool = false
    
    convenience init(_ food: FoodProtocol) {
        self.init(item: food)
        target = food.target
        canDrop = food.canDrop
        itemType = ItemType.food.rawValue
    }
    
}
