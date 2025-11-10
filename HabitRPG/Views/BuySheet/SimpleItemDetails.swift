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

    var body: some View {
        if let sprite = item.imageName {
            if #available(iOS 26.0, *) {
                PixelArtView(name: sprite)
                    .frame(width: 102, height: 102)
                    .frame(width: 120, height: 120)
                    .glassEffect(.regular.tint(Color(ThemeService.shared.theme.windowBackgroundColor).opacity(0.65)), in: RoundedRectangle(cornerRadius: 26))
                    .padding(.bottom, 9)
            } else {
                PixelArtView(name: sprite).frame(width: 120, height: 120)
                    .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                    .cornerRadius(26)
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
