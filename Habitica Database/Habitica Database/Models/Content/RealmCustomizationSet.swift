//
//  RealmCustomizationSet.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmCustomizationSet: Object, CustomizationSetProtocol {
    @objc dynamic var key: String?
    @objc dynamic var text: String?
    @objc dynamic var availableFrom: Date?
    @objc dynamic var availableUntil: Date?
    @objc dynamic var setPrice: Float = 0
    var setItems: [CustomizationProtocol]? {
        return realmSetItems.map({ (customization) -> CustomizationProtocol in
            return customization
        })
    }
    
    var realmSetItems = LinkingObjects(fromType: RealmCustomization.self, property: "realmSet")
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["setItems"]
    }
    
    convenience init(_ setProtocol: CustomizationSetProtocol) {
        self.init()
        key = setProtocol.key
        text = setProtocol.text
        availableFrom = setProtocol.availableFrom
        availableUntil = setProtocol.availableUntil
        setPrice = setProtocol.setPrice
    }
}
