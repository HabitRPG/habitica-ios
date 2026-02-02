//
//  HabitControlsFormView.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

struct HabitControlsFormView: View {
    @ObservedObject var themeService = ThemeService.shared
    let taskColor: Color
    @Binding var isUp: Bool
    @Binding var isDown: Bool
    
    private func buildOption(text: String, icon: UIImage, isActive: Binding<Bool>) -> some View {
        return VStack(spacing: 12) {
            Group {
                ZStack {
                    Rectangle()
                        .fill()
                        .foregroundStyle(Color(themeService.theme.windowBackgroundColor))
                        .frame(width: 57, height: 57)
                    if isActive.wrappedValue {
                        RoundedRectangle(cornerRadius: UIConstants.mediumCornerRadius, )
                            .fill()
                            .frame(width: 57, height: 57)
                            .foregroundStyle(taskColor)
                            .transition(.scale)
                            .zIndex(1)
                    }
                    Image(uiImage: icon)
                        .accessibilityHidden(true)
                        .frame(width: 57, height: 57)
                        .zIndex(2)
                }
                .clipShape(.rect(cornerRadius: UIConstants.mediumCornerRadius))
                Text(text)
                    .accessibilityHidden(true)
                    .font(.system(size: 15, weight: isActive.wrappedValue ? .semibold : .regular))
                    .foregroundStyle(isActive.wrappedValue ? taskColor : Color(themeService.theme.ternaryTextColor))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(text + " control, " + "\( isActive.wrappedValue ? "on": "off")")
            .accessibilityRemoveTraits(.isImage)
        }
        .padding(.top, 4)
        .onTapGesture {
            UISelectionFeedbackGenerator.oneShotSelectionChanged()
            withAnimation(.bouncy) {
                isActive.wrappedValue.toggle()
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 42) {
            buildOption(text: L10n.Tasks.Form.positive, icon: HabiticaIcons.imageOfHabitControlPlus(taskTintColor: taskColor.uiColor(), isActive: isUp), isActive: $isUp)
            buildOption(text: L10n.Tasks.Form.negative, icon: HabiticaIcons.imageOfHabitControlMinus(taskTintColor: taskColor.uiColor(), isActive: isDown), isActive: $isDown)
        }
    }
}
