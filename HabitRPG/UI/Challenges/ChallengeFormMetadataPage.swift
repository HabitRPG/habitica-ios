//
//  ChallengeFormMetadataPage.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.03.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import SwiftUI
import Habitica_Models
import ReactiveSwift

struct ChallengeFormMetadataPage: View {
    @ObservedObject var viewModel: ChallengeFormViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("What’s your Challenge about?")
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.45)
                    .lineSpacing(1)
                Text("This information helps others know the topic, rules, and goals of your Challenge.")
                    .font(.system(size: 17))
                    .tracking(-0.43)
                    .lineSpacing(2)
                    .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                ChallengeMetadataForm(viewModel: viewModel)
                    .padding(.top, 12)
            }.padding(.horizontal, 22)
                .padding(.top, 16)
        }
    }
}