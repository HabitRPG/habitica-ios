//
//  AchievementsCollectionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models
import ReactiveSwift

struct Header: Identifiable {
    public var id: String {
        return title
    }
    
    var title: String
    var count: Int
}

enum AchievementPageItem: Identifiable, Hashable {
    static func == (lhs: AchievementPageItem, rhs: AchievementPageItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    case achievement(AchievementProtocol)
    case header(Header)
    
    var id: String {
        switch self {
        case .achievement(let achievement):
            return achievement.key ?? ""
        case .header(let header):
            return header.id
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class AchievementsViewModel: ViewModel {
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    
    @Published var isGridLayout = false
    @Published var items: [AchievementPageItem] = []
    @Published var quests: [String: QuestProtocol] = [:]
    
    var onShowAchievementDetail: ((AchievementProtocol) -> Void)?

    private static func appendSection(_ header: Header, from achievements: [AchievementProtocol], with key: String) -> [AchievementPageItem] {
        var modifiedHeader = header
        let matched = achievements.filter({ $0.category == key })
        var achievements: [AchievementPageItem] = matched.map({ achievement in
            return .achievement(achievement)
        })
        modifiedHeader.count = matched.filter({ achievement in
            return achievement.earned
        }).count
        achievements.insert(.header(modifiedHeader), at: 0)
        return achievements
    }
    
    override init() {
        super.init()
        
        let onboardingHeader = Header(title: L10n.Achievements.onboarding, count: 0)
        let basicHeader = Header(title: L10n.Achievements.basic, count: 0)
        let seasonalHeader = Header(title: L10n.Achievements.seasonal, count: 0)
        let specialHeader = Header(title: L10n.Achievements.special, count: 0)
        let questsHeader = Header(title: L10n.Achievements.quests, count: 0)
        let challengesHeader = Header(title: L10n.Achievements.challenges, count: 0)
        
        disposable.add(userRepository.getAchievements().on(value: {[weak self] (achievements, _) in
            var sections = [AchievementPageItem]()
            
            sections.append(contentsOf: AchievementsViewModel.appendSection(onboardingHeader, from: achievements, with: "onboarding"))
            sections.append(contentsOf: AchievementsViewModel.appendSection(basicHeader, from: achievements, with: "basic"))
            sections.append(contentsOf: AchievementsViewModel.appendSection(seasonalHeader, from: achievements, with: "seasonal"))
            sections.append(contentsOf: AchievementsViewModel.appendSection(specialHeader, from: achievements, with: "special"))
            sections.append(contentsOf: AchievementsViewModel.appendSection(questsHeader, from: achievements, with: "quests"))
            sections.append(contentsOf: AchievementsViewModel.appendSection(challengesHeader, from: achievements, with: "challenges"))

            self?.items = sections
        }).flatMap(.latest, {[weak self] (achievements, _) in
            return self?.inventoryRepository.getQuests(keys: achievements.map { $0.key ?? "" }) ?? SignalProducer.empty
        }).on(value: {[weak self] (quests, _) in
            self?.quests = Dictionary(uniqueKeysWithValues: quests.map { ($0.key ?? "", $0) })
        }).start())
    }
    
    func retrieveData(completed: (() -> Void)?) {
        disposable.add(userRepository.retrieveAchievements().observeCompleted {
            completed?()
        })
    }
}

struct AchievementIconView: View {
    let achievement: AchievementProtocol
    
    var body: some View {
        Group {
            if achievement.isQuestAchievement {
                EmptyView()
            } else if achievement.isChallengeAchievement {
                Image(Asset.wonChallengeIcon.name)
                    .frame(width: 48)
            } else if achievement.earned {
                PixelArtView(name: (achievement.icon ?? "") + "2x")
                    .frame(width: 48, height: 52)
            } else {
                PixelArtView(name: "achievement-unearned2x")
                    .frame(width: 48, height: 52)
            }
        }
    }
}

private struct AchievementHeaderView: View {
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(count)")
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                .cornerRadius(26)
        }
        .scaledFont(size: 15, weight: .semibold)
        .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
    }
}

private struct ListItem: View {
    let achievement: AchievementProtocol
    let questDetails: QuestProtocol?

    var body: some View {
        HStack(spacing: 18) {
            AchievementIconView(achievement: achievement)
            VStack(alignment: .leading, spacing: 4) {
                if let title = achievement.title {
                    Text(title)
                        .scaledFont(size: 15, weight: .semibold)
                        .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                } else if achievement.isQuestAchievement, let questDetails = questDetails {
                    Text(questDetails.text ?? "")
                        .scaledFont(size: 15, weight: .semibold)
                        .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                }
                if let text = achievement.text {
                    Text(text)
                        .scaledFont(size: 13)
                        .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color(ThemeService.shared.theme.windowBackgroundColor))
            .cornerRadius(26)
            .padding(.horizontal, 16)
    }
}

struct AchievementList: View {
    let viewModel: AchievementsViewModel
    let items: [AchievementPageItem]
    let quests: [String: QuestProtocol]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(items) { item in
                    switch item {
                    case .header(let header):
                        AchievementHeaderView(title: header.title, count: header.count)
                            .padding(.top, 22)
                            .padding(.leading, 32)
                            .padding(.trailing, 25)
                    case .achievement(let achievement):
                        ListItem(achievement: achievement, questDetails: quests[achievement.key ?? ""])
                            .onTapGesture {
                                if let action = viewModel.onShowAchievementDetail {
                                    action(achievement)
                                }
                            }
                    }
                }
            }.padding(.top, 8)
        }
    }
}

struct AchievementGridItem: View {
    let achievement: AchievementProtocol
    let questDetails: QuestProtocol?
    
