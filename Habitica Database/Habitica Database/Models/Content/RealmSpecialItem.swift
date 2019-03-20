//
//  RealmSpecialItem.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 08.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmSpecialItem: RealmItem, SpecialItemProtocol {
    var target: String?
    var immediateUse: Bool = false
    var silent: Bool = false
    
    convenience init(_ specialItem: SpecialItemProtocol) {
        self.init(item: specialItem)
        target = specialItem.target
        immediateUse = specialItem.immediateUse
        silent = specialItem.silent
        itemType = ItemType.special.rawValue
    }
    
}
