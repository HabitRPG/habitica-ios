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
        VStack(alignment: .leading, spacing: 3) {
            if let title = task.text, !title.isEmpty {
                Text(title.unicodeEmoji)
                    .font(.system(size: 16, weight: .semibold))
                    .lineSpacing(2)
            }
            if let notes = task.notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty {
                Text(notes.unicodeEmoji)
                    .font(.system(size: 15))
                    .lineSpacing(3)
                    .foregroundStyle(Color(ThemeService.shared.theme.ternaryTextColor))
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

struct ChallengeChecklistEntry: Equatable {
    let text: String
    let isCompleted: Bool
}

struct ChallengeTaskSnapshot: Equatable {
    let id: String
    let type: String?
    let text: String
    let notes: String?
    let value: Float
    let up: Bool
    let down: Bool
    let checklist: [ChallengeChecklistEntry]

    init(_ task: TaskProtocol) {
        id = task.id ?? ""
        type = task.type
        text = task.text ?? ""
        notes = task.notes
        value = task.value
        up = task.up
        down = task.down
        checklist = task.checklist.map { ChallengeChecklistEntry(text: $0.text ?? "", isCompleted: $0.completed) }
    }
}

struct ChallengeFormTaskRow: View {
    @ObservedObject private var themeService = ThemeService.shared
    let task: ChallengeTaskSnapshot
    @State private var isChecklistExpanded = false

    private var showsChecklist: Bool {
        (task.type == TaskType.daily || task.type == TaskType.todo) && !task.checklist.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if task.type == TaskType.habit {
                    habitColumn(isPositive: true)
                } else if task.type == TaskType.daily || task.type == TaskType.todo {
                    checkboxColumn
                }
                taskText
                    .padding(.leading, task.type == TaskType.reward ? 12 : 10)
                    .padding(.trailing, 11)
                if showsChecklist {
                    checklistIndicator
                }
                if task.type == TaskType.habit {
                    habitColumn(isPositive: false)
                } else if task.type == TaskType.reward {
                    rewardColumn
                }
            }
            .frame(minHeight: showsChecklist ? 60 : 46)
            if showsChecklist && isChecklistExpanded {
                checklistItems
            }
        }
        .background(ChallengeTheme.formFieldFill)
        .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.taskRadius, style: .continuous))
        .padding(.horizontal, 6)
    }

    private var taskText: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(task.text.unicodeEmoji)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
            if let notes = task.notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty {
                Text(notes.unicodeEmoji)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(themeService.theme.ternaryTextColor))
            }
        }
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var checklistIndicator: some View {
        let completedCount = task.checklist.filter { $0.isCompleted }.count
        let hasRemaining = completedCount < task.checklist.count
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isChecklistExpanded.toggle()
            }
        } label: {
            let contentColor = hasRemaining ? themeService.theme.primaryTextColor : themeService.theme.quadTextColor
            VStack(spacing: 1) {
                Text("\(completedCount)")
                Rectangle()
                    .fill(Color(contentColor))
                    .frame(width: 13, height: 1)
                Text("\(task.checklist.count)")
            }
            .font(.system(size: 15, weight: .semibold))
            .monospacedDigit()
            .foregroundStyle(Color(contentColor))
            .frame(minWidth: 34)
            .padding(.vertical, 5)
            .background(Color(themeService.theme.offsetBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.mediumCornerRadius, style: .continuous))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .frame(maxHeight: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isChecklistExpanded ? L10n.Accessibility.collapseChecklist : L10n.Accessibility.expandChecklist)
        .accessibilityValue("\(completedCount)/\(task.checklist.count)")
    }

    private var checklistItems: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(task.checklist.enumerated()), id: \.offset) { _, item in
                HStack(spacing: 0) {
                    checklistBox(isCompleted: item.isCompleted)
                        .frame(width: 40)
                    Text(item.text.unicodeEmoji)
                        .font(.system(size: 16, weight: .semibold))
                        .strikethrough(item.isCompleted)
                        .foregroundStyle(Color(item.isCompleted ? themeService.theme.quadTextColor : themeService.theme.primaryTextColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                        .padding(.trailing, 15)
                        .padding(.vertical, 10)
                }
            }
        }
        .padding(.bottom, 6)
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isChecklistExpanded = false
            }
        }
    }

    private func checklistBox(isCompleted: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: task.type == TaskType.daily ? 6 : 12)
                .fill(Color(themeService.theme.offsetBackgroundColor))
                .frame(width: 24, height: 24)
            if isCompleted {
                Image(uiImage: Asset.checkChecklist.image.withRenderingMode(.alwaysTemplate))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(Color(themeService.theme.quadTextColor))
            }
        }
    }

    private func habitColumn(isPositive: Bool) -> some View {
        let theme = themeService.theme
        let isActive = isPositive ? task.up : task.down
        let circleColor: UIColor
        if !isActive {
            circleColor = theme.separatorColor
        } else if task.value >= -1 && task.value < 1 {
            circleColor = .yellow10
        } else {
            circleColor = .forTaskValue(task.value)
        }
        let icon = isPositive ? Asset.plus.image : Asset.minus.image
        return ZStack {
            Color(isActive ? UIColor.forTaskValueLight(task.value) : theme.windowBackgroundColor)
            Circle()
                .fill(Color(circleColor))
                .frame(width: 24, height: 24)
            taskOverlay
            Image(uiImage: icon.withRenderingMode(.alwaysTemplate))
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .foregroundStyle(Color(isActive ? UIColor.white : theme.quadTextColor))
        }
        .frame(width: 40)
        .frame(maxHeight: .infinity)
    }

    private var checkboxColumn: some View {
        let theme = themeService.theme
        return ZStack {
            Color(UIColor.forTaskValueLight(task.value))
            RoundedRectangle(cornerRadius: task.type == TaskType.daily ? 6 : 12)
                .fill(Color(UIColor(white: theme.isDark ? 0.0 : 1.0, alpha: theme.isDark ? 0.25 : 0.7)))
                .frame(width: 24, height: 24)
            taskOverlay
        }
        .frame(width: 40)
        .frame(maxHeight: .infinity)
    }

    private var rewardColumn: some View {
        VStack(spacing: 2) {
            Image(uiImage: HabiticaIcons.imageOfGold)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
            Text("\(Int(task.value))")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(themeService.theme.isDark ? UIColor.yellow100 : UIColor.yellow1))
        }
        .frame(width: 56)
        .frame(maxHeight: .infinity)
        .background(Color(UIColor.yellow500.withAlphaComponent(0.3)))
    }

    @ViewBuilder private var taskOverlay: some View {
        if themeService.theme.isDark {
            Color(themeService.theme.taskOverlayTint)
        }
    }
}

struct TaskListItem: View {
    let task: ChallengeTaskSnapshot

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
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                Spacer()
                if !tasks.isEmpty {
                    Text("\(tasks.count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(ChallengeTheme.formSectionLabel)
                        .frame(width: 22, height: 22)
                        .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 8)
            if tasks.first?.isValid == true {
                ForEach(tasks, id: \.id) { task in
                    TaskListItem(task: ChallengeTaskSnapshot(task))
                        .onTapGesture {
                            if let action = viewModel.presentTaskForm {
                                action(taskType, task)
                            }
                        }
                }
            }
            Button {
                if let action = viewModel.presentTaskForm {
                    action(taskType, nil)
                }
            } label: {
                Text(buttonText)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(ChallengeTheme.formFieldFill)
                    .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.containerRadius, style: .continuous))
            }
            .buttonStyle(.plain)
        }.padding(.top, 24)
    }
}
