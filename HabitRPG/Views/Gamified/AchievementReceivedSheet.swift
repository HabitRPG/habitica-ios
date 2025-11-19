//
//  AchievementReceivedSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct AchievementReceivedSheet<Title: View, Description: View>: View {
    @Environment(\.presentationManager) var presentationManager

    let key: String
    let isOnboarding: Bool
    let text: Title
    let description: Description
    
    var body: some View {
        GamifiedBottomSheet(upperBackgroundColor: .yellow100,
                            upperContent: VStack {FanfareContainer(haloColor: .yellow500,
                                                                   circleColor: Color(ThemeService.shared.theme.contentBackgroundColor),
                                                                   outerRingColor: .yellow500,
                                                                   plusColor: .yellow100, content: {
            PixelArtView(name: "achievement-\(key)2x")
        })
            Text(L10n.youGotAchievement).scaledFont(size: 22, weight: .semibold).foregroundStyle(Color.yellow1)
        }, title: text, description: description, buttons: {
            HabiticaButtonUI(label: Text(L10n.onwards), color: Color(ThemeService.shared.theme.fixedTintColor)) {
                presentationManager.dismiss()
            }
            if isOnboarding {
                HabiticaButtonUI(label: Text(L10n.viewOnboardingTasks).foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor)), color: Color(ThemeService.shared.theme.offsetBackgroundColor)) {
                    presentationManager.dismiss()
                }
            }
        })
    }
}

#Preview {
    AchievementReceivedSheet(key: "", isOnboarding: false, text: Text("Test Achievement"), description: Text("Some Achievement you received"))
}
