//
//  LoginIncentiveSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct LoginIncentiveSheet: View {
    @ObservedObject var themeService = ThemeService.shared
    @Environment(\.presentationManager) var presentationManager
    
    let imageName: String
    let text: String
    let nextUnlockIn: Int
    
    var body: some View {
        GamifiedBottomSheet(upperBackgroundColor: .blue100, upperContent: VStack(spacing: 0) {
            FanfareContainer(haloColor: .blue500, circleColor: Color(themeService.theme.contentBackgroundColor), outerRingColor: .blue500, plusColor: .blue10) {
                PixelArtView(name: imageName)
            }
            Text(L10n.unlockedAnotherCheckinPrize)
                .foregroundStyle(.blue1)
                .scaledFont(size: 22, weight: .bold)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true)
        }, title: Text(text), description: VStack {
            Text(L10n.checkinPrizeEarned(text))
            if nextUnlockIn > 0 {
                Text(L10n.nextPrizeInXCheckins(nextUnlockIn))
                    .scaledFont(size: 15)
                    .foregroundStyle(Color.blue10)
                    .padding(.top, 20)
            }
        }) {
            HabiticaButtonUI(label: Text(L10n.seeYouTomorrow), color: Color(themeService.theme.fixedTintColor)) {
                presentationManager.dismiss()
            }
        }
    }
}

#Preview {
    LoginIncentiveSheet(imageName: "", text: "Royal Purple Hatching Potion", nextUnlockIn: 5)
}
