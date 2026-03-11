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
                    .padding(.horizontal, 23)
                Text("This information helps others know the topic, rules, and goals of your Challenge.")
                    .font(.system(size: 17))
                    .padding(.horizontal, 23)
                ChallengeMetadataForm(viewModel: viewModel)
                    .padding(.top, 12)
            }.padding(.horizontal, 12)
                .padding(.top, 16)
        }
    }
}