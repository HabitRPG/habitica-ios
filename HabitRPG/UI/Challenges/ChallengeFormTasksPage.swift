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
                Text("Add some tasks")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.horizontal, 23)
                Text("Finally, it’s time to create the tasks you’d like all Challenge participants to complete.")
                    .font(.system(size: 17))
                    .padding(.horizontal, 23)
                ChallengeFormTaskList(viewModel: viewModel,
                                      title: Text("Challenge Habits"),
                                      taskType: .habit,
                                      tasks: $viewModel.habits,
                                      buttonText: "New Habit")
                ChallengeFormTaskList(viewModel: viewModel,
                                      title: Text("Challenge Dailies"),
                                      taskType: .daily,
                                      tasks: $viewModel.dailies,
                                      buttonText: "New Daily")
                ChallengeFormTaskList(viewModel: viewModel,
                                      title: Text("Challenge To Do's"),
                                      taskType: .todo,
                                      tasks: $viewModel.todos,
                                      buttonText: "New To Do")
                ChallengeFormTaskList(viewModel: viewModel,
                                      title: Text("Challenge Rewards"),
                                      taskType: .reward,
                                      tasks: $viewModel.rewards,
                                      buttonText: "New Reward")
            }.padding(.horizontal, 12)
                .padding(.top, 16)
        }
    }
}