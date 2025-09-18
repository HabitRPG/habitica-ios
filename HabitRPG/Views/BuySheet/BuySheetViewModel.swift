//
//  BuySheetViewModel.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.09.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//


import SwiftUI
import Habitica_Models
import ReactiveSwift
import Habitica_Database

class BuySheetViewModel: ObservableObject {
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    private let customizationRepository = CustomizationRepository()
    private let stableRepository = StableRepository()
    
    var item: InAppRewardProtocol
    var shopIdentifier: String?
    var onInventoryRefresh: (() -> Void)?
    var dismisser: Dismisser = Dismisser()

    @Published var user: UserProtocol?
    @Published var isPinned: Bool = false
    @Published var quantity: Int = 1
    @Published var isPurchasing = false
    
    @Published var gear: GearProtocol?
    @Published var quest: QuestProtocol?
    
    let itemCurrency: Currency
    
    var userCurrencyOwned: Int {
        if itemCurrency == .gem {
            return user?.gemCount ?? 0
        } else if itemCurrency == .hourglass {
            return user?.purchased?.subscriptionPlan?.consecutive?.hourglasses ?? 0
        } else {
            return Int(user?.stats?.gold ?? 0)
        }
    }
    
    var totalValue: Float {
        return item.value * Float(quantity)
    }
    
    var isInstantUse: Bool {
        return item.key == "potion"
    }
    
    var canPin: Bool {
        return item.key != "armoire" && item.key != "potion"
    }
    
    var canAfford: Bool {
        if itemCurrency == .hourglass || itemCurrency == .gem {
            return true
        }
        return item.value <= Float(userCurrencyOwned)
    }
    
    var isLocked: Bool {
        return item.locked == true
    }
    
    var canBuy: Bool {
        return canAfford && !isLocked
    }
    
    var canBulkPurchase: Bool {
        return item.key == "gem" || ["eggs", "hatchingPotions", "food"].contains(item.purchaseType ?? "")
    }
    
    init(item: InAppRewardProtocol, shopIdentifier: String?, onInventoryRefresh: (() -> Void)?) {
        self.item = item
        self.shopIdentifier = shopIdentifier
        self.onInventoryRefresh = onInventoryRefresh
        itemCurrency = Currency(rawValue: item.currency ?? "gold") ?? .gold
        setup()
    }
    
    func setup() {
        if shopIdentifier == nil {
            isPinned = true
        }
        
        userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start()
        
        if item.purchaseType == "gear" {
            inventoryRepository.getGear(keys: [item.key ?? ""]).take(first: 1)
                .on(value: { foundGear in
                    self.gear = foundGear.value.first
                })
                .start()
        } else if item.purchaseType == "quest" {
            inventoryRepository.getQuest(key: item.key ?? "").take(first: 1)
                .on(value: { quest in
                    self.quest = quest
                })
                .start()
        }
        
        userRepository.getInAppRewards().take(first: 1)
            .map({ (rewards, _) in
                return rewards.map({ (reward) in
                    return reward.key
                })
            }).on(value: {[weak self]rewards in
                self?.isPinned = rewards.contains(self?.item.key)
            }).start()
    }
    
    func dismiss() {
        if let action = dismisser.dismiss {
            action()
        }
    }
    
    func pinItem() {
        guard let pinType = item.pinType, let path = item.path else {
            return
        }
        inventoryRepository.togglePinnedItem(pinType: pinType, path: path).observeValues {[weak self] (_) in
            self?.isPinned = !(self?.isPinned ?? false)
        }
    }
    
