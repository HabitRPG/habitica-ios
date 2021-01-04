//
//  RealmBuff.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmBuff: Object, BuffProtocol {
    @objc dynamic var strength: Int = 0
    @objc dynamic var intelligence: Int = 0
    @objc dynamic var constitution: Int = 0
    @objc dynamic var perception: Int = 0
    @objc dynamic var shinySeed: Bool = false
    @objc dynamic var snowball: Bool = false
    @objc dynamic var seafoam: Bool = false
    @objc dynamic var streaks: Bool = false
    @objc dynamic var stealth: Int = 0
    @objc dynamic var spookySparkles: Bool = false
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(id: String?, buff: BuffProtocol) {
        self.init()
        self.id = id
        strength = buff.strength
        intelligence = buff.intelligence
        constitution = buff.constitution
        perception = buff.perception
        streaks = buff.streaks
        stealth = buff.stealth
        shinySeed = buff.shinySeed
        seafoam = buff.seafoam
        snowball = buff.snowball
        spookySparkles = buff.spookySparkles
    }
}
