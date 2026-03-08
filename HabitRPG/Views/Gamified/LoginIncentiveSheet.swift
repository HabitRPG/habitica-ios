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
    @Environment(\.presentationManager)
    var presentationManager
    
    let rewards: [String]
    let text: String
    let nextUnlockIn: Int
    
    @State private var imageIndex = 0
    
    private func corrected(imageName: String) -> String {
        if imageName.contains("slim_armor") {
            return imageName.replacingOccurrences(of: "slim_", with: "shop_")
        } else if imageName.contains("_special_") && !imageName.contains("shop_") {
            return "shop_\(imageName)"
        }
        return imageName
    }
    
    @ViewBuilder
    func image(imageName: String) -> some View {
        if imageName == "background_purple" {
            Image(Asset.rewardPlainBackgrounds.name)
        } else if imageName.contains("2x") {
            PixelArtView(name: imageName)
                .frame(width: 72, height: 72)
        } else {
            PixelArtView(name: corrected(imageName: imageName))
        }
    }
    
    var body: some View {
        GamifiedBottomSheet(upperBackgroundColor: .blue100, upperContent: VStack(spacing: 0) {
            FanfareContainer(haloColor: .blue500, outerRingColor: .blue500, plusColor: .blue10) {
                ZStack {
                    ForEach(enumerating: rewards) { (index, reward) in
                        image(imageName: reward)
                            .opacity(index == imageIndex ? 1 : 0)
                    }
                }
            }
            Text(L10n.unlockedAnotherCheckinPrize)
                .foregroundStyle(.blue1)
                .scaledFont(size: 22, weight: .bold)
                .padding(.horizontal, 50)
                .fixedSize(horizontal: false, vertical: true)
        }, title: Text(text), description: VStack {
            if rewards.first == "background_purple" {
                Text(L10n.checkinPrizeSetDescription(text))
            } else {
                Text(L10n.checkinPrizeDescription(text))
            }
            if nextUnlockIn > 0 {
                Text(nextUnlockIn == 1 ? L10n.nextPrizeIn1Checkin : L10n.nextPrizeInXCheckins(nextUnlockIn))
                    .scaledFont(size: 15, weight: .semibold)
                    .foregroundStyle(themeService.theme.isDark ? Color.blue500 : Color.blue10)
                    .padding(.top, 20)
            }
        }) {
            HabiticaButtonUI(label: Text(L10n.seeYouTomorrow), color: Color(themeService.theme.fixedTintColor)) {
                presentationManager.dismiss()
            }
        }.task {
            if rewards.count > 1 {
                repeat {
                    try? await Task.sleep(for: .seconds(2))
                    withAnimation(.smooth) {
                        if imageIndex == rewards.count - 1 {
                            imageIndex = 0
                        } else {
                            imageIndex += 1
                        }
                    }
                } while (!Task.isCancelled)
            }
        }
    }
}

#Preview {
    LoginIncentiveSheet(rewards: [""], text: "Royal Purple Hatching Potion", nextUnlockIn: 5)
}
