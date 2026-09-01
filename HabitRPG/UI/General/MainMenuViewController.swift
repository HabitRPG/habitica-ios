//
//  MainMenuViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 27.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import SwiftUIX

class MenuItem {
    enum Key: String {
        case tasks
        case habits
        case dailies
        case todos
        case rewards
        
        case skills
        case selectClass
        case stats
        case achievements
        
        case customizeAvatar
        case equipment
        case items
        case stable
        case gems
        case subscription
        
        case market
        case questShop
        case seasonalShop
        case timeTravelersShop
        case customizationShop
        
        case party
        case groupPlan
        case questDetail
        case challenges
        
        case support
        case about
        case news
        
        case settings
        case notifications
        case messages
    }
    
    var key: MenuItem.Key
    var iconKey: MenuItem.Key?
    var title: String
    var subtitle: String?
    var subtitleColor: UIColor?
    var pillText: String?
    var pillColor: UIColor?
    var pillBuilder: ((PillView) -> Void)?
    var accessibilityLabel: String?
    var segue: String
    var vcInstantiator: (() -> UIViewController?)?
    var cellName = "Cell"
    var showIndicator = false
    var isHidden = false
    var isDisabled = false
    
    init(key: Key, title: String, subtitle: String? = nil, pillText: String? = nil, accessibilityLabel: String? = nil, segue: String? = nil,
         vcInstantiator: (() -> UIViewController?)? = nil, cellName: String = "Cell", showIndicator: Bool = false, isHidden: Bool = false) {
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.pillText = pillText
        self.accessibilityLabel = accessibilityLabel
        self.segue = segue ?? ""
        self.vcInstantiator = vcInstantiator
        self.cellName = cellName
        self.showIndicator = showIndicator
        self.isHidden = isHidden
    }
    
    static let allItems = [
        MenuItem(key: .tasks, title: "", vcInstantiator: StoryboardScene.Main.taskBoardViewController.instantiate),
        MenuItem(key: .habits, title: "", vcInstantiator: StoryboardScene.Main.habitsViewController.instantiate),
        MenuItem(key: .dailies, title: "", vcInstantiator: StoryboardScene.Main.dailiesViewController.instantiate),
        MenuItem(key: .todos, title: "", vcInstantiator: StoryboardScene.Main.todosViewController.instantiate),
        MenuItem(key: .rewards, title: "", vcInstantiator: StoryboardScene.Main.rewardsViewController.instantiate),
        MenuItem(key: .skills, title: "", vcInstantiator: StoryboardScene.User.spellsViewController.instantiate),
        MenuItem(key: .stats, title: "", vcInstantiator: StoryboardScene.User.attributePointsViewController.instantiate),
        MenuItem(key: .achievements, title: "", vcInstantiator: StoryboardScene.User.achievementsCollectionViewController.instantiate),
        MenuItem(key: .market, title: "", segue: StoryboardSegue.Main.showMarketSegue.rawValue),
        MenuItem(key: .questShop, title: "", segue: StoryboardSegue.Main.showQuestShopSegue.rawValue),
        MenuItem(key: .seasonalShop, title: "", segue: StoryboardSegue.Main.showSeasonalShopSegue.rawValue),
        MenuItem(key: .customizationShop, title: "", segue: StoryboardSegue.Main.showCustomizationShopSegue.rawValue),
        MenuItem(key: .timeTravelersShop, title: "", segue: StoryboardSegue.Main.showTimeTravelersSegue.rawValue),
        MenuItem(key: .customizeAvatar, title: "", vcInstantiator: StoryboardScene.Main.avatarOverviewViewController.instantiate),
        MenuItem(key: .equipment, title: "", vcInstantiator: StoryboardScene.Main.equipmentOverviewViewController.instantiate),
        MenuItem(key: .items, title: "", vcInstantiator: StoryboardScene.Main.itemsViewController.instantiate),
        MenuItem(key: .stable, title: "", vcInstantiator: StoryboardScene.Stable.stableViewController.instantiate),
        MenuItem(key: .gems, title: "", vcInstantiator: StoryboardScene.Main.purchaseGemNavController.instantiate),
        MenuItem(key: .subscription, title: "", vcInstantiator: StoryboardScene.Main.subscriptionNavController.instantiate),
        MenuItem(key: .party, title: "", vcInstantiator: StoryboardScene.Social.partyViewController.instantiate),
        MenuItem(key: .questDetail, title: "", vcInstantiator: StoryboardScene.Social.questDetailViewController.instantiate),
        MenuItem(key: .challenges, title: "", vcInstantiator: StoryboardScene.Social.challengeTableViewController.instantiate),
        MenuItem(key: .news, title: "", vcInstantiator: StoryboardScene.Main.newsViewController.instantiate),
        MenuItem(key: .support, title: "", vcInstantiator: StoryboardScene.Support.initialScene.instantiate),
        MenuItem(key: .about, title: "", vcInstantiator: StoryboardScene.Main.aboutViewController.instantiate),
        MenuItem(key: .settings, title: "", vcInstantiator: StoryboardScene.Settings.initialScene.instantiate),
        MenuItem(key: .messages, title: "", vcInstantiator: StoryboardScene.Social.inboxNavigationViewController.instantiate),
        MenuItem(key: .notifications, title: "", vcInstantiator: StoryboardScene.Main.notificationsNavigationController.instantiate)
    ]
    
