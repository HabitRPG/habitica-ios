//
//  AchievementSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

struct AchievementDetailSheet: View {
    @ObservedObject var themeService = ThemeService.shared
    let achievement: AchievementProtocol
    var body: some View {
        BottomSheetView( content: VStack(spacing: 16) {
            AchievementIconView(achievement: achievement)
                .frame(width: 72, height: 72)
                .background(Color(themeService.theme.offsetBackgroundColor))
                .cornerRadius(UIConstants.mediumCornerRadius)
            Text(achievement.title ?? "").font(.headline)
            Text(achievement.text ?? "").scaledFont(size: 17)
                .multilineTextAlignment(.center)
        }, topPadding: 32)
    }
}
