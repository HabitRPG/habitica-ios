//
//  InventoryRepository.swift
//  Habitica
//
//  Created by Phillip on 25.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation

class InventoryRepository {
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return HRPGManager.shared().getManagedObjectContext()
    }()
    
    func getGear(_ key: String) -> Gear? {
        let fetchRequest = NSFetchRequest<Gear>(entityName: "Gear")
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        let result = try? managedObjectContext.fetch(fetchRequest)
        if let gear = result?[0] {
            return gear
        }
        return nil
    }
    
    func getQuest(_ key: String) -> Quest? {
        let fetchRequest = NSFetchRequest<Quest>(entityName: "Quest")
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        let result = try? managedObjectContext.fetch(fetchRequest)
        if let quest = result?[0] {
            return quest
        }
        return nil
    }
    
}
