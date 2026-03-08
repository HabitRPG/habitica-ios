//
//  RealmGearSet.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 24.10.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmGearSet: Object, GearSetProtocol {
    @objc dynamic var key: String?
    @objc dynamic var text: String?
    @objc dynamic var start: Date?
    @objc dynamic var end: Date?
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    convenience init(_ protocolObject: GearSetProtocol) {
        self.init()
        key = protocolObject.key
        text = protocolObject.text
        start = protocolObject.start
        end = protocolObject.end
    }
}
