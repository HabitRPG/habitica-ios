//
//  BaseLocalRepository.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

public class BaseLocalRepository {
    
    required public init() {
        
    }
    
    func getRealm() -> Realm? {
        return try? Realm()
    }
    
    public func save(object realmObject: Object?) {
        if let object = realmObject {
            let realm = getRealm()
            realm?.refresh()
            try? realm?.safeWrite {
                realm?.add(object, update: true)
            }
        }
    }
    
    public func save(objects realmObjects: [Object]?) {
        if let objects = realmObjects {
            let realm = getRealm()
            realm?.refresh()
            try? realm?.safeWrite {
                realm?.add(objects, update: true)
            }
        }
    }
    
    public func updateCall(_ transaction: ((Realm) -> Void)) {
        if let realm = getRealm() {
            realm.refresh()
            try? realm.safeWrite {
                transaction(realm)
            }
        }
    }
    
    public func clearDatabase() {
        let realm = getRealm()
        realm?.refresh()
        try? realm?.write {
            realm?.deleteAll()
        }
    }
}
