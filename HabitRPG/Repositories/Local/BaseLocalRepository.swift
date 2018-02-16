//
//  BaseLocalRepository.swift
//  Flytrap
//
//  Created by Phillip Thelen on 13.02.18.
//  Copyright © 2018 Phillip Thelen. All rights reserved.
//

import Foundation
import RealmSwift

class BaseLocalRepository: NSObject {
    
    lazy internal var realm = try! Realm()
    
    required override init() {
        super.init()
    }
    
    func save(object: Object) {
        try? self.realm.write {
            self.realm.add(object, update: true)
        }
    }
    
    func save(objects: [Object]) {
        try? self.realm.write {
            self.realm.add(objects, update: true)
        }
    }
}
