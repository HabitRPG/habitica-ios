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
}

private struct ProfileContainer: ViewModifier {
    let spacing: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(spacing)
            .background(Color(ThemeService.shared.theme.windowBackgroundColor))
            .cornerRadius(26)
    }
}

extension View {
    func profileContainer(spacing: CGFloat = 17) -> some View {
        modifier(ProfileContainer(spacing: spacing))
    }
}

struct ValueBarProgressStyle: ProgressViewStyle {
    var gradientStart: Color
    var gradientEnd: Color
    
    func makeBody(configuration: Configuration) -> some View {
        Capsule().fill(Color(ThemeService.shared.theme.offsetBackgroundColor))
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
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(ThemeService.shared.theme.secondaryTextColor))
                }
            }.frame(width: 68, height: 58)
                .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                .cornerRadius(13)
            label
                .scaledFont(size: 12)
        }
    }
}

struct GearGridView: View {
    let outfit: OutfitProtocol
    let background: String?
    
    var body: some View {
        HStack {
            VStack(spacing: 17) {
                GearGridItem(iconName: outfit.weapon != nil ? "shop_\(outfit.weapon ?? "")" : nil, label: Text(L10n.Equipment.weapon))
                GearGridItem(iconName: outfit.armor != nil ? "shop_\(outfit.armor ?? "")" : nil, label: Text(L10n.Equipment.armor))
                GearGridItem(iconName: outfit.back != nil ? "shop_\(outfit.back ?? "")" : nil, label: Text(L10n.Equipment.back))
            }
            Spacer()
            VStack(spacing: 17) {
                GearGridItem(iconName: outfit.shield != nil ? "shop_\(outfit.shield ?? "")" : nil, label: Text(L10n.Equipment.offHand))
                GearGridItem(iconName: outfit.headAccessory != nil ? "shop_\(outfit.headAccessory ?? "")" : nil, label: Text(L10n.Equipment.headAccessory))
                GearGridItem(iconName: outfit.eyewear != nil ? "shop_\(outfit.eyewear ?? "")" : nil, label: Text(L10n.Equipment.eyewear))
            }
            Spacer()
            VStack(spacing: 17) {
                GearGridItem(iconName: outfit.head != nil ? "shop_\(outfit.head ?? "")" : nil, label: Text(L10n.Equipment.head))
                GearGridItem(iconName: outfit.body != nil ? "shop_\(outfit.body ?? "")" : nil, label: Text(L10n.Equipment.body))
                GearGridItem(iconName: background != nil ? "shop_\(background ?? "")" : nil, label: Text(L10n.background))
            }
        }.profileContainer()
    }
}

struct ProfilePage: View {
    @ObservedObject fileprivate var viewModel: ProfileViewModel
    
    @State private var showEquipmentCostume = "equipment"
    
