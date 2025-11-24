//
//  RYABottomSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.10.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

class RYABottomSheetViewModel: ViewModel {
    var dismisser = Dismisser()
    
    private let taskRepository = TaskRepository()
    private let userRepository = UserRepository()

    @Published var checkedTasks = [String]()
    @Published var isRunningCron = false
    var tasks: [TaskProtocol]
    private var onCronRun: () -> Void
    
    init(tasks: [TaskProtocol], onCronRun: @escaping () -> Void) {
        self.tasks = tasks
        self.onCronRun = onCronRun
        super.init()
    }
    
    func runCron() {
        if isRunningCron {
            return
        }
        withAnimation {
            isRunningCron = true
        }
        var completedTasks = [TaskProtocol]()
        var completedChecklistItems = [(TaskProtocol, ChecklistItemProtocol)]()
        for task in tasks {
            if task.completed || isChecked(task: task) {
                completedTasks.append(task)
            }
            
            for item in task.checklist where item.completed {
                completedChecklistItems.append((task, item))
            }
        }
        userRepository.runCron(checklistItems: completedChecklistItems, tasks: completedTasks)
        UserManager.shared.yesterdailiesDialog = nil
        dismisser.dismiss()
    }
    
    func isChecked(task: TaskProtocol) -> Bool {
        return checkedTasks.contains { taskId in
            return taskId == task.id
        }
    }
    
    func mark(task: TaskProtocol, asChecked checked: Bool) {
        if isRunningCron {
            return
        }
        withAnimation(.bouncy(duration: 0.2)) {
            if checked && !isChecked(task: task), let id = task.id {
                checkedTasks.append(id)
            } else if !checked == isChecked(task: task) {
                checkedTasks = checkedTasks.filter({ id in
                    return id != task.id
                })
            }
        }
    }
}

struct TaskCheckBox: View {
    let type: TaskType
    let value: Float
    var isDue: Bool = true
    var boxSize: CGFloat = 24
    let isChecked: Bool
    let onCheck: (Bool) -> Void
    
    @ViewBuilder private var shape: some View {
        if type == .daily {
            Rectangle().cornerRadius(6)
                .fill()
        } else {
            Circle().fill()
        }
    }
    
    private var boxColor: Color {
        let theme = ThemeService.shared.theme
        if isChecked {
            return Color(theme.offsetBackgroundColor)
        } else if isDue {
            return Color(white: theme.isDark ? 0.0 : 1.0, opacity: theme.isDark ? 0.25 : 0.7)
        } else {
            return Color(theme.windowBackgroundColor)
        }
    }
    
    private var backgroundColor: Color {
        if isChecked {
            return Color(ThemeService.shared.theme.windowBackgroundColor)
        } else if isDue != false {
            return Color(UIColor.forTaskValueLight(value))
        } else {
            return Color(ThemeService.shared.theme.offsetBackgroundColor)
        }
    }
    
    var body: some View {
        ZStack {
            shape
                .frame(width: boxSize, height: boxSize)
                .foregroundStyle(boxColor)
            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .semibold))
                    .transition(.scale)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }
}

struct RYATaskView: View {
    let task: TaskProtocol
    let isChecked: Bool
    let onChecked: (Bool) -> Void
    
    @State private var checklistCounter = 0
    
    var body: some View {
        VStack {
            HStack {
                TaskCheckBox(type: .daily, value: task.value, isChecked: isChecked) { check in
                    onChecked(check)
                }.frame(width: 40)
                Text(task.text ?? "")
                    .foregroundStyle(Color(isChecked ? ThemeService.shared.theme.secondaryTextColor : ThemeService.shared.theme.primaryTextColor))
                    .scaledFont(size: 16, weight: .semibold)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if !task.checklist.isEmpty {
                ForEach(task.checklist, id: \.id) { checklistItem in
                    HStack {
                        ZStack {
                            Rectangle().cornerRadius(6)
                                .fill()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color(ThemeService.shared.theme.offsetBackgroundColor))
                            if isChecked {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .semibold))
                                    .transition(.scale)
                            }
                        }
                        .frame(maxWidth: 40, maxHeight: .infinity)
                        Text(checklistItem.text ?? "")
                            .scaledFont(size: 16, weight: .semibold)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(Color(checklistItem.completed ? ThemeService.shared.theme.secondaryTextColor : ThemeService.shared.theme.primaryTextColor))
                    .scaledFont(size: 16, weight: .semibold)
                    .onTapGesture {
                        checklistItem.completed = true
                        checklistCounter += 1
                    }
                    .frame(minHeight: 40)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(minHeight: 50)
        .frame(maxWidth: .infinity)
        .background(Color(ThemeService.shared.theme.windowBackgroundColor))
        .cornerRadius(UIConstants.mediumCornerRadius)
        .onTapGesture {
            onChecked(!isChecked)
        }
    }
}

struct RYABottomSheet: View, Dismissable {
    var dismisser: Dismisser {
        get {
            return viewModel.dismisser
        }
        set {
            viewModel.dismisser = newValue
        }
    }
    @ObservedObject var viewModel: RYABottomSheetViewModel
    
    init(tasks: [TaskProtocol], onCronRun: @escaping () -> Void) {
        viewModel = RYABottomSheetViewModel(tasks: tasks, onCronRun: onCronRun)
    }
    
    var body: some View {
        BottomSheetView(dismisser: dismisser, content: VStack(spacing: 0) {
            let topContent = VStack(spacing: 9) {
                Text(L10n.welcomeBack)
                    .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                    .scaledFont(size: 22, weight: .bold)
                Text(L10n.checkinYesterdaysDalies)
                    .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                    .scaledFont(size: 17)
            }.padding(.top, 32)
            
            let scrollView = ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.tasks, id: \.id) { task in
                        RYATaskView(task: task, isChecked: viewModel.isChecked(task: task)) { checked in
                            viewModel.mark(task: task, asChecked: checked)
                        }
                    }
                }
            }.scrollBounceBehavior(.basedOnSize)
                .padding(.top, 16)
            
            let bottomContent = Group {
                if viewModel.isRunningCron {
                    HabiticaProgressView()
                        .transition(.opacity)
                } else {
                    HabiticaButtonUI(label: Text(L10n.startMyDay), color: Color(ThemeService.shared.theme.tintColor)) {
                        viewModel.runCron()
                    }
                    .transition(.opacity)
                }
            }
                .frame(height: 60)
            
            if #available(iOS 26.0, *) {
                scrollView
                    .safeAreaBar(edge: .top, content: {
                        topContent
                    })
                    .safeAreaBar(edge: .bottom) {
                        bottomContent
                            .padding(.bottom, 12)
                    }
            } else {
                topContent
                scrollView
                bottomContent
                    .padding(.bottom, 28)
            }
        },
                        topPadding: 0,
                        bottomPadding: 0)
        .ignoresSafeArea()
    }
}
