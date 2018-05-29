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
import Result

class InventoryRepository: BaseRepository<InventoryLocalRepository> {

    let localUserRepository = UserLocalRepository()
    
    func getOwnedGear(userID: String? = nil) -> SignalProducer<ReactiveResults<[OwnedGearProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getOwnedGear(userID: userID ?? currentUserId ?? "")
    }
    
    func getGear(predicate: NSPredicate? = nil) -> SignalProducer<ReactiveResults<[GearProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getGear(predicate: predicate)
    }
    
    func getGear(keys: [String]) -> SignalProducer<ReactiveResults<[GearProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getGear(predicate: NSPredicate(format: "key IN %@", keys))
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
    
    func getFood(keys: [String]) ->SignalProducer<ReactiveResults<[FoodProtocol]>, ReactiveSwiftRealmError> {
            return localRepository.getFood(keys: keys)
    }
    
    func getQuest(key: String) ->SignalProducer<QuestProtocol?, ReactiveSwiftRealmError> {
        return localRepository.getQuest(key: key)
    }
    
    func sell(item: ItemProtocol) -> Signal<UserProtocol?, NoError> {
        let call = SellItemCall(item: item)
        call.fire()
        return call.objectSignal.on(value: { user in
            if let user = user, let userID = self.currentUserId {
                self.localUserRepository.updateUser(id: userID, updateUser: user)
            }
        })
    }
    
    func hatchPet(egg: EggProtocol, potion: HatchingPotionProtocol) -> Signal<UserItemsProtocol?, NoError> {
        let call = HatchPetCall(egg: egg, potion: potion)
        call.fire()
        return call.objectSignal.on(value: { userItems in
            if let userItems = userItems, let userID = self.currentUserId {
                self.localUserRepository.updateUser(id: userID, userItems: userItems)
            }
        })
    }
    
    func inviteToQuest(quest: QuestProtocol) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = InviteToQuestCall(groupID: "party", quest: quest)
        call.fire()
        return call.objectSignal
    }
    
    func equip(type: String, key: String) -> Signal<UserItemsProtocol?, NoError> {
        let call = EquipCall(type: type, itemKey: key)
        call.fire()
        return call.objectSignal.on(value: { userItems in
            if let userItems = userItems, let userID = self.currentUserId {
                self.localUserRepository.updateUser(id: userID, userItems: userItems)
            }
        })
    }
    
    func buyObject(key: String) -> Signal<UserProtocol?, NoError> {
        let call = BuyObjectCall(key: key)
        call.fire()
        return call.objectSignal.on(value: { updatedUser in
            if let updatedUser = updatedUser, let userID = self.currentUserId {
                self.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
        })
    }
    
    func purchaseItem(purchaseType: String, key: String) -> Signal<UserProtocol?, NoError> {
        let call = PurchaseItemCall(purchaseType: purchaseType, key: key)
        call.fire()
        return call.objectSignal.on(value: { updatedUser in
            if let updatedUser = updatedUser, let userID = self.currentUserId {
                self.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
        })
    }
    
    func purchaseHourglassItem(purchaseType: String, key: String) -> Signal<UserProtocol?, NoError> {
        let call = PurchaseHourglassItemCall(purchaseType: purchaseType, key: key)
        call.fire()
        return call.objectSignal.on(value: { updatedUser in
            if let updatedUser = updatedUser, let userID = self.currentUserId {
                self.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
        })
    }
    
    func purchaseMysterySet(identifier: String) -> Signal<UserProtocol?, NoError> {
        let call = PurchaseMysterySetCall(identifier: identifier)
        call.fire()
        return call.objectSignal.on(value: { updatedUser in
            if let updatedUser = updatedUser, let userID = self.currentUserId {
                self.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
        })
    }
    
    func purchaseQuest(key: String) -> Signal<UserProtocol?, NoError> {
        let call = PurchaseQuestCall(key: key)
        call.fire()
        return call.objectSignal.on(value: { updatedUser in
            if let updatedUser = updatedUser, let userID = self.currentUserId {
                self.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
        })
    }
    
    func togglePinnedItem(pinType: String, path: String) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = TogglePinnedItemCall(pinType: pinType, path: path)
        call.fire()
        return call.objectSignal
    }
    
    func retrieveShopInventory(identifier: String) -> Signal<ShopProtocol?, NoError> {
        let call = RetrieveShopInventoryCall(identifier: identifier)
        call.fire()
        return call.objectSignal.on(value: { shop in
            if let shop = shop {
                shop.identifier = identifier
                self.localRepository.save(shop: shop)
            }
        })
    }
    
    func getShop(identifier: String) -> SignalProducer<ShopProtocol?, ReactiveSwiftRealmError> {
        return localRepository.getShop(identifier: identifier)
    }
    
    func getShops() -> SignalProducer<ReactiveResults<[ShopProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getShops()
    }
    
    func feed(pet: PetProtocol, food: FoodProtocol) -> Signal<Int?, NoError> {
        let call = FeedPetCall(pet: pet, food: food)
        call.fire()
        call.habiticaResponseSignal.observeValues { response in
            if let message = response?.message {
                let toastView = ToastView(title: message, background: .green)
                ToastManager.show(toast: toastView)
            }
        }
        return call.objectSignal.on(value: { petValue in
            if let userID = self.currentUserId, let key = pet.key, let trained = petValue, let foodKey = food.key {
                self.localRepository.updatePetTrained(userID: userID, key: key, trained: trained, consumedFood: foodKey)
            }
        })
    }
}
