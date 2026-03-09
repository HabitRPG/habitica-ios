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

enum ChallengeFormStep: CaseIterable {
    case prize
    case metadata
    case tags
    case tasks
}

struct ChallengeLocation: Identifiable {
    let id: String
    let name: String
}

class ChallengeFormViewModel: ViewModel {
    private let userRepository = UserRepository()
    private let socialRepository = SocialRepository()
    var onDismiss: (() -> Void)?
    
    @Published var userGemCount = 0
    
    @Published var currentStepIndex: Int? = 0
    let steps = ChallengeFormStep.allCases
    
    @Published var prizeAmount: Int = 1
    @Published var challengeLocation: ChallengeLocation? = nil
    @Published var name: String = ""
    @Published var summary: String = ""
    @Published var description: String = ""
    @Published var challengeTag: String = ""
    @Published var challengeCategories = Set<ChallengeCategory>()

    @Published var habits: [TaskProtocol] = []
    @Published var dailies: [TaskProtocol] = []
    @Published var todos: [TaskProtocol] = []
    @Published var rewards: [TaskProtocol] = []
    
    @Published var challengeLocations: [ChallengeLocation] = [
        ChallengeLocation(id: Constants.TAVERN_ID, name: "Public Challenge List")
    ]
    
    var canCreate: Bool {
        return false
    }
    
    var minGemAmount: Int {
        if challengeLocation?.id == Constants.TAVERN_ID {
            return 1
        } else {
            return 0
        }
    }
    
    override init() {
        super.init()
        challengeLocation = challengeLocations.first
        disposable.add(userRepository.getUser().on(value: {[weak self] user in
            self?.userGemCount = user.gemCount
        })
            .map({ user in
                return user.party?.id
            })
            .filter { $0 != nil }
            .flatMap(.latest, {[weak self] partyID in
                return self?.socialRepository.getGroup(groupID: partyID ?? "") ?? SignalProducer.empty
            }).on(value: { party in
                if let party = party, !self.challengeLocations.contains(where: { $0.id == party.id }) {
                    self.challengeLocations.insert(ChallengeLocation(id: party.id ?? "", name: party.name ?? ""), at: 1)
                }
            }).start())
        disposable.add(userRepository.getGroupPlans()
            .on(value: { plans in
                plans.value.forEach { plan in
                    if !self.challengeLocations.contains(where: { $0.id == plan.id }) {
                        self.challengeLocations.append(ChallengeLocation(id: plan.id ?? "", name: plan.name ?? ""))
                    }
                }
            }).start())
    }

    func dismiss() {
        if let action = onDismiss {
            action()
        }
    }
    
    var hasPreviousStep: Bool {
        return (currentStepIndex ?? 0) > 0
    }
    
    var hasNextStep: Bool {
        return (currentStepIndex ?? 0) < 3
    }
    
    func showPreviousStep() {
        if let index = currentStepIndex {
            if index > 0 {
                currentStepIndex = index - 1
            }
        }
    }
    
    func showNextStep() {
        if let index = currentStepIndex {
            if index < 4 {
                currentStepIndex = index + 1
            }
        }
    }
    
    func categoryTapepd(category: ChallengeCategory) {
        withAnimation {
            if challengeCategories.contains(category) {
                challengeCategories.remove(category)
            } else if challengeCategories.count < 3 {
                challengeCategories.insert(category)
            }
        }
    }
}

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
                                viewModel.challengeLocation = location
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
                Text("If you’re making a public Challenge, you have to offer at least 1 Gem as a prize")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
        }
    }
}

struct ChallengeFormField<Label: View>: View {
    let label: Label
    @Binding var text: String
    let multiline: Bool
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            label
                .font(.system(size: 17, weight: .semibold))
                .padding(.leading, 23)
            TextField("", text: $text, prompt: Text(placeholder), axis: multiline ? .vertical : .horizontal)
                .lineLimit(4...)
                .padding(18)
                .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                .cornerRadius(UIConstants.largeCornerRadius)
        }
    }
}

