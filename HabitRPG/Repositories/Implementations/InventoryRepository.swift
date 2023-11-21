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
    func getItems(keys: [ItemType: [String]]) -> SignalProducer<(eggs: ReactiveResults<[EggProtocol]>,
                                                                 food: ReactiveResults<[FoodProtocol]>,
                                                                 hatchingPotions: ReactiveResults<[HatchingPotionProtocol]>,
                                                                 special: ReactiveResults<[SpecialItemProtocol]>,
                                                                 quests: ReactiveResults<[QuestProtocol]>), ReactiveSwiftRealmError> {
        return localRepository.getItems(keys: keys).map { items in
            return (eggs: items.0, food: items.1, hatchingPotions: items.2, special: items.3, quests: items.4)
        }
    }
    
    func getFood(keys: [String]) -> SignalProducer<ReactiveResults<[FoodProtocol]>, ReactiveSwiftRealmError> {
            return localRepository.getFood(keys: keys)
    }
    
    func getItems(type: ItemType) -> SignalProducer<ReactiveResults<[ItemProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getItems(type: type)
    }
    
    func getSpecialItems(keys: [String]) -> SignalProducer<ReactiveResults<[SpecialItemProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getSpecialItems(keys: keys)
    }
    
    func getQuest(key: String) -> SignalProducer<QuestProtocol?, ReactiveSwiftRealmError> {
        return localRepository.getQuest(key: key)
    }
    
    func getQuests(keys: [String]) -> SignalProducer<ReactiveResults<[QuestProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getQuests(keys: keys)
    }
    
    func sell(item: ItemProtocol) -> Signal<UserProtocol?, Never> {
        let call = SellItemCall(item: item)
        let toastView = ToastView(goldDiff: item.value, background: .green, delay: 0.5)
        
        return call.objectSignal.on(value: {[weak self]user in
            ToastManager.show(toast: toastView)
            if let user = user, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, updateUser: user)
            }
        })
    }
    
    func hatchPet(egg: EggProtocol, potion: HatchingPotionProtocol) -> Signal<UserItemsProtocol?, Never> {
        return hatchPet(egg: egg.key, potion: potion.key)
    }
    
    func hatchPet(egg: String?, potion: String?) -> Signal<UserItemsProtocol?, Never> {
        let call = HatchPetCall(egg: egg ?? "", potion: potion ?? "")
        
        return call.objectSignal.on(value: {[weak self]userItems in
            if let userItems = userItems, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, userItems: userItems)
            }
        })
    }
    
    func inviteToQuest(quest: QuestProtocol) -> Signal<EmptyResponseProtocol?, Never> {
        let call = InviteToQuestCall(groupID: "party", quest: quest)
        return call.objectSignal
    }
    
    func equip(type: String, key: String) -> Signal<UserItemsProtocol?, Never> {
        let call = EquipCall(type: type, itemKey: key)
        
        return call.objectSignal.on(value: {[weak self]userItems in
            if let userItems = userItems, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, userItems: userItems)
            }
        })
    }
    
    func buyObject(key: String, quantity: Int, price: Int, text: String, openArmoireView: Bool = true) -> Signal<BuyResponseProtocol?, Never> {
        let call = BuyObjectCall(key: key, quantity: quantity)
        
        return call.habiticaResponseSignal.on(value: {[weak self]habiticaResponse in
            if let buyResponse = habiticaResponse?.data, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, price: price, buyResponse: buyResponse)
                
                if let armoire = buyResponse.armoire {
                    if openArmoireView {
                        let viewController = ArmoireViewController()
                        viewController.configure(type: armoire.type ?? "", text: armoire.dropText ?? "", key: armoire.dropKey, value: armoire.value)
                        viewController.show()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                        ToastManager.show(text: L10n.purchased(text), color: .green)
                    }
                }
                UINotificationFeedbackGenerator.oneShotNotificationOccurred(.success)
            }
        }).map({ habiticaResponse in
            return habiticaResponse?.data
        })
    }
    
    func purchaseItem(purchaseType: String, key: String, value: Int, quantity: Int, text: String) -> Signal<UserProtocol?, Never> {
        let call = PurchaseItemCall(purchaseType: purchaseType, key: key, quantity: quantity)
        
        return call.objectSignal.on(value: {[weak self]updatedUser in
            if let updatedUser = updatedUser, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, balanceDiff: -(Float(value) / 4.0))
                self?.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                ToastManager.show(text: L10n.purchased(text), color: .green)
            }
        })
    }
    
    func purchaseHourglassItem(purchaseType: String, key: String, text: String) -> Signal<UserProtocol?, Never> {
        let call = PurchaseHourglassItemCall(purchaseType: purchaseType, key: key)
        
        return call.objectSignal.on(value: {[weak self]updatedUser in
            if let updatedUser = updatedUser, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                ToastManager.show(text: L10n.purchased(text), color: .green)
            }
        })
    }
    
    func purchaseMysterySet(identifier: String, text: String) -> Signal<UserProtocol?, Never> {
        let call = PurchaseMysterySetCall(identifier: identifier)
        
        return call.objectSignal.on(value: {[weak self]updatedUser in
            if let updatedUser = updatedUser, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                ToastManager.show(text: L10n.purchased(text), color: .green)
            }
        })
    }
    
    func openMysteryItem() -> Signal<GearProtocol?, Never> {
        let call = OpenMysteryItemCall()
        
        return call.objectSignal
            .skipNil()
            .flatMap(.latest, {[weak self] (gear) -> SignalProducer<GearProtocol?, Never> in
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
                }
            })
    }
    
    func purchaseQuest(key: String, text: String) -> Signal<UserProtocol?, Never> {
        let call = PurchaseQuestCall(key: key)
        
        return call.objectSignal.on(value: {[weak self]updatedUser in
            if let updatedUser = updatedUser, let userID = self?.currentUserId {
                self?.localUserRepository.updateUser(id: userID, updateUser: updatedUser)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                ToastManager.show(text: L10n.purchased(text), color: .green)
            }
        })
    }
    
    func togglePinnedItem(pinType: String, path: String) -> Signal<PinResponseProtocol?, Never> {
        let call = TogglePinnedItemCall(pinType: pinType, path: path)
        
        return call.objectSignal.on(value: {[weak self] pinResponse in
            if let pinResponse = pinResponse, let userID = self?.currentUserId {
                self?.localRepository.updatePinnedItems(userID: userID, pinResponse: pinResponse)
            }
        })
    }
    
    func retrieveShopInventory(identifier: String) -> Signal<ShopProtocol?, Never> {
        let call = RetrieveShopInventoryCall(identifier: identifier, language: LanguageHandler.getAppLanguage().code)
        
        return call.objectSignal.on(value: {[weak self] shop in
            if let shop = shop {
                shop.identifier = identifier
                if shop.identifier == Constants.SeasonalShopKey {
                    shop.categories.sort(by: { (first, second) -> Bool in
                        if first.items.count == 1 || second.items.count == 1 {
                            return false
                        }
                        if first.items.first?.currency != second.items.first?.currency {
                            return first.items.first?.currency == "gold"
                        }
                        return (first.items.first?.eventEnd ?? Date()) > second.items.first?.eventStart ?? Date()
                    })
                }
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
    
    func feed(pet: PetProtocol, food: FoodProtocol) -> Signal<HabiticaResponse<Int>?, Never> {
        feed(pet: pet, food: food.key ?? "")
    }
    
    func feed(pet: PetProtocol, food: String) -> Signal<HabiticaResponse<Int>?, Never> {
        let call = FeedPetCall(pet: pet.key ?? "", food: food)
        
        if food == "Saddle" {
            call.httpResponseSignal.observeValues { response in
                if response.statusCode == 404 {
                    let alert = HabiticaAlertController(title: L10n.Inventory.noSaddleTile, message: L10n.Inventory.noSaddleDescription)
                    alert.addAction(title: L10n.Inventory.visitMarket, style: .default, isMainAction: true) {_ in
                        RouterHandler.shared.handle(urlString: "/inventory/market")
                    }
                    alert.addCloseAction()
                    alert.show()
                }
            }
        }
        
        return call.habiticaResponseSignal.on(value: {[weak self] response in
            if let message = response?.message {
                let alert = ImageOverlayView(imageName: "stable_Mount_Icon_\(pet.key ?? "")", title: L10n.Stable.evolvedPet(pet.text ?? ""))
                alert.addAction(title: L10n.onwards, isMainAction: true)
                alert.addAction(title: L10n.equip) { _ in
                    self?.equip(type: "mount", key: pet.key ?? "").observeCompleted {}
                }
                alert.addAction(title: L10n.share) { _ in
                    var items: [Any] = [
                    ]
                    if let image = alert.image {
                        items.insert(image, at: 0)
                    }
                    SharingManager.share(identifier: "raisedPet", items: items, presentingViewController: nil, sourceView: nil)
                }
                alert.show()
            }
            if let userID = self?.currentUserId, let trained = response?.data {
                self?.localRepository.updatePetTrained(userID: userID, key: pet.key ?? "", trained: trained, consumedFood: food)
            }
        })
    }
    
    func getNewInAppReward() -> InAppRewardProtocol {
        return localRepository.getNewInAppReward()
    }
    
    func getLatestMysteryGear() -> SignalProducer<GearProtocol?, ReactiveSwiftRealmError> {
        return localRepository.getLatestMysteryGear()
    }
    
    func getCurrentTimeLimitedItems() -> SignalProducer<[ItemProtocol], ReactiveSwiftRealmError> {
        return localRepository.getCurrentTimeLimitedItems()
    }
    
    func getArmoireRemainingCount() -> SignalProducer<ReactiveResults<[GearProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (currentUserID) in
            return self?.localRepository.getArmoireRemainingCount(userID: currentUserID) ?? SignalProducer.empty
        })
    }
}
