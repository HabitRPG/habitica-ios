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
import SwiftUIX

class BuySheetViewModel: ViewModel {
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    private let customizationRepository = CustomizationRepository()
    private let stableRepository = StableRepository()
    
    var item: InAppRewardProtocol
    var shopIdentifier: String?
    var onInventoryRefresh: (() -> Void)?
    var dismisser: Dismisser = Dismisser()
    
    @Published var keyboardHeight: CGFloat = 0

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
    
    var canAffordDisplay: Bool {
        if itemCurrency == .hourglass || itemCurrency == .gem {
            return true
        }
        return totalValue <= Float(userCurrencyOwned)
    }
    
    var canAfford: Bool {
        return totalValue <= Float(userCurrencyOwned)
    }
    
    var isLocked: Bool {
        return item.locked == true
    }
    
    var canBuyDisplay: Bool {
        if item.key == "gem" && user?.purchased?.subscriptionPlan?.gemsRemaining == 0 {
            return false
        }
        return canAffordDisplay && !isLocked
    }
    
    var canBuy: Bool {
        return canAfford && !isLocked
    }
    
    var canBulkPurchase: Bool {
        return item.key == "gem" || ["eggs", "hatchingPotions", "food"].contains(item.purchaseType ?? "") || item.pinType == "seasonalSpell"
    }
    
    init(item: InAppRewardProtocol, shopIdentifier: String?, onInventoryRefresh: (() -> Void)?) {
        self.item = item
        self.shopIdentifier = shopIdentifier
        self.onInventoryRefresh = onInventoryRefresh
        itemCurrency = Currency(rawValue: item.currency ?? "gold") ?? .gold
        super.init()
        setup()
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(self.keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func keyboardShow(notice: Notification) {
        keyboardHeight = KeyboardManager.height
    }
    
    @objc
    func keyboardHide(notice: Notification) {
        keyboardHeight = 0
    }
    
    func setup() {
        if shopIdentifier == nil {
            isPinned = true
        }
        
        disposable.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start())
        
        if item.purchaseType == "gear" {
            disposable.add(inventoryRepository.getGear(keys: [item.key ?? ""]).take(first: 1)
                .on(value: { foundGear in
                    self.gear = foundGear.value.first
                })
                .start())
        } else if item.purchaseType == "quests" {
            disposable.add(inventoryRepository.getQuest(key: item.key ?? "").take(first: 1)
                .on(value: { quest in
                    self.quest = quest
                })
                .start())
        }
        
        disposable.add(userRepository.getInAppRewards().take(first: 1)
            .map({ (rewards, _) in
                return rewards.map({ (reward) in
                    return reward.key
                })
            }).on(value: {[weak self]rewards in
                self?.isPinned = rewards.contains(self?.item.key)
            }).start())
    }
    
    func dismiss() {
        dispose()
        dismisser.dismiss()
    }
    
    func pinItem() {
        guard let pinType = item.pinType, let path = item.path else {
            return
        }
        inventoryRepository.togglePinnedItem(pinType: pinType, path: path)
            .flatMap(.latest, { _ in
                self.userRepository.retrieveInAppRewards()
            })
            .observeValues {[weak self] (_) in
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
                    BuySheetViewModel.displayGemCapReachedModal()
                } else if !canAfford {
                    if currency == .hourglass {
                        if user?.isSubscribed == true {
                            BuySheetViewModel.displayInsufficientHourglassesModal(user: user)
                        } else {
                            HabiticaApplication.shared.topmostViewController?.present(SubscriptionModalViewController(presentationPoint: .timetravelers), animated: true)
                        }
                    } else if currency == .gem {
                        BuySheetViewModel.displayInsufficientGemsModal(reward: item)
                    } else {
                        BuySheetViewModel.displayInsufficientGoldModal()
                    }
                }
                return
            }
            remainingPurchaseQuantity { remainingQuantity in
                var quantity = self.quantity
                if remainingQuantity >= 0 {
                    if remainingQuantity < quantity {
                        self.displayPurchaseConfirmationDialog(quantity: remainingQuantity)
                        return
                    }
                }
                if self.item.purchaseType == "gems", let remaining = self.user?.purchased?.subscriptionPlan?.gemsRemaining {
                    quantity = min(remaining, quantity)
                }
                withAnimation {
                    self.isPurchasing = true
                }
                self.buyItem(quantity: quantity)
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
    
    static func displayInsufficientGemsModal(reward: InAppRewardProtocol? = nil, reason: String = "purchase modal", delayDisplay: Bool = true) {
        HabiticaAnalytics.shared.log("show insufficient gems modal", withEventProperties: ["reason": "purchase modal", "item": reward?.key ?? ""])
        let sheet = InsufficientCurrencySheet(backgroundColor: .purple400,
                                              circleColor: .purple100,
                                              ringColor: .purple300,
                                              plusColor: .purple500,
                                              icon: Image(Asset.insufficientGems.name),
                                              title: Text(L10n.moreGemsMessage),
                                              content: Text(L10n.gemsSupportDevelopers)) {
            HabiticaButtonUI(label: Text(L10n.purchaseGems), color: Color(ThemeService.shared.theme.tintColor)) {
                RouterHandler.shared.handle(.purchaseGems)
            }
        }
        let viewController = HostingBottomSheetController(rootView: sheet, prefersGrabberVisible: false)
        if delayDisplay {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                viewController.show()
            }
        } else {
            viewController.show()
        }
    }
    
    static func displayInsufficientGoldModal() {
        let sheet = InsufficientCurrencySheet(backgroundColor: .yellow100,
                                              circleColor: Color(ThemeService.shared.theme.contentBackgroundColor),
                                              ringColor: .yellow500,
                                              plusColor: .yellow10,
                                              icon: Image(Asset.insufficientGold.name),
                                              title: Text(L10n.notEnoughGold),
                                              content: Text(L10n.completeMoreTasks)) {
        }
        let viewController = HostingBottomSheetController(rootView: sheet, prefersGrabberVisible: false)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            viewController.show()
        }
    }
    
