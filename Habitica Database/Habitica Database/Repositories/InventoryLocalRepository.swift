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

public class InventoryLocalRepository: ContentLocalRepository {
    
    public func getGear(predicate: NSPredicate? = nil) -> SignalProducer<ReactiveResults<[GearProtocol]>, ReactiveSwiftRealmError> {
        var producer: SignalProducer<Results<RealmGear>, ReactiveSwiftRealmError>?
        if let searchPredicate = predicate {
            producer = RealmGear.findBy(predicate: searchPredicate)
        } else {
            producer = RealmGear.findAll()
        }
        
        // swiftlint:disable:next force_unwrapping
        return producer!.sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[GearProtocol]> in
            return (value.map({ (entry) -> GearProtocol in return entry }), changeset)
        })
    }
    
    public func getOwnedItems(userID: String, itemType: String?) -> SignalProducer<ReactiveResults<[OwnedItemProtocol]>, ReactiveSwiftRealmError> {
        var query = "userID == '\(userID)' && numberOwned > 0"
        if let itemType = itemType {
            query = "\(query) && itemType =='\(itemType)'"
        }
        return RealmOwnedItem.findBy(query: query).reactive().map({ (value, changeset) -> ReactiveResults<[OwnedItemProtocol]> in
            return (value.map({ (item) -> OwnedItemProtocol in return item }), changeset)
        })
    }
    
    public func getOwnedGear(userID: String) -> SignalProducer<ReactiveResults<[OwnedGearProtocol]>, ReactiveSwiftRealmError> {
        return RealmOwnedGear.findBy(query: "userID == '\(userID)' && isOwned == true").reactive().map({ (value, changeset) -> ReactiveResults<[OwnedGearProtocol]> in
            return (value.map({ (item) -> OwnedGearProtocol in return item }), changeset)
        })
    }
    
    // swiftlint:disable:next large_tuple
    public func getItems(keys: [ItemType: [String]]) -> SignalProducer<(ReactiveResults<[EggProtocol]>,
        ReactiveResults<[FoodProtocol]>,
        ReactiveResults<[HatchingPotionProtocol]>,
        ReactiveResults<[SpecialItemProtocol]>,
        ReactiveResults<[QuestProtocol]>), ReactiveSwiftRealmError> {
        return SignalProducer.combineLatest(
            RealmEgg.findBy(predicate: NSPredicate(format: "key IN %@", keys[ItemType.eggs] ?? [])).sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[EggProtocol]> in
                return (value.map({ (item) -> EggProtocol in return item }), changeset)
            }),
            RealmFood.findBy(predicate: NSPredicate(format: "key IN %@", keys[ItemType.food] ?? [])).sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[FoodProtocol]> in
                return (value.map({ (item) -> FoodProtocol in return item }), changeset)
            }),
            RealmHatchingPotion.findBy(predicate: NSPredicate(format: "key IN %@", keys[ItemType.hatchingPotions] ?? [])).sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[HatchingPotionProtocol]> in
                return (value.map({ (item) -> HatchingPotionProtocol in return item }), changeset)
            }),
            RealmSpecialItem.findBy(predicate: NSPredicate(format: "key IN %@", keys[ItemType.special] ?? [])).sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[SpecialItemProtocol]> in
                return (value.map({ (item) -> SpecialItemProtocol in return item }), changeset)
            }),
            RealmQuest.findBy(predicate: NSPredicate(format: "key IN %@", keys[ItemType.quests] ?? [])).sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[QuestProtocol]> in
                return (value.map({ (item) -> QuestProtocol in return item }), changeset)
            }))
    }
    
    public func getItems(type: ItemType) -> SignalProducer<ReactiveResults<[ItemProtocol]>, ReactiveSwiftRealmError> {
        if type == ItemType.eggs {
            return RealmEgg.findAll().sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[ItemProtocol]> in
                return (value.map({ (item) -> ItemProtocol in return item }), changeset)
            })
        } else if type == ItemType.hatchingPotions {
            return RealmHatchingPotion.findAll().sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[ItemProtocol]> in
                return (value.map({ (item) -> ItemProtocol in return item }), changeset)
            })
        } else if type == ItemType.food {
            return RealmFood.findAll().sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[ItemProtocol]> in
                return (value.map({ (item) -> ItemProtocol in return item }), changeset)
            })
        } else if type == ItemType.special {
            return RealmSpecialItem.findAll().sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[ItemProtocol]> in
                return (value.map({ (item) -> ItemProtocol in return item }), changeset)
            })
        }
        return SignalProducer.empty
    }
    
    public func getSpecialItems(keys: [String]) -> SignalProducer<ReactiveResults<[SpecialItemProtocol]>, ReactiveSwiftRealmError> {
        return RealmSpecialItem.findBy(predicate: NSPredicate(format: "key IN %@", keys)).sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[SpecialItemProtocol]> in
                return (value.map({ (item) -> SpecialItemProtocol in return item }), changeset)
            })
    }
    
    public func getFood(keys: [String]) -> SignalProducer<ReactiveResults<[FoodProtocol]>, ReactiveSwiftRealmError> {
        return RealmFood.findBy(predicate: NSPredicate(format: "key IN %@", keys)).sorted(key: "text").reactive().map({ (value, changeset) -> ReactiveResults<[FoodProtocol]> in
            return (value.map({ (item) -> FoodProtocol in return item }), changeset)
        })
    }
    
    public func getQuest(key: String) -> SignalProducer<QuestProtocol?, ReactiveSwiftRealmError> {
        return RealmQuest.findBy(key: key).map({ quest -> QuestProtocol? in
            return quest
        })
    }
    
    public func getQuests(keys: [String]) -> SignalProducer<ReactiveResults<[QuestProtocol]>, ReactiveSwiftRealmError> {
        return RealmQuest.findBy(predicate: NSPredicate(format: "key IN %@", keys)).reactive().map({ (value, changeset) -> ReactiveResults<[QuestProtocol]> in
            return (value.map({ (item) -> QuestProtocol in return item }), changeset)
        })
    }
    
    public func getShop(identifier: String) -> SignalProducer<ShopProtocol?, ReactiveSwiftRealmError> {
        return RealmShop.findBy(query: "identifier == '\(identifier)'").reactive().map({ shops -> ShopProtocol? in
            return shops.value.first
        })
    }
    
    public func getShops() -> SignalProducer<ReactiveResults<[ShopProtocol]>, ReactiveSwiftRealmError> {
        return RealmShop.findBy(query: "identifier != 'market-gear'").reactive().map({ (value, changeset) -> ReactiveResults<[ShopProtocol]> in
            return (value.map({ (item) -> ShopProtocol in return item }), changeset)
        })
    }
    
    public func save(shop: ShopProtocol) {
        if let realmShop = shop as? RealmShop {
            save(object: realmShop)
            return
        }
        save(object: RealmShop(shop))
    }
    
    public func updatePetTrained(userID: String, key: String, trained: Int, consumedFood: String) {
        let realm = getRealm()
        let ownedPet = realm?.object(ofType: RealmOwnedPet.self, forPrimaryKey: userID+key)
        let ownedFood = realm?.object(ofType: RealmOwnedItem.self, forPrimaryKey: userID + consumedFood + "food")
        updateCall { realm in
            ownedPet?.trained = trained
            ownedFood?.numberOwned -= 1
            if trained == -1 {
                realm.add(RealmOwnedMount(userID: userID, key: key, owned: true), update: .modified)
            }
        }
    }
    
    public func getNewInAppReward() -> InAppRewardProtocol {
        return RealmInAppReward()
    }
    
    public func receiveMysteryItem(userID: String, key: String) {
        guard let realm = getRealm() else {
            return
        }
        let ownedGear = RealmOwnedGear()
        ownedGear.key = key
        ownedGear.userID = userID
        ownedGear.isOwned = true
        let user = realm.object(ofType: RealmUser.self, forPrimaryKey: userID)
        updateCall { realm in
            realm.add(ownedGear, update: .modified)
            let index = user?.purchased?.subscriptionPlan?.mysteryItems.firstIndex(of: key)
            user?.purchased?.subscriptionPlan?.mysteryItems.remove(at: index ?? 0)
        }
    }
    
    public func updatePinnedItems(userID: String, pinResponse: PinResponseProtocol) {
        guard let realm = getRealm() else {
            return
        }
        let pinnedItems = realm.objects(RealmInAppReward.self).filter("userID == %@", userID)
        let newPinnedItems = pinResponse.pinnedItems.filter { (item) -> Bool in
            return !pinnedItems.contains(where: { (reward) -> Bool in
                return reward.path == item.path && reward.pinType == item.type
            })
        }
        let pinsToRemove = pinnedItems.filter { (reward) -> Bool in
            return pinResponse.unpinnedItems.contains(where: { (item) -> Bool in
                return reward.path == item.path && reward.pinType == item.type
            }) || !pinResponse.pinnedItems.contains(where: { (item) -> Bool in
                return reward.path == item.path && reward.pinType == item.type
            })
        }
        updateCall { realm in
            realm.delete(pinsToRemove)
            for newItem in newPinnedItems {
                let reward = RealmInAppReward()
                reward.userID = userID
                reward.key = String(newItem.path.split(separator: ".").last ?? "")
                reward.combinedKey = (reward.userID ?? "") + (reward.key ?? "")
                reward.path = newItem.path
                reward.pinType = newItem.type
            }
        }
    }
    
    public func getLatestMysteryGear() -> SignalProducer<GearProtocol?, ReactiveSwiftRealmError> {
        return RealmGear.findBy(query: "set CONTAINS 'mystery-2'").sorted(key: "set", ascending: false)
        .reactive()
            .map { (result, _) in
                return result.first
        }
    }
    
    public func getCurrentTimeLimitedItems() -> SignalProducer<[ItemProtocol], ReactiveSwiftRealmError> {
        let now = Date() as NSDate
        return SignalProducer.combineLatest(
            RealmEgg.findBy(predicate: NSPredicate(format: "eventStart < %@ && %@ < eventEnd", now, now)).reactive().map({ (value, changeset) -> ReactiveResults<[EggProtocol]> in
                return (value.map({ (item) -> EggProtocol in return item }), changeset)
            }),
            RealmFood.findBy(predicate: NSPredicate(format: "eventStart < %@ && %@ < eventEnd", now, now)).reactive().map({ (value, changeset) -> ReactiveResults<[FoodProtocol]> in
                return (value.map({ (item) -> FoodProtocol in return item }), changeset)
            }),
            RealmHatchingPotion.findBy(predicate: NSPredicate(format: "eventStart < %@ && %@ < eventEnd", now, now)).reactive().map({ (value, changeset) -> ReactiveResults<[HatchingPotionProtocol]> in
                return (value.map({ (item) -> HatchingPotionProtocol in return item }), changeset)
            }),
            RealmSpecialItem.findBy(predicate: NSPredicate(format: "eventStart < %@ && %@ < eventEnd", now, now)).reactive().map({ (value, changeset) -> ReactiveResults<[SpecialItemProtocol]> in
                return (value.map({ (item) -> SpecialItemProtocol in return item }), changeset)
            }),
            RealmQuest.findBy(predicate: NSPredicate(format: "eventStart < %@ && %@ < eventEnd", now, now)).reactive().map({ (value, changeset) -> ReactiveResults<[QuestProtocol]> in
                return (value.map({ (item) -> QuestProtocol in return item }), changeset)
            })).map { items in
                var allItems = [ItemProtocol]()
                for type in [items.0.value, items.1.value, items.2.value, items.3.value, items.4.value] as [[ItemProtocol]] {
                    for item in type {
                        allItems.append(item)
                    }
                }
                return allItems
            }
    }
}
