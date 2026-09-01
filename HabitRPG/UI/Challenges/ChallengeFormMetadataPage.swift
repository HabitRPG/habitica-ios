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
                Text(L10n.ChallengeForm.metadataTitle)
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.45)
                    .lineSpacing(1)
                    .padding(.horizontal, 8)
                Text(L10n.ChallengeForm.metadataDescription)
                    .font(.system(size: 17))
                    .tracking(-0.43)
                    .lineSpacing(2)
                    .foregroundStyle(ChallengeTheme.handle)
                    .padding(.horizontal, 8)
                ChallengeMetadataForm(viewModel: viewModel)
                    .padding(.top, 12)
            }.padding(.horizontal, 18)
                .padding(.top, 16)
        }
    }
}