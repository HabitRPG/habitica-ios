//
//  RealmPet.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift

class RealmPet: Object, PetProtocol {
    @objc dynamic var key: String?
    @objc dynamic var egg: String?
    @objc dynamic var potion: String?
    @objc dynamic var type: String?
    @objc dynamic var text: String?
    
    override static func primaryKey() -> String {
        return "key"
    }
    
    convenience init(_ petProtocol: PetProtocol) {
        self.init()
        key = petProtocol.key
        egg = petProtocol.egg
        potion = petProtocol.potion
        if petProtocol.type == "whacky" {
            type = "wacky"
        } else {
            type = petProtocol.type
        }
        text = petProtocol.text
    }
}
