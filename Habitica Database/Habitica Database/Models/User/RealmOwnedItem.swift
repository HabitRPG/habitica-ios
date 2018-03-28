//
//  RealmOwnedItem.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

@objc
class RealmOwnedItem: Object, OwnedItemProtocol {

    @objc dynamic var combinedKey: String?
    
    var key: String?
    var numberOwned: Int = 0
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init( userId: String?, itemProtocol: OwnedItemProtocol) {
        self.init()
        combinedKey = (userId ?? "") + (itemProtocol.key ?? "")
        key = itemProtocol.key
        numberOwned = itemProtocol.numberOwned
    }
}
