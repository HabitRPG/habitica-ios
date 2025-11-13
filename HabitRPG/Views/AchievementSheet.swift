//
//  AchievementSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

struct AchievementSheet: View {
    let achievement: AchievementProtocol
    var body: some View {
        BottomSheetView(title: Text(achievement.title ?? ""), content: VStack(spacing: 16) {
            AchievementIconView(achievement: achievement)
                .frame(width: 72, height: 72)
                .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                .cornerRadius(UIConstants.mediumCornerRadius)
            Text(achievement.text ?? "").scaledFont(size: 17)
        }, topPadding: 32)
    }
}
