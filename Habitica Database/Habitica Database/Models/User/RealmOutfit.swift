//
//  RealmOutfit.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 09.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmOutfit: Object, OutfitProtocol {
    @objc dynamic var back: String?
    @objc dynamic var body: String?
    @objc dynamic var armor: String?
    @objc dynamic var eyewear: String?
    @objc dynamic var headAccessory: String?
    @objc dynamic var head: String?
    @objc dynamic var weapon: String?
    @objc dynamic var shield: String?
    
    convenience init(_ outfit: OutfitProtocol) {
        self.init()
        back = outfit.back
        body = outfit.body
        armor = outfit.armor
        eyewear = outfit.eyewear
        headAccessory = outfit.headAccessory
        head = outfit.head
        weapon = outfit.weapon
        shield = outfit.shield
    }
}
