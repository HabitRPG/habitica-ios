//
//  RealmSkill.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmSkill: Object, SkillProtocol {
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
    @objc dynamic var test: Bool = false
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    convenience init(_ skill: SkillProtocol) {
        self.init()
        key = skill.key
        text = skill.text
        notes = skill.notes
        mana = skill.mana
        level = skill.level
        target = skill.target
        habitClass = skill.habitClass
        value = skill.value
        immediateUse = skill.immediateUse
        silent = skill.silent
    }
}
