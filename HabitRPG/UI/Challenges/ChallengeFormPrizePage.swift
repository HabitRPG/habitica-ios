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
                    .font(.system(size: 24, weight: .bold))
                Text("First, set a prize and choose where to create the Challenge.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                PlusMinusStepperView(amount: $viewModel.prizeAmount,
                                     icon: Image(Asset.gem.name),
                                     minAmount: viewModel.minGemAmount,
                                     maxAmount: viewModel.userGemCount)
                    .padding(.vertical, 35)
                    .frame(maxWidth: .infinity)
                Text("Add this Challenge to...")
                    .font(.system(size: 17, weight: .bold))
                VStack(spacing: 15) {
                    ForEach(viewModel.challengeLocations, id: \.id) { location in
                        let isSelected = viewModel.challengeLocation?.id == location.id
                        HStack {
                            Text(location.name)
                                .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? ChallengeTheme.deepPurple : Color(ThemeService.shared.theme.primaryTextColor))
                            Spacer()
                        }.contentShape(.rect)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.challengeLocation = location
                                }
                                if viewModel.prizeAmount < viewModel.minGemAmount {
                                    viewModel.prizeAmount = 1
                                }
                            }
                        if location.id != viewModel.challengeLocations.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(15)
                .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                .cornerRadius(16)
                if viewModel.isPublicChallenge {
                    Text("If you’re making a public Challenge, you have to offer at least 1 Gem as a prize")
                        .font(.system(size: 14))
                        .foregroundStyle(ChallengeTheme.counter)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 14)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 16)
        }
    }
}