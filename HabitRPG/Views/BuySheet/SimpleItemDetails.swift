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
    let item: InAppRewardProtocol
    
    @State private var isAnimating = false

    var body: some View {
        if let sprite = item.imageName {
            if #available(iOS 26.0, *) {
                PixelArtView(name: sprite)
                    .offset(y: isAnimating ? 0 : -10)
                    .animation(.easeInOut(duration: 0.3).delay(0.2), value: isAnimating)
                    .frame(width: 120, height: 120)
                    .glassEffect(.regular.tint(Color(ThemeService.shared.theme.windowBackgroundColor).opacity(0.65)), in: RoundedRectangle(cornerRadius: UIConstants.largeCornerRadius))
                    .padding(.bottom, 9)
                    .onAppear {
                        isAnimating = true
                    }
            } else {
                PixelArtView(name: sprite).frame(width: 120, height: 120)
                    .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                    .cornerRadius(UIConstants.largeCornerRadius)
                    .padding(.bottom, 9)
            }
        }
        Text(item.text ?? "").foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor)).scaledFont(size: 22, weight: .bold)
        if let notes = item.notes, !notes.isEmpty, let nsAttr = try? HabiticaMarkdownHelper.toHabiticaAttributedString(notes) {
            Text(AttributedString(nsAttr)).foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor)).scaledFont(size: 17)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.top, 6)
        }
    }
}
