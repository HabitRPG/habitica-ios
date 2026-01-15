//
//  HatchSuggestionSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct PetItemsFlowView<LeftIcon: View, MiddleIcon: View, RightIcon: View>: View {
    @ObservedObject var themeService = ThemeService.shared

    let leftIcon: LeftIcon
    let middleIcon: MiddleIcon
    let rightIcon: RightIcon
    var isleftIconActive = true
    var isRightIconActive = true
    
    @State private var highlightedStep = 0
    
    var body: some View {
        HStack(spacing: 0) {
            leftIcon
                .frame(width: 60, height: 60)
                .background(Color(themeService.theme.contentBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: 68, height: 68)
            .border(Color.purple300, width: 8, cornerRadius: 13, antialiased: true)
            .opacity(isleftIconActive ? 1 : 0.6)
            Spacer()
            Circle().fill().frame(width: 8, height: 8).foregroundStyle(highlightedStep == 1 ? Color.purple500 : Color.purple300)
            Spacer()
            Circle().fill().frame(width: 8, height: 8).foregroundStyle(highlightedStep == 2 ? Color.purple500 : Color.purple300)
            Spacer()
            Circle().fill().frame(width: 8, height: 8).foregroundStyle(highlightedStep == 3 ? Color.purple500 : Color.purple300)
            Spacer()
            middleIcon
                .opacity(highlightedStep == 5 ? 0.7 : 1)
            .frame(width: 96, height: 96)
            .background(Color(themeService.theme.contentBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .border(highlightedStep == 4 ? Color.purple200 : Color.purple300, width: 8, cornerRadius: 13, antialiased: true)
            Spacer()
            Circle().fill().frame(width: 8, height: 8).foregroundStyle(highlightedStep == 3 ? Color.purple500 : Color.purple300)
            Spacer()
            Circle().fill().frame(width: 8, height: 8).foregroundStyle(highlightedStep == 2 ? Color.purple500 : Color.purple300)
            Spacer()
            Circle().fill().frame(width: 8, height: 8).foregroundStyle(highlightedStep == 1 ? Color.purple500 : Color.purple300)
            Spacer()
            rightIcon
                .frame(width: 60, height: 60)
                .background(Color(themeService.theme.contentBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: 68, height: 68)
            .border(Color.purple300, width: 8, cornerRadius: 13, antialiased: true)
            .opacity(isRightIconActive ? 1 : 0.6)
    }
        .animation(.easeInOut(duration: 0.2), value: highlightedStep)
        .padding(.top, 70)
        .padding(.horizontal, 32)
        .task {
            repeat {
                withAnimation {
                    highlightedStep += 1
                }
                try? await Task.sleep(for: .seconds(0.2))
                withAnimation {
                    highlightedStep += 1
                }
                try? await Task.sleep(for: .seconds(0.2))
                withAnimation {
                    highlightedStep += 1
                }
                try? await Task.sleep(for: .seconds(0.2))
                withAnimation {
                    highlightedStep += 1
                }
                try? await Task.sleep(for: .seconds(0.3))
                withAnimation {
                    highlightedStep += 1
                }
                try? await Task.sleep(for: .seconds(0.3))
                withAnimation {
                    highlightedStep = 0
                }
                try? await Task.sleep(for: .seconds(2))
            } while (!Task.isCancelled)
        }
    }
}

struct HatchSuggestionSheet: View {
    @ObservedObject var themeService = ThemeService.shared
    @Environment(\.presentationManager)
    var presentationManager
    
    private let inventoryRepository = InventoryRepository()

    let item: PetStableItem
    let ownedEggCount: Int
    let ownedPotionCount: Int
    
    @State var isHatching = false
        
    private var descriptionText: String {
        if ownedEggCount > 0 && ownedPotionCount > 0 {
            return L10n.canHatchPet(item.pet?.egg ?? "", item.pet?.potion ?? "")
        } else if ownedEggCount == 0 && ownedPotionCount > 0 {
            return L10n.suggestPetHatchMissingEgg(item.pet?.egg ?? "")
        } else if ownedPotionCount == 0 {
            return L10n.suggestPetHatchMissingPotion(item.pet?.potion ?? "")
        } else {
            return L10n.suggestPetHatchMissingBoth(item.pet?.egg ?? "", item.pet?.potion ?? "")
        }
    }
    
    var body: some View {
        GamifiedBottomSheet(upperContent: VStack(spacing: 25) {
            PetItemsFlowView(leftIcon: PixelArtView(name: "Pet_Egg_\(item.pet?.egg ?? "")"),
                             middleIcon: PixelArtView(name: "stable_Pet-\(item.pet?.egg ?? "")-\(item.pet?.potion ?? "")-outline"),
                             rightIcon: PixelArtView(name: "Pet_HatchingPotion_\(item.pet?.potion ?? "")"),
            isleftIconActive: ownedEggCount > 0,
            isRightIconActive: ownedPotionCount > 0)
            Text((ownedEggCount > 0 && ownedPotionCount > 0) ? L10n.hatchPetNewTitle : L10n.unhatchedPet)
                .scaledFont(size: 22, weight: .bold)
                .padding(.horizontal, 50)
                .foregroundStyle(.white)
        }, title: Text(item.pet?.text ?? ""), description: Text(descriptionText)) {
            if ownedEggCount > 0 && ownedPotionCount > 0 {
                if isHatching {
                    HabiticaProgressView().frame(height: 60)
                } else {
                    HabiticaButtonUI(label: Text(L10n.hatch), color: Color(themeService.theme.fixedTintColor)) {
                        withAnimation {
                            isHatching = true
                        }
                        inventoryRepository.hatchPet(egg: item.pet?.egg ?? "", potion: item.pet?.potion ?? "")
                            .observeCompleted {
                                presentationManager.dismiss()
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    HatchSuggestionSheet(item: PetStableItem(pet: PreviewPet(egg: "Bear", potion: "Base"), trained: 0, canRaise: true), ownedEggCount: 5, ownedPotionCount: 2)
}
