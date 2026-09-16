//
//  ChallengesFormViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 04.03.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models
import ReactiveSwift

struct PagerIndicator: View {
    let currentIndex: Int
    let total: Int
    
    var size: CGFloat = 7

    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 8) {
                ForEach(0..<total, id: \.self) { _ in
                    Circle()
                        .fill()
                        .foregroundStyle(Color(ThemeService.shared.theme.offsetBackgroundColor))
                        .frame(width: size, height: size)
                }
            }
            Circle()
                .fill()
                .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                .frame(width: size, height: size)
                .offset(x: CGFloat(currentIndex) * (size + 8), y: 0)
        }
    }
}

struct CreateChallengeForm: View {
    @ObservedObject var themeService = ThemeService.shared
    @ObservedObject var viewModel: ChallengeFormViewModel
    
    @Namespace private var buttonsNamespace
    @State private var isEditingText = false
    @FocusState private var focusedField: ChallengeFormFocus?
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                    let content = ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(Array(viewModel.steps.enumerated()), id: \.offset) { index, step in
                                page(for: step)
                                    .frame(width: geometry.size.width)
                                    .id(index)
                            }
                        }
                        .foregroundStyle(Color(themeService.theme.primaryTextColor))
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollPosition(id: $viewModel.currentStepIndex)
                    .navigationTitle(viewModel.isEditing ? L10n.editChallenge : L10n.createChallenge)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                if viewModel.hasPreviousStep {
                                    withAnimation(.bouncy) {
                                        viewModel.showPreviousStep()
                                    }
                                } else {
                                    viewModel.dismiss()
                                }
                            } label: {
                                Image(systemName: viewModel.hasPreviousStep ? "chevron.left" : "xmark")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            confirmButton
                        }
                }
                Group {
                    if #available(iOS 26.0, *) {
                        content.safeAreaBar(edge: .bottom, content: {
                            bottomDock
                        })
                    } else {
                        VStack(spacing: 0) {
                            content
                            bottomDock
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                    isEditingText = true
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    isEditingText = false
                }
            }
        }
    }

    @ViewBuilder private func page(for step: ChallengeFormStep) -> some View {
        switch step {
        case .prize:
            ChallengeFormPrizePage(viewModel: viewModel)
        case .info:
            ChallengeFormMetadataPage(viewModel: viewModel, focus: $focusedField)
        case .tasks:
            ChallengeFormTasksPage(viewModel: viewModel)
        }
    }

    @ViewBuilder private var confirmButton: some View {
        let canConfirm = viewModel.canSave
        if #available(iOS 26.0, *) {
            Button(role: .confirm) {
                viewModel.save()
            }
            .buttonStyle(.glassProminent)
            .tint(Color(themeService.theme.fixedTintColor))
            .disabled(!canConfirm)
        } else {
            Button {
                viewModel.save()
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(canConfirm ? .white : Color(themeService.theme.quadTextColor))
                    .frame(width: 30, height: 30)
                    .background(canConfirm ? Color(themeService.theme.fixedTintColor) : Color(themeService.theme.offsetBackgroundColor))
                    .clipShape(Circle())
            }
            .disabled(!canConfirm)
        }
    }

    @ViewBuilder private var bottomDock: some View {
        VStack(spacing: 20) {
            if viewModel.steps.count > 2 {
                PagerIndicator(currentIndex: viewModel.currentStepIndex ?? 0, total: viewModel.steps.count)
            }
            if viewModel.isSaving {
                HabiticaProgressView()
                    .frame(height: 40)
                    .padding(10)
            } else if isEditingText {
                let nextField = focusedField?.next
                ChallengePillButton(nextField == nil ? L10n.done : L10n.ChallengeForm.nextField,
                                    fill: Color(themeService.theme.fixedTintColor),
                                    textColor: .white,
                                    weight: .semibold) {
                    if let nextField = nextField {
                        focusedField = nextField
                    } else {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            } else if viewModel.hasNextStep {
                let nextStep = viewModel.steps[(viewModel.currentStepIndex ?? 0) + 1]
                ChallengePillButton(nextStep == .tasks ? L10n.ChallengeForm.reviewTasks : L10n.next,
                                    fill: Color(themeService.theme.fixedTintColor),
                                    textColor: .white,
                                    weight: .semibold) {
                    withAnimation(.bouncy) {
                        viewModel.showNextStep()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

class CreateChallengeViewController: BaseHostingViewController<CreateChallengeForm>, ChallengeTaskFormDelegate {
    private let viewModel = ChallengeFormViewModel()
    private var selectedIndex: Int?
    
    required init() {
        super.init(rootView: CreateChallengeForm(viewModel: viewModel))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: CreateChallengeForm(viewModel: viewModel))
    }

    func prepareForEditing(challenge: ChallengeProtocol) {
        viewModel.configureForEditing(challenge)
    }

    func prepareForCloning(challenge: ChallengeProtocol) {
        viewModel.configureForCloning(challenge)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onDismiss = { [weak self] in
            self?.dismiss(animated: true)
        }
        viewModel.presentTaskForm = {[weak self] taskType, task in
            let navigationController = StoryboardScene.Tasks.taskFormViewController.instantiate()
            if let taskFormController = navigationController.topViewController as? TaskFormController {
                taskFormController.taskType = taskType
                taskFormController.editedTask = task
                taskFormController.challengeTaskDelegate = self
            }
            self?.present(navigationController, animated: true)
        }
    }
    
    func created(taskType: TaskType, task: any TaskProtocol) {
        var taskList = viewModel.taskListFor(taskType: taskType)
        taskList.append(task)
        viewModel.updateTaskListFor(taskType: taskType, updatedList: taskList)
    }
    
    func updated(taskType: TaskType, task: any TaskProtocol) {
        var taskList = viewModel.taskListFor(taskType: taskType)
        guard let index = taskList.firstIndex(where: { $0.id == task.id }) else {
            taskList.append(task)
            viewModel.updateTaskListFor(taskType: taskType, updatedList: taskList)
            return
        }
        taskList.remove(at: index)
        taskList.insert(task, at: index)
        viewModel.updateTaskListFor(taskType: taskType, updatedList: taskList)
    }
    
    func deleted(taskType: TaskType, task: any TaskProtocol) {
        var taskList = viewModel.taskListFor(taskType: taskType)
        guard let index = taskList.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        taskList.remove(at: index)
        viewModel.updateTaskListFor(taskType: taskType, updatedList: taskList)
    }
}