    private func classTextColor(className: String) -> Color {
        if ThemeService.shared.theme.isDark {
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
                return Color(ThemeService.shared.theme.primaryTextColor)
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
                return Color(ThemeService.shared.theme.primaryTextColor)
            }
        }
    }
    
    @ViewBuilder
    private func classImage(className: String) -> some View {
        if className == "warrior" {
            Image(uiImage: HabiticaIcons.imageOfWarriorDarkBg)
                .frame(width: 32, height: 32)
                .background(.red500)
                .cornerRadius(16)
        } else if className == "healer" {
            Image(uiImage: HabiticaIcons.imageOfHealerDarkBg)
                .frame(width: 32, height: 32)
                .background(.yellow500)
                .cornerRadius(16)
        } else if className == "wizard" {
            Image(uiImage: HabiticaIcons.imageOfMageDarkBg)
                .frame(width: 32, height: 32)
                .background(.blue500)
                .cornerRadius(16)
        } else if className == "rogue" {
            Image(uiImage: HabiticaIcons.imageOfRogueDarkBg)
                .frame(width: 32, height: 32)
                .background(.purple500)
                .cornerRadius(16)
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
                        .cornerRadius(26)
                        VStack(alignment: .leading, spacing: 7) {
                            HStack(spacing: 10) {
                                if member.hasHabiticaClass {
                                    classImage(className: member.stats?.habitClass ?? "")
                                    Text("Lv. \(member.stats?.level ?? 0) \(member.stats?.habitClassNice?.capitalized ?? "")")
                                        .foregroundColor(classTextColor(className: member.stats?.habitClass ?? ""))
                                } else {
                                    Text("Lv. \(member.stats?.level ?? 0)")
                                }
                            }.scaledFont(size: 12, weight: .black)
                            if let stats = member.stats {
                                HStack(spacing: 8) {
                                    Image(uiImage: ThemeService.shared.theme.isDark ? HabiticaIcons.imageOfHeartDarkBg : HabiticaIcons.imageOfHeartLightBg)
                                        .frame(width: 28)
                                    ValueBar(value: stats.health, maxValue: stats.maxHealth, leadingLabel: Text("HP"), barStartColor: .red100, barEndColor: .orange100)
                                        .foregroundColor(Color.maroon100)
                                }
                                HStack(spacing: 8) {
                                    Image(uiImage: HabiticaIcons.imageOfExperience)
                                        .frame(width: 28)
                                    ValueBar(value: stats.experience, maxValue: stats.toNextLevel, leadingLabel: Text("EXP"), barStartColor: .orange100, barEndColor: .yellow100)
                                        .foregroundColor(Color.yellow1)
                                }
                                HStack(spacing: 8) {
                                    Image(uiImage: HabiticaIcons.imageOfMagic)
                                        .frame(width: 28)
                                    ValueBar(value: stats.mana, maxValue: stats.maxMana, leadingLabel: Text("MP"), barStartColor: .blue100, barEndColor: .teal100)
                                        .foregroundColor(Color.blue10)
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
                        
                        Separator(padding: 0)
                        
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
                            Separator(padding: 0)
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
                    .cornerRadius(13)
                    .profileContainer(spacing: 26)
                    
                    HStack(spacing: 12) {
                        VStack(spacing: 26) {
                            VStack {
                                Text(L10n.pet).scaledFont(size: 17, weight: .semibold)
                                if let pet = viewModel.currentPet {
                                    Text(pet.text ?? "")
                                } else {
                                    Text(L10n.none).foregroundStyle(Color(ThemeService.shared.theme.dimmedTextColor))
                                }
                            }
                            VStack {
                                Text("\(member.items?.ownedPets.filter { pet in pet.trained != 0 } .count ?? 0)").scaledFont(size: 17, weight: .semibold)
                                Text(L10n.petsFound)
                            }
                            VStack {
                                Text("\(member.items?.ownedPets.filter { pet in viewModel.baseAnimalKeys.contains(pet.key ?? "") && pet.trained != 0 }.count ?? 0)/\(viewModel.baseAnimalKeys.size)")
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
                                    Text(L10n.none).foregroundStyle(Color(ThemeService.shared.theme.dimmedTextColor))
                                }
                            }
                            VStack {
                                Text("\(member.items?.ownedMounts.filter { mount in mount.owned }.count ?? 0)").scaledFont(size: 17, weight: .semibold)
                                Text(L10n.mountsFound)
                            }
                            VStack {
                                Text("\(member.items?.ownedMounts.filter { mount in viewModel.baseAnimalKeys.contains(mount.key ?? "") && mount.owned } .count ?? 0)/\(viewModel.baseAnimalKeys.size)")
                                    .scaledFont(size: 17, weight: .semibold)
                                Text(L10n.standardMounts)
                            }
                        }.profileContainer()
                    }.scaledFont(size: 13)
                    
                    Text(L10n.stats)
                        .scaledFont(size: 22, weight: .bold)
                        .padding(.top, 28)
                    
                    Text("\(viewModel.calculatedStats.levelStat)")
                    Text("\(viewModel.calculatedStats.gearStrength)")
                    
                    Text(L10n.Titles.achievements)
                        .scaledFont(size: 22, weight: .bold)
                        .padding(.top, 28)
                    LazyVGrid(columns: [.init(.adaptive(minimum: 115, maximum: 180), spacing: 12)], spacing: 12) {
                        ForEach(viewModel.achievements, id: \.key) { achievement in
                            AchievementIconView(achievement: achievement)
                                .frame(height: 94)
                                .frame(maxWidth: .infinity)
                                .background(Color(ThemeService.shared.theme.windowBackgroundColor))
                                .cornerRadius(26)
                        }
                    }
                    
                    Text(L10n.quests)
                        .scaledFont(size: 22, weight: .bold)
                        .padding(.top, 28)
                    if viewModel.questData.isEmpty {
                        Text(L10n.playerNotCompletedQuests)
                            .scaledFont(size: 17, weight: .semibold)
                            .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                            .profileContainer()
                    } else {
                        ForEach(member.achievements?.quests ?? [], id: \.key) { questAchievement in
                            HStack(spacing: 15) {
                                Text("\(questAchievement.optionalCount)")
                                    .scaledFont(size: 15, weight: .semibold)
                                    .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                                    .frame(width: 40, height: 40)
                                    .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                                    .cornerRadius(20)
                                Text(viewModel.questData[questAchievement.key ?? ""]?.text ?? "")
                                    .scaledFont(size: 15, weight: .semibold)
                                    .frame(maxWidth: .infinity)
                            }.profileContainer()
                        }
                    }
                    
                    Text(L10n.challengesWon)
                        .scaledFont(size: 22, weight: .bold)
                        .padding(.top, 28)
                    let challenges = member.achievements?.challenges ?? []
                    if challenges.isEmpty {
                        Text(L10n.playerNotWonChallenges)
                            .scaledFont(size: 17, weight: .semibold)
                            .foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
                            .profileContainer()
                    } else {
                        ForEach(challenges, id: \.key) { challenge in
                            HStack(spacing: 15) {
                                AchievementIconView(achievement: challenge)
                                Text(challenge.title ?? "")
                                    .scaledFont(size: 15, weight: .semibold)
                                    .frame(maxWidth: .infinity)
                            }.profileContainer()
                        }
                    }
                }.padding(.horizontal, 12)
                    .padding(.bottom, 16)
            }
        }.foregroundStyle(Color(ThemeService.shared.theme.secondaryTextColor))
    }
}

// swiftlint:disable:next type_body_length
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
