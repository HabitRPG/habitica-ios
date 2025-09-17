//
//  BuySheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.09.25.
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
    
    let itemCurrency: Currency
    
    var userCurrencyOwned: Int {
        if itemCurrency == .gold {
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
        
        if item.purchaseType == "gear" {
            inventoryRepository.getGear(keys: [item.key ?? ""]).take(first: 1)
                .on(value: { foundGear in
                    self.gear = foundGear.value.first
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

struct BuyCurrencyView: View {
    let value: Int
    let currency: Currency
    
    private var textColor: Color {
        switch currency {
        case .gem:
            return .green1
        case .gold:
            return .yellow1
        case .hourglass:
            return .blue1
        }
    }
    
    private var backgroundColor: Color {
        switch currency {
        case .gem:
            return .green500
        case .gold:
            return .yellow500
        case .hourglass:
            return .blue500
        }
    }
    
    var body: some View {
        HStack(spacing: 5) {
            Image(uiImage: currency.getImage())
            Text("\(value.formatted(.number))")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(textColor)
        }.padding(9)
            .background(backgroundColor.opacity(0.8))
            .cornerRadius(26)
    }
}

struct SimpleItemDetails: View {
    let item: InAppRewardProtocol

    var body: some View {
        if let sprite = item.imageName {
            if #available(iOS 26.0, *) {
                PixelArtView(name: sprite).frame(width: 120, height: 120)
                    .glassEffect(.regular.tint(Color(ThemeService.shared.theme.windowBackgroundColor).opacity(0.65)), in: RoundedRectangle(cornerRadius: 26))
                    .padding(.bottom, 9)
            } else {
                PixelArtView(name: sprite).frame(width: 120, height: 120)
                    .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                    .cornerRadius(26)
                    .padding(.bottom, 9)
            }
        }
        Text(item.text ?? "").foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor)).scaledFont(size: 22, weight: .bold)
        if let notes = item.notes, !notes.isEmpty {
            Text(notes).foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor)).scaledFont(size: 17)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.top, 6)
        }
    }
}

struct StatsLabel: View {
    let label: String
    let value: Int?
    
    var body: some View {
        HStack {
            Text("\(label):").foregroundStyle((value ?? 0) > 0 ? Color(ThemeService.shared.theme.primaryTextColor) : Color(ThemeService.shared.theme.dimmedTextColor))
            Spacer()
            if let value = value {
                Text("+\(value)").foregroundStyle(value > 0 ? Color(ThemeService.shared.theme.successColor) : Color(ThemeService.shared.theme.dimmedTextColor))
            }
        }
    }
}

struct StatsDetails: View {
    let gear: GearProtocol?
    
    var body: some View {
        VStack {
            HStack(spacing: 29) {
                StatsLabel(label: "STR", value: gear?.strength)
                StatsLabel(label: "PER", value: gear?.perception)
            }
            HStack(spacing: 29) {
                StatsLabel(label: "CON", value: gear?.constitution)
                StatsLabel(label: "INT", value: gear?.intelligence)
            }
        }
        .scaledFont(size: 17, weight: .semibold)
        .padding(.vertical, 25)
            .padding(.horizontal, 33)
            .background(Color(ThemeService.shared.theme.windowBackgroundColor))
            .cornerRadius(26)
            .padding(.top, 16)
            .padding(.horizontal, 44)
    }
}

struct BuyBanner<Content: View>: View {
    var color: Color
    var content: Content
    
    var body: some View {
        content
            .scaledFont(size: 15, weight: .semibold)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(color)
            .clipShape(.capsule)
            .padding(.top, 16)
    }
}

struct BuySheet: View, Dismissable {
    @ObservedObject private var viewModel: BuySheetViewModel
    
    var dismisser: Dismisser {
        get {
            return viewModel.dismisser
        }
        set {
            viewModel.dismisser = newValue
        }
    }
    
    init(item: InAppRewardProtocol, shopIdentifier: String?, onInventoryRefresh: (() -> Void)? = nil) {
        viewModel = BuySheetViewModel(item: item, shopIdentifier: shopIdentifier, onInventoryRefresh: onInventoryRefresh)
    }
    
    @ViewBuilder
    private func itemDetailsView() -> some View {
        let item = viewModel.item
        if item.type == "quest" {
            SimpleItemDetails(item: item)
        } else {
            SimpleItemDetails(item: item)
        }
        if item.purchaseType == "gear" {
            StatsDetails(gear: viewModel.gear)
        }
    }
    
