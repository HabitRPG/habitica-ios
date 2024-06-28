//
//  FeedSheetView.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.09.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models
import Kingfisher

private class FeedSheetViewModel: ObservableObject {
    @Published var food: [FoodProtocol] = []
    @Published var ownedFoods: [String: Int] = [:]
    private let inventoryRepository = InventoryRepository()
    
    init() {
        inventoryRepository.getOwnedItems(itemType: "food").on(value: { owned in
            self.ownedFoods = Dictionary(uniqueKeysWithValues: owned.value.map { ($0.key ?? "", $0.numberOwned) })
        })
            .flatMap(.latest, { ownedFood in
                return self.inventoryRepository.getFood(keys: ownedFood.value.map({ ownedItem in
                    return ownedItem.key ?? ""
                }))
            })
            .on(value: { food in
            self.food = food.value
        }).start()
    }
}

@available(iOS 16.0, *)
struct FeedSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject fileprivate var viewModel = FeedSheetViewModel()
    let onFeed: (FoodProtocol) -> Void
    var dismissParent: (() -> Void)?
    
    var body: some View {
            if viewModel.food.isEmpty {
                VStack {
                    Image(uiImage: Asset.Empty.food.image)
                    Text(L10n.noX(L10n.food)).font(.headline)
                    Text(L10n.Items.Empty.foodDescription).font(.body)
                }
            } else {
                List {
                    Section(content: {
                        ForEach(viewModel.food, id: \.key) { foodItem in
                            HStack {
                                Group {
                                    PixelArtView(name: "Pet_Food_\(foodItem.key ?? "")").frame(width: 68, height: 68)
                                }.frame(width: 50, height: 50)
                                Text(foodItem.text ?? "")
                                    .font(.system(.headline))
                                Spacer()
                                Text("\(viewModel.ownedFoods[foodItem.key ?? ""] ?? 0)")
                                    .font(.system(.subheadline))
                            }
                            .listRowSpacing(0)
                            .listRowInsets(.none)
                            .onTapGesture {
                                onFeed(foodItem)
                                presentationMode.dismiss()
                            }
                        }
                    }, footer: {
                        VStack {
                            Image(uiImage: Asset.shop.image)
                            Text(L10n.Items.footerFoodTitle).font(.system(size: 16, weight: .semibold)).foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                                .padding(.vertical, 1)
                            Text(L10n.Items.footerFoodDescription).font(.system(size: 13)).foregroundStyle(Color(ThemeService.shared.theme.ternaryTextColor))
                        }
                        .padding(.top, 16)
                        .multilineTextAlignment(.center)
                        .onTapGesture {
                            presentationMode.dismiss()
                            dismissParent?()
                            RouterHandler.shared.handle(.market)
                        }
                    }).listRowBackground(Color(ThemeService.shared.theme.windowBackgroundColor))
                }
                .scrollContentBackground(.hidden)
                .background(Color(ThemeService.shared.theme.contentBackgroundColor))
                .listStyle(.insetGrouped)
            }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        return FeedSheetView { _ in
        }
    } else {
       return EmptyView()
    }
}
