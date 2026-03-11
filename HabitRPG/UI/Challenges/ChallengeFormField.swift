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
    let label: Label
    @Binding var text: String
    let multiline: Bool
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            label
                .font(.system(size: 17, weight: .semibold))
                .padding(.leading, 23)
            TextField("", text: $text, prompt: Text(placeholder), axis: multiline ? .vertical : .horizontal)
                .lineLimit(4...)
                .padding(18)
                .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                .cornerRadius(UIConstants.largeCornerRadius)
        }
    }
}