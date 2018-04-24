//
//  RealmPurchased.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 23.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmPurchased: Object, PurchasedProtocol {
    var hair: [OwnedCustomizationProtocol] {
        get {
            return realmHair.map({ (ownedCustomization) -> OwnedCustomizationProtocol in
                return ownedCustomization
            })
        }
        set {
            realmHair.removeAll()
            newValue.forEach { (ownedCustomization) in
                if let realmCustomization = ownedCustomization as? RealmOwnedCustomization {
                    realmHair.append(realmCustomization)
                } else {
                    realmHair.append(RealmOwnedCustomization(ownedCustomization))
                }
            }
        }
    }
    var realmHair = List<RealmOwnedCustomization>()
    var skin: [OwnedCustomizationProtocol] {
        get {
            return realmSkin.map({ (ownedCustomization) -> OwnedCustomizationProtocol in
                return ownedCustomization
            })
        }
        set {
            realmSkin.removeAll()
            newValue.forEach { (ownedCustomization) in
                if let realmCustomization = ownedCustomization as? RealmOwnedCustomization {
                    realmSkin.append(realmCustomization)
                } else {
                    realmSkin.append(RealmOwnedCustomization(ownedCustomization))
                }
            }
        }
    }
    var realmSkin = List<RealmOwnedCustomization>()
    var shirt: [OwnedCustomizationProtocol] {
        get {
            return realmShirt.map({ (ownedCustomization) -> OwnedCustomizationProtocol in
                return ownedCustomization
            })
        }
        set {
            realmShirt.removeAll()
            newValue.forEach { (ownedCustomization) in
                if let realmCustomization = ownedCustomization as? RealmOwnedCustomization {
                    realmShirt.append(realmCustomization)
                } else {
                    realmShirt.append(RealmOwnedCustomization(ownedCustomization))
                }
            }
        }
    }
    var realmShirt = List<RealmOwnedCustomization>()
    var background: [OwnedCustomizationProtocol] {
        get {
            return realmBackground.map({ (ownedCustomization) -> OwnedCustomizationProtocol in
                return ownedCustomization
            })
        }
        set {
            realmBackground.removeAll()
            newValue.forEach { (ownedCustomization) in
                if let realmCustomization = ownedCustomization as? RealmOwnedCustomization {
                    realmBackground.append(realmCustomization)
                } else {
                    realmBackground.append(RealmOwnedCustomization(ownedCustomization))
                }
            }
        }
    }
    var realmBackground = List<RealmOwnedCustomization>()
    var subscriptionPlan: SubscriptionPlanProtocol? {
        get {
            return realmSubscriptionPlan
        }
        set {
            if let item = newValue as? RealmSubscriptionPlan {
                realmSubscriptionPlan = item
            }
            if let item = newValue {
                realmSubscriptionPlan = RealmSubscriptionPlan(userID: id, protocolObject: item)
            }
        }
    }
    @objc dynamic var realmSubscriptionPlan: RealmSubscriptionPlan?
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(userID: String?, protocolObject: PurchasedProtocol) {
        self.init()
        self.id = userID
        hair = protocolObject.hair
        skin = protocolObject.skin
        shirt = protocolObject.shirt
        background = protocolObject.background
        subscriptionPlan = protocolObject.subscriptionPlan
    }
}