    static var titleMapping: [MenuItem.Key: String] {
        return [
            .tasks: L10n.Tasks.tasks,
            .habits: L10n.Tasks.habits,
            .dailies: L10n.Tasks.dailies,
            .todos: L10n.Tasks.todos,
            .rewards: L10n.Tasks.rewards,
            .skills: L10n.Menu.skills,
            .stats: L10n.Titles.stats,
            .achievements: L10n.Titles.achievements,
            .market: L10n.Locations.market,
            .questShop: L10n.Locations.questShop,
            .seasonalShop: L10n.Locations.seasonalShop,
            .customizationShop: L10n.customizationShop,
            .timeTravelersShop: L10n.Menu.timeTravelersShop,
            .customizeAvatar: L10n.Menu.avatarCustomization,
            .equipment: L10n.Titles.equipment,
            .items: L10n.Titles.items,
            .stable: L10n.Titles.petsAndMounts,
            .gems: L10n.Menu.gems,
            .subscription: L10n.Menu.subscription,
            .party: L10n.Titles.party,
            .questDetail: L10n.quest,
            .challenges: L10n.Titles.challenges,
            .news: L10n.Titles.news,
            .support: L10n.Menu.helpFaq,
            .about: L10n.Menu.helpAbout,
            .settings: L10n.Titles.settings,
            .messages: L10n.Titles.messages,
            .notifications: L10n.Titles.notifications,
            .selectClass: ""
        ]
    }
    
    static func localizedTitle(for key: MenuItem.Key) -> String {
        return titleMapping[key] ?? ""
    }
}

struct MenuSection {
    enum Key: String {
        case user
        case groupPlans
        case inventory
        case shops
        case purchases
        case social
        case about
    }
    let key: Key
    let title: String?
    var isHidden: Bool = false
    var items: [MenuItem]
    
    var visibleItems: [MenuItem] {
        return items.filter({ (item) -> Bool in return !item.isHidden })
    }
}

// swiftlint:disable:next type_body_length
class MainMenuViewController: BaseTableViewController {
    
    private var navbarColor = ThemeService.shared.theme.navbarHiddenColor {
        didSet {
            topHeaderCoordinator?.navbarVisibleColor = navbarColor
            if isVisible {
                navbarView.backgroundColor = navbarColor
            }
        }
    }
    private var questTintColor: UIColor?
    private var navbarView = MenuNavigationBarView()
    private var questHeaderView: QuestMenuHeader?
    
    private var userRepository = UserRepository()
    private var socialRepository = SocialRepository()
    private var inventoryRepository = InventoryRepository()
    private let contentRepository = ContentRepository()
    private let configRepository = ConfigRepository.shared
    
    private var disposable = ScopedDisposable(CompositeDisposable())
    private var seasonalShopTimer: Timer?
    private var promoTimer: Timer?
    private let stretchView = GradientView()
    private let sheetCornerView = UIView()
    private let sheetCornerMask = CAShapeLayer()
    private var lastKnownSeason = ""
    private var groupPlanItems = [MenuItem]()
    private var lastWorldState: WorldStateProtocol?
    private var lastSeasonalItems = [ItemProtocol]()

    private var menuSections = [MenuSection]()
    var visibleSections: [MenuSection] {
        return menuSections.filter { (section) in (!section.isHidden && !section.visibleItems.isEmpty) }
    }
    private var giftRecipientUsername = ""
    
    private var activePromo: HabiticaPromotion?

    private var user: UserProtocol? {
        didSet {
            guard user?.isValid == true else {
                return
            }
            if let user = self.user {
                navbarView.configure(user: user)
            }
            let statsItem = menuItem(withKey: .stats)
            if user?.preferences?.disableClasses == true {
                statsItem.isHidden = true
            } else if (user?.stats?.level ?? 0) >= 10 && user?.flags?.classSelected == false {
                statsItem.isHidden = true
            } else {
                statsItem.isHidden = false
                if user?.stats?.level ?? 0 < 10 {
                    statsItem.subtitle = L10n.unlocksLevelTen
                    statsItem.isDisabled = true
                } else {
                    statsItem.subtitle = nil
                    statsItem.isDisabled = false
                }
            }
            let hasNewStuff = user?.flags?.hasNewStuff == true
            menuItem(withKey: .news).showIndicator = hasNewStuff
            menuItem(withKey: .news).subtitle = hasNewStuff ? L10n.Menu.newAnnouncement : nil

            if let partyID = user?.party?.id {
                let hasPartyActivity = user?.hasNewMessages.first(where: { (newMessages) -> Bool in
                    return newMessages.id == partyID
                })?.hasNewMessages ?? false
                menuItem(withKey: .party).showIndicator = hasPartyActivity
                menuItem(withKey: .party).subtitle = hasPartyActivity ? L10n.Menu.newMessage : nil
            } else {
                menuItem(withKey: .party).showIndicator = false
                menuItem(withKey: .party).subtitle = nil
            }

            tableView.reloadData()
            
            if user?.isSubscribed == true && activePromo == nil {
                tableView.tableFooterView = nil
            }
            if user?.isSubscribed == true {
                if let endDate = user?.purchased?.subscriptionPlan?.dateTerminated {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .long
                    menuItem(withKey: .subscription).subtitle = L10n.subscriptionEndsOn(formatter.string(from: endDate))
                } else {
                    menuItem(withKey: .subscription).subtitle = nil
                }
            } else if menuItem(withKey: .subscription).pillText != L10n.sale {
                menuItem(withKey: .subscription).subtitle = L10n.getMoreHabitica
            }
            
            if !configRepository.enableIPadUI() && configRepository.testingLevel != .debug && configRepository.testingLevel != .simulator {
                let customMenu = configRepository.array(variable: .customMenu)
                // swiftlint:disable:next empty_count
                if customMenu.count > 0 {
                    reorderMenu(customMenu)
                }
            }
            
            menuItem(withKey: .challenges).isHidden = configRepository.bool(variable: .hideChallenges)
        }
    }
    
