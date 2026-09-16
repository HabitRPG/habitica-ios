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

struct ChallengeTagSection: View {
    @ObservedObject var viewModel: ChallengeFormViewModel
    var focus: FocusState<ChallengeFormFocus?>.Binding?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ChallengeFormField(label: Text(L10n.ChallengeForm.tagLabel), text: $viewModel.challengeTag, multiline: false, placeholder: L10n.ChallengeForm.tagPlaceholder, focus: focus, field: .tag)
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
    }
}
