//
//  DifficultyPicker.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

struct DifficultyPicker: View {
    @ObservedObject var themeService = ThemeService.shared
    @Binding var selectedDifficulty: Float
    var tintColor: Color = .accentColor
        
    private let difficulties: [Float] = [
        0.1,
        1.0,
        1.5,
        2.0
    ]
    
    @ViewBuilder
    func difficultyOption(text: String, value: Float) -> some View {
        let theme = themeService.theme
        VStack {
            let isActive = value == selectedDifficulty
            let accessibilityText = "Difficulty " + text + ", \(isActive ? "on" : "off")"
            Group {
                Image(uiImage: HabiticaIcons.imageOfTaskDifficultyStars(taskTintColor: .white, difficulty: value == 0.1 ? 0.1 : CGFloat(value), isActive: true).withRenderingMode(.alwaysTemplate))
                    .foregroundStyle(isActive ? .white : Color(theme.dimmedColor))
                    .animation(.spring(), value: isActive)
                    .frame(width: 57, height: 57)
                Text(text)
                    .font(.system(size: 15, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? tintColor : Color(theme.ternaryTextColor))
                    .frame(maxWidth: .infinity)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityText)
            .accessibilityRemoveTraits(.isImage)
        }.onTapGesture {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
            withAnimation {
                selectedDifficulty = value
            }
        }
    }
    
    var body: some View {
        let theme = themeService.theme
        GeometryReader { reader in
            let itemWidth = reader.size.width / 4
            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: UIConstants.mediumCornerRadius)
                        .frame(width: 57, height: 57)
                        .foregroundStyle(selectedDifficulty == 0.1 ? .clear : Color(theme.windowBackgroundColor))
                        .frame(width: itemWidth)
                    RoundedRectangle(cornerRadius: UIConstants.mediumCornerRadius)
                        .frame(width: 57, height: 57)
                        .foregroundStyle(selectedDifficulty == 1.0 ? .clear : Color(theme.windowBackgroundColor))
                        .frame(width: itemWidth)
                    RoundedRectangle(cornerRadius: UIConstants.mediumCornerRadius)
                        .frame(width: 57, height: 57)
                        .foregroundStyle(selectedDifficulty == 1.5 ? .clear : Color(theme.windowBackgroundColor))
                        .frame(width: itemWidth)
                    RoundedRectangle(cornerRadius: UIConstants.mediumCornerRadius)
                        .frame(width: 57, height: 57)
                        .foregroundStyle(selectedDifficulty == 2.0 ? .clear : Color(theme.windowBackgroundColor))
                        .frame(width: itemWidth)
                }
                let offset = (CGFloat(difficulties.firstIndex(of: selectedDifficulty) ?? 0) * itemWidth) + (itemWidth - 57) / 2
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: UIConstants.mediumCornerRadius)
                        .foregroundStyle(.clear)
                        .glassEffect(.regular.tint(tintColor), in: RoundedRectangle(cornerRadius: UIConstants.mediumCornerRadius))
                        .frame(width: 57, height: 57)
                        .padding(.leading, offset)
                        .animation(.bouncy, value: selectedDifficulty)
                } else {
                    RoundedRectangle(cornerRadius: UIConstants.mediumCornerRadius).foregroundStyle(tintColor)
                        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 3)
                        .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
                        .frame(width: 57, height: 57)
                        .padding(.leading, offset)
                        .animation(.bouncy, value: selectedDifficulty)
                }
                HStack(spacing: 0) {
                    difficultyOption(text: L10n.Tasks.Form.trivial, value: 0.1).frame(width: itemWidth)
                    difficultyOption(text: L10n.Tasks.Form.easy, value: 1.0).frame(width: itemWidth)
                    difficultyOption(text: L10n.Tasks.Form.medium, value: 1.5).frame(width: itemWidth)
                    difficultyOption(text: L10n.Tasks.Form.hard, value: 2.0).frame(width: itemWidth)
                }
            }
        }.frame(height: 86)
    }
}
