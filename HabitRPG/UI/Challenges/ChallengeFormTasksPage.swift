//
//  ChallengeFormTasksPage.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.03.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//


import SwiftUI
import Habitica_Models
import ReactiveSwift

struct ChallengeFormTasksPage: View {
    @ObservedObject var viewModel: ChallengeFormViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.ChallengeForm.tasksTitle)
                    .font(.system(size: 20, weight: .semibold))
                    .tracking(-0.45)
                    .lineSpacing(1)
                    .padding(.horizontal, 8)
                Text(L10n.ChallengeForm.tasksDescription)
                    .font(.system(size: 17))
                    .tracking(-0.43)
                    .lineSpacing(2)
                    .foregroundStyle(ChallengeTheme.handle)
                    .padding(.horizontal, 8)
                ChallengeFormTaskList(viewModel: viewModel,
                                      title: Text(L10n.challengeHabits),
                                      taskType: .habit,
                                      tasks: $viewModel.habits,
                                      buttonText: L10n.Tasks.Form.create(L10n.Tasks.habit))
                ChallengeFormTaskList(viewModel: viewModel,
                                      title: Text(L10n.challengeDailies),
                                      taskType: .daily,
                                      tasks: $viewModel.dailies,
                                      buttonText: L10n.Tasks.Form.create(L10n.Tasks.daily))
                ChallengeFormTaskList(viewModel: viewModel,
                                      title: Text(L10n.challengeTodos),
                                      taskType: .todo,
                                      tasks: $viewModel.todos,
                                      buttonText: L10n.Tasks.Form.create(L10n.Tasks.todo))
                ChallengeFormTaskList(viewModel: viewModel,
                                      title: Text(L10n.challengeRewards),
                                      taskType: .reward,
                                      tasks: $viewModel.rewards,
                                      buttonText: L10n.Tasks.Form.create(L10n.Tasks.reward))
            }.padding(.horizontal, 18)
                .padding(.top, 16)
        }
        .scrollDismissesKeyboard(.immediately)
    }
}