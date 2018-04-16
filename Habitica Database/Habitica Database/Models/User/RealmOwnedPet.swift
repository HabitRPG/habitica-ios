//
//  RealmOwnedPet.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Habitica_Models

@objc
class RealmOwnedPet: Object, OwnedPetProtocol {
    
    @objc dynamic var combinedKey: String?
    
    @objc dynamic var key: String?
    @objc dynamic var userID: String?
    @objc dynamic var trained: Int = 0
    
    override static func primaryKey() -> String {
        return "combinedKey"
    }
    
    convenience init(userID: String?, petProtocol: OwnedPetProtocol) {
        self.init()
        combinedKey = (userID ?? "") + (petProtocol.key ?? "")
        self.userID = userID
        key = petProtocol.key
        trained = petProtocol.trained
    }
}
