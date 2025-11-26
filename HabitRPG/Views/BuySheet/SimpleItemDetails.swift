//
//  SimpleItemDetails.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.09.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models
import ReactiveSwift
import Habitica_Database

struct SimpleItemDetails: View {
    @ObservedObject var themeService = ThemeService.shared

    let item: InAppRewardProtocol
    let user: UserProtocol?
    
    @State private var isAnimating = false
    
    @ViewBuilder private var iconView: some View {
        if item.purchaseType == "backgrounds" {
            ZStack {
                PixelArtView(name: "background_\(item.key ?? "")")
                if let avatar = user {
                    AvatarViewUI(avatar: AvatarViewModel(avatar: avatar), showBackground: false)
                }
            }
                .frame(width: 140, height: 147)
                .padding(6)
        } else {
            PixelArtView(name: item.imageName ?? "")
                .offset(y: isAnimating ? 0 : -10)
                .animation(.easeInOut(duration: 0.3).delay(0.2), value: isAnimating)
                .frame(width: 120, height: 120)
                .onAppear {
                    isAnimating = true
                }
        }
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            iconView
                .glassEffect(.regular.tint(Color(themeService.theme.windowBackgroundColor).opacity(0.65)), in: RoundedRectangle(cornerRadius: UIConstants.largeCornerRadius))
                .padding(.bottom, 9)
        } else {
            iconView
                .background(Color(themeService.theme.windowBackgroundColor))
                .cornerRadius(UIConstants.largeCornerRadius)
                .padding(.bottom, 9)
        }
        Text(item.text ?? "").foregroundStyle(Color(themeService.theme.primaryTextColor)).scaledFont(size: 22, weight: .bold)
        if let notes = item.notes, !notes.isEmpty, let nsAttr = try? HabiticaMarkdownHelper.toHabiticaAttributedString(notes) {
            Text(AttributedString(nsAttr)).foregroundStyle(Color(themeService.theme.primaryTextColor)).scaledFont(size: 17)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.top, 6)
        }
    }
}