    func buyPressed() {
        if item.isValid != true {
            return
        }
        if isLocked {
            return
        }
        
        if item.key?.isEmpty == false {
            let currency = itemCurrency
            if !canBuy {
                if item.key == "gem" {
                    HRPGBuyItemModalViewController.displayGemCapReachedModal()
                } else if !canAfford {
                    if currency == .hourglass {
                        if user?.isSubscribed == true {
                            HRPGBuyItemModalViewController.displayInsufficientHourglassesModal(user: user)
                        } else {
                            SubscriptionModalViewController(presentationPoint: .timetravelers).show()
                        }
                    } else if currency == .gem {
                        HRPGBuyItemModalViewController.displayInsufficientGemsModal(reward: item)
                    } else {
                        HRPGBuyItemModalViewController.displayInsufficientGoldModal()
                    }
                }
                return
            }
            remainingPurchaseQuantity { remainingQuantity in
                if remainingQuantity >= 0 {
                    if remainingQuantity < self.quantity {
                        // self.displayPurchaseConfirmationDialog(quantity: remainingQuantity)
                        return
                    }
                }
                withAnimation {
                    self.isPurchasing = true
                }
                self.buyItem(quantity: self.quantity)
            }
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    private func buyItem(quantity: Int) {
        let key = item.key ?? ""
        let purchaseType = item.purchaseType ?? ""
        let setIdentifier = item.key ?? ""
        let value = Int(item.value)
        let text = item.text ?? ""
        let handleResult = {[weak self] (result: Result<UserProtocol?, Never>) in
                switch result {
                case .success:
                    SoundManager.shared.play(effect: .rewardBought)
                    self?.userRepository.retrieveInAppRewards().observeCompleted {
                    }
                    if let action = self?.onInventoryRefresh {
                        action()
                    }
                    self?.dismiss()
                case .failure:
                    withAnimation {
                        self?.isPurchasing = false
                    }
                    // HRPGBuyItemModalViewController.displayInsufficientHourglassesModal(user: self?.user)
                }
        }
        if itemCurrency == .hourglass {
            if purchaseType == "gear" || purchaseType == "mystery_set" {
                inventoryRepository.purchaseMysterySet(identifier: setIdentifier, text: text)
                .flatMap(.latest, { _ in
                    return self.userRepository.retrieveUser()
                }).observeResult(handleResult)
            } else {
                inventoryRepository.purchaseHourglassItem(purchaseType: purchaseType, key: key, text: text)
                .flatMap(.latest, { _ in
                    return self.userRepository.retrieveUser()
                }).observeResult(handleResult)
            }
        } else if purchaseType == "fortify" {
            userRepository.reroll().observeResult(handleResult)
        } else if purchaseType == "backgrounds" || purchaseType == "customization" {
            let path: String
            if purchaseType == "backgrounds" {
                path = "background.\(item.key ?? "")"
            } else {
                path = item.path ?? ""
            }
            customizationRepository.unlock(path: path, value: item.value, text: text).observeResult(handleResult)
        } else if itemCurrency == .gem || purchaseType == "gems" {
            inventoryRepository.purchaseItem(purchaseType: purchaseType, key: key, value: value, quantity: quantity, text: text)
            .flatMap(.latest, { _ in
                return self.userRepository.retrieveUser()
            }).observeResult(handleResult)
        } else {
            if itemCurrency == .gold && purchaseType == "quests" {
                inventoryRepository.purchaseQuest(key: key, text: text)
                    .flatMap(.latest, { _ in
                        return self.userRepository.retrieveUser()
                    })
                    .observeResult(handleResult)
            } else if purchaseType == "debuffPotion" {
                userRepository.useDebuffItem(key: key).observeResult(handleResult)
            } else {
                inventoryRepository.buyObject(key: key, quantity: quantity, price: value, text: text)
                    .flatMap(.latest, { _ in
                        return self.userRepository.retrieveUser(forced: true)
                    })
                    .observeResult(handleResult)
            }
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    private func remainingPurchaseQuantity(onResult: @escaping ((Int) -> Void)) {
        var ownedCount = 0
        var shouldWarn = true
        var hasNoMounts = false
        if item.purchaseType == "eggs" {
            stableRepository.getPets(query: "type == 'quest' && egg == '\(item.key ?? "")'").take(first: 1).filter { pets -> Bool in
                shouldWarn = !pets.value.isEmpty
                return shouldWarn
            }.flatMap(.latest) { _ in
                return self.inventoryRepository.getOwnedItems(userID: nil, itemType: "eggs")
            }.flatMap(.latest) { eggs -> SignalProducer<ReactiveResults<[OwnedPetProtocol]>, ReactiveSwiftRealmError> in
                for egg in eggs.value where egg.key == self.item.key {
                    ownedCount += egg.numberOwned
                }
                return self.stableRepository.getOwnedPets()
            }.flatMap(.latest) { pets -> SignalProducer<ReactiveResults<[OwnedMountProtocol]>, ReactiveSwiftRealmError> in
                for pet in pets.value where pet.key?.contains(self.item.key ?? "") == true {
                    ownedCount += 1
                }
                return self.stableRepository.getOwnedMounts()
                }.take(first: 1)
                .on(completed: {
                    if !shouldWarn {
                        onResult(-1)
                        return
                    }
                    let remaining = 20 - ownedCount
                    onResult(max(0, remaining))
                }, value: { mounts in
                    for mount in mounts.value where mount.key?.contains(self.item.key ?? "") == true {
                        ownedCount += 1
                    }
                })
                .start()
        } else if item.purchaseType == "hatchingPotions" {
            stableRepository.getPets(query: "(type == 'premium' || type == 'wacky') && potion == '\(item.key ?? "")'").take(first: 1).filter { pets -> Bool in
            shouldWarn = !pets.value.isEmpty
                if pets.value.first?.type == "wacky" {
                    hasNoMounts = true
                }
            return shouldWarn
            }.flatMap(.latest) { _ in
                return self.inventoryRepository.getOwnedItems(userID: nil, itemType: "hatchingPotions")
            }.flatMap(.latest) { potions -> SignalProducer<ReactiveResults<[OwnedPetProtocol]>, ReactiveSwiftRealmError> in
                for potion in potions.value where potion.key == self.item.key {
                    ownedCount += potion.numberOwned
                }
                return self.stableRepository.getOwnedPets()
            }.flatMap(.latest) { pets -> SignalProducer<ReactiveResults<[OwnedMountProtocol]>, ReactiveSwiftRealmError> in
                for pet in pets.value where pet.key?.contains(self.item.key ?? "") == true {
                    ownedCount += 1
                }
                return self.stableRepository.getOwnedMounts()
                }.take(first: 1)
                .on(completed: {
                    if !shouldWarn {
                        onResult(-1)
                        return
                    }
                    let remaining = (hasNoMounts ? 9 : 18) - ownedCount
                    onResult(max(0, remaining))
                }, value: { mounts in
                    for mount in mounts.value where mount.key?.contains(self.item.key ?? "") == true {
                        ownedCount += 1
                    }
                })
                .start()
        } else {
            onResult(-1)
        }
    }
}
