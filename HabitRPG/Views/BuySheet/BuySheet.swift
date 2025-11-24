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

struct BuyCurrencyView: View {
    let value: Int
    let currency: Currency
    
    private var textColor: Color {
        switch currency {
        case .gem:
            return ThemeService.shared.theme.isDark ? .green500 : .green1
        case .gold:
            return ThemeService.shared.theme.isDark ? .yellow500 : .yellow1
        case .hourglass:
            return ThemeService.shared.theme.isDark ? .blue500 : .blue1
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
        let content = HStack(spacing: 5) {
            Image(uiImage: currency.getImage())
            Text("\(value.formatted(.number))")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(textColor)
        }.padding(9)
        
        if #available(iOS 26.0, *) {
            content
                .contentTransition(.numericText(countsDown: true))
                .animation(.default, value: value)
                .glassEffect(.regular.tint(backgroundColor.opacity(0.3)))
        } else {
            content
                .contentTransition(.numericText(countsDown: true))
                .animation(.default, value: value)
                .background(backgroundColor.opacity(0.3))
                .cornerRadius(UIConstants.largeCornerRadius)
        }
    }
}

struct BuyBanner<Content: View>: View {
    var color: Color
    var content: Content
    
    private var shape: some Shape {
        if #available(iOS 26.0, *) {
            return .capsule
        } else {
            return .rect(cornerRadius: UIConstants.largeCornerRadius)
        }
    }
    
    var body: some View {
        content
            .scaledFont(size: 15, weight: .semibold)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(color)
            .clipShape(shape)
    }
}

