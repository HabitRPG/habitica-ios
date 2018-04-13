//
//  InventoryRepository.swift
//  Habitica
//
//  Created by Phillip on 25.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import Habitica_Database
import Habitica_API_Client
import ReactiveSwift

class InventoryRepository: BaseRepository<InventoryLocalRepository> {

    lazy var managedObjectContext: NSManagedObjectContext = {
        return HRPGManager.shared().getManagedObjectContext()
    }()
    
    func getFetchRequest<T: NSManagedObject>(entityName: String, predicate: NSPredicate) -> NSFetchRequest<T> {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    internal func makeFetchRequest<T: NSManagedObject>(entityName: String, predicate: NSPredicate) -> T? {
        let fetchRequest: NSFetchRequest<T> = getFetchRequest(entityName: entityName, predicate: predicate)
        let result = try? managedObjectContext.fetch(fetchRequest)
        if result?.count ?? 0 > 0, let item = result?[0] {
            return item
        }
        return nil
    }
    
    func getGear(_ key: String) -> Gear? {
        return makeFetchRequest(entityName: "Gear", predicate: NSPredicate(format: "key == %@", key))
    }
    
    func getQuest(_ key: String) -> Quest? {
        return makeFetchRequest(entityName: "Quest", predicate: NSPredicate(format: "key == %@", key))
    }
    
    func getGear(predicate: NSPredicate? = nil) -> SignalProducer<ReactiveResults<[GearProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getGear(predicate: predicate)
    }
    
    func getOwnedItems(userID: String? = nil) -> SignalProducer<ReactiveResults<[OwnedItemProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getOwnedItems(userID: userID ?? currentUserId ?? "")
    }
    
    func getItems(keys: [String]) -> SignalProducer<(ReactiveResults<[EggProtocol]>,
        ReactiveResults<[FoodProtocol]>,
        ReactiveResults<[HatchingPotionProtocol]>,
        ReactiveResults<[QuestProtocol]>), ReactiveSwiftRealmError> {
        return localRepository.getItems(keys: keys)
    }
}
