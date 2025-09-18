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

struct QuestDetails: View {
    let quest: QuestProtocol?
    
    var body: some View {
        Text(quest?.boss?.name ?? "")
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
        SimpleItemDetails(item: item)
        if item.purchaseType == "gear" {
            StatsDetails(gear: viewModel.gear)
        }
        if item.purchaseType == "quests" {
            QuestDetails(quest: viewModel.quest)
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
