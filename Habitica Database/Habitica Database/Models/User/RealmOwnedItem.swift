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
    
    @objc dynamic var key: String?
    @objc dynamic var userID: String?
    @objc dynamic var numberOwned: Int = 0
    @objc dynamic var itemType: String?
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init( userID: String?, itemProtocol: OwnedItemProtocol) {
        self.init()
        combinedKey = (userID ?? "") + (itemProtocol.key ?? "") + (itemProtocol.itemType ?? "")
        self.userID = userID
        key = itemProtocol.key
        numberOwned = itemProtocol.numberOwned
        itemType = itemProtocol.itemType
    }
}