    private func reorderMenu(_ customMenu: NSArray) {
        var newOrder = [MenuSection]()
        for section in customMenu {
            if let entry = section as? NSDictionary, let key = MenuSection.Key(rawValue: entry["key"] as? String ?? "") {
                if var existingSection = menuSection(withKey: key) {
                    if let itemKeys = entry["items"] as? NSArray {
                        var items = [MenuItem]()
                        for key in itemKeys {
                            if let itemKey = MenuItem.Key(rawValue: key as? String ?? "") {
                                items.append(menuItem(withKey: itemKey))
                            }
                        }
                        existingSection.items = items
                        if key == .social {
                            existingSection.items.append(contentsOf: groupPlanItems)
                        }
                    }
                    newOrder.append(existingSection)
                }
            }
        }
        menuSections = newOrder
        tableView.reloadData()
    }
    
    private static let subscriptionFooterTag = 11111

    private func setupPinnedPill() {
        guard !configRepository.enableIPadUI(), let promo = activePromo, promo.hasPinnedPill else {
            tableView.tableHeaderView = nil
            return
        }
        let width = tableView.frame.size.width
        let pillWidth = width - 34
        let pill = UIView(frame: CGRect(x: 17, y: 12, width: pillWidth, height: 40))
        pill.cornerRadius = 20
        pill.clipsToBounds = true
        if let pillBackground = promo.pinnedPillBackground {
            pill.backgroundColor = pillBackground
        } else if let start = promo.gradientStart, let end = promo.gradientEnd {
            let gradient = CAGradientLayer()
            gradient.colors = [start.cgColor, end.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.frame = CGRect(x: 0, y: 0, width: pillWidth, height: 40)
            pill.layer.insertSublayer(gradient, at: 0)
        } else {
            pill.backgroundColor = promo.backgroundColor
        }
        var artTrailing: CGFloat = 0
        if let leftArt = promo.pinnedPillLeftArt {
            let artHeight = promo.pinnedPillArtHeight
            let artWidth = artHeight * (leftArt.size.width / max(leftArt.size.height, 1))
            let artView = UIImageView(image: leftArt)
            artView.contentMode = .scaleAspectFit
            let fitsInPill = artHeight <= 40
            let artX: CGFloat = fitsInPill ? 0 : -12
            artView.frame = CGRect(x: artX, y: fitsInPill ? 0 : 42 - artHeight, width: artWidth, height: artHeight)
            pill.addSubview(artView)
            artTrailing = artX + artWidth
        }
        if let title = promo.pinnedPillTitle {
            let label = UILabel()
            let titleFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
            let titleLineHeight: CGFloat = 22
            let paragraph = NSMutableParagraphStyle()
            paragraph.minimumLineHeight = titleLineHeight
            paragraph.maximumLineHeight = titleLineHeight
            paragraph.alignment = artTrailing > 0 ? .natural : .center
            label.attributedText = NSAttributedString(string: title, attributes: [
                .font: titleFont,
                .kern: -0.43,
                .foregroundColor: UIColor.white,
                .baselineOffset: (titleLineHeight - titleFont.lineHeight) / 4,
                .paragraphStyle: paragraph
            ])
            let labelX = artTrailing > 0 ? artTrailing + 16 : 44
            label.frame = CGRect(x: labelX, y: 0, width: pillWidth - 32 - labelX, height: 40)
            pill.addSubview(label)
        } else if let image = promo.pinnedPillTitleImage {
            let maxW = pillWidth - 108
            let maxH: CGFloat = 15
            let scale = min(maxW / image.size.width, maxH / image.size.height)
            let scaledWidth = image.size.width * scale
            let scaledHeight = image.size.height * scale
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            let centeredX = (pillWidth - scaledWidth) / 2
            let titleX = artTrailing > 0 ? min(artTrailing + 16, centeredX) : centeredX
            imageView.frame = CGRect(x: titleX, y: (40 - scaledHeight) / 2, width: scaledWidth, height: scaledHeight)
            pill.addSubview(imageView)
        }
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: chevronConfig))
        chevron.tintColor = promo.pinnedPillArrowColor
        chevron.contentMode = .scaleAspectFit
        chevron.frame = CGRect(x: pillWidth - 32, y: 12, width: 16, height: 16)
        pill.addSubview(chevron)
        pill.isUserInteractionEnabled = true
        pill.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pinnedPillTapped)))
        let container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 55))
        container.addSubview(pill)
        tableView.tableHeaderView = container
    }

    @objc
    private func pinnedPillTapped() {
        if activePromo?.isWebPromo == true {
            perform(segue: StoryboardSegue.Main.showWebPromoSegue)
        } else {
            perform(segue: StoryboardSegue.Main.showPromoInfoSegue)
        }
    }

    fileprivate func setupFooter() {
        stretchView.isHidden = true
        if configRepository.bool(variable: .showSubscriptionBanner) {
            if tableView.tableFooterView?.tag == MainMenuViewController.subscriptionFooterTag {
                return
            }
            let view = SubscriptionPromoView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 148))
            view.onButtonTapped = { [weak self] in self?.performSegue(withIdentifier: StoryboardSegue.Main.subscriptionSegue.rawValue, sender: self) }
            view.tag = MainMenuViewController.subscriptionFooterTag
            tableView.tableFooterView = view
        } else if let promo = activePromo {
            if !UserDefaults.standard.bool(forKey: "hide\(promo.identifier)") {
                let promoTag = promo.identifier.hashValue
                if tableView.tableFooterView?.tag == promoTag {
                    return
                }
                let view = PromoMenuView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 157))
                promo.configurePromoMenuView(view: view)
                view.frame.size.height = view.fittingHeight(forWidth: tableView.frame.size.width)
                view.onButtonTapped = { [weak self] in
                    if self?.activePromo?.isWebPromo == true {
                        self?.perform(segue: StoryboardSegue.Main.showWebPromoSegue)
                    } else {
                        self?.perform(segue: StoryboardSegue.Main.showPromoInfoSegue)
                    }
                }
                view.onCloseButtonTapped = { [weak self] in
                    self?.tableView.tableFooterView = nil
                    self?.tableView.reloadData()
                    UserDefaults.standard.set(true, forKey: "hide\(promo.identifier)")
                }
                view.tag = promoTag
                tableView.tableFooterView = view
            } else {
                tableView.tableFooterView = nil
                stretchView.isHidden = false
            }
        } else {
            tableView.tableFooterView = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MainTableviewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 56
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        setupHeader()
        
        #if !targetEnvironment(macCatalyst)
        let refreshControl = HabiticaRefresControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        #endif
        
        setupMenu()
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: .languageChanged, object: nil)
                
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        })
        .filter({ $0.party?.id != nil })
        .map({ $0.party?.id ?? "" })
        .flatMap(.latest, { partyID in
            return self.socialRepository.getGroup(groupID: partyID).skipNil()
        })
        .on(value: {[weak self] party in
            if party.quest?.active == true && self?.configRepository.bool(variable: .showQuestInMenu) == true {
                if self?.questHeaderView == nil {
                    self?.questHeaderView = UIView.fromNib(nibName: "QuestMenuHeader")
                }
                self?.questHeaderView?.configure(group: party)
                if let user = self?.user {
                    self?.questHeaderView?.configure(user: user)
                }
                self?.tableView?.tableHeaderView = self?.questHeaderView
            } else if self?.tableView.tableHeaderView == self?.questHeaderView {
                self?.tableView.tableHeaderView = nil
            }
        })
        .filter({ $0.quest?.active ==  true })
        .flatMap(.latest, { party in
            return self.inventoryRepository.getQuest(key: party.quest?.key ?? "").skipNil()
        })
        .on(value: {[weak self] quest in
            if quest.isBossQuest {
                self?.questHeaderView?.configure(quest: quest)
            } else if self?.tableView.tableHeaderView == self?.questHeaderView {
                self?.tableView.tableHeaderView = nil
            }
        })
        .start())
        disposable.inner.add(userRepository.getGroupPlans().on(value: {[weak self] value in
            guard let self = self else {
                return
            }
            self.groupPlanItems = value.value.map { plan in
                let item = MenuItem(key: MenuItem.Key(rawValue: plan.id ?? "") ?? .about, title: plan.name ?? plan.summary ?? "", vcInstantiator: {
                    let viewController = StoryboardScene.Social.groupTableViewController.instantiate()
                    viewController.groupID = plan.id
                    return viewController
                })
                item.iconKey = .groupPlan
                return item
            }
            if let index = self.menuSections.firstIndex(where: { $0.key == .social }) {
                self.menuSections[index].items = self.socialItems()
                self.tableView.reloadData()
            }
        }).start())
        disposable.inner.add(userRepository.getUnreadNotificationCount().on(value: {[weak self] notificationCount in
            if notificationCount > 0 {
                self?.navbarView.notificationsBadge.text = String(notificationCount)
                self?.navbarView.notificationsBadge.isHidden = false
            } else {
                self?.navbarView.notificationsBadge.isHidden = true
            }        }).start())
                
        disposable.inner.add(contentRepository.getWorldState()
                                .combineLatest(with: inventoryRepository.getCurrentTimeLimitedItems())
                                .on(value: {[weak self] (worldState, items) in
            self?.seasonalShopTimer?.invalidate()
                                    self?.updateSeasonalEntries(worldState: worldState, items: items)
            self?.seasonalShopTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: {[weak self] _ in
                self?.updateSeasonalEntries(worldState: worldState, items: items)
            })
        }).start())
        
        splitViewController?.displayModeButtonVisibility = .always
        splitViewController?.showsSecondaryOnlyButton = true
        tableView.addSubview(stretchView)
        sheetCornerView.isUserInteractionEnabled = false
        sheetCornerView.layer.mask = sheetCornerMask
        tableView.addSubview(sheetCornerView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSheetCorner()
    }

    private func updateSheetCorner() {
        if configRepository.enableIPadUI() {
            sheetCornerView.isHidden = true
            return
        }
        guard navbarView.window != nil else {
            sheetCornerView.isHidden = true
            return
        }
        sheetCornerView.isHidden = false
        let radius: CGFloat = 40
        let junctionY = navbarView.convert(CGPoint(x: 0, y: navbarView.bounds.maxY), to: tableView).y
        sheetCornerView.frame = CGRect(x: 0, y: junctionY, width: tableView.frame.size.width, height: radius)
        sheetCornerView.backgroundColor = navbarColor
        let rect = sheetCornerView.bounds
        let path = UIBezierPath(rect: rect)
        path.append(UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius)))
        sheetCornerMask.frame = rect
        sheetCornerMask.fillRule = .evenOdd
        sheetCornerMask.path = path.cgPath
        tableView.bringSubviewToFront(sheetCornerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !configRepository.enableIPadUI() {
            (navigationController as? TopHeaderViewController)?.shouldHideTopHeader = false
            topHeaderCoordinator?.contentInsetModifier = UIEdgeInsets(top: headerInsetCorrection, left: 0, bottom: 0, right: 0)
        }
        super.viewWillAppear(animated)
        refreshPromoState()

        if activePromo != nil {
                promoTimer?.invalidate()
                promoTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: {[weak self] _ in
                    self?.updatePromoCells()
                })
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        if contentHeight > 0 {
            let footerSize = (tableView.tableFooterView?.frame.height ?? 0)
            let bottomSize = max(0, scrollView.contentOffset.y - (contentHeight - scrollView.frame.size.height)) + footerSize
            stretchView.frame = CGRect(x: 0, y: contentHeight - footerSize, width: scrollView.frame.size.width, height: bottomSize)
        }
        updateSheetCorner()
        super.scrollViewDidScroll(scrollView)
    }
    
    private func updatePromoCells() {
        if (activePromo?.endDate.timeIntervalSince1970 ?? 0) < Date().timeIntervalSince1970 {
            menuItem(withKey: .gems).pillText = nil
            menuItem(withKey: .subscription).pillText = nil
            return
        }
        if let promo = activePromo {
            var promoItem: MenuItem?
            if promo.promoType == .gemsPrice || promo.promoType == .gemsAmount {
                promoItem = menuItem(withKey: .gems)
            } else if promo.promoType == .subscription {
                promoItem = menuItem(withKey: .subscription)
            }
            promoItem?.pillText = L10n.sale
            promoItem?.pillBuilder = promo.configurePill
            promoItem?.subtitle = L10n.saleEndsIn(promo.endDate.getShortRemainingString())
        }
    }
    
    private func updateSeasonalEntries(worldState: WorldStateProtocol, items: [ItemProtocol]) {
        let market = menuItem(withKey: .market)
        if !items.isEmpty && items.first?.isValid == true && (items.first?.eventEnd ?? Date()) > Date() {
            market.pillText = L10n.new
            market.subtitle = L10n.seasonalPotionsAvailable
        } else {
            market.pillText = nil
            market.subtitle = nil
        }
        lastKnownSeason = worldState.currentSeason ?? ""
        lastWorldState = worldState
        lastSeasonalItems = items
        let seasonText: String
        switch currentSeason {
        case "winter", "nye", "birthday", "valentines":
            seasonText = L10n.winter
        case "spring":
            seasonText = L10n.spring
        case "summer":
            seasonText = L10n.summer
        case "fall", "habitoween", "thanksgiving":
            seasonText = L10n.fall
        default:
            seasonText = L10n.isOpen
        }
        menuItem(withKey: .seasonalShop).pillText = seasonText
        menuItem(withKey: .seasonalShop).pillColor = MainMenuTheme.seasonalBadge
        tableView.reloadData()
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        navbarColor = MainMenuTheme.headerBackground
        if !configRepository.enableIPadUI() {
            topHeaderCoordinator?.navbarVisibleColor = navbarColor
            navbarView.backgroundColor = navbarColor
        }
        tableView.backgroundColor = MainMenuTheme.sheetBackground
        tableView.separatorStyle = .none
        tableView.reloadData()
    }

    private func setupHeader() {
        topHeaderCoordinator?.hideNavBar = !configRepository.enableIPadUI()
        if !configRepository.enableIPadUI() {
            topHeaderCoordinator?.alternativeHeader = navbarView
            topHeaderCoordinator?.navbarVisibleColor = navbarColor
            navbarView.backgroundColor = navbarColor
        } else {
            navbarColor = ThemeService.shared.theme.contentBackgroundColor
        }
        topHeaderCoordinator?.followScrollView = false
        
        navbarView.messagesAction = {[weak self] in
            self?.perform(segue: StoryboardSegue.Main.inboxSegue)
        }
        navbarView.settingsAction = {[weak self] in
            self?.perform(segue: StoryboardSegue.Main.settingsSegue)
        }
        navbarView.notificationsAction = {[weak self] in
            let viewController = StoryboardScene.Main.notificationsNavigationController.instantiate()
            viewController.modalPresentationStyle = .popover
            guard let popover = viewController.popoverPresentationController else {
                return
            }
            popover.sourceView = self?.navbarView
            popover.sourceRect = self?.navbarView.notificationsButton.frame ?? CGRect.zero
            self?.present(viewController, animated: true, completion: nil)
        }
        navbarView.profileAction = {[weak self] in
            RouterHandler.shared.handle(urlString: "/profile/\(self?.user?.id ?? "")")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func languageChanged() {
        updateMenuTitles()
        setupMenu()
        tableView.reloadData()
    }
    
    private func updateMenuTitles() {
        for item in MenuItem.allItems {
            item.title = MenuItem.localizedTitle(for: item.key)
        }
    }
    
    private func socialItems() -> [MenuItem] {
        return [menuItem(withKey: .party)] + groupPlanItems + [menuItem(withKey: .messages), menuItem(withKey: .challenges)]
    }

    private func setupMenu() {
        updateMenuTitles()
        menuSections = [
            MenuSection(key: .user, title: L10n.Settings.user, items: [
                menuItem(withKey: .tasks),
                menuItem(withKey: .notifications),
                menuItem(withKey: .skills),
                menuItem(withKey: .stats),
                menuItem(withKey: .achievements)
                ]),
            MenuSection(key: .shops, title: L10n.Menu.shops, items: [
                menuItem(withKey: .market),
                menuItem(withKey: .questShop),
                menuItem(withKey: .customizationShop),
                menuItem(withKey: .seasonalShop),
                menuItem(withKey: .timeTravelersShop)
            ]),
            MenuSection(key: .inventory, title: L10n.Menu.inventory, items: [
                menuItem(withKey: .items),
                menuItem(withKey: .equipment),
                menuItem(withKey: .customizeAvatar),
                menuItem(withKey: .stable)
                ]),
            MenuSection(key: .social, title: L10n.Menu.social, items: socialItems()),
            MenuSection(key: .purchases, title: nil, items: [
                menuItem(withKey: .gems),
                menuItem(withKey: .subscription)
                ]),
            MenuSection(key: .about, title: L10n.Titles.about, items: [
                menuItem(withKey: .settings),
                menuItem(withKey: .news),
                menuItem(withKey: .about)
                ])
        ]
        
        if !configRepository.enableIPadUI() {
            menuItem(withKey: .tasks).isHidden = true
            menuItem(withKey: .settings).isHidden = true
            menuItem(withKey: .messages).isHidden = true
            menuItem(withKey: .notifications).isHidden = true
        } else {
            menuItem(withKey: .tasks).isHidden = false
            menuItem(withKey: .settings).isHidden = false
            menuItem(withKey: .messages).isHidden = false
            menuItem(withKey: .notifications).isHidden = false
        }
    }
    
    private func menuSection(withKey key: MenuSection.Key) -> MenuSection? {
        for section in menuSections where section.key == key {
            return section
        }
        return nil
    }
    
    private func menuItem(withKey key: MenuItem.Key) -> MenuItem {
        for item in MenuItem.allItems where item.key == key {
            return item
        }
        return MenuItem.allItems[0]
    }
    
    @objc
    private func refresh() {
        disposable.inner.add(userRepository.retrieveUser().observeCompleted {
            self.refreshControl?.endRefreshing()
        })
        disposable.inner.add(contentRepository.retrieveWorldState(force: true).observeCompleted {})
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return visibleSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionAt(index: section)?.visibleItems.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        return sectionAt(index: section)?.title
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = MainMenuTheme.sheetBackground
        return view
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = MainMenuTheme.sheetBackground
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (sectionAt(index: section)?.visibleItems.count ?? 0) == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return section == 0 ? 9 : 20
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    private var headerInsetCorrection: CGFloat {
        guard let navController = navigationController as? TopHeaderViewController else {
            return 0
        }
        return navController.topHeaderHeight - navController.contentInset
    }

    private func refreshPromoState() {
        activePromo = configRepository.activePromotion()
        updatePromoCells()
        setupFooter()
        setupPinnedPill()
        tableView.reloadData()
    }

    private static let rowIcons: [MenuItem.Key: String] = [
        .skills: "menu_skills", .stats: "menu_stats", .achievements: "menu_achievements",
        .market: "menu_market", .questShop: "menu_questShop", .customizationShop: "menu_customizationShop",
        .timeTravelersShop: "menu_timeTravelersShop", .customizeAvatar: "menu_avatarCustomization",
        .equipment: "menu_equipment", .items: "menu_items", .stable: "menu_petsMounts",
        .gems: "menu_gems", .subscription: "menu_subscription", .party: "menu_party",
        .challenges: "menu_challenges", .news: "menu_news", .support: "menu_help", .about: "menu_help",
        .groupPlan: "menu_groupPlan"
    ]

    private var currentSeason: String {
        return lastKnownSeason
    }

    private func seasonalIconName() -> String {
        switch currentSeason {
        case "spring":
            return "menu_SeasonalShopSpring"
        case "summer":
            return "menu_SeasonalShopSummer"
        case "fall", "habitoween", "thanksgiving":
            return "menu_SeasonalShopFall"
        case "winter", "nye", "birthday", "valentines":
            return "menu_SeasonalShopWinter"
        default:
            switch Calendar.current.component(.month, from: Date()) {
            case 3, 4, 5:
                return "menu_SeasonalShopSpring"
            case 6, 7, 8:
                return "menu_SeasonalShopSummer"
            case 9, 10, 11:
                return "menu_SeasonalShopFall"
            default:
                return "menu_SeasonalShopWinter"
            }
        }
    }

    private func iconImage(for key: MenuItem.Key?) -> UIImage? {
        guard let key = key else {
            return nil
        }
        let name = key == .seasonalShop ? seasonalIconName() : MainMenuViewController.rowIcons[key]
        guard let name = name else {
            return nil
        }
        return UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
    }

    private var currentSecondaryIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = visibleSections[indexPath.section].visibleItems[indexPath.item]
        if item.isDisabled {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if let instantiator = item.vcInstantiator, let viewController = instantiator() {
            if let navigationController = viewController as? UINavigationController {
                present(navigationController, animated: true, completion: nil)
            } else {
                if let splitViewController = splitViewController, !splitViewController.isCollapsed {
                    let oldIndexPath = currentSecondaryIndexPath
                    currentSecondaryIndexPath = indexPath
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [indexPath, oldIndexPath], with: .automatic)
                    tableView.endUpdates()
                    viewController.navigationItem.setHidesBackButton(true, animated: false)
                    splitViewController.showDetailViewController(viewController, sender: self)
                } else {
                    navigationController?.pushViewController(viewController, animated: true)
                }
            }
        } else {
            performSegue(withIdentifier: item.segue, sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = visibleItemAt(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: item?.cellName ?? "Cell", for: indexPath)
        if item?.accessibilityLabel?.isEmpty != true {
            cell.accessibilityLabel = accessibilityLabel
        } else {
            cell.accessibilityLabel = title
        }
        
        cell.accessoryType = .none
        let label = cell.viewWithTag(1) as? UILabel
        let titleColor: UIColor
        if indexPath == tableView.indexPathForSelectedRow || (indexPath == currentSecondaryIndexPath && splitViewController != nil) {
            cell.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            titleColor = ThemeService.shared.theme.tintColor
        } else {
            cell.backgroundColor = MainMenuTheme.sheetBackground
            titleColor = item?.isDisabled == true ? MainMenuTheme.lockedRowTitle : MainMenuTheme.rowTitle
        }
        label?.attributedText = NSAttributedString(string: item?.title ?? "", attributes: [
            .font: UIFontMetrics.default.scaledSystemFont(ofSize: 17, ofWeight: .semibold),
            .kern: -0.2,
            .foregroundColor: titleColor
        ])
        label?.backgroundColor = .clear

        let indicatorView = cell.viewWithTag(2)
        indicatorView?.isHidden = item?.showIndicator == false
        indicatorView?.layer.cornerRadius = (indicatorView?.frame.size.height ?? 0) / 2
        indicatorView?.backgroundColor = MainMenuTheme.notificationDot
        indicatorView?.layer.borderWidth = 2
        indicatorView?.layer.borderColor = MainMenuTheme.notificationDotRing.cgColor
        
        let pillView = cell.viewWithTag(3) as? PillView
        pillView?.text = item?.pillText
        pillView?.isHidden = item?.pillText == nil
        if let builder = item?.pillBuilder, let pill = pillView {
            builder(pill)
        } else {
            pillView?.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            pillView?.automaticTextColor = false
            pillView?.pillColor = item?.pillColor ?? MainMenuTheme.seasonalBadge
            pillView?.textColor = MainMenuTheme.seasonalBadgeText
        }
        
        let subtitleLabel = cell.viewWithTag(4) as? UILabel
        subtitleLabel?.text = item?.subtitle
        subtitleLabel?.isHidden = item?.subtitle == nil
        subtitleLabel?.font = UIFontMetrics.default.scaledSystemFont(ofSize: 13)
        subtitleLabel?.textColor = item?.subtitleColor ?? MainMenuTheme.rowSubtitle

        let iconView = cell.viewWithTag(5) as? UIImageView
        if let image = iconImage(for: item?.iconKey ?? item?.key) {
            iconView?.image = image
            iconView?.tintColor = MainMenuTheme.iconTint
            iconView?.isHidden = false
            iconView?.alpha = item?.isDisabled == true ? 0.45 : 1.0
        } else {
            iconView?.image = nil
            iconView?.isHidden = true
        }
        let lockView = cell.viewWithTag(6) as? UIImageView
        if item?.isDisabled == true {
            lockView?.image = MainMenuTheme.lockBadgeImage
            lockView?.contentMode = .center
            lockView?.isHidden = false
        } else {
            lockView?.isHidden = true
        }

        cell.selectionStyle = item?.isDisabled == true ? .default : .none
        return cell
    }
    
    private func sectionAt(index: Int) -> MenuSection? {
        if visibleSections.count <= index {
            return nil
        }
        return visibleSections[index]
    }
    
    private func visibleItemAt(indexPath: IndexPath) -> MenuItem? {
        guard let section = sectionAt(index: indexPath.section) else {
            return nil
        }
        let items = section.visibleItems
        if items.count <= indexPath.item {
            return nil
        }
        return items[indexPath.item]
    }
    
    func giftSubscriptionButtonTapped() {
        let alertController = GiftingAlertController(title: L10n.giftSubscription, message: L10n.giftGemsAlertText) { username in
            RouterHandler.shared.handle(.giftSubscription(username: username))
        }
        alertController.show()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.showMarketSegue.rawValue {
            (segue.destination as? ShopViewController)?.shopIdentifier = Constants.MarketKey
        } else if segue.identifier == StoryboardSegue.Main.showQuestShopSegue.rawValue {
            (segue.destination as? ShopViewController)?.shopIdentifier = Constants.QuestShopKey
        } else if segue.identifier == StoryboardSegue.Main.showSeasonalShopSegue.rawValue {
            (segue.destination as? ShopViewController)?.shopIdentifier = Constants.SeasonalShopKey
        } else if segue.identifier == StoryboardSegue.Main.showTimeTravelersSegue.rawValue {
            (segue.destination as? ShopViewController)?.shopIdentifier = Constants.TimeTravelersShopKey
        } else if segue.identifier == StoryboardSegue.Main.showCustomizationShopSegue.rawValue {
            (segue.destination as? ShopViewController)?.shopIdentifier = Constants.CustomizationShopKey
        } else if segue.identifier == StoryboardSegue.Main.showUserProfileSegue.rawValue {
            (segue.destination as? UserProfileViewController)?.username = user?.username
            (segue.destination as? UserProfileViewController)?.userID = user?.id
        }
    }
}

enum MainMenuTheme {
    private static func color(_ light: String, _ dark: String) -> UIColor {
        ThemeService.shared.theme.isDark ? UIColor(dark) : UIColor(light)
    }

    private static var theme: Theme { ThemeService.shared.theme }

    private static var isDefaultTheme: Bool {
        (ThemeName(rawValue: UserDefaults.standard.string(forKey: "theme") ?? "") ?? .defaultTheme) == .defaultTheme
    }

    static var headerBackground: UIColor { isDefaultTheme ? .purple300 : theme.menuHeaderBackground }
    static var headerText: UIColor { isDefaultTheme ? .white : theme.menuHeaderText }
    static var headerIcon: UIColor { isDefaultTheme ? .white : theme.menuHeaderIcon }
    static var headerBubble: UIColor { theme.menuHeaderBubble }
    static var headerBubbleText: UIColor { theme.menuHeaderBubbleText }
    static var sheetBackground: UIColor { theme.menuBackground }
    static var rowTitle: UIColor { theme.menuText }
    static var iconTint: UIColor { theme.menuIcon }
    static var rowSubtitle: UIColor { color("#79659D", "#B7ADCD") }
    static var lockedRowTitle: UIColor { color("#A89BC7", "#7A7387") }
    static var notificationDot: UIColor { .red100 }
    static var notificationDotRing: UIColor { sheetBackground }
    static var seasonalBadge: UIColor { theme.menuPillBackground }
    static var seasonalBadgeText: UIColor { theme.menuPillText }
    static var lockBadge: UIColor { theme.menuLockBackground }
    static var lockBadgeGlyph: UIColor { theme.menuLockIcon }

    private static var lockBadgeCache: [String: UIImage] = [:]

    static var lockBadgeImage: UIImage {
        let cacheKey = "\(lockBadge.hexString())-\(lockBadgeGlyph.hexString())"
        if let cached = lockBadgeCache[cacheKey] {
            return cached
        }
        let size = CGSize(width: 24, height: 24)
        let glyphHeight: CGFloat = 10
        let image = UIGraphicsImageRenderer(size: size).image { context in
            lockBadge.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            let source = Asset.menuLockIcon.image
            let glyph = source.withRenderingMode(.alwaysTemplate).withTintColor(lockBadgeGlyph, renderingMode: .alwaysOriginal)
            let glyphWidth = glyphHeight * (source.size.width / max(source.size.height, 1))
            glyph.draw(in: CGRect(x: (size.width - glyphWidth) / 2,
                                  y: (size.height - glyphHeight) / 2,
                                  width: glyphWidth,
                                  height: glyphHeight))
        }
        lockBadgeCache[cacheKey] = image
        return image
    }
}
