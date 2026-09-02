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
    var focus: FocusState<ChallengeFormFocus?>.Binding?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.ChallengeForm.tagsTitle)
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.45)
                    .lineSpacing(1)
                    .padding(.horizontal, 8)
                Text(L10n.ChallengeForm.tagsDescription)
                    .font(.system(size: 17))
                    .tracking(-0.43)
                    .lineSpacing(2)
                    .foregroundStyle(ChallengeTheme.handle)
                    .padding(.horizontal, 8)
                VStack(alignment: .leading, spacing: 10) {
                    ChallengeFormField(label: Text(L10n.ChallengeForm.tagLabel), text: $viewModel.challengeTag, multiline: false, placeholder: L10n.ChallengeForm.tagPlaceholder, focus: focus, field: .tag)
                        .padding(.top, 18)
                    Text(L10n.categories)
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.top, 26)
                        .padding(.leading, 8)
                    ChallengeSelectionList {
                        ForEach(ChallengeCategory.allCases) { challengeCategory in
                            if challengeCategory != .official {
                                let isSelected = viewModel.challengeCategories.contains(challengeCategory)
                                ChallengeSelectionRow(title: challengeCategory.localizedName,
                                                      isSelected: isSelected,
                                                      isDisabled: !isSelected && viewModel.challengeCategories.count >= 3,
                                                      showsCheckmark: true,
                                                      showsDivider: challengeCategory != ChallengeCategory.allCases.last) {
                                    viewModel.categoryTapped(category: challengeCategory)
                                }
                            }
                        }
                    }
                }
            }.padding(.horizontal, 18)
                .padding(.top, 16)
        }
        .scrollDismissesKeyboard(.immediately)
    }
}
