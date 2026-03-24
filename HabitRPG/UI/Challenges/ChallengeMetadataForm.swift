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
        VStack(alignment: .leading, spacing: 20) {
            ChallengeFormField(label: Text(L10n.name),
                               text: $viewModel.name,
                               multiline: false,
                               placeholder: "What is your Challenge called?")
            ChallengeFormField(label: Text(L10n.summary),
                               text: $viewModel.summary,
                               multiline: true,
                               placeholder: "What’s the main purpose of your Challenge? This short summary will show in the list of Challenges.")
            ChallengeFormField(label: Text(L10n.description),
                               text: $viewModel.description,
                               multiline: true,
                               placeholder: "What details do participants need to know about your Challenge?")
        }
    }
}