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
            } else if let item = newValue {
                realmEquipped = RealmOutfit(id: id, type: "equipped", outfit: item)
            } else {
                realmEquipped = nil
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
            } else if let item = newValue {
                realmCostume = RealmOutfit(id: id, type: "costume", outfit: item)
            } else {
                realmCostume = nil
            }
        }
    }
    @objc dynamic var realmCostume: RealmOutfit?
    
    var owned: [OwnedGearProtocol] {
        get {
            return realmOwned.map({ (quest) -> OwnedGearProtocol in
                return quest
            })
        }
        set {
            realmOwned.removeAll()
            newValue.forEach { (ownedGear) in
                if let realmOwnedGear = ownedGear as? RealmOwnedGear {
                    realmOwned.append(realmOwnedGear)
                } else {
                    realmOwned.append(RealmOwnedGear(userID: id, gearProtocol: ownedGear))
                }
            }
        }
    }
    var realmOwned = List<RealmOwnedGear>()
    
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
        owned = userGear.owned
    }
}
