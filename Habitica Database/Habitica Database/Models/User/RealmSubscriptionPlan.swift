//
//  RealmSubscriptionPlan.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 23.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmSubscriptionPlan: Object, SubscriptionPlanProtocol {
    @objc dynamic var quantity: Int = 0
    @objc dynamic var gemsBought: Int = 0
    @objc dynamic var dateTerminated: Date?
    @objc dynamic var dateUpdated: Date?
    @objc dynamic var dateCreated: Date?
    @objc dynamic var planId: String?
    @objc dynamic var paymentMethod: String?
    @objc dynamic var customerId: String?
    var consecutive: SubscriptionConsecutiveProtocol? {
        get {
            return realmSubscriptionConsecutive
        }
        set {
            if let item = newValue as? RealmSubscriptionConsecutive {
                realmSubscriptionConsecutive = item
            }
            if let item = newValue {
                realmSubscriptionConsecutive = RealmSubscriptionConsecutive(userID: id, protocolObject: item)
            }
        }
    }
    @objc dynamic var realmSubscriptionConsecutive: RealmSubscriptionConsecutive?
    @objc dynamic var mysteryItems: [String] {
        get {
            return realmMysteryItems.map({ (key) in
                return key
            })
        }
        set {
            realmMysteryItems.removeAll()
            realmMysteryItems.append(objectsIn: newValue)
        }
    }
    var realmMysteryItems = List<String>()
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["mysteryItems"]
    }
    
    convenience init(userID: String?, protocolObject: SubscriptionPlanProtocol) {
        self.init()
        self.id = userID
        quantity = protocolObject.quantity
        gemsBought = protocolObject.gemsBought
        dateTerminated = protocolObject.dateTerminated
        dateUpdated = protocolObject.dateUpdated
        dateCreated = protocolObject.dateCreated
        planId = protocolObject.planId
        customerId = protocolObject.customerId
        consecutive = protocolObject.consecutive
        paymentMethod = protocolObject.paymentMethod
        mysteryItems = protocolObject.mysteryItems
    }
}
