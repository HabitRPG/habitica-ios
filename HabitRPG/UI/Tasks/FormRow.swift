//
//  FormRow.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

struct FormRow<TitleView: View, LabelView: View>: View {
    @ObservedObject var themeService = ThemeService.shared
    let title: TitleView
    let valueLabel: LabelView
    var action: (() -> Void)?
    
    var body: some View {
        if let action = action {
            Button(action: action, label: {
                HStack {
                    title.foregroundStyle(Color(themeService.theme.primaryTextColor))
                    Spacer()
                    valueLabel
                        .padding(.vertical, 6)
                        .padding(.horizontal, 11)
                        .background(Color(themeService.theme.offsetBackgroundColor))
                        .cornerRadius(UIConstants.largeCornerRadius)
                }.frame(height: 45).padding(.leading, 26).padding(.trailing, 12)
            }).buttonStyle { configuration in
                if UIAccessibility.buttonShapesEnabled {
                    configuration.label
                        .background(Color(themeService.theme.offsetBackgroundColor))
                        .cornerRadius(UIConstants.largeCornerRadius).padding(4)
                } else {
                    configuration.label
                }
            }
        } else {
            HStack {
                title.foregroundStyle(.primary)
                Spacer()
                valueLabel
                    .padding(.vertical, 6)
                    .padding(.horizontal, 11)
                    .background(Color(themeService.theme.offsetBackgroundColor))
                    .cornerRadius(UIConstants.largeCornerRadius)
            }.frame(height: 45).padding(.leading, 26).padding(.trailing, 12)
        }
    }
}
