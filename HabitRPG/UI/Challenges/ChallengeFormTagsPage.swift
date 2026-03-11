//
//  ChallengeFormTagsPage.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.03.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import SwiftUI
import Habitica_Models
import ReactiveSwift

struct ChallengeFormTagsPage: View {
    @ObservedObject var viewModel: ChallengeFormViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Identify your Challenge")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.horizontal, 23)
                Text("Pick a short tag that will be added to all your Challenge’s tasks and up to 3 categories to help players find you!")
                    .font(.system(size: 17))
                    .padding(.horizontal, 23)
                VStack(alignment: .leading, spacing: 10) {
                    ChallengeFormField(label: Text("Challenge Tag"), text: $viewModel.challengeTag, multiline: false, placeholder: "What tag will identify your Challenge?")
                    Text("Categories")
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.leading, 23)
                        .padding(.top, 26)
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(ChallengeCategory.allCases) { challengeCategory in
                            if challengeCategory != .official {
                                HStack {
                                    Text(challengeCategory.localizedName)
                                    Spacer()
                                    if viewModel.challengeCategories.contains(challengeCategory) {
                                        Image(Asset.checkmark.name)
                                            .renderingMode(.template)
                                            .foregroundStyle(Color(ThemeService.shared.theme.fixedTintColor))
                                    }
                                }.padding(.leading, 12)
                                    .contentShape(.rect)
                                    .onTapGesture {
                                        viewModel.categoryTapped(category: challengeCategory)
                                    }
                                if challengeCategory != ChallengeCategory.allCases.last {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(15)
                    .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                    .cornerRadius(UIConstants.largeCornerRadius)
                }
            }.padding(.horizontal, 12)
                .padding(.top, 16)
        }
    }
}
