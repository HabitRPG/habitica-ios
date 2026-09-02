//
//  ChallengeFormPrizePage.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.03.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import SwiftUI
import Habitica_Models
import ReactiveSwift

struct ChallengeFormPrizePage: View {
    @ObservedObject var viewModel: ChallengeFormViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.ChallengeForm.prizeTitle)
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.45)
                    .lineSpacing(1)
                    .padding(.horizontal, 8)
                Text(L10n.ChallengeForm.prizeDescription)
                    .font(.system(size: 17))
                    .tracking(-0.43)
                    .lineSpacing(2)
                    .foregroundStyle(ChallengeTheme.handle)
                    .padding(.horizontal, 8)
                ChallengePrizeStepper(amount: $viewModel.prizeAmount,
                                      minAmount: viewModel.minGemAmount,
                                      maxAmount: viewModel.userGemCount)
                    .padding(.top, 26)
                    .frame(maxWidth: .infinity)
                Text(viewModel.userGemCount > 0 ? L10n.ChallengeForm.selectUpToGems(viewModel.userGemCount) : L10n.ChallengeForm.needsGems)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ChallengeTheme.handle)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 26)
                Text(L10n.ChallengeForm.locationTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.horizontal, 8)
                ChallengeSelectionList {
                    ForEach(viewModel.challengeLocations, id: \.id) { location in
                        ChallengeSelectionRow(title: location.name,
                                              isSelected: viewModel.challengeLocation?.id == location.id,
                                              showsDivider: location.id != viewModel.challengeLocations.last?.id) {
                            withAnimation {
                                viewModel.challengeLocation = location
                            }
                            if viewModel.prizeAmount < viewModel.minGemAmount {
                                viewModel.prizeAmount = 1
                            }
                        }
                    }
                }
                if viewModel.isPublicChallenge {
                    Text(L10n.ChallengeForm.publicGemNote)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(ChallengeTheme.handle)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 14)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

struct ChallengePrizeStepper: View {
    @ObservedObject private var themeService = ThemeService.shared
    @Binding var amount: Int
    let minAmount: Int
    let maxAmount: Int
    @State private var isEditing = false

    private var textProxy: Binding<String> {
        Binding<String>(get: { String(amount) }, set: { newValue in
            let parsed = Int(newValue.filter { $0.isASCII && $0.isNumber }) ?? minAmount
            amount = max(minAmount, min(parsed, maxAmount))
        })
    }

    private func isWholeNumber(_ text: String) -> Bool {
        return text.count <= 9 && text.allSatisfy { $0.isASCII && $0.isNumber }
    }

    var body: some View {
        HStack(spacing: 20) {
            stepButton(systemName: "minus") {
                amount = max(minAmount, amount - 1)
            }
            HStack(spacing: 9) {
                Image(uiImage: Asset.gem.image)
                    .resizable().scaledToFit().frame(width: 22, height: 18)
                FocusableTextField(placeholder: "", text: textProxy, isFirstResponder: $isEditing, shouldChangeText: isWholeNumber, configuration: { textField in
                    textField.keyboardType = .numberPad
                    textField.textAlignment = .center
                    textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
                    textField.textColor = themeService.theme.primaryTextColor
                })
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 26)
            .frame(minWidth: 112)
            .background(Color(themeService.theme.windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            stepButton(systemName: "plus") {
                amount = max(minAmount, min(maxAmount, amount + 1))
            }
        }
    }

    private func stepButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(ChallengeTheme.purple)
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
    }
}