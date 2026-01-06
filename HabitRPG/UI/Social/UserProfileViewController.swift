//
//  UserProfileViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import Down
import SwiftUI
import Kingfisher

private class ProfileViewModel: ViewModel {
    @Published var member: MemberProtocol?
    @Published var hallMember: MemberProtocol?
    @Published var user: UserProtocol?
    @Published var achievements = [AchievementProtocol]()
    @Published var questData = [String: QuestProtocol]()
    
    @Published var calculatedStats = CalculatedUserStats()
    
    @Published var baseAnimalKeys = [String]()
    
    @Published var currentPet: PetProtocol?
    @Published var currentMount: MountProtocol?
    
    var onAchievementDetail: ((AchievementProtocol) -> Void)?
}

private struct ProfileContainer: ViewModifier {
    @ObservedObject var themeService = ThemeService.shared
    let spacing: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(spacing)
            .background(Color(themeService.theme.windowBackgroundColor))
            .cornerRadius(UIConstants.largeCornerRadius)
    }
}

extension View {
    func profileContainer(spacing: CGFloat = 17) -> some View {
        modifier(ProfileContainer(spacing: spacing))
    }
}

struct ValueBarProgressStyle: ProgressViewStyle {
    @ObservedObject var themeService = ThemeService.shared
    var gradientStart: Color
    var gradientEnd: Color
    
    func makeBody(configuration: Configuration) -> some View {
        Capsule().fill(Color(themeService.theme.offsetBackgroundColor))
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule().fill(
                        LinearGradient(
                              gradient: .init(colors: [self.gradientStart, self.gradientEnd]),
                              startPoint: .init(x: 0, y: 0),
                              endPoint: .init(x: 1.0, y: 0)
                            )
                    )
                        .frame(width: proxy.size.width * (configuration.fractionCompleted ?? 0))
                }
            }
    }
}

struct ValueBar<LeadingLabel: View, TrailingLabel: View>: View {
    var value: Float
    var maxValue: Float
    var leadingLabel: LeadingLabel
    var trailingLabel: TrailingLabel?
    var barHeight: CGFloat = 15
    var barStartColor: Color
    var barEndColor: Color
    
    var body: some View {
        VStack {
            ProgressView(value: value, total: maxValue == 0 ? (value + 1) : maxValue)
                .progressViewStyle(ValueBarProgressStyle(gradientStart: barStartColor, gradientEnd: barEndColor))
                .frame(height: barHeight)
            HStack {
                leadingLabel.scaledFont(size: 12, weight: .black)
                Spacer()
                trailingLabel
                if trailingLabel == nil {
                    Text("\(value, format: .number.precision(.fractionLength(0)))/\(maxValue, format: .number.precision(.fractionLength(0)))")
                }
            }.scaledFont(size: 12, weight: .bold)
        }
    }
}

extension ValueBar where TrailingLabel == EmptyView {
    init(value: Float, maxValue: Float, leadingLabel: LeadingLabel, barStartColor: Color, barEndColor: Color) {
        self.init(value: value, maxValue: maxValue, leadingLabel: leadingLabel, trailingLabel: nil, barStartColor: barStartColor, barEndColor: barEndColor)
    }
}

private struct GearGridItem<Label: View>: View {
    @ObservedObject var themeService = ThemeService.shared
    let iconName: String?
    let label: Label
    
    var body: some View {
        VStack(spacing: 7) {
            Group {
                if let iconName = iconName {
                    PixelArtView(name: iconName)
                        .transition(.scale)
                } else {
                    Rectangle().stroke(style: StrokeStyle(lineWidth: 2, dash: [2]))
                        .frame(width: 58, height: 58)
                        .foregroundStyle(Color(themeService.theme.dimmedTextColor))
                }
            }.frame(width: 70, height: 70)
                .background(Color(themeService.theme.offsetBackgroundColor))
                .cornerRadius(UIConstants.smallCornerRadius)
            label
                .scaledFont(size: 12, weight: .medium)
        }
    }
}

struct GearGridView: View {
    let outfit: OutfitProtocol
    let background: String?
    
