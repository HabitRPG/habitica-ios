//
//  InventoryRepository.swift
//  Habitica
//
//  Created by Phillip on 25.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

class InventoryRepository: BaseRepository {

    func getGear(_ key: String) -> Gear? {
        return makeFetchRequest(entityName: "Gear", predicate: NSPredicate(format: "key == %@", key))
    }
    
    func getQuest(_ key: String) -> Quest? {
        return makeFetchRequest(entityName: "Quest", predicate: NSPredicate(format: "key == %@", key))
    }
    
}
