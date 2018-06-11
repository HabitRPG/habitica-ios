//
//  RealmGear.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmGear: Object, GearProtocol {
    @objc dynamic var key: String?
    @objc dynamic var text: String?
    @objc dynamic var notes: String?
    @objc dynamic var value: Float = 0
    @objc dynamic var type: String?
    @objc dynamic var set: String?
    @objc dynamic var gearSet: String?
    @objc dynamic var habitClass: String?
    @objc dynamic var specialClass: String?
    @objc dynamic var index: String?
    @objc dynamic var twoHanded: Bool = false
    @objc dynamic var strength: Int = 0
    @objc dynamic var intelligence: Int = 0
    @objc dynamic var perception: Int = 0
    @objc dynamic var constitution: Int = 0
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    convenience init(_ gear: GearProtocol) {
        self.init()
        key = gear.key
        text = gear.text
        notes = gear.notes
        value = gear.value
        type = gear.type
        set = gear.set
        gearSet = gear.gearSet
        habitClass = gear.habitClass
        specialClass = gear.specialClass
        index = gear.index
        twoHanded = gear.twoHanded
        strength = gear.strength
        intelligence = gear.intelligence
        perception = gear.perception
        constitution = gear.constitution
    }
}
