//
// Created by Phillip Thelen on 27.02.18.
// Copyright (c) 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
@testable import Habitica
import RestKit

@objc
extension HRPGManager {

    public static func setupTestManager() {
        let manager = HRPGManager.uninitializedShared()
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Habitica", ofType: "momd") ?? "")
        let managedObjectModel = NSManagedObjectModel(contentsOf: url)?.mutableCopy() as? NSManagedObjectModel
        let managedObjectStore = RKManagedObjectStore(managedObjectModel: managedObjectModel!)
        try? managedObjectStore?.addInMemoryPersistentStore()
        managedObjectStore?.createManagedObjectContexts()
        manager?.loadObjectManager(managedObjectStore)
    }

}