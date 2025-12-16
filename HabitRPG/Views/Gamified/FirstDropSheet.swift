//
//  FirstDropSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct FirstDropSheet: View {
    @ObservedObject var themeService = ThemeService.shared
    @Environment(\.presentationManager) var presentationManager
    let eggKey: String
    let potionKey: String
    
    var body: some View {
        GamifiedBottomSheet(upperContent: VStack {
            PetItemsFlowView(leftIcon: PixelArtView(name: "Pet_Egg_\(eggKey)"),
                             middleIcon: Image(Asset.Empty.eggs.name),
                             rightIcon: PixelArtView(name: "Pet_HatchingPotion_\(potionKey)"))
            Text(L10n.firstDropTitle).scaledFont(size: 22, weight: .semibold).foregroundStyle(.white)
        },
                            title: Text(L10n.firstDropExplanation2),
                            description: Text(L10n.firstDropExplanation1)) {
            HabiticaButtonUI(label: Text(L10n.goToPetsMounts), color: Color(themeService.theme.fixedTintColor), onTap: {
                presentationManager.dismiss()
                RouterHandler.shared.handle(urlString: "/inventory/stable")
            })
        }
    }
}

#Preview {
    FirstDropSheet(eggKey: "Wolf", potionKey: "Base")
}
