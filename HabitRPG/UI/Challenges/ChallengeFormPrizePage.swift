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
                Text("Let's make a new Challenge")
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.45)
                    .lineSpacing(1)
                    .padding(.horizontal, 8)
                Text("First, set a prize and choose where to create the Challenge.")
                    .font(.system(size: 17))
                    .tracking(-0.43)
                    .lineSpacing(2)
                    .foregroundStyle(ChallengeTheme.handle)
                    .padding(.horizontal, 8)
                ChallengePrizeStepper(amount: $viewModel.prizeAmount,
                                      minAmount: viewModel.minGemAmount,
                                      maxAmount: viewModel.userGemCount)
                    .padding(.vertical, 26)
                    .frame(maxWidth: .infinity)
                Text("Add this Challenge to...")
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
                    Text("If you’re making a public Challenge, you have to offer at least 1 Gem as a prize")
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
    }
}

struct ChallengePrizeStepper: View {
    @ObservedObject private var themeService = ThemeService.shared
    @Binding var amount: Int
    let minAmount: Int
    let maxAmount: Int

    var body: some View {
        HStack(spacing: 20) {
            stepButton(systemName: "minus") {
                amount = max(minAmount, amount - 1)
            }
            HStack(spacing: 9) {
                Image(uiImage: Asset.gem.image)
                    .resizable().scaledToFit().frame(width: 22, height: 18)
                Text("\(amount)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 26)
            .background(Color(themeService.theme.windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            stepButton(systemName: "plus") {
                amount = min(maxAmount, amount + 1)
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