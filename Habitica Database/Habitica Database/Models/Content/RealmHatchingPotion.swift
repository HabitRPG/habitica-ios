//
//  RealmHatchingPotion.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmHatchingPotion: RealmItem, HatchingPotionProtocol {
    var premium: Bool = false
    var limited: Bool = false
    
    convenience init(_ hatchingPotion: HatchingPotionProtocol) {
        self.init(item: hatchingPotion)
        premium = hatchingPotion.premium
        limited = hatchingPotion.limited
    }
    
}
