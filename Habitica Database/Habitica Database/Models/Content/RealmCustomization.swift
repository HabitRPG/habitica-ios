//
//  RealmCustomization.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmCustomization: Object, CustomizationProtocol {
    var key: String?
    var type: String?
    var group: String?
    var price: Float = 0
    var set: CustomizationSetProtocol? {
        get {
            return realmSet
        }
        set {
            if let newSet = newValue as? RealmCustomizationSet {
                realmSet = newSet
            } else if let newSet = newValue {
                realmSet = RealmCustomizationSet(newSet)
            }
        }
    }
    var realmSet: RealmCustomizationSet?
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    convenience init(_ customizationProtocol: CustomizationProtocol) {
        self.init()
        key = customizationProtocol.key
        type = customizationProtocol.type
        group = customizationProtocol.group
        price = customizationProtocol.price
        set = customizationProtocol.set
    }
}
