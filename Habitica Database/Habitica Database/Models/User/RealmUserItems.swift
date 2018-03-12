//
//  RealmUserItems.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmUserItems: Object, UserItemsProtocol {
    @objc dynamic var gear: UserGearProtocol? {
        get {
            return realmGear
        }
        set {
            if let item = newValue as? RealmUserGear {
                realmGear = item
            }
            if let item = newValue {
                realmGear = RealmUserGear(item)
            }
        }
    }
    @objc dynamic var realmGear: RealmUserGear?
    @objc dynamic var currentMount: String?
    @objc dynamic var currentPet: String?
    
    override static func ignoredProperties() -> [String] {
        return ["gear"]
    }
    
    convenience init(_ userItems: UserItemsProtocol) {
        self.init()
        gear = userItems.gear
        currentMount = userItems.currentMount
        currentPet = userItems.currentPet
    }
}
