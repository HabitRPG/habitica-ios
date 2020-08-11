//
//  RealmBacker.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 11.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

@objc
class RealmBacker: Object, BackerProtocol {
    
    @objc dynamic var tier: Int = 0
    @objc dynamic var npc: String?
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(id: String?, backer: BackerProtocol) {
        self.init()
        self.id = id
        tier = backer.tier
        npc = backer.npc
    }
    
}
