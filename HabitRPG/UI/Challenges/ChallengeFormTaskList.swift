//
//  ChallengeFormTaskList.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.03.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models
import ReactiveSwift

struct TaskListItemWrapper<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(spacing: 12) {
            content
        }
        .frame(minHeight: 50)
        .background(Color(ThemeService.shared.theme.windowBackgroundColor))
        .cornerRadius(UIConstants.mediumCornerRadius)
        .padding(.horizontal, 8)
    }
}

struct TaskMainContent: View {
    let task: TaskProtocol
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = task.text, !title.isEmpty {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            if let notes = task.notes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 15))
            }
        }.foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
    }
}

struct HabitButtonUI: View {
    let isPositive: Bool
    let isActive: Bool
    var isLocked = false
    let taskValue: Float
    
    var icon: UIImage {
        if isLocked {
            return Asset.taskLockLight.image.withRenderingMode(.alwaysTemplate)
        } else if isPositive {
            return Asset.plus.image.withRenderingMode(.alwaysTemplate)
        } else {
            return Asset.minus.image.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill()
                .foregroundStyle(Color(isActive
                                       ? UIColor.forTaskValue(taskValue)
                                       : ThemeService.shared.theme.separatorColor))
                .frame(width: 24, height: 24)
            Image(uiImage: icon)
            .foregroundStyle(Color(isActive ? UIColor.white : ThemeService.shared.theme.quadTextColor))
        }
        .frame(maxHeight: .infinity)
        .frame(width: 40)
        .background(Color(isActive ? UIColor.forTaskValueLight(taskValue) : ThemeService.shared.theme.windowBackgroundColor))
    }
}

struct HabitListItem: View {
    let habit: TaskProtocol
    
    var body: some View {
        TaskListItemWrapper {
            HabitButtonUI(isPositive: true, isActive: habit.up, taskValue: habit.value)
            TaskMainContent(task: habit)
            HabitButtonUI(isPositive: false, isActive: habit.down, taskValue: habit.value)
        }
    }
}

struct TaskCheckmarkView: View {
    let isActive: Bool
    var isLocked = false
    let taskValue: Float
    let radius: CGFloat
    
    var body: some View {
        let theme = ThemeService.shared.theme
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill()
                .foregroundStyle(Color(isActive ? UIColor(white: theme.isDark ? 0.0 : 1.0, alpha: theme.isDark ? 0.25 : 0.7) : theme.windowBackgroundColor))
                .frame(width: 24, height: 24)
        }
        .frame(maxHeight: .infinity)
        .frame(width: 40)
        .background(Color(isActive ? UIColor.forTaskValueLight(taskValue) : ThemeService.shared.theme.offsetBackgroundColor))
    }
}

struct DailyListItem: View {
    let daily: TaskProtocol
    
    var body: some View {
        TaskListItemWrapper {
            TaskCheckmarkView(isActive: true, taskValue: daily.value, radius: 3)
            TaskMainContent(task: daily)
        }
    }
}

struct ToDoListItem: View {
    let todo: TaskProtocol
    
    var body: some View {
        TaskListItemWrapper {
            TaskCheckmarkView(isActive: true, taskValue: todo.value, radius: 12)
            TaskMainContent(task: todo)
        }
    }
}

struct RewardListItem: View {
    let reward: TaskProtocol
    
    var body: some View {
        TaskListItemWrapper {
            TaskMainContent(task: reward)
                .padding(.leading, 12)
            VStack(spacing: 2) {
                Image(uiImage: HabiticaIcons.imageOfGold)
                Text("\(Int(reward.value))")
            }
            .padding(.horizontal, 8)
            .frame(maxHeight: .infinity)
            .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
        }
    }
}

struct ChallengeFormTaskSquare: View {
    let fill: Color
    let glyph: String

    var body: some View {
        ZStack {
            fill
            Image(systemName: glyph)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 52)
        .frame(maxHeight: .infinity)
    }
}

struct ChallengeFormTaskRow: View {
    @ObservedObject private var themeService = ThemeService.shared
    let task: TaskProtocol

    var body: some View {
        Group {
            if task.type == TaskType.reward {
                rewardRow
            } else {
                standardRow
            }
        }
        .frame(minHeight: 54)
        .background(Color(themeService.theme.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var standardRow: some View {
        HStack(spacing: 0) {
            leadingSquare
            Text(task.text ?? "")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
            if task.type == TaskType.habit {
                ChallengeFormTaskSquare(fill: ChallengeTheme.habitFill, glyph: "minus")
            }
        }
    }

    private var rewardRow: some View {
        HStack(spacing: 0) {
            Text(task.text ?? "")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .padding(.leading, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(spacing: 1) {
                Image(uiImage: HabiticaIcons.imageOfGold)
                    .resizable().scaledToFit().frame(width: 17, height: 17)
                Text("\(Int(task.value))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ChallengeTheme.username)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 12)
            .background(Color(red: 0xEC / 255, green: 0xEB / 255, blue: 0xED / 255))
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            .padding(.trailing, 8)
            .padding(.vertical, 6)
        }
    }

    @ViewBuilder private var leadingSquare: some View {
        if task.type == TaskType.habit {
            ChallengeFormTaskSquare(fill: ChallengeTheme.habitFill, glyph: "plus")
        } else if task.type == TaskType.daily {
            ChallengeFormTaskSquare(fill: ChallengeTheme.dailyFill, glyph: "checkmark")
        } else if task.type == TaskType.todo {
            ChallengeFormTaskSquare(fill: ChallengeTheme.todoFill, glyph: "checkmark")
        }
    }
}

struct TaskListItem: View {
    let task: TaskProtocol

    var body: some View {
        ChallengeFormTaskRow(task: task)
    }
}

struct ChallengeFormTaskList<Title: View>: View {
    let viewModel: ChallengeFormViewModel
    let title: Title
    var taskType: TaskType
    @Binding var tasks: [TaskProtocol]
    let buttonText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                title
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ChallengeTheme.formSectionLabel)
                Spacer()
                if !tasks.isEmpty {
                    Text("\(tasks.count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(ChallengeTheme.formSectionLabel)
                        .frame(minWidth: 22, minHeight: 22)
                        .padding(.horizontal, 6)
                        .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                        .clipShape(Capsule())
                }
            }
            ForEach(tasks, id: \.id) { task in
                TaskListItem(task: task)
                    .onTapGesture {
                        if let action = viewModel.presentTaskForm {
                            action(taskType, task)
                        }
                    }
            }
            Button {
                if let action = viewModel.presentTaskForm {
                    action(taskType, nil)
                }
            } label: {
                Text(buttonText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(.plain)
        }.padding(.top, 24)
    }
}
