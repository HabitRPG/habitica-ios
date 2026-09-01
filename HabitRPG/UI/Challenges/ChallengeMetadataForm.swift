//
//  ChallengeMetadataForm.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.03.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import SwiftUI
import Habitica_Models
import ReactiveSwift

struct ChallengeMetadataForm: View {
    @ObservedObject var viewModel: ChallengeFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ChallengeFormField(label: Text(L10n.name),
                               text: $viewModel.name,
                               multiline: false,
                               placeholder: L10n.ChallengeForm.namePlaceholder)
            ChallengeFormField(label: Text(L10n.summary),
                               text: $viewModel.summary,
                               multiline: true,
                               placeholder: L10n.ChallengeForm.summaryPlaceholder)
            ChallengeFormField(label: Text(L10n.description),
                               text: $viewModel.description,
                               multiline: true,
                               placeholder: L10n.ChallengeForm.descriptionPlaceholder,
                               minHeight: 104)
        }
    }
}