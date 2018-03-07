//
//  BaseLocalRepository.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift

public class BaseLocalRepository {
    
    let realm = try? Realm()
    
    required public init() {
        
    }
    
    func save(object realmObject: Object) {
        try? realm?.write {
            realm?.add(realmObject, update: true)
        }
    }
    
    func save(objects realmObjects: [Object]) {
        try? realm?.write {
            realm?.add(realmObjects, update: true)
        }
    }
    
}