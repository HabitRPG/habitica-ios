//
//  RealmUserGear.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmUserGear: Object, UserGearProtocol {
    @objc dynamic var equipped: OutfitProtocol? {
        get {
            return realmEquipped
        }
        set {
            if let item = newValue as? RealmOutfit {
                realmEquipped = item
            }
            if let item = newValue {
                realmEquipped = RealmOutfit(id: id, outfit: item)
            }
        }
    }
    @objc dynamic var realmEquipped: RealmOutfit?
    @objc dynamic var costume: OutfitProtocol? {
        get {
            return realmCostume
        }
        set {
            if let item = newValue as? RealmOutfit {
                realmCostume = item
            }
            if let item = newValue {
                realmCostume = RealmOutfit(id: id, outfit: item)
            }
        }
    }
    @objc dynamic var realmCostume: RealmOutfit?
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["equipped", "costume"]
    }
    
    convenience init(id: String?, userGear: UserGearProtocol) {
        self.init()
        self.id = id
        equipped = userGear.equipped
        costume = userGear.costume
    }
}
