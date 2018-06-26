//
//  RealmHair.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmHair: Object, HairProtocol {
    var color: String?
    var bangs: Int = 0
    var base: Int = 0
    var beard: Int = 0
    var mustache: Int = 0
    var flower: Int = 0
    
    @objc dynamic var id: String?
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(userID: String?, protocolObject: HairProtocol) {
        self.init()
        self.id = userID
        color = protocolObject.color
        bangs = protocolObject.bangs
        base = protocolObject.base
        beard = protocolObject.beard
        mustache = protocolObject.mustache
        flower = protocolObject.flower
    }
}
