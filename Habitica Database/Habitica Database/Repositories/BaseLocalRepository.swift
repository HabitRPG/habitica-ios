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
    
    required public init() {
        
    }
    
    func getRealm() -> Realm? {
        return try? Realm()
    }
    
    func save(object realmObject: Object?) {
        if let object = realmObject {
            let realm = getRealm()
            try? realm?.write {
                realm?.add(object, update: true)
            }
        }
    }
    
    func save(objects realmObjects: [Object]?) {
        if let objects = realmObjects {
            let realm = getRealm()
            try? realm?.write {
                realm?.add(objects, update: true)
            }
        }
    }
    
    public func updateCall(_ transaction: (() -> Void)) {
        try? getRealm()?.write {
            transaction()
        }
    }
    
    public func clearDatabase() {
        let realm = getRealm()
        try? realm?.write {
            realm?.deleteAll()
        }
    }
}
