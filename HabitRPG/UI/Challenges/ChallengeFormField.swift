//
//  ChallengeFormField.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.03.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import SwiftUI
import Habitica_Models
import ReactiveSwift

struct ChallengeFormField<Label: View>: View {
    @ObservedObject private var themeService = ThemeService.shared
    let label: Label
    @Binding var text: String
    let multiline: Bool
    let placeholder: String
    var minHeight: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            label
                .font(.system(size: 17, weight: .bold))
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(ChallengeTheme.counter), axis: multiline ? .vertical : .horizontal)
                .font(.system(size: 16))
                .lineLimit(multiline ? 3...8 : 1...1)
                .padding(.vertical, 15)
                .padding(.horizontal, 16)
                .frame(minHeight: multiline ? (minHeight ?? 78) : nil, alignment: .top)
                .background(Color(themeService.theme.windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}