//
//  RealmShopCategory.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmShopCategory: Object, ShopCategoryProtocol {
    @objc dynamic var combinedKey: String?
    @objc dynamic var shopIdentifier: String?
    var identifier: String?
    var text: String?
    var notes: String?
    var items: [InAppRewardProtocol] {
        get {
            return realmItems.map({ (category) -> InAppRewardProtocol in
                return category
            })
        }
        set {
            realmItems.removeAll()
            newValue.forEach { (item) in
                if let realmCollectItem = item as? RealmInAppReward {
                    realmItems.append(realmCollectItem)
                } else {
                    realmItems.append(RealmInAppReward(userID: combinedKey, protocolObject: item))
                }
            }
        }
    }
    var realmItems = List<RealmInAppReward>()
    
    override static func primaryKey() -> String {
        return "identifier"
    }
    
    convenience init(shopIdentifier: String?, protocolObject: ShopCategoryProtocol) {
        self.init()
        combinedKey = (shopIdentifier ?? "") + (protocolObject.identifier ?? "")
        self.shopIdentifier = shopIdentifier
        identifier = protocolObject.identifier
        text = protocolObject.text
        notes = protocolObject.notes
        items = protocolObject.items
    }
}