    static func displayInsufficientHourglassesModal(user: UserProtocol?) {
        let isSubscribed = user?.isSubscribed == true
        let sheet = InsufficientCurrencySheet(backgroundColor: .blue100,
                                              circleColor: Color(ThemeService.shared.theme.contentBackgroundColor),
                                              ringColor: .blue500,
                                              plusColor: .blue10,
                                              icon: Image(Asset.insufficientHourglasses.name),
                                              title: Text(L10n.notEnoughHourglasses),
                                              content: Text(isSubscribed ? L10n.insufficientHourglassesMessageSubscriber : L10n.insufficientHourglassesMessage)) {
            HabiticaButtonUI(label: Text(L10n.learnMore), color: Color(ThemeService.shared.theme.tintColor)) {
                RouterHandler.shared.handle(.subscription)
            }
        }
        let viewController = HostingBottomSheetController(rootView: sheet, prefersGrabberVisible: false)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            viewController.show()
        }
    }
    
    static func displayGemCapReachedModal() {
        let sheet = InsufficientCurrencySheet(backgroundColor: .purple400,
                                              circleColor: .purple100,
                                              ringColor: .purple300,
                                              plusColor: .purple500,
                                              icon: Image(Asset.insufficientGems.name),
                                              title: Text(L10n.monthlyGemCapReached),
                                              content: Text(L10n.Inventory.noGemsLeft)) {
        }
        let viewController = HostingBottomSheetController(rootView: sheet, prefersGrabberVisible: false)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            viewController.show()
        }
    }
    
    func displayPurchaseConfirmationDialog(quantity: Int) {
        if quantity == 0 {
            displayNoRemainingConfirmationDialog()
        } else {
            displaySomeRemainingConfirmationDialog(quantity: quantity)
        }
    }
    
    func displayNoRemainingConfirmationDialog() {
        let alert = HabiticaAlertController(title: L10n.excessItems, message: L10n.excessNoItemsLeft(item.text ?? "", quantity, item.text ?? ""))
        alert.addAction(title: L10n.purchaseX(quantity), isMainAction: true) { _ in
            self.buyItem(quantity: self.quantity)
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addCancelAction()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.enqueue()
        }
    }
    
    func displaySomeRemainingConfirmationDialog(quantity: Int) {
        let alert = HabiticaAlertController(title: L10n.excessItems, message: L10n.excessXItemsLeft(quantity, item.text ?? "", quantity))
        alert.addAction(title: L10n.purchaseX(quantity), isMainAction: true) { _ in
            self.buyItem(quantity: self.quantity)
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addCancelAction()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.enqueue()
        }
    }
}
