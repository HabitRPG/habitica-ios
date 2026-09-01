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
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                    let content = ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ChallengeFormPrizePage(viewModel: viewModel)
                                .frame(width: geometry.size.width)
                                .id(0)
                            ChallengeFormMetadataPage(viewModel: viewModel)
                                .frame(width: geometry.size.width)
                                .id(1)
                            ChallengeFormTagsPage(viewModel: viewModel)
                                .frame(width: geometry.size.width)
                                .id(2)
                            ChallengeFormTasksPage(viewModel: viewModel)
                                .frame(width: geometry.size.width)
                                .id(3)
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
        }
    }

    @ViewBuilder private var confirmButton: some View {
        let canConfirm = !viewModel.hasNextStep && viewModel.canSave
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
            PagerIndicator(currentIndex: viewModel.currentStepIndex ?? 0, total: 4)
            if viewModel.isSaving {
                HabiticaProgressView()
                    .frame(height: 40)
                    .padding(10)
            } else if viewModel.hasNextStep {
                let disableButton = !viewModel.isComplete(page: viewModel.currentStepIndex ?? 0)
                ChallengePillButton(L10n.next,
                                    fill: disableButton ? Color(themeService.theme.offsetBackgroundColor) : Color(themeService.theme.fixedTintColor),
                                    textColor: disableButton ? Color(themeService.theme.quadTextColor) : .white,
                                    weight: .semibold) {
                    withAnimation(.bouncy) {
                        viewModel.showNextStep()
                    }
                }
                .disabled(disableButton)
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
