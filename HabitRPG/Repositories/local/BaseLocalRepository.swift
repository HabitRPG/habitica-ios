//
//  BaseLocalRepository.swift
//  Habitica
//
//  Created by Phillip on 17.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift

class BaseLocalRepository: NSObject {
    
    private let realm = try? Realm()
    
    required override init() {
        super.init()
    }
    
    func save(object: Object) {
        try? self.realm?.write {
            self.realm?.add(object, update: true)
        }
    }
    
    func save(objects: [Object]) {
        try? self.realm?.write {
            self.realm?.add(objects, update: true)
        }
    }
}