    func isEquipped(key: String?) -> Bool {
        if key == nil {
            return false
        }
        if key?.contains("_0") == true {
            return false
        }
        return true
    }
    
    var body: some View {
        HStack {
            VStack(spacing: 17) {
                GearGridItem(iconName: isEquipped(key: outfit.weapon) ? "shop_\(outfit.weapon ?? "")" : nil, label: Text(L10n.Equipment.weapon))
                GearGridItem(iconName: isEquipped(key: outfit.armor) ? "shop_\(outfit.armor ?? "")" : nil, label: Text(L10n.Equipment.armor))
                GearGridItem(iconName: isEquipped(key: outfit.back) ? "shop_\(outfit.back ?? "")" : nil, label: Text(L10n.Equipment.back))
            }
            Spacer()
            VStack(spacing: 17) {
                GearGridItem(iconName: isEquipped(key: outfit.shield) ? "shop_\(outfit.shield ?? "")" : nil, label: Text(L10n.Equipment.offHand))
                GearGridItem(iconName: isEquipped(key: outfit.headAccessory) ? "shop_\(outfit.headAccessory ?? "")" : nil, label: Text(L10n.Equipment.headAccessory))
                GearGridItem(iconName: isEquipped(key: outfit.eyewear) ? "shop_\(outfit.eyewear ?? "")" : nil, label: Text(L10n.Equipment.eyewear))
            }
            Spacer()
            VStack(spacing: 17) {
                GearGridItem(iconName: isEquipped(key: outfit.head) ? "shop_\(outfit.head ?? "")" : nil, label: Text(L10n.Equipment.head))
                GearGridItem(iconName: isEquipped(key: outfit.body) ? "shop_\(outfit.body ?? "")" : nil, label: Text(L10n.Equipment.body))
                GearGridItem(iconName: isEquipped(key: background) ? "icon_background_\(background ?? "")" : nil, label: Text(L10n.background))
            }
        }.profileContainer()
    }
}

struct StatsViewUI: View {
    @ObservedObject var themeService = ThemeService.shared
    let upperBackgroundColor: Color
    let upperTextColor: Color
    let title: String
    
    let totalValue: Int
    let levelValue: Int
    let equipmentValue: Int
    let buffValue: Int
    let allocatedValue: Int
    
    @ViewBuilder
    func makeEntry(value: Int, name: String) -> some View {
        VStack {
            Text("\(value)").scaledFont(size: 22, weight: .semibold)
            Text(name).scaledFont(size: 13)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                Spacer()
                Text("\(totalValue)")
            }
            .scaledFont(size: 22, weight: .bold)
            .padding(.vertical, 8)
            .padding(.horizontal, 26)
            .frame(minHeight: 28)
            .background(upperBackgroundColor)
            .foregroundStyle(upperTextColor)
            HStack {
                Spacer()
                makeEntry(value: levelValue, name: L10n.level)
                Spacer()
                makeEntry(value: equipmentValue, name: L10n.Equipment.equipment)
                Spacer()
                makeEntry(value: buffValue, name: L10n.buffs)
                Spacer()
                makeEntry(value: allocatedValue, name: L10n.allocated)
                Spacer()
            }.padding(.vertical, 16)
                .foregroundStyle(Color(themeService.theme.ternaryTextColor))
        }.background(Color(themeService.theme.windowBackgroundColor))
            .cornerRadius(UIConstants.largeCornerRadius)
    }
}

struct ProfilePage: View {
    @ObservedObject var themeService = ThemeService.shared
    @ObservedObject fileprivate var viewModel: ProfileViewModel
    
    @State private var showEquipmentCostume = "equipment"
    
    private func classTextColor(className: String) -> Color {
        if themeService.theme.isDark {
            switch className {
            case "warrior":
                return .red500
            case "healer":
                return .yellow500
            case "wizard":
                return .blue500
            case "rogue":
                return .purple500
            default:
                return Color(themeService.theme.primaryTextColor)
            }
        } else {
            switch className {
            case "warrior":
                return .red1
            case "healer":
                return .yellow1
            case "wizard":
                return .blue1
            case "rogue":
                return .purple10
            default:
                return Color(themeService.theme.primaryTextColor)
            }
        }
    }
    
