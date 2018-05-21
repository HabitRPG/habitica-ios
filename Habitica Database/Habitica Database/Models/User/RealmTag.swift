//
//  RealmTag.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmTag: Object, TagProtocol {
    @objc dynamic var id: String?
    @objc dynamic var userID: String?
    @objc dynamic var text: String?
    @objc dynamic var order: Int = 0
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(userID: String?, tagProtocol: TagProtocol) {
        self.init()
        id = tagProtocol.id
        text = tagProtocol.text
        order = tagProtocol.order
    }
}
