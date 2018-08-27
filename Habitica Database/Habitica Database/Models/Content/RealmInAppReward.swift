//
//  RealmInAppReward.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 17.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmInAppReward: Object, InAppRewardProtocol {
    @objc dynamic var combinedKey: String?
    @objc dynamic var userID: String?
    @objc dynamic var key: String?
    @objc dynamic var availableUntil: Date?
    @objc dynamic var currency: String?
    @objc dynamic var isSuggested: Bool = false
    @objc dynamic var lastPurchased: Date?
    @objc dynamic var locked: Bool = false
    @objc dynamic var path: String?
    @objc dynamic var pinType: String?
    @objc dynamic var purchaseType: String?
    @objc dynamic var imageName: String?
    @objc dynamic var text: String?
    @objc dynamic var notes: String?
    @objc dynamic var type: String?
    @objc dynamic var value: Float = 0
    @objc dynamic var isSubscriberItem: Bool = false
    
    @objc dynamic var category: ShopCategoryProtocol? {
        get {
            return realmCategory.first
        }
    }
    var realmCategory = LinkingObjects(fromType: RealmShopCategory.self, property: "realmItems")
    
    var isValid: Bool {
        return !isInvalidated
    }
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init(userID: String?, protocolObject: InAppRewardProtocol) {
        self.init()
        self.combinedKey = (userID ?? "") + (protocolObject.key ?? "")
        self.userID = userID
        key = protocolObject.key
        availableUntil = protocolObject.availableUntil
        currency = protocolObject.currency
        isSuggested = protocolObject.isSuggested
        lastPurchased = protocolObject.lastPurchased
        locked = protocolObject.locked
        path = protocolObject.path
        pinType = protocolObject.pinType
        purchaseType = protocolObject.purchaseType
        imageName = protocolObject.imageName
        text = protocolObject.text
        notes = protocolObject.notes
        type = protocolObject.type
        value = protocolObject.value
        isSubscriberItem = protocolObject.isSubscriberItem
    }
}
