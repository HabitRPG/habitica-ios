//
//  RealmOwnedMount.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

@objc
class RealmOwnedMount: Object, OwnedMountProtocol {
    
    @objc dynamic var combinedKey: String?
    
    @objc dynamic var key: String?
    @objc dynamic var userID: String?
    @objc dynamic var owned: Bool = false
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init(userID: String?, mountProtocol: OwnedMountProtocol) {
        self.init()
        combinedKey = (userID ?? "") + (mountProtocol.key ?? "")
        self.userID = userID
        key = mountProtocol.key
        owned = mountProtocol.owned
    }
    
    convenience init(userID: String?, key: String, owned: Bool) {
        self.init()
        combinedKey = (userID ?? "") + (key)
        self.userID = userID
        self.key = key
        self.owned = owned
    }
}