struct ChallengeMetadataForm: View {
    @ObservedObject var viewModel: ChallengeFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ChallengeFormField(label: Text(L10n.name),
                               text: $viewModel.name,
                               multiline: false,
                               placeholder: "What is your Challenge called?")
            ChallengeFormField(label: Text(L10n.summary),
                               text: $viewModel.summary,
                               multiline: true,
                               placeholder: "What’s the main purpose of your Challenge? This short summary will show in the list of Challenges.")
            ChallengeFormField(label: Text(L10n.description),
                               text: $viewModel.description,
                               multiline: true,
                               placeholder: "What details do participants need to know about your Challenge?")
        }
    }
}

struct ChallengeFormMetadataPage: View {
    @ObservedObject var viewModel: ChallengeFormViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("What’s your Challenge about?")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.horizontal, 23)
                Text("This information helps others know the topic, rules, and goals of your Challenge.")
                    .font(.system(size: 17))
                    .padding(.horizontal, 23)
                ChallengeMetadataForm(viewModel: viewModel)
                    .padding(.top, 12)
            }.padding(.horizontal, 12)
                .padding(.top, 16)
        }
    }
}

struct ChallengeFormTagsPage: View {
    @ObservedObject var viewModel: ChallengeFormViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Identify your Challenge")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.horizontal, 23)
                Text("Pick a short tag that will be added to all your Challenge’s tasks and up to 3 categories to help players find you!")
                    .font(.system(size: 17))
                    .padding(.horizontal, 23)
                VStack(alignment: .leading, spacing: 10) {
                    ChallengeFormField(label: Text("Challenge Tag"), text: $viewModel.challengeTag, multiline: false, placeholder: "What tag will identify your Challenge?")
                    Text("Categories")
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.leading, 23)
                        .padding(.top, 26)
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(ChallengeCategory.allCases) { challengeCategory in
                            HStack {
                                Text(challengeCategory.localizedName)
                                Spacer()
                                if viewModel.challengeCategories.contains(challengeCategory) {
                                    Image(Asset.checkmark.name)
                                        .renderingMode(.template)
                                        .foregroundStyle(Color(ThemeService.shared.theme.fixedTintColor))
                                }
                            }.padding(.leading, 12)
                                .contentShape(.rect)
                                .onTapGesture {
                                    viewModel.categoryTapepd(category: challengeCategory)
                                }
                            if challengeCategory != ChallengeCategory.allCases.last {
                                Divider()
                            }
                        }
                    }
                    .padding(15)
                    .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                    .cornerRadius(UIConstants.largeCornerRadius)
                }
            }.padding(.horizontal, 12)
                .padding(.top, 16)
        }
    }
}

struct ChallengeFormTaskList<Title: View>: View {
    let title: Title
    @Binding var tasks: [TaskProtocol]
    let buttonText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {title
                .font(.system(size: 15, weight: .semibold))
                .padding(.horizontal, 23)
                Spacer()
                if !tasks.isEmpty {
                    Text("\(tasks.count)")
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            HabiticaButtonUI(label: Text(buttonText).foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor)),
                             color: Color(ThemeService.shared.theme.windowBackgroundColor)) {
            }
        }.padding(.top, 26)
    }
}

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
                ChallengeFormTaskList(title: Text("Challenge Habits"),
                                      tasks: $viewModel.habits,
                                      buttonText: "New Habit")
                ChallengeFormTaskList(title: Text("Challenge Dailies"),
                                      tasks: $viewModel.dailies,
                                      buttonText: "New Daily")
                ChallengeFormTaskList(title: Text("Challenge To Do's"),
                                      tasks: $viewModel.todos,
                                      buttonText: "New To Do")
                ChallengeFormTaskList(title: Text("Challenge Rewards"),
                                      tasks: $viewModel.rewards,
                                      buttonText: "New Reward")
            }.padding(.horizontal, 12)
                .padding(.top, 16)
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
                                    let disableButton = !viewModel.hasNextStep && !viewModel.canCreate
                                    HabiticaButtonUI(label: Text(viewModel.hasNextStep ? L10n.next : L10n.createChallenge)
                                        .foregroundStyle(disableButton ? Color(themeService.theme.quadTextColor) : .white),
                                                     color: Color(disableButton ? themeService.theme.offsetBackgroundColor : themeService.theme.fixedTintColor)) {
                                        withAnimation(.bouncy) {
                                            viewModel.showNextStep()
                                        }
                                    }
                                    .disabled(disableButton)
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

class CreateChallengeViewController: BaseHostingViewController<CreateChallengeForm> {
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
    }
}
