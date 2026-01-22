//
//  ClassConfirmationSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

struct ClassConfirmationSheet: View {
    @ObservedObject var themeService = ThemeService.shared
    @Environment(\.presentationManager) var presentationManager
    
    var selectedClass: HabiticaClass
    
    private var backgroundColor: Color {
        switch selectedClass {
        case .warrior:
            return .red100
        case .mage:
            return .blue100
        case .healer:
            return .yellow100
        case .rogue:
            return .purple300
        }
    }
    
    private var textColor: Color {
        switch selectedClass {
        case .warrior:
            return .red1
        case .mage:
            return .blue1
        case .healer:
            return .yellow1
        case .rogue:
            return .white
        }
    }
    
    @ViewBuilder private var upperContent: some View {
        switch selectedClass {
        case .warrior:
            FanfareContainer(haloColor: .red500, outerRingColor: .red500, plusColor: .red10, content: {
                Image(uiImage: HabiticaIcons.imageOfWarriorLarge)
            })
        case .mage:
            FanfareContainer(haloColor: .blue500, outerRingColor: .blue500, plusColor: .blue10, content: {
                Image(uiImage: HabiticaIcons.imageOfMageLarge)
            })
        case .healer:
            FanfareContainer(haloColor: .yellow500, outerRingColor: .yellow500, plusColor: .yellow10, content: {
                Image(uiImage: HabiticaIcons.imageOfHealerLarge)
            })
        case .rogue:
            FanfareContainer(haloColor: .purple500, outerRingColor: .purple500, plusColor: .purple500, content: {
                Image(uiImage: HabiticaIcons.imageOfRogueLarge)
            })
        }
    }
    
    var body: some View {
        GamifiedBottomSheet(upperBackgroundColor: backgroundColor, upperContent: VStack {
            upperContent
            Text(L10n.classChangeSuccessTitle(selectedClass.translatedName))
                .scaledFont(size: 22, weight: .bold)
                .foregroundStyle(textColor)
                .padding(.horizontal, 50)
        }, title: Text(L10n.classChangeSuccessSubtitle), description: VStack(spacing: 20) {
            Text(L10n.classChangeSuccessDescription)
            Text(L10n.findStatsMenu).scaledFont(size: 15, weight: .semibold)
                .foregroundStyle(Color(themeService.theme.ternaryTextColor))
        }) {
            HabiticaButtonUI(label: Text(L10n.viewStats), color: Color(themeService.theme.fixedTintColor)) {
                presentationManager.dismiss()
                RouterHandler.shared.handle(urlString: "/user/stats")
            }
        }
    }
}

#Preview("Warrior") {
    ClassConfirmationSheet(selectedClass: .warrior)
}

#Preview("Mage") {
    ClassConfirmationSheet(selectedClass: .mage)
}

#Preview("Healer") {
    ClassConfirmationSheet(selectedClass: .healer)
}

#Preview("rogue") {
    ClassConfirmationSheet(selectedClass: .rogue)
}
