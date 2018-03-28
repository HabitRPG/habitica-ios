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
                realmGear = RealmUserGear(id: id, userGear: item)
            }
        }
    }
    @objc dynamic var realmGear: RealmUserGear?
    @objc dynamic var currentMount: String?
    @objc dynamic var currentPet: String?
    
    var ownedQuests: [OwnedItemProtocol] {
        get {
            return realmOwnedQuests.map({ (quest) -> OwnedItemProtocol in
                return quest
            })
        }
        set {
            realmOwnedQuests.removeAll()
            newValue.forEach { (ownedItem) in
                if let realmOwnedQuest = ownedItem as? RealmOwnedItem {
                    realmOwnedQuests.append(realmOwnedQuest)
                } else {
                    realmOwnedQuests.append(RealmOwnedItem(userId: id, itemProtocol: ownedItem))
                }
            }
        }
    }
    var realmOwnedQuests = List<RealmOwnedItem>()
    
    var ownedFood: [OwnedItemProtocol] {
        get {
            return realmOwnedFood.map({ (quest) -> OwnedItemProtocol in
                return quest
            })
        }
        set {
            realmOwnedFood.removeAll()
            newValue.forEach { (ownedItem) in
                if let realmOwnedItem = ownedItem as? RealmOwnedItem {
                    realmOwnedFood.append(realmOwnedItem)
                } else {
                    realmOwnedFood.append(RealmOwnedItem(userId: id, itemProtocol: ownedItem))
                }
            }
        }
    }
    var realmOwnedFood = List<RealmOwnedItem>()
    
    var ownedHatchingPotions: [OwnedItemProtocol] {
        get {
            return realmOwnedHatchingPotions.map({ (quest) -> OwnedItemProtocol in
                return quest
            })
        }
        set {
            realmOwnedHatchingPotions.removeAll()
            newValue.forEach { (ownedItem) in
                if let realmOwnedItem = ownedItem as? RealmOwnedItem {
                    realmOwnedHatchingPotions.append(realmOwnedItem)
                } else {
                    realmOwnedHatchingPotions.append(RealmOwnedItem(userId: id, itemProtocol: ownedItem))
                }
            }
        }
    }
    var realmOwnedHatchingPotions = List<RealmOwnedItem>()
    
    var ownedEggs: [OwnedItemProtocol] {
        get {
            return realmOwnedEggs.map({ (quest) -> OwnedItemProtocol in
                return quest
            })
        }
        set {
            realmOwnedEggs.removeAll()
            newValue.forEach { (ownedItem) in
                if let realmOwnedItem = ownedItem as? RealmOwnedItem {
                    realmOwnedEggs.append(realmOwnedItem)
                } else {
                    realmOwnedEggs.append(RealmOwnedItem(userId: id, itemProtocol: ownedItem))
                }
            }
        }
    }
    var realmOwnedEggs = List<RealmOwnedItem>()
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["gear", "ownedQuests", "ownedFood", "ownedHatchingPotions", "ownedEggs"]
    }
    
    convenience init(id: String?, userItems: UserItemsProtocol) {
        self.init()
        self.id = id
        gear = userItems.gear
        currentMount = userItems.currentMount
        currentPet = userItems.currentPet
        ownedQuests = userItems.ownedQuests
        ownedFood = userItems.ownedFood
        ownedHatchingPotions = userItems.ownedHatchingPotions
        ownedEggs = userItems.ownedEggs
    }
}
