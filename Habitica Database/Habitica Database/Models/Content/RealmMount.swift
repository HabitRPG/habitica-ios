//
//  RealmMount.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmMount: BaseModel, MountProtocol {
    @objc dynamic var key: String?
    @objc dynamic var egg: String?
    @objc dynamic var potion: String?
    @objc dynamic var type: String?
    @objc dynamic var text: String?
    
    override static func primaryKey() -> String {
        return "key"
    }

    convenience init(_ mountProtocol: MountProtocol) {
        self.init()
        key = mountProtocol.key
        egg = mountProtocol.egg
        potion = mountProtocol.potion
        type = mountProtocol.type
        text = mountProtocol.text
    }
}
