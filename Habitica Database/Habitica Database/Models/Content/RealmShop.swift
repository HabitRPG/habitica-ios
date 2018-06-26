//
//  RealmShop.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 21.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmShop: Object, ShopProtocol {
    var identifier: String?
    var text: String?
    var notes: String?
    var imageName: String?
    var hasNew: Bool = false
    @objc dynamic var test: Bool = false
    var categories: [ShopCategoryProtocol] {
        get {
            return realmCategories.map({ (category) -> ShopCategoryProtocol in
                return category
            })
        }
        set {
            realmCategories.removeAll()
            newValue.forEach { (category) in
                if let realmCategory = category as? RealmShopCategory {
                    realmCategories.append(realmCategory)
                } else {
                    realmCategories.append(RealmShopCategory(shopIdentifier: identifier, protocolObject: category))
                }
            }
        }
    }
    var realmCategories = List<RealmShopCategory>()
    
    override static func primaryKey() -> String {
        return "identifier"
    }
    
    convenience init(_ protocolObject: ShopProtocol) {
        self.init()
        identifier = protocolObject.identifier
        text = protocolObject.text
        notes = protocolObject.notes
        imageName = protocolObject.imageName
        hasNew = protocolObject.hasNew
        categories = protocolObject.categories
    }
}
