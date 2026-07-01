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
                    .font(.system(size: 24, weight: .bold))
                Text("Pick a short tag that will be added to all your Challenge’s tasks and up to 3 categories to help players find you!")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                VStack(alignment: .leading, spacing: 10) {
                    ChallengeFormField(label: Text("Challenge Tag"), text: $viewModel.challengeTag, multiline: false, placeholder: "What tag will identify your Challenge?")
                    Text(L10n.categories)
                        .font(.system(size: 17, weight: .bold))
                        .padding(.top, 26)
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(ChallengeCategory.allCases) { challengeCategory in
                            if challengeCategory != .official {
                                let isSelected = viewModel.challengeCategories.contains(challengeCategory)
                                let isDisabled = !isSelected && viewModel.challengeCategories.count >= 3
                                HStack {
                                    Text(challengeCategory.localizedName)
                                        .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                                        .foregroundStyle(isDisabled
                                                         ? Color(red: 0xC7 / 255, green: 0xC5 / 255, blue: 0xCC / 255)
                                                         : (isSelected ? ChallengeTheme.deepPurple : Color(ThemeService.shared.theme.primaryTextColor)))
                                    Spacer()
                                }
                                    .contentShape(.rect)
                                    .onTapGesture {
                                        if !isDisabled {
                                            viewModel.categoryTapped(category: challengeCategory)
                                        }
                                    }
                                if challengeCategory != ChallengeCategory.allCases.last {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(15)
                    .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                    .cornerRadius(16)
                }
            }.padding(.horizontal, 22)
                .padding(.top, 16)
        }
    }
}