    @ViewBuilder
    private func classImage(className: String) -> some View {
        if className == "warrior" {
            Image(uiImage: HabiticaIcons.imageOfWarriorDarkBg)
                .frame(width: 32, height: 32)
                .background(.red500)
                .clipShape(.circle)
        } else if className == "healer" {
            Image(uiImage: HabiticaIcons.imageOfHealerDarkBg)
                .frame(width: 32, height: 32)
                .background(.yellow500)
                .clipShape(.circle)
        } else if className == "wizard" {
            Image(uiImage: HabiticaIcons.imageOfMageDarkBg)
                .frame(width: 32, height: 32)
                .background(.blue500)
                .clipShape(.circle)
        } else if className == "rogue" {
            Image(uiImage: HabiticaIcons.imageOfRogueDarkBg)
                .frame(width: 32, height: 32)
                .background(.purple500)
                .clipShape(.circle)
        }
    }
    
    var body: some View {
        ScrollView {
            if let member = viewModel.member {
                LazyVStack(spacing: 12) {
                    HStack(spacing: 11) {
                        ZStack {
                            AvatarViewUI(avatar: AvatarViewModel(avatar: member))
                                .frame(width: 141, height: 147)
                        }
                        .frame(width: 135, height: 141)
                        .cornerRadius(UIConstants.largeCornerRadius)
                        VStack(alignment: .leading, spacing: 7) {
                            HStack(spacing: 10) {
                                if member.hasHabiticaClass {
                                    classImage(className: member.stats?.habitClass ?? "")
                                    Text("Lv. \(member.stats?.level ?? 0) \(member.stats?.habitClassNice?.capitalized ?? "")")
                                        .foregroundStyle(classTextColor(className: member.stats?.habitClass ?? ""))
                                } else {
                                    Text("Lv. \(member.stats?.level ?? 0)")
                                }
                            }.scaledFont(size: 12, weight: .black)
                            if let stats = member.stats {
                                HStack(spacing: 8) {
                                    Image(uiImage: themeService.theme.isDark ? HabiticaIcons.imageOfHeartDarkBg : HabiticaIcons.imageOfHeartLightBg)
                                        .frame(width: 28)
                                    ValueBar(value: stats.health, maxValue: stats.maxHealth, leadingLabel: Text("HP"), barStartColor: .red100, barEndColor: .orange100)
                                        .foregroundStyle(Color.maroon100)
                                }
                                HStack(spacing: 8) {
                                    Image(uiImage: HabiticaIcons.imageOfExperience)
                                        .frame(width: 28)
                                    ValueBar(value: stats.experience, maxValue: stats.toNextLevel, leadingLabel: Text("EXP"), barStartColor: .orange100, barEndColor: .yellow100)
                                        .foregroundStyle(Color.yellow1)
                                }
                                HStack(spacing: 8) {
                                    Image(uiImage: HabiticaIcons.imageOfMagic)
                                        .frame(width: 28)
                                    ValueBar(value: stats.mana, maxValue: stats.maxMana, leadingLabel: Text("MP"), barStartColor: .blue100, barEndColor: .teal100)
                                        .foregroundStyle(Color.blue10)
                                }
                            }
                        }.frame(maxWidth: .infinity)
                    }.profileContainer(spacing: 15)
                    
                    VStack(spacing: 2) {
                        Text(member.profile?.name ?? "")
                            .scaledFont(size: 22, weight: .bold)
                        if let createdDate = member.authentication?.timestamps?.createdAt {
                            Text(L10n.joinedX(createdDate.formatted(date: .abbreviated, time: .omitted)))
                                .scaledFont(size: 17)
                        }
                    }.profileContainer()
                    HStack(spacing: 12) {
                        VStack {
                            Text(L10n.logins).scaledFont(size: 17, weight: .semibold)
                            Text("\(member.loginIncentives)").scaledFont(size: 17)
                        }.profileContainer()
                        VStack {
                            Text(L10n.Member.lastLoggedIn).scaledFont(size: 17, weight: .semibold)
                            if let loggedin = member.authentication?.timestamps?.loggedIn {
                                Text("\(loggedin.formatted(date: .abbreviated, time: .omitted))").scaledFont(size: 17)
                            }
                        }.profileContainer()
                    }
                    
                    VStack(spacing: 14) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(L10n.username).scaledFont(size: 17, weight: .semibold)
                                Text("@\(viewModel.member?.username ?? "")")
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            Button {
                                
                            } label: {
                                Image(systemName: "document.on.document")
                            }.buttonStyle(.borderless)
                        }.padding(.horizontal, 13)
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(L10n.userID).scaledFont(size: 17, weight: .semibold)
                                Text("\(viewModel.member?.id ?? "")")
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            Button {
                                
                            } label: {
                                Image(systemName: "document.on.document")
                            }.buttonStyle(.borderless)
                        }.padding(.horizontal, 13)
                        
                        if let blurb = viewModel.member?.profile?.blurb {
                            Divider()
                            VStack(alignment: .leading) {
                                Text(L10n.Titles.about).scaledFont(size: 17, weight: .semibold)
                                Text(blurb)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 13)
                        }
                    }.profileContainer(spacing: 13)
                    
                    if let photoUrl = viewModel.member?.profile?.photoUrl {
                        KFImage(URL(string: photoUrl))
                    }
                    
                    Text(L10n.equippedGear)
                        .scaledFont(size: 22, weight: .bold)
                        .padding(.top, 28)
                    Picker(selection: $showEquipmentCostume) {
                        Text(L10n.Equipment.equipment).tag("equipment")
                        Text(L10n.Equipment.costume).tag("costume")
                    }.pickerStyle(.segmented)
                    
                    if let outfit = showEquipmentCostume == "equipment" ? member.items?.gear?.equipped : member.items?.gear?.costume {
                        GearGridView(outfit: outfit, background: member.preferences?.background)
                    }
                    
                    Text(L10n.Stable.petsAndMounts)
                        .scaledFont(size: 22, weight: .bold)
                        .padding(.top, 28)
                    StableBackgroundView(content: HStack(spacing: 57) {
                        if let pet = viewModel.currentPet {
                            PetView(pet: pet).padding(.top, 40)
                        }
                        if let mount = viewModel.currentMount {
                            MountView(mount: mount).padding(.top, 30)
                        }
                    }, animateFlying: false)
                    .cornerRadius(UIConstants.mediumCornerRadius)
                    .profileContainer(spacing: 26)
                    
                    HStack(spacing: 12) {
                        VStack(spacing: 26) {
                            VStack {
                                Text(L10n.pet).scaledFont(size: 17, weight: .semibold)
                                if let pet = viewModel.currentPet {
                                    Text(pet.text ?? "")
                                } else {
                                    Text(L10n.none).foregroundStyle(Color(themeService.theme.dimmedTextColor))
                                }
                            }
                            VStack {
                                Text("\(member.items?.ownedPets.filter { pet in pet.trained != 0 } .count ?? 0)").scaledFont(size: 17, weight: .semibold)
                                Text(L10n.petsFound)
                            }
                            VStack {
                                Text("\(member.items?.ownedPets.filter { pet in viewModel.baseAnimalKeys.contains(pet.key ?? "") && pet.trained != 0 }.count ?? 0)/\(viewModel.baseAnimalKeys.count)")
                                    .scaledFont(size: 17, weight: .semibold)
                                Text(L10n.standardPets)
                            }
                        }.profileContainer()
                        
                        VStack(spacing: 26) {
                            VStack {
                                Text(L10n.mount).scaledFont(size: 17, weight: .semibold)
                                if let mount = viewModel.currentMount {
                                    Text(mount.text ?? "")
                                } else {
                                    Text(L10n.none).foregroundStyle(Color(themeService.theme.dimmedTextColor))
                                }
                            }
                            VStack {
                                Text("\(member.items?.ownedMounts.filter { mount in mount.owned }.count ?? 0)").scaledFont(size: 17, weight: .semibold)
                                Text(L10n.mountsFound)
                            }
                            VStack {
                                Text("\(member.items?.ownedMounts.filter { mount in viewModel.baseAnimalKeys.contains(mount.key ?? "") && mount.owned } .count ?? 0)/\(viewModel.baseAnimalKeys.count)")
                                    .scaledFont(size: 17, weight: .semibold)
                                Text(L10n.standardMounts)
                            }
                        }.profileContainer()
                    }.scaledFont(size: 13)
                    
                    Text(L10n.stats)
                        .scaledFont(size: 22, weight: .bold)
                        .padding(.top, 28)
                    let calc = viewModel.calculatedStats
                    StatsViewUI(upperBackgroundColor: .red100,
                                upperTextColor: .red1,
                                title: L10n.Stats.strengthTitle,
                                totalValue: calc.totalStrength,
                                levelValue: calc.levelStat,
                                equipmentValue: calc.gearStrength,
                                buffValue: calc.buffStrength,
                                allocatedValue: calc.allocatedStrength)
                    
                    StatsViewUI(upperBackgroundColor: .blue100,
                                upperTextColor: .blue1,
                                title: L10n.Stats.intelligenceTitle,
                                totalValue: calc.totalIntelligence,
                                levelValue: calc.levelStat,
                                equipmentValue: calc.gearIntelligence,
                                buffValue: calc.buffIntelligence,
                                allocatedValue: calc.allocatedIntelligence)
                
                    StatsViewUI(upperBackgroundColor: .yellow100,
                                upperTextColor: .yellow1,
                                title: L10n.Stats.constitutionTitle,
                                totalValue: calc.totalConstitution,
                                levelValue: calc.levelStat,
                                equipmentValue: calc.gearConstitution,
                                buffValue: calc.buffConstitution,
                                allocatedValue: calc.allocatedConstitution)
                
                    StatsViewUI(upperBackgroundColor: .purple300,
                                upperTextColor: .white,
                                title: L10n.Stats.perceptionTitle,
                                totalValue: calc.totalPerception,
                                levelValue: calc.levelStat,
                                equipmentValue: calc.gearPerception,
                                buffValue: calc.buffPerception,
                                allocatedValue: calc.allocatedPerception)
                    
                    Text(L10n.Titles.achievements)
                        .scaledFont(size: 22, weight: .bold)
                        .padding(.top, 28)
                    LazyVGrid(columns: [.init(.adaptive(minimum: 114, maximum: 180), spacing: 12)], spacing: 12) {
                        ForEach(viewModel.achievements, id: \.key) { achievement in
                            AchievementIconView(achievement: achievement)
                                .frame(height: 94)
                                .frame(maxWidth: .infinity)
                                .background(Color(themeService.theme.windowBackgroundColor))
                                .cornerRadius(UIConstants.largeCornerRadius)
                                .onTapGesture {
                                    if let action = viewModel.onAchievementDetail {
                                        action(achievement)
                                    }
                                }
                        }
                    }
                    
                    Text(L10n.quests)
                        .scaledFont(size: 22, weight: .bold)
                        .padding(.top, 28)
                    if viewModel.questData.isEmpty {
                        Text(L10n.playerNotCompletedQuests)
                            .scaledFont(size: 17, weight: .semibold)
                            .foregroundStyle(Color(themeService.theme.secondaryTextColor))
                            .profileContainer()
                    } else {
                        VStack(spacing: 8) {
                            ForEach(member.achievements?.quests ?? [], id: \.key) { questAchievement in
                                HStack(spacing: 15) {
                                    Text("\(questAchievement.optionalCount)")
                                        .scaledFont(size: 15, weight: .semibold)
                                        .minimumScaleFactor(0.6)
                                        .padding(4)
                                        .foregroundStyle(Color(themeService.theme.secondaryTextColor))
                                        .frame(width: 40, height: 40)
                                        .background(Color(themeService.theme.offsetBackgroundColor))
                                        .cornerRadius(20)
                                    Text(viewModel.questData[questAchievement.key ?? ""]?.text ?? "")
                                        .scaledFont(size: 15, weight: .semibold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }.profileContainer()
                            }
                        }
                    }
                    
                    Text(L10n.challengesWon)
                        .scaledFont(size: 22, weight: .bold)
                        .padding(.top, 28)
                    let challenges = member.achievements?.challenges ?? []
                    if challenges.isEmpty {
                        Text(L10n.playerNotWonChallenges)
                            .scaledFont(size: 17, weight: .semibold)
                            .foregroundStyle(Color(themeService.theme.secondaryTextColor))
                            .profileContainer()
                    } else {
                        VStack(spacing: 8) {
                            ForEach(challenges, id: \.index) { challenge in
                                HStack(spacing: 15) {
                                    AchievementIconView(achievement: challenge)
                                    Text(challenge.title ?? "")
                                        .scaledFont(size: 15, weight: .semibold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }.profileContainer()
                            }
                        }
                    }
                }.padding(.horizontal, 12)
                    .padding(.bottom, 16)
            }
        }.foregroundStyle(Color(themeService.theme.secondaryTextColor))
    }
}