    var body: some View {
        let theme = ThemeService.shared.theme
        BottomSheetView(dismisser: viewModel.dismisser, content: VStack(spacing: 0) {
            HStack {
                if #available(iOS 26.0, *) {
                    Button {
                        viewModel.dismiss()
                    } label: {
                        Image(systemName: "xmark").frame(width: 30, height: 36).foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                            .font(.system(size: 20, weight: .bold))
                    }.buttonStyle(.glass)
                        .clipShape(.circle)
                        .tintColor(Color(ThemeService.shared.theme.windowBackgroundColor))
                    Spacer()
                    BuyCurrencyView(value: viewModel.userCurrencyOwned, currency: viewModel.itemCurrency)
                    Spacer()
                    if viewModel.canPin {
                        Button {
                            viewModel.pinItem()
                        } label: {
                            if viewModel.isPinned {
                                Image(uiImage: HabiticaIcons.imageOfUnpinItem.withRenderingMode(.alwaysTemplate)).frame(height: 36)

                            } else {
                                Image(uiImage: HabiticaIcons.imageOfPinItem.withRenderingMode(.alwaysTemplate)).frame(height: 36)
                            }
                        }.buttonStyle(.glassProminent)
                            .tintColor(Color(viewModel.isPinned ? UIColor.red100 : ThemeService.shared.theme.fixedTintColor))
                    } else {
                        Spacer().frame(width: 44)
                    }
                } else {
                    Button {
                        viewModel.dismiss()
                    } label: {
                        Image(systemName: "xmark").frame(width: 30, height: 36).foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                            .font(.system(size: 20, weight: .bold))
                    }
                        .clipShape(.circle)
                        .tintColor(Color(ThemeService.shared.theme.windowBackgroundColor))
                    Spacer()
                    BuyCurrencyView(value: viewModel.userCurrencyOwned, currency: viewModel.itemCurrency)
                    Spacer()
                    if viewModel.canPin {
                        Button {
                            viewModel.pinItem()
                        } label: {
                            if viewModel.isPinned {
                                Image(uiImage: HabiticaIcons.imageOfUnpinItem.withRenderingMode(.alwaysTemplate)).frame(height: 36)
                            } else {
                                Image(uiImage: HabiticaIcons.imageOfPinItem.withRenderingMode(.alwaysTemplate)).frame(height: 36)
                            }
                        }.buttonStyle(.borderedProminent)
                            .tintColor(Color(viewModel.isPinned ? UIColor.red100 : ThemeService.shared.theme.fixedTintColor))
                    } else {
                        Spacer().frame(width: 44)
                    }
                }
            }
            .padding(.bottom, 26)
            Spacer()
            itemDetailsView()
            if viewModel.isInstantUse {
                BuyBanner(color: Color(theme.offsetBackgroundColor), content: Text(L10n.takeEffectImmediately).foregroundStyle(Color(theme.secondaryTextColor))
                          )
            }
            if let date = viewModel.item.availableUntil() {
                BuyBanner(color: .purple500, content: Text(L10n.Inventory.availableFor(date.getShortRemainingString()))
                    .foregroundStyle(Color.purple100))
            }
            Spacer()
            let canBuy = viewModel.canBuy
            if viewModel.isPurchasing {
                ProgressView().habiticaProgressStyle().frame(width: 42, height: 42)
                    .transition(.opacity)
                    .padding(9)
                    .padding(.top, 15)
            } else {
                HabiticaButtonUI(label: HStack(spacing: 5) {
                    Text(L10n.buy.localizedCapitalized)
                    Image(uiImage: viewModel.itemCurrency.getImage()).padding(.leading, 3)
                    Text("\(viewModel.item.value.formatted(.number))")
                }.foregroundStyle(canBuy ? .white : Color(theme.quadTextColor)),
                                 color: Color(canBuy ? theme.fixedTintColor : theme.offsetBackgroundColor)) {
                    viewModel.buyPressed()
                }.disabled(!canBuy)
                    .transition(.opacity)
                    .padding(.top, 15)
            }
        }.padding(.vertical, 17)
                        )
        .ignoresSafeArea()
    }
}

private class PreviewInAppReward: InAppRewardProtocol {
    var key: String?
    var eventStart: Date?
    var eventEnd: Date?
    var endDate: Date?
    var currency: String?
    var isSuggested: Bool = false
    var lastPurchased: Date?
    var locked: Bool = false
    var path: String?
    var pinType: String?
    var purchaseType: String?
    var imageName: String?
    var isSubscriberItem: Bool = false
    var unlockConditionReason: String?
    var unlockConditionText: String?
    var unlockConditionIncentiveThreshold: Int = 0
    var previous: String?
    var level: Int = 0
    var category: (any Habitica_Models.ShopCategoryProtocol)?
    var text: String?
    var notes: String?
    var type: String?
    var value: Float = 20
    var isValid: Bool = true
    var isManaged: Bool = false
}

#Preview("BuySheet Egg") {
    if #available(iOS 26.0, *) {
        NavigationView(content: {
            Image("market").resizable().frame(maxHeight: .infinity)
                .ignoresSafeArea()
        })
        .sheet(isPresented: .constant(true)) {
            let item = PreviewInAppReward()
            item.imageName = "Pet_Egg_Wolf"
            item.text = "Wolf Egg"
            item.notes = "Give it food, make it big"
            return BuySheet(item: item, shopIdentifier: "market")
                .presentationDetents([.fraction(0.5), .medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}

#Preview("BuySheet Potion") {
    if #available(iOS 26.0, *) {
        NavigationView(content: {
            Image("market").resizable().frame(maxHeight: .infinity)
                .ignoresSafeArea()
        })
        .sheet(isPresented: .constant(true)) {
            let item = PreviewInAppReward()
            item.key = "potion"
            item.imageName = "shop_potion"
            item.text = "Health Potion"
            item.notes = "Recovers 15 Health (Instant Use)"
            return BuySheet(item: item, shopIdentifier: nil)
                .presentationDetents([.fraction(0.55), .medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}

#Preview("BuySheet Gear") {
    if #available(iOS 26.0, *) {
        NavigationView(content: {
            Image("market").resizable().frame(maxHeight: .infinity)
                .ignoresSafeArea()
        })
        .sheet(isPresented: .constant(true)) {
            let item = PreviewInAppReward()
            item.key = "armor_birthday_2020"
            item.type = "gear"
            item.imageName = "shop_armor_special_birthday2020"
            item.text = "Absurd Party Robes"
            item.notes = "Happy Birthday Habitica! Wear these Absurd Party Robes to celebrate this wonderful day."
            return BuySheet(item: item, shopIdentifier: nil)
                .presentationDetents([.fraction(0.7), .large])
                .presentationDragIndicator(.hidden)
        }
    }
}
