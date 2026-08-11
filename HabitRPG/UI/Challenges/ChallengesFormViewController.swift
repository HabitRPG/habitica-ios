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
                        if viewModel.hasPreviousStep {
                            ToolbarItem(placement: .topBarLeading) {
                                ChallengeCircleButton(systemName: "chevron.left") {
                                    withAnimation(.bouncy) {
                                        viewModel.showPreviousStep()
                                    }
                                }
                            }
                        } else {
                            ToolbarItem(placement: .topBarLeading) {
                                HStack(spacing: 5) {
                                    Image(uiImage: Asset.gem.image)
                                        .resizable().scaledToFit().frame(width: 18, height: 15)
                                    Text("\(viewModel.userGemCount)")
                                        .font(.system(size: 15, weight: .bold))
                                        .lineLimit(1)
                                        .foregroundStyle(Color(themeService.theme.primaryTextColor))
                                }
                                .fixedSize()
                                .padding(.leading, 10)
                                .padding(.trailing, 12)
                                .padding(.vertical, 6)
                                .background(Color(themeService.theme.offsetBackgroundColor))
                                .clipShape(Capsule())
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            ChallengeCircleButton(systemName: "xmark") {
                                viewModel.dismiss()
                            }
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

    @ViewBuilder private var bottomDock: some View {
        VStack(spacing: 20) {
            PagerIndicator(currentIndex: viewModel.currentStepIndex ?? 0, total: 4)
            if viewModel.isSaving {
                HabiticaProgressView()
                    .frame(height: 40)
                    .padding(10)
            } else {
                let disableButton = (!viewModel.hasNextStep && !viewModel.canSave) ||
                    (viewModel.hasNextStep && !viewModel.isComplete(page: viewModel.currentStepIndex ?? 0))
                ChallengePillButton(viewModel.hasNextStep ? L10n.next : L10n.createMyChallenge,
                                    fill: disableButton ? Color(themeService.theme.offsetBackgroundColor) : Color(themeService.theme.fixedTintColor),
                                    textColor: disableButton ? Color(themeService.theme.quadTextColor) : .white,
                                    weight: viewModel.hasNextStep ? .semibold : .bold) {
                    withAnimation(.bouncy) {
                        if viewModel.hasNextStep {
                            viewModel.showNextStep()
                        } else {
                            viewModel.save()
                        }
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
