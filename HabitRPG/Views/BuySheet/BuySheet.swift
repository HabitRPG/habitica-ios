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

private struct QuestGoalViewUI: View {
    let quest: QuestProtocol
    
    var body: some View {
        VStack(spacing: 0) {
            if let boss = quest.boss {
                HStack {
                    Text(boss.name ?? "")
                    Spacer()
                    HStack(spacing: 4) {
                        Text("\(boss.health)")
                            .padding(.leading, 4)
                            .font(.system(size: 15, weight: .semibold))
                        Image(uiImage: HabiticaIcons.imageOfHeartLightBg)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }.padding(4)
                        .background(Color.red500)
                        .cornerRadius(26)
                }
                .padding(.vertical, 11)
                .padding(.leading, 25)
                .padding(.trailing, 11)
                .foregroundStyle(Color.red1)
                .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.red100)
            }
            if let collects = quest.collect {
                HStack {
                    Text(L10n.collect)
                    Spacer()
                    let collectCount = collects.map { collect in
                        return collect.count
                    }.reduce(0) { partial, next in
                        return partial + next
                    }
                    Text("\(collectCount)")
                        .font(.system(size: 15, weight: .semibold))
                        .padding(4)
                    .background(Color.red500)
                    .cornerRadius(26)
                }
                .padding(.vertical, 11)
                .padding(.leading, 25)
                .padding(.trailing, 11)
                .foregroundStyle(Color.red1)
                .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.red100)
            }
            HStack {
                Text(L10n.difficulty).foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                Spacer()
                Image(uiImage: HabiticaIcons.imageOfDifficultyStars(difficulty: quest.difficulty))
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                        .cornerRadius(26)
            }
            .padding(.vertical, 11)
            .padding(.leading, 25)
            .padding(.trailing, 11)
        }
        .font(.system(size: 17, weight: .semibold))
        .background(Color(ThemeService.shared.theme.windowBackgroundColor))
        .cornerRadius(26)
        .padding(.vertical, 15)
    }
}

struct QuestReward<Icon: View, Label: View>: View {
    let icon: Icon
    let label: Label
    
    var body: some View {
        HStack(spacing: 14) {
            icon
                .frame(width: 68, height: 68)
                .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                .cornerRadius(14)
            label
                .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                .scaledFont(size: 15, weight: .semibold)
                .frame(maxWidth: .infinity)
        }
        .padding(4)
        .background(Color(ThemeService.shared.theme.windowBackgroundColor))
        .cornerRadius(16)
    }
}

struct QuestDetails: View {
    let quest: QuestProtocol?
    
    var body: some View {
        if let quest = quest {
            QuestGoalViewUI(quest: quest)
            Text(L10n.Tasks.rewards)
                .scaledFont(size: 16, weight: .semibold)
            VStack(spacing: 8) {
                if let experience = quest.drop?.experience {
                    QuestReward(icon: Image(uiImage: HabiticaIcons.imageOfExperienceReward), label: Text(L10n.Quests.rewardExperience(experience)))
                }
                if let gold = quest.drop?.gold {
                    QuestReward(icon: Image(uiImage: HabiticaIcons.imageOfGoldReward), label: Text(L10n.Quests.rewardGold(gold)))
                }
                ForEach(quest.drop?.items ?? [], id: \.key) { drop in
                    QuestReward(icon: PixelArtView(name: drop.imageName), label: Text(drop.text ?? ""))
                }
            }
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
        let content = HStack(spacing: 5) {
            Image(uiImage: currency.getImage())
            Text("\(value.formatted(.number))")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(textColor)
        }.padding(9)
        
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(backgroundColor.opacity(0.3)))
        } else {
            content
            .background(backgroundColor.opacity(0.3))
            .cornerRadius(26)
        }
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
            .frame(maxWidth: .infinity)
            .background(color)
            .clipShape(.capsule)
            .padding(.bottom, 16)
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
        let item = viewModel.item
        SimpleItemDetails(item: item)
        if item.purchaseType == "gear" {
            StatsDetails(gear: viewModel.gear)
        }
        if item.purchaseType == "quests" {
            QuestDetails(quest: viewModel.quest)
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
                                .foregroundStyle(Color.maroon100)
                        } else {
                            Image(uiImage: HabiticaIcons.imageOfPinItem.withRenderingMode(.alwaysTemplate)).frame(height: 36)
                                .foregroundStyle(Color.purple400)
                        }
                    }.buttonStyle(.glassProminent)
                        .tintColor(Color(viewModel.isPinned ? UIColor.red100 : ThemeService.shared.theme.fixedTintColor).opacity(0.4))
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
                                .foregroundStyle(Color.maroon100)
                        } else {
                            Image(uiImage: HabiticaIcons.imageOfPinItem.withRenderingMode(.alwaysTemplate)).frame(height: 36)
                                .foregroundStyle(Color.purple400)
                        }
                    }.buttonStyle(.borderedProminent)
                        .tintColor(Color(viewModel.isPinned ? UIColor.red100 : ThemeService.shared.theme.fixedTintColor))
                } else {
                    Spacer().frame(width: 44)
                }
            }
        }.padding(.top, 16)
            .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private func bottomContent() -> some View {
        VStack {
            if viewModel.isInstantUse {
                BuyBanner(color: Color(ThemeService.shared.theme.offsetBackgroundColor), content: Text(L10n.takeEffectImmediately).foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                )
            }
            if let date = viewModel.item.availableUntil() {
                BuyBanner(color: .purple500.opacity(0.4), content: Text(L10n.Inventory.availableFor(date.getShortRemainingString()))
                    .foregroundStyle(Color.purple100))
            }
            let canBuy = viewModel.canBuy
            if viewModel.isPurchasing {
                ProgressView().habiticaProgressStyle().frame(width: 42, height: 42)
                    .transition(.opacity)
                    .padding(9)
            } else {
                HabiticaButtonUI(label: HStack(spacing: 5) {
                    Text(L10n.buy.localizedCapitalized)
                    Image(uiImage: viewModel.itemCurrency.getImage()).padding(.leading, 3)
                    Text("\(viewModel.item.value.formatted(.number))")
                }.foregroundStyle(canBuy ? .white : Color(ThemeService.shared.theme.quadTextColor)),
                                 color: Color(canBuy ? ThemeService.shared.theme.fixedTintColor : ThemeService.shared.theme.offsetBackgroundColor)) {
                    viewModel.buyPressed()
                }.disabled(!canBuy)
                    .transition(.opacity)
            }
        }.padding(.bottom, 20)
            .padding(.top, 16)
    }
    
    var body: some View {
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
