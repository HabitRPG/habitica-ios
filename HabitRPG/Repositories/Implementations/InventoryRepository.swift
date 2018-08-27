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
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (currentUserID) in
            return self?.localRepository.getOwnedGear(userID: userID ?? currentUserID) ?? SignalProducer.empty
        })
    }
    
    func getGear(predicate: NSPredicate? = nil) -> SignalProducer<ReactiveResults<[GearProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getGear(predicate: predicate)
    }
    
    func getGear(keys: [String]) -> SignalProducer<ReactiveResults<[GearProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getGear(predicate: NSPredicate(format: "key IN %@", keys))
    }
    
    func getOwnedItems(userID: String? = nil, itemType: String? = nil) -> SignalProducer<ReactiveResults<[OwnedItemProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (currentUserID) in
            return self?.localRepository.getOwnedItems(userID: userID ?? currentUserID, itemType: itemType) ?? SignalProducer.empty
        })
    }
    
    // swiftlint:disable:next large_tuple
    func getItems(keys: [ItemType: [String]]) -> SignalProducer<(ReactiveResults<[EggProtocol]>,
        ReactiveResults<[FoodProtocol]>,
        ReactiveResults<[HatchingPotionProtocol]>,
        ReactiveResults<[SpecialItemProtocol]>,
        ReactiveResults<[QuestProtocol]>), ReactiveSwiftRealmError> {
        return localRepository.getItems(keys: keys)
    }
    
    func getFood(keys: [String]) ->SignalProducer<ReactiveResults<[FoodProtocol]>, ReactiveSwiftRealmError> {
            return localRepository.getFood(keys: keys)
    }
    
    func getSpecialItems(keys: [String]) ->SignalProducer<ReactiveResults<[SpecialItemProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getSpecialItems(keys: keys)
    }
    
    func getQuest(key: String) ->SignalProducer<QuestProtocol?, ReactiveSwiftRealmError> {
        return localRepository.getQuest(key: key)
    }
    
    func sell(item: ItemProtocol) -> Signal<UserProtocol?, NoError> {
        let call = SellItemCall(item: item)
        call.fire()
        return call.objectSignal.on(value: {[weak self]user in
            if let user = user, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, updateUser: user)
            }
        })
    }
    
    func hatchPet(egg: EggProtocol, potion: HatchingPotionProtocol) -> Signal<UserItemsProtocol?, NoError> {
        let call = HatchPetCall(egg: egg, potion: potion)
        call.fire()
        return call.objectSignal.on(value: {[weak self]userItems in
            if let userItems = userItems, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, userItems: userItems)
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
        return call.objectSignal.on(value: {[weak self]userItems in
            if let userItems = userItems, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, userItems: userItems)
            }
        })
    }
    
    func buyObject(key: String) -> Signal<BuyResponseProtocol?, NoError> {
        let call = BuyObjectCall(key: key)
        call.fire()
        return call.habiticaResponseSignal.on(value: {[weak self]habiticaResponse in
            if let buyResponse = habiticaResponse?.data, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, buyResponse: buyResponse)
                
                if let armoire = buyResponse.armoire {
                    guard let text = habiticaResponse?.message?.stripHTML().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                        return
                    }
                    if armoire.type == "experience" {
                        ToastManager.show(text: text, color: .yellow)
                    } else if armoire.type == "food" {
                        ToastManager.show(text: text, color: .gray)
                        //TODO: Show images in armoire toasts
                        /*ImageManager.getImage(name: "Pet_Food_\(armoire.dropText ?? "")", completion: { (image, _) in
                            if let image = image {
                                let toastView = ToastView(title: text, icon: image, background: .gray)
                                ToastManager.show(toast: toastView)
                            }
                        })*/
                    } else if armoire.type == "gear" {
                        ToastManager.show(text: text, color: .gray)
                        //TODO: Show images in armoire toasts
                        /*ImageManager.getImage(name: "shop_\(armoire.dropText ?? "")", completion: { (image, _) in
                            if let image = image {
                                let toastView = ToastView(title: text, icon: image, background: .gray)
                                ToastManager.show(toast: toastView)
                            }
                        })*/
                    }
                }
            }
        }).map({ habiticaResponse in
            return habiticaResponse?.data
        })
    }
    
    func purchaseItem(purchaseType: String, key: String, value: Int) -> Signal<UserProtocol?, NoError> {
        let call = PurchaseItemCall(purchaseType: purchaseType, key: key)
        call.fire()
        return call.objectSignal.on(value: {[weak self]updatedUser in
            if let updatedUser = updatedUser, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, balanceDiff: -(Float(value) / 4.0))
                self?.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
        })
    }
    
    func purchaseHourglassItem(purchaseType: String, key: String) -> Signal<UserProtocol?, NoError> {
        let call = PurchaseHourglassItemCall(purchaseType: purchaseType, key: key)
        call.fire()
        return call.objectSignal.on(value: {[weak self]updatedUser in
            if let updatedUser = updatedUser, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
        })
    }
    
    func purchaseMysterySet(identifier: String) -> Signal<UserProtocol?, NoError> {
        let call = PurchaseMysterySetCall(identifier: identifier)
        call.fire()
        return call.objectSignal.on(value: {[weak self]updatedUser in
            if let updatedUser = updatedUser, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
        })
    }
    
    func openMysteryItem() -> Signal<GearProtocol?, NoError> {
        let call = OpenMysteryItemCall()
        call.fire()
        return call.objectSignal
            .skipNil()
            .flatMap(.latest, {[weak self] (gear) -> SignalProducer<GearProtocol?, NoError> in
                let key = gear.key ?? ""
                return self?.localRepository.getGear(predicate: NSPredicate(format: "key == %@", key)).map({ (values, _) in
                    return values.first
                }).flatMapError({ _ in
                    return SignalProducer.empty
                }) ?? SignalProducer.empty
            })
            .on(value: {[weak self] gear in
                if let key = gear?.key {
                    self?.localRepository.receiveMysteryItem(userID: self?.currentUserId ?? "", key: key)
                    ToastManager.show(text: L10n.receivedMysteryItem(gear?.text ?? ""), color: .green)
                }
            })
    }
    
    func purchaseQuest(key: String) -> Signal<UserProtocol?, NoError> {
        let call = PurchaseQuestCall(key: key)
        call.fire()
        return call.objectSignal.on(value: {[weak self]updatedUser in
            if let updatedUser = updatedUser, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
        })
    }
    
    func togglePinnedItem(pinType: String, path: String) -> Signal<PinResponseProtocol?, NoError> {
        let call = TogglePinnedItemCall(pinType: pinType, path: path)
        call.fire()
        return call.objectSignal.on(value: {[weak self] pinResponse in
            if let pinResponse = pinResponse, let userID = self?.currentUserId {
                self?.localRepository.updatePinnedItems(userID: userID, pinResponse: pinResponse)
            }
        })
    }
    
    func retrieveShopInventory(identifier: String) -> Signal<ShopProtocol?, NoError> {
        let call = RetrieveShopInventoryCall(identifier: identifier)
        call.fire()
        return call.objectSignal.on(value: {[weak self]shop in
            if let shop = shop {
                shop.identifier = identifier
                self?.localRepository.save(shop: shop)
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
        return call.objectSignal.on(value: {[weak self]petValue in
            if let userID = self?.currentUserId, let key = pet.key, let trained = petValue, let foodKey = food.key {
                self?.localRepository.updatePetTrained(userID: userID, key: key, trained: trained, consumedFood: foodKey)
            }
        })
    }
    
    func getNewInAppReward() -> InAppRewardProtocol {
        return localRepository.getNewInAppReward()
    }
}
