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
    
    var size: CGFloat = 8
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 8) {
                ForEach(0..<total) { index in
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
                .offset(x: CGFloat(currentIndex * 16), y: 0)
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
                    .navigationTitle(L10n.createChallenge)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        if viewModel.hasPreviousStep {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    withAnimation(.bouncy) {
                                        viewModel.showPreviousStep()
                                    }
                                } label: {
                                    Image(Asset.caretLeft.name)
                                }
                            }
                        } else {
                            ToolbarItem(placement: .topBarLeading) {
                                CurrencyView(value: viewModel.userGemCount,
                                             currency: .gem,
                                             textColor: themeService.theme.isDark ? .green500 : .green1)
                                .fixedSize()
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                viewModel.dismiss()
                            } label: {
                                Image(Asset.close.name)
                            }
                        }
                }
                if #available(iOS 26.0, *) {
                    content.safeAreaBar(edge: .bottom, content: {
                        VStack {
                            PagerIndicator(currentIndex: viewModel.currentStepIndex ?? 0, total: 4)
                            if viewModel.isSaving {
                                HabiticaProgressView()
                                    .frame(height: 40)
                                    .padding(10)
                            } else {
                                let disableButton = (!viewModel.hasNextStep && !viewModel.canSave) ||
                                (viewModel.hasNextStep && !viewModel.isComplete(page: viewModel.currentStepIndex ?? 0))
                                HabiticaButtonUI(label: Text(viewModel.hasNextStep ? L10n.next : L10n.createChallenge)
                                    .foregroundStyle(disableButton ? Color(themeService.theme.quadTextColor) : .white),
                                                 color: Color(disableButton ? themeService.theme.offsetBackgroundColor : themeService.theme.fixedTintColor)) {
                                    withAnimation(.bouncy) {
                                        if viewModel.hasNextStep {
                                            viewModel.showNextStep()
                                        } else {
                                            viewModel.save()
                                        }
                                    }
                                }.disabled(disableButton)
                            }
                        }.padding(16)
                    })
                } else {
                    VStack {
                        content
                        VStack {
                                HStack {
                                    if viewModel.hasPreviousStep {
                                        Button {
                                            withAnimation(.bouncy) {
                                                viewModel.showPreviousStep()
                                            }
                                        } label: {
                                            Image(Asset.caretLeft.name)
                                                .frame(minWidth: 40, minHeight: 40)
                                        }
                                        .contentShape(.circle)
                                    }
                                    HabiticaButtonUI(label: Text(L10n.next), color: Color(themeService.theme.fixedTintColor)) {
                                        withAnimation(.bouncy) {
                                            viewModel.showNextStep()
                                        }
                                    }
                                }
                        }.padding(16)
                    }
                }
            }
        }
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
