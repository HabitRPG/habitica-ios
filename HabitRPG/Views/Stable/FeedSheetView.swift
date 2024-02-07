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
    
struct FeedSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject fileprivate var viewModel = FeedSheetViewModel()
    let onFeed: (FoodProtocol) -> Void
    
    var body: some View {
        ScrollView {
            if viewModel.food.isEmpty {
                VStack {
                    Text(L10n.noX(L10n.food)).font(.headline)
                    Text(L10n.Items.Empty.foodDescription).font(.body)
                }
            } else {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.food, id: \.key) { foodItem in
                        HStack {
                            PixelArtView(name: "Pet_Food_\(foodItem.key ?? "")").frame(width: 44, height: 44)
                            Text(foodItem.text ?? "")
                                .font(.system(.headline))
                            Spacer()
                            Text("\(viewModel.ownedFoods[foodItem.key ?? ""] ?? 0)")
                                .font(.system(.subheadline))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(ThemeService.shared.theme.contentBackgroundColor))
                        .onTapGesture {
                            onFeed(foodItem)
                            presentationMode.dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    FeedSheetView { _ in
    }
}