struct BulkPurchaseView: View {
    @Binding var quantity: Int
    let showGem: Bool
    let canPurchase: Bool
    
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    quantity -= 1
                }
            } label: {
                Image(systemName: "minus")
                    .scaledFont(size: 22, weight: .semibold)
            }.disabled(quantity <= 1 || !canPurchase)
            HStack(spacing: 4) {
                if showGem {
                    Image(uiImage: HabiticaIcons.imageOfGem)
                }
                Text("\(quantity)")
                    .contentTransition(.numericText())
                    .scaledFont(size: 22, weight: .bold)
                    .foregroundStyle(Color(canPurchase ? ThemeService.shared.theme.primaryTextColor : ThemeService.shared.theme.ternaryTextColor))
            }
                .padding(.vertical, 11)
                .padding(.horizontal, 31)
                .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                .clipShape(.capsule)
            Button {
                withAnimation {
                    quantity += 1
                }
            } label: {
                Image(systemName: "plus")
                    .scaledFont(size: 22, weight: .semibold)
            }.disabled(!canPurchase)
        }
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
    
    init(item: InAppRewardProtocol, shopIdentifier: String? = nil, onInventoryRefresh: (() -> Void)? = nil) {
        viewModel = BuySheetViewModel(item: item, shopIdentifier: shopIdentifier, onInventoryRefresh: onInventoryRefresh)
    }
    
    @ViewBuilder
    private func itemDetailsView() -> some View {
        VStack(spacing: 0) {
            let item = viewModel.item
            SimpleItemDetails(item: item, user: viewModel.user)
            if item.purchaseType == "gear" {
                StatsDetails(gear: viewModel.gear)
            }
            if item.purchaseType == "quests" {
                QuestDetails(quest: viewModel.quest)
            }
        }
    }
    
    @ViewBuilder
    private func topContent() -> some View {
        HStack {
            if #available(iOS 26.0, *) {
                Button {
                    viewModel.dismiss()
                } label: {
                    Image(systemName: "xmark").frame(width: 30, height: 36).foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                        .font(.system(size: 20, weight: .bold))
                }.buttonStyle(.glass)
                    .clipShape(.circle)
                    .tintColor(Color(ThemeService.shared.theme.windowBackgroundColor).opacity(0.4))
                Spacer()
                BuyCurrencyView(value: viewModel.userCurrencyOwned, currency: viewModel.itemCurrency)
                Spacer()
                if viewModel.canPin {
                    Button {
                        viewModel.pinItem()
                    } label: {
                        if viewModel.isPinned {
                            Image(uiImage: HabiticaIcons.imageOfUnpinItem.withRenderingMode(.alwaysTemplate)).frame(height: 36)
                                .foregroundStyle(ThemeService.shared.theme.isDark ? Color.red500 : Color.maroon100)
                        } else {
                            Image(uiImage: HabiticaIcons.imageOfPinItem.withRenderingMode(.alwaysTemplate)).frame(height: 36)
                                .foregroundStyle(ThemeService.shared.theme.isDark ? Color.purple500 : Color.purple400)
                        }
                    }.buttonStyle(.glassProminent)
                        .tintColor(Color(viewModel.isPinned ? UIColor.red100 : ThemeService.shared.theme.fixedTintColor).opacity(0.4))
                        .clipShape(.circle)
                } else {
                    Spacer().frame(width: 44)
                }
            } else {
                Button {
                    viewModel.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .scaledFont(size: 24)
                        .frame(width: 24, height: 24)
                }.buttonStyle(.bordered)
                    .tint(.gray10)
                    .clipShape(.circle)
                Spacer()
                BuyCurrencyView(value: viewModel.userCurrencyOwned, currency: viewModel.itemCurrency)
                Spacer()
                if viewModel.canPin {
                    Button {
                        viewModel.pinItem()
                    } label: {
                        if viewModel.isPinned {
                            Image(uiImage: HabiticaIcons.imageOfUnpinItem.withRenderingMode(.alwaysTemplate)).frame(height: 36)
                                .foregroundStyle(Color.maroon100)
                        } else {
                            Image(uiImage: HabiticaIcons.imageOfPinItem.withRenderingMode(.alwaysTemplate)).frame(height: 36)
                                .foregroundStyle(Color.purple400)
                        }
                    }.buttonStyle(.borderedProminent)
                        .tintColor(Color(viewModel.isPinned ? UIColor.red100 : ThemeService.shared.theme.fixedTintColor).opacity(0.4))
                        .clipShape(.circle)
                } else {
                    Spacer().frame(width: 44)
                }
            }
        }.padding(.top, 16)
            .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private func bottomContent() -> some View {
        let isDarkTheme = ThemeService.shared.theme.isDark
        VStack(spacing: 16) {
            let remainingGems = viewModel.user?.purchased?.subscriptionPlan?.gemsRemaining ?? 0
            if viewModel.canBulkPurchase {
                BulkPurchaseView(quantity: $viewModel.quantity, showGem: viewModel.item.key == "gem", canPurchase: viewModel.item.key == "gem" ? remainingGems > 0 : true)
            }
            if viewModel.isInstantUse {
                BuyBanner(color: Color(ThemeService.shared.theme.offsetBackgroundColor), content: Text(L10n.takeEffectImmediately).foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                )
            }
            if let date = viewModel.item.availableUntil() {
                BuyBanner(color: (isDarkTheme ? Color.purple500 : .purple400).opacity(0.4), content: Text(L10n.Inventory.availableFor(date.getShortRemainingString()))
                    .foregroundStyle(ThemeService.shared.theme.isDark ? Color.purple600 : Color.purple100))
            } else if viewModel.item.locked {
                BuyBanner(color: Color(ThemeService.shared.theme.offsetBackgroundColor),
                          content: Text(viewModel.item.lockedReason ?? viewModel.item.shortLockedReason ?? L10n.itemIsLocked).foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor)))
            }
            if viewModel.item.key == "gem" {
                let total = viewModel.user?.purchased?.subscriptionPlan?.gemCapTotal ?? 0
                if total > 0 && viewModel.user?.isSubscribed == true {
                    if remainingGems > 0 {
                        BuyBanner(color: (isDarkTheme ? Color.green500 : .green100).opacity(0.4),
                                  content: Text(L10n.Inventory.numberGemsLeft(remainingGems, total)).foregroundStyle(Color.green1))
                    } else {
                        BuyBanner(color: (isDarkTheme ? Color.yellow500 : .yellow100).opacity(0.4),
                                  content: Text(L10n.Inventory.numberGemsLeft(remainingGems, total)).foregroundStyle(Color.green1))
                    }
                } else {
                    // This shouldn't show and is mostly for layouting purposes
                    BuyBanner(color: Color(ThemeService.shared.theme.offsetBackgroundColor), content: Text(L10n.Inventory.noGemsLeft))
                }
            }
            if viewModel.isPurchasing {
                ProgressView().habiticaProgressStyle().frame(width: 42, height: 42)
                    .transition(.opacity)
                    .padding(9)
            } else {
                let canBuy = viewModel.canBuyDisplay
                HabiticaButtonUI(label: HStack(spacing: 5) {
                    Text(L10n.buy.localizedCapitalized)
                    Image(uiImage: viewModel.itemCurrency.getImage()).padding(.leading, 3)
                    Text("\(viewModel.totalValue.formatted(.number))")
                        .contentTransition(.numericText())
                }.foregroundStyle(canBuy ? .white : Color(ThemeService.shared.theme.quadTextColor)),
                                 color: Color(canBuy ? ThemeService.shared.theme.fixedTintColor : ThemeService.shared.theme.offsetBackgroundColor)) {
                    viewModel.buyPressed()
                }.disabled(!canBuy)
                    .transition(.opacity)
            }
        }.padding(.bottom, 28)
    }
    
    var body: some View {
        if viewModel.item.isValid {
            BottomSheetView(dismisser: viewModel.dismisser, content: VStack(spacing: 0) {
                let scrollView = ScrollView {
                    itemDetailsView()
                }
                    .scrollBounceBehavior(.basedOnSize)
                if #available(iOS 26.0, *) {
                    scrollView
                        .safeAreaBar(edge: .top,
                                     alignment: .center,
                                     spacing: 0,
                                     content: topContent)
                        .safeAreaBar(edge: .bottom,
                                     alignment: .center,
                                     spacing: 0,
                                     content: bottomContent)
                        .scrollEdgeEffectStyle(.soft, for: .all)
                        .scrollEdgeEffectHidden(false)
                        .scrollIndicators(.hidden)
                } else {
                    topContent()
                    scrollView
                    bottomContent()
                }
            },
                            topPadding: 0,
                            bottomPadding: 0
            )
            .ignoresSafeArea()
        } else {
            Text("")
                .task {
                    viewModel.dismiss()
                }
        }
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
