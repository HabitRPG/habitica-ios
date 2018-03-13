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
    var key: String?
    var text: String?
    var notes: String?
    var value: Float = 0
    var type: String?
    var set: String?
    var habitClass: String?
    var index: String?
    var strength: Int = 0
    var intelligence: Int = 0
    var perception: Int = 0
    var constitution: Int = 0
    
    convenience init(_ gear: GearProtocol) {
        self.init()
        key = gear.key
        text = gear.text
        notes = gear.notes
        value = gear.value
        type = gear.type
        set = gear.set
        habitClass = gear.habitClass
        index = gear.index
        strength = gear.strength
        intelligence = gear.intelligence
        perception = gear.perception
        constitution = gear.constitution
    }
}
