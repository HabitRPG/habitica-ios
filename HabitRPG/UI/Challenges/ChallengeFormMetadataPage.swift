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
    var focus: FocusState<ChallengeFormFocus?>.Binding?

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ChallengeMetadataForm(viewModel: viewModel, focus: focus)
                ChallengeTagSection(viewModel: viewModel, focus: focus)
            }.padding(.horizontal, 18)
                .padding(.top, 16)
        }
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: focus?.wrappedValue) { _, newValue in
            guard let newValue = newValue else { return }
            withAnimation { proxy.scrollTo(newValue, anchor: .center) }
        }
        }
    }
}