    var body: some View {
        VStack(spacing: 15) {
            AchievementIconView(achievement: achievement)
            if let title = achievement.title {
                Text(title)
            } else if achievement.isQuestAchievement, let questDetails = questDetails {
                Text(questDetails.text ?? "")
            }
        }
        .scaledFont(size: 15, weight: .semibold)
        .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
        .padding(.vertical, 20)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(ThemeService.shared.theme.windowBackgroundColor))
            .cornerRadius(26)
    }
}

struct AchievementSection: Identifiable {
    var id = UUID()
    var header: Header
    var items: [AchievementProtocol]
}

struct AchievementGrid: View {
    let viewModel: AchievementsViewModel
    let items: [AchievementPageItem]
    let quests: [String: QuestProtocol]
    
    private func groupItems() -> [AchievementSection] {
        var grouped = [AchievementSection]()
        var lastKey: Header?
        var lastItems: [AchievementProtocol] = []
        for item in items {
            switch item {
            case .header(let header):
                if let lastKey = lastKey {
                    grouped.append(AchievementSection(header: lastKey, items: lastItems))
                }
                lastKey = header
                lastItems = []
            case .achievement(let achievement):
                lastItems.append(achievement)
            }
        }
        return grouped
    }
    
    var body: some View {
        let grouped = groupItems()
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 150, maximum: 180), spacing: 11)], spacing: 11) {
                ForEach(grouped) { section in
                    Section(header: AchievementHeaderView(title: section.header.title, count: section.header.count)
                        .padding(.top, 30)
                        .padding(.leading, 16)
                        .padding(.trailing, 9)) {
                        ForEach(section.items, id: \.key) { achievement in
                            AchievementGridItem(achievement: achievement, questDetails: quests[achievement.key ?? ""])
                                .onTapGesture {
                                    if let action = viewModel.onShowAchievementDetail {
                                        action(achievement)
                                    }
                                }
                        }
                    }
                }
            }.padding(.horizontal, 16)
        }
    }
}

struct AchievementsPage: View {
    @ObservedObject var viewModel: AchievementsViewModel
    
    var body: some View {
        if viewModel.isGridLayout {
            AchievementGrid(viewModel: viewModel, items: viewModel.items, quests: viewModel.quests)
        } else {
            AchievementList(viewModel: viewModel, items: viewModel.items, quests: viewModel.quests)
        }
    }
}

class AchievementsCollectionViewController: BaseHostingViewController<AchievementsPage> {
    private var viewModel = AchievementsViewModel()
    @IBOutlet weak var viewSwitcherButton: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: AchievementsPage(viewModel: viewModel))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        topHeaderCoordinator?.followScrollView = false
        viewModel.retrieveData(completed: nil)
        viewSwitcherButton.image = Asset.buttonGrid.image
        viewModel.onShowAchievementDetail = { achievement in
            let sheet = HostingBottomSheetController(rootView: AchievementSheet(achievement: achievement))
            self.present(sheet, animated: true)
        }
    }
    
    override func populateText() {
        super.populateText()
        title = L10n.Titles.achievements
    }
    
    @IBAction func viewSwitcherTapped(_ sender: Any) {
        viewModel.isGridLayout = !viewModel.isGridLayout
        if viewModel.isGridLayout == true {
            viewSwitcherButton.image = Asset.buttonList.image
        } else {
            viewSwitcherButton.image = Asset.buttonGrid.image
        }
    }
}
