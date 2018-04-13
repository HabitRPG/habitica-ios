//
//  RealmOwnedGear.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 12.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

@objc
class RealmOwnedGear: Object, OwnedGearProtocol {
    
    @objc dynamic var combinedKey: String?
    
    @objc dynamic var key: String?
    @objc dynamic var userID: String?
    @objc dynamic var isOwned: Bool = false
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init(userID: String?, gearProtocol: OwnedGearProtocol) {
        self.init()
        combinedKey = (userID ?? "") + (gearProtocol.key ?? "")
        self.userID = userID
        key = gearProtocol.key
        isOwned = gearProtocol.isOwned
    }
}