class UserProfileViewController: BaseHostingViewController<ProfilePage> {
    private var viewModel = ProfileViewModel()
    
    private var isModerator = false
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    private let stableRepository = StableRepository()
    private let configRepository = ConfigRepository.shared
    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    var interactor = CalculateUserStatsInteractor()
    private let (lifetime, token) = Lifetime.make()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    @objc var userID: String?
    @objc var username: String?
    @objc var needsDoneButton = false
    
    private var gearDictionary: [String: GearProtocol] = [:]
    private var isAttributesExpanded = true
    
    private var user: UserProtocol?
    
    private var isBlocked: Bool {
        return user?.inbox?.blocks.contains(userID ?? "") == true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ProfilePage(viewModel: viewModel))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        topHeaderCoordinator?.followScrollView = false
        
        navigationItem.title = username
        moreButton.menu = overflowMenu
        
        viewModel.onAchievementDetail = { achievement in
            let sheet = HostingBottomSheetController(rootView: AchievementDetailSheet(achievement: achievement))
            self.present(sheet, animated: true)
        }
        
        let subscriber = Signal<CalculatedUserStats, NSError>.Observer(value: {[weak self] stats in
            self?.viewModel.calculatedStats = stats
        })
        
        disposable.inner.add(interactor.reactive.take(during: lifetime).observe(subscriber))
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.isModerator = user.hasPermission(.userSupport)
            if self?.viewModel.member == nil {
                self?.refresh()
            }
            if self?.isModerator == true {
                self?.disposable.inner.add(self?.socialRepository.retrieveMember(userID: self?.userID ?? "", fromHall: true).observeValues({ member in
                    self?.viewModel.hallMember = member
                }))
            }
        }).start())
        
        disposable.inner.add(inventoryRepository.getGear().on(value: {[weak self] gear in
            self?.gearDictionary.removeAll()
            gear.value.forEach({ (gearItem) in
                self?.gearDictionary[gearItem.key ?? ""] = gearItem
            })
        }).start())
        
        disposable.inner.add(stableRepository.getPets(query: "type == 'drop'").on(value: {[weak self] pets in
            self?.viewModel.baseAnimalKeys = pets.value.map({ pet in
                return pet.key ?? ""
            })
        }).start())
        
        if let userID = userID {
            disposable.inner.add(socialRepository.retrieveMemberAchievements(userID: userID).observeValues { achievements in
                self.viewModel.achievements = achievements?.filter({ achievement in
                    return achievement.earned
                }) ?? []
            })
            disposable.inner.add(socialRepository.getMember(userID: userID).skipNil().flatMap(.latest, {[weak self] (member) in
                return self?.fetchGearStats(member: member) ?? SignalProducer.empty
            }).on(value: {[weak self] (member, gear) in
                if !member.isValid {
                    return
                }
                self?.viewModel.member = member
                if self?.username == nil {
                    self?.username = member.username
                }
                self?.navigationItem.title = member.profile?.name
                if let stats = member.stats {
                    self?.interactor.run(with: (stats, gear))
                }
                
                if let pet = member.items?.currentPet, let stableRepository = self?.stableRepository {
                    self?.disposable.inner.add(stableRepository.getPet(key: pet).on(value: { currentPet in
                        self?.viewModel.currentPet = currentPet
                    }).take(first: 1).start())
                }
                if let mount = member.items?.currentMount, let stableRepository = self?.stableRepository {
                    self?.disposable.inner.add(stableRepository.getMount(key: mount).on(value: { currentMount in
                        self?.viewModel.currentMount = currentMount
                    }).take(first: 1).start())
                }
                
                if let inventoryRepository = self?.inventoryRepository, let questKeys = member.achievements?.quests.map({ achievement in
                    return achievement.key ?? ""
                }) {
                    self?.disposable.inner.add(inventoryRepository.getQuests(keys: questKeys).on(value: { result in
                        var data = [String: QuestProtocol]()
                        result.value.forEach { quest in
                            data[quest.key ?? ""] = quest
                        }
                        self?.viewModel.questData = data
                    }).start())
                }
            }).start())
        }
        
        disposable.inner.add( userRepository.getUser().take(first: 1).on(
            value: {[weak self] user in
                self?.user = user
                
                if (self?.username == user.username || self?.userID == user.id) && user.loginIncentives >= 10 {
                    UIApplication.requestReview()
                }
            }).start())
        
        if needsDoneButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        }
    }
    
    override func applyTheme(theme: any Theme) {
        super.applyTheme(theme: theme)
        navigationItem.leftBarButtonItem?.tintColor = theme.fixedTintColor
    }
    
    @objc
    private func doneTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func refresh() {
        if let userID = self.userID {
            socialRepository.retrieveMember(userID: userID, fromHall: false).observeCompleted {}
        }
    }
    
    private func fetchGearStats(member: MemberProtocol) -> SignalProducer<(MemberProtocol, [GearProtocol]), Never> {
        var keys = [String]()
        if let outfit = member.items?.gear?.equipped {
            keys.append(outfit.armor ?? "")
            keys.append(outfit.back ?? "")
            keys.append(outfit.body ?? "")
            keys.append(outfit.eyewear ?? "")
            keys.append(outfit.head ?? "")
            keys.append(outfit.headAccessory ?? "")
            keys.append(outfit.weapon ?? "")
            keys.append(outfit.shield ?? "")
        }
        
        let gearProducer = inventoryRepository.getGear(predicate: NSPredicate(format: "key in %@", keys)).map({ gear in
            return gear.value
        }).flatMapError({ (_) -> SignalProducer<[GearProtocol], Never> in
            return SignalProducer.empty
        })
        
        return gearProducer.withLatest(from: SignalProducer<MemberProtocol, Never>(value: member)).map({ (gear, user) in
            return (user, gear)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.writeMessageSegue.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let chatViewController = navigationController?.topViewController as? InboxChatViewController
            chatViewController?.isPresentedModally = true
            chatViewController?.userID = userID
            chatViewController?.username = username
            chatViewController?.displayName = viewModel.member?.profile?.name
        } else if segue.identifier == StoryboardSegue.Social.giftSubscriptionSegue.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let giftViewController = navigationController?.topViewController as? GiftSubscriptionViewController
            giftViewController?.giftRecipientUsername = username ?? userID
        } else if segue.identifier == StoryboardSegue.Social.giftGemsSegue.rawValue {
                   let navigationController = segue.destination as? UINavigationController
                   let giftViewController = navigationController?.topViewController as? GiftGemsViewController
                   giftViewController?.giftRecipientUsername = username ?? userID
               }
    }
    
    private var overflowMenu: UIMenu {
        return UIMenu(children: [
            UIMenu(options: .displayInline, children: [ UIDeferredMenuElement({[weak self] add in
                var items = [] as [UIAction]
                if self?.user?.id != self?.userID {
                    if self?.isBlocked == true {
                        items.append(UIAction(title: L10n.unblockUser, image: UIImage(systemName: "person.slash"), attributes: .destructive) {[weak self] _ in
                            self?.socialRepository.blockMember(userID: self?.userID ?? self?.username ?? "").observeCompleted {
                                ToastManager.show(text: L10n.userWasUnblocked(self?.username ?? ""), color: .red)
                            }
                        })
                    } else {
                        items.append(UIAction(title: L10n.blockUser, image: UIImage(systemName: "person.slash"), attributes: .destructive) {[weak self] _ in
                            self?.showBlockDialog()
                        })
                    }
                    items.append(UIAction(title: L10n.reportX(L10n.player), image: UIImage(systemName: "flag"), attributes: .destructive) {[weak self] _ in
                        if let member = self?.viewModel.member {
                            let controller = FlagViewController(type: .member, offendingItem: member)
                            self?.present(controller, animated: true)
                        }
                    })
                }
                add(items)
            })]),
            UIAction(title: L10n.giftGems, image: UIImage(systemName: "gift")) {[weak self] _ in
                self?.perform(segue: StoryboardSegue.Social.giftGemsSegue)
            },
            UIAction(title: L10n.giftSubscription, image: UIImage(systemName: "giftcard")) {[weak self] _ in
                self?.perform(segue: StoryboardSegue.Social.giftGemsSegue)
            },
            UIMenu(options: .displayInline, children: [ UIDeferredMenuElement({[weak self] add in
                var items = [] as [UIAction]
                guard let member = self?.viewModel.hallMember else {
                    add([])
                    return
                }
                if self?.user?.hasPermission(.userSupport) == true {
                    items.append(UIAction(title: member.authentication?.blocked == true ? L10n.unbanUser : L10n.banUser,
                                          image: UIImage(systemName: "hammer"), attributes: .destructive) {[weak self] _ in
                        self?.showBanDialog()
                    })
                    items.append(UIAction(title: member.flags?.chatShadowMuted == true ? L10n.unshadowMuteUser : L10n.shadowMuteUser,
                                          image: UIImage(systemName: "speaker.slash"), attributes: .destructive) {[weak self] _ in
                        self?.showShadowMuteDialog()
                    })
                    items.append(UIAction(title: member.flags?.chatRevoked == true ? L10n.unmuteUser : L10n.muteUser,
                                          image: UIImage(systemName: "speaker.slash"), attributes: .destructive) {[weak self] _ in
                        self?.showMuteDialog()
                    })
                }
                add(items)
            })])
        ])
    }
    
    private func showBlockDialog() {
        let alert = HabiticaAlertController(title: L10n.blockUsername(username ?? viewModel.member?.profile?.name ?? userID ?? ""), message: L10n.blockDescription)
        let confirmationText = L10n.userWasBlocked(username ?? "")
        alert.addAction(title: L10n.block, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.socialRepository.blockMember(userID: self?.userID ?? self?.username ?? "").observeCompleted {
                ToastManager.show(text: confirmationText, color: .red)
            }
        }
        alert.addCancelAction()
        alert.show()
    }
    
    private func showBanDialog() {
        let isBanned = viewModel.member?.authentication?.blocked == true
        let alert = HabiticaAlertController(title: isBanned ? L10n.unbanUserConfirm : L10n.banUserConfirm)
        alert.addAction(title: L10n.block, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.socialRepository.updateMember(userID: self?.userID ?? "", key: "auth.blocked", value: !isBanned).observeCompleted {
                ToastManager.show(text: L10n.completed, color: .green)
            }
        }
        alert.addCancelAction()
        alert.show()
    }
    
    private func showShadowMuteDialog() {
        let isShadowMuted = viewModel.member?.flags?.chatShadowMuted == true
        let alert = HabiticaAlertController(title: isShadowMuted ? L10n.unshadowMuteUserConfirm : L10n.shadowMuteUserConfirm)
        alert.addAction(title: L10n.block, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.socialRepository.updateMember(userID: self?.userID ?? "", key: "flags.chatShadowMuted", value: !isShadowMuted).observeCompleted {
                ToastManager.show(text: L10n.completed, color: .green)
            }
        }
        alert.addCancelAction()
        alert.show()
    }
    
    private func showMuteDialog() {
        let isMuted = viewModel.member?.authentication?.blocked == true
        let alert = HabiticaAlertController(title: isMuted ? L10n.unmuteUserConfirm : L10n.muteUserConfirm)
        alert.addAction(title: L10n.block, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.socialRepository.updateMember(userID: self?.userID ?? "", key: "flags.chatRevoked", value: !isMuted).observeCompleted {
                ToastManager.show(text: L10n.completed, color: .green)
            }
        }
        alert.addCancelAction()
        alert.show()
    }
}
