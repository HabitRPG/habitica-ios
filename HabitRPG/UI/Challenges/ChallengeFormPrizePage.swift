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
                    .padding(.horizontal, 23)
                Text("First, set a prize and choose where to create the Challenge.")
                    .font(.system(size: 17))
                    .padding(.horizontal, 23)
                PlusMinusStepperView(amount: $viewModel.prizeAmount,
                                     icon: Image(Asset.gem.name),
                                     minAmount: viewModel.minGemAmount,
                                     maxAmount: viewModel.userGemCount)
                    .padding(.vertical, 35)
                    .frame(maxWidth: .infinity)
                Text("Add this Challenge to...")
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.horizontal, 23)
                VStack(spacing: 15) {
                    ForEach(viewModel.challengeLocations, id: \.id) { location in
                        HStack {
                            Text(location.name)
                            Spacer()
                            if viewModel.challengeLocation?.id == location.id {
                                Image(Asset.checkmark.name)
                                    .renderingMode(.template)
                                    .foregroundStyle(Color(ThemeService.shared.theme.fixedTintColor))
                            }
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
                .cornerRadius(UIConstants.largeCornerRadius)
                if viewModel.isPublicChallenge {
                    Text("If you’re making a public Challenge, you have to offer at least 1 Gem as a prize")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
        }
    }
}