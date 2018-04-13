//
//  InventoryLocalRepository.swift
//  Habitica Database
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import RealmSwift
import ReactiveSwift
import Result

public class InventoryLocalRepository: ContentLocalRepository {
    
    public func getGear(predicate: NSPredicate? = nil) -> SignalProducer<ReactiveResults<[GearProtocol]>, ReactiveSwiftRealmError> {
        var producer: SignalProducer<Results<RealmGear>, ReactiveSwiftRealmError>?
        if let searchPredicate = predicate {
            producer = RealmGear.findBy(predicate: searchPredicate)
        } else {
            producer = RealmGear.findAll()
        }
        return producer!.reactive().map({ (value, changeset) -> ReactiveResults<[GearProtocol]> in
            return (value.map({ (entry) -> GearProtocol in return entry }), changeset)
        })
    }
    
    public func getOwnedItems(userID: String) -> SignalProducer<ReactiveResults<[OwnedItemProtocol]>, ReactiveSwiftRealmError> {
        return RealmOwnedItem.findBy(query: "userID == '\(userID)' && numberOwned > 0").reactive().map({ (value, changeset) -> ReactiveResults<[OwnedItemProtocol]> in
            return (value.map({ (item) -> OwnedItemProtocol in return item }), changeset)
        })
    }
    
    public func getItems(keys: [String]) -> SignalProducer<(ReactiveResults<[EggProtocol]>,
        ReactiveResults<[FoodProtocol]>,
        ReactiveResults<[HatchingPotionProtocol]>,
        ReactiveResults<[QuestProtocol]>), ReactiveSwiftRealmError> {
        let producer = SignalProducer.combineLatest(
            RealmEgg.findBy(predicate: NSPredicate(format: "key IN %@", keys)).reactive().map({ (value, changeset) -> ReactiveResults<[EggProtocol]> in
                return (value.map({ (item) -> EggProtocol in return item }), changeset)
            }),
            RealmFood.findBy(predicate: NSPredicate(format: "key IN %@", keys)).reactive().map({ (value, changeset) -> ReactiveResults<[FoodProtocol]> in
                return (value.map({ (item) -> FoodProtocol in return item }), changeset)
            }),
            RealmHatchingPotion.findBy(predicate: NSPredicate(format: "key IN %@", keys)).reactive().map({ (value, changeset) -> ReactiveResults<[HatchingPotionProtocol]> in
                return (value.map({ (item) -> HatchingPotionProtocol in return item }), changeset)
            }),
            RealmQuest.findBy(predicate: NSPredicate(format: "key IN %@", keys)).reactive().map({ (value, changeset) -> ReactiveResults<[QuestProtocol]> in
                return (value.map({ (item) -> QuestProtocol in return item }), changeset)
            }))
        return producer
    }
}
