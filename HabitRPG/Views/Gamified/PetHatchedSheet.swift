//
//  PetHatchedSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

struct PetHatchedSheet: View, Dismissable {
    @ObservedObject var themeService = ThemeService.shared
    var dismisser = Dismisser()
    let pet: PetProtocol
    var onEquip: () -> Void = { }
    
    var body: some View {
        GamifiedBottomSheet(upperBackground: StableBackgroundView(),
                            upperContent: PetView(pet: pet).padding(.top, 40),
                            upperContentBottomPadding: 10,
                            title: Text(L10n.Inventory.hatched(pet.text ?? "")),
                            xButtonBackground: .gray600.opacity(0.7)) {
            HabiticaButtonUI(label: Text(L10n.equip), color: Color(themeService.theme.fixedTintColor)) {
                onEquip()
                dismisser.dismiss()
            }
            HabiticaButtonUI(label: Text(L10n.share).foregroundStyle(Color(themeService.theme.primaryTextColor)), color: Color(themeService.theme.offsetBackgroundColor)) {
                SharingManager.share(pet: pet, shareIdentifier: "hatchedPet")
                dismisser.dismiss()
            }
        }
    }
}

#Preview {
    PetHatchedSheet(pet: PreviewPet(egg: "BearCub", potion: "Base", type: "drop", text: "Base Bear Cub"))
}
