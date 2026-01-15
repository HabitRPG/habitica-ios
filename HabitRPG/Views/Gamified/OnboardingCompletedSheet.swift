//
//  OnboardingCompletedSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 15.01.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct OnboardingCompletedSheet: View {
    @ObservedObject var themeService = ThemeService.shared
    @Environment(\.presentationManager)
    var presentationManager
    
    var body: some View {
        GamifiedBottomSheet(upperBackgroundColor: .yellow100,
                            upperContent: ZStack(alignment: .top) {
            VStack(spacing: 0) {
                FanfareContainer(haloColor: .yellow500,
                                 outerRingColor: .yellow500,
                                 plusColor: .clear, content: {
                    Image(Asset.onboardingDoneArt.name)
                        .frame(width: 72, height: 72)
                })
                Text(L10n.onboardingCompleteAchievementTitle)
                    .scaledFont(size: 22, weight: .bold)
                    .foregroundStyle(Color.yellow1)
                    .padding(.horizontal, 50)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Image(Asset.onboardingGoldLeft.name)
                Spacer().frame(width: 145)
                Image(Asset.onboardingGoldRight.name)
            }.padding(.top, 70)
        }, title: Text(markdown: L10n.onboardingCompleteTitle).scaledFont(size: 20).padding(.bottom, 12).padding(.horizontal, 8).tint(themeService.theme.isDark ? .yellow500 : .yellow10), description: Text(L10n.onboardingCompleteDescription), buttons: {
            HabiticaButtonUI(label: Text(L10n.viewAchievements), color: Color(themeService.theme.fixedTintColor)) {
                RouterHandler.shared.handle(.achievements)
                presentationManager.dismiss()
            }
            HabiticaButtonUI(label: Text(L10n.share).foregroundStyle(Color(themeService.theme.primaryTextColor)), color: Color(themeService.theme.offsetBackgroundColor)) {
                let userRepository = UserRepository()
                userRepository.getUser().take(first: 1)
                    .on(value: { user in
                        SharingManager.share(avatar: user)
                        presentationManager.dismiss()
                    })
                    .start()
            }
        })
    }
}

#Preview {
    OnboardingCompletedSheet()
}
