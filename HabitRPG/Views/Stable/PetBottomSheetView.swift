//
//  PetBottomSheetView.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.09.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models
import Kingfisher

struct PetBottomSheetView: View, Dismissable {
    var dismisser: Dismisser = Dismisser()
    
    let pet: PetProtocol
    let trained: Int
    let canRaise: Bool
    let isCurrentPet: Bool
    let onEquip: () -> Void
    
    private let inventoryRepository = InventoryRepository()
    @State private var isShowingFeeding = false
    
    private func getFoodName() -> String {
        switch pet.potion {
        case "Base":
            return Asset.feedBase.name
        case "CottonCandyBlue":
            return Asset.feedBlue.name
        case "Golden":
            return Asset.feedGolden.name
        case "CottonCandyPink":
            return Asset.feedPink.name
        case "Red":
            return Asset.feedRed.name
        case "Shade":
            return Asset.feedShade.name
        case "Skeleton":
            return Asset.feedSkeleton.name
        case "White":
            return Asset.feedWhite.name
        case "Zombie":
            return Asset.feedZombie.name
        default:
            return Asset.feedBase.name
        }
    }
    
    var body: some View {
        let theme = ThemeService.shared.theme
        BottomSheetView(dismisser: dismisser, title: Text(pet.text ?? ""), content: VStack(spacing: 16) {
            StableBackgroundView(content: KFImage(ImageManager.buildImageUrl(name: "stable_Pet-\(pet.key ?? "")")).frame(width: 70, height: 70).padding(.top, 40), animateFlying: false)
                .clipShape(.rect(cornerRadius: 12))
            if trained > 0 && pet.type != "special" && canRaise {
                let buttonBackground = Color(theme.isDark ? UIColor.blackPurple100 : UIColor.purple5060)
                HStack(spacing: 16) {
                    Button(action: {
                        inventoryRepository.feed(pet: pet.key ?? "", food: "Saddle").observeCompleted {
                            
                        }
                        dismisser.dismiss?()
                    }, label: {
                        VStack {
                            Image(Asset.feedSaddle.name)
                            Text(L10n.Stable.useSaddle).font(.system(size: 16, weight: .semibold))
                        }
                        .frame(height: 101)
                        .maxWidth(.infinity)
                        .background(buttonBackground)
                        .clipShape(.rect(cornerRadius: 12))
                    })
                    Button(action: {
                        isShowingFeeding = true
                    }, label: {
                        VStack {
                            Image(getFoodName())
                            Text(L10n.Stable.feed).font(.system(size: 16, weight: .semibold))
                        }
                        .frame(height: 101)
                        .maxWidth(.infinity)
                        .background(buttonBackground)
                        .clipShape(.rect(cornerRadius: 12))
                    })
                }
            }
            HabiticaButtonUI(label: Text(L10n.share), color: Color(theme.tintColor)) {
                dismisser.dismiss?()
            }
            if trained > 0 {
                HabiticaButtonUI(label: Text(isCurrentPet ? L10n.unequip : L10n.equip), color: Color(theme.tintColor)) {
                    onEquip()
                    dismisser.dismiss?()
                }
            }
        }
        )
        .sheet(isPresented: $isShowingFeeding, content: {
            NavigationView {
                if #available(macCatalyst 16.0, *) {
                    FeedSheetView { food in
                        self.feedPet(food: food)
                    }.presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                } else {
                    FeedSheetView { food in
                        self.feedPet(food: food)
                    }
                }
            }
        })
    }
    
    private func feedPet(food: FoodProtocol) {
        self.inventoryRepository.feed(pet: pet, food: food).observeValues { response in
            if response?.data == -1 {
                dismisser.dismiss?()
            }
        }
    }
}

#Preview {
    PetBottomSheetView(pet: PreviewPet(egg: "BearCub", potion: "Base", type: "drop", text: "Base Bear Cub"), trained: 10, canRaise: true, isCurrentPet: false, onEquip: {})
        .previewLayout(.fixed(width: 400, height: 500))
}

private class PreviewPet: PetProtocol {
    init(egg: String, potion: String, type: String? = nil, text: String? = nil) {
        self.key = "\(egg)-\(potion)"
        self.egg = egg
        self.potion = potion
        self.type = type
        self.text = text
    }
    
    var key: String?
    var egg: String?
    var potion: String?
    var type: String?
    var text: String?
    var isValid: Bool = true
    var isManaged: Bool = true
    
}
