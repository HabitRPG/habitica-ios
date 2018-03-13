//
//  RealmSpell.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmSpell: Object, SpellProtocol {
    @objc dynamic var key: String?
    @objc dynamic var text: String?
    @objc dynamic var notes: String?
    @objc dynamic var mana: Int = 0
    @objc dynamic var level: Int = 0
    @objc dynamic var target: String?
    @objc dynamic var habitClass: String?
    @objc dynamic var value: Float = 0
    @objc dynamic var immediateUse: Bool = false
    @objc dynamic var silent: Bool = false
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    convenience init(_ spell: SpellProtocol) {
        self.init()
        key = spell.key
        text = spell.text
        notes = spell.notes
        mana = spell.mana
        level = spell.level
        target = spell.target
        habitClass = spell.habitClass
        value = spell.value
        immediateUse = spell.immediateUse
        silent = spell.silent
    }
}
