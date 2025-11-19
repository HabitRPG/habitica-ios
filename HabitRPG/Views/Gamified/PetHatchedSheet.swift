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
    var dismisser = Dismisser()
    let pet: PetProtocol
    var onEquip: () -> Void = { }
    
    var body: some View {
        GamifiedBottomSheet(upperBackground: StableBackgroundView(),
                            upperContent: PetView(pet: pet).padding(.top, 40),
                            upperContentBottomPadding: 10,
                            title: Text(L10n.Inventory.hatched(pet.text ?? ""))) {
            HabiticaButtonUI(label: Text(L10n.equip), color: Color(ThemeService.shared.theme.tintColor)) {
                onEquip()
                dismisser.dismiss()
            }
            HabiticaButtonUI(label: Text(L10n.share).foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor)), color: Color(ThemeService.shared.theme.offsetBackgroundColor)) {
                SharingManager.share(pet: pet, shareIdentifier: "hatchedPet")
                dismisser.dismiss()
            }
        }
    }
}

#Preview {
    PetHatchedSheet(pet: PreviewPet(egg: "BearCub", potion: "Base", type: "drop", text: "Base Bear Cub"))
}
