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
    var key: String?
    var text: String?
    var availableFrom: Date?
    var availableUntil: Date?
    var setPrice: Float = 0
    
    override static func primaryKey() -> String {
        return "key"
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
