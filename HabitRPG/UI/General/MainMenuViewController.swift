//
//  MainMenuViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 27.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import Eureka
import ReactiveSwift

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
        
        case tavern
        case party
        case questDetail
        case guilds
        case challenges
        
        case support
        case about
        case news
        
        case settings
        case notifications
        case messages
    }
    
    var key: MenuItem.Key
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
    
    init(key: Key, title: String, subtitle: String? = nil, pillText: String? = nil, accessibilityLabel: String? = nil, segue: String? = nil, vcInstantiator: (() -> UIViewController?)? = nil, cellName: String = "Cell", showIndicator: Bool = false, isHidden: Bool = false) {
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
        MenuItem(key: .habits, title: L10n.Tasks.tasks, segue: StoryboardSegue.Main.tasksBoardSegue.rawValue),
        MenuItem(key: .habits, title: L10n.Tasks.habits, vcInstantiator: StoryboardScene.Main.habitsViewController.instantiate),
        MenuItem(key: .dailies, title: L10n.Tasks.dailies, vcInstantiator: StoryboardScene.Main.dailiesViewController.instantiate),
        MenuItem(key: .todos, title: L10n.Tasks.todos, vcInstantiator: StoryboardScene.Main.todosViewController.instantiate),
        MenuItem(key: .rewards, title: L10n.Tasks.rewards, vcInstantiator: StoryboardScene.Main.rewardsViewController.instantiate),
        MenuItem(key: .skills, title: L10n.Menu.skills, segue: StoryboardSegue.Main.spellsSegue.rawValue),
        MenuItem(key: .stats, title: L10n.Titles.stats, segue: StoryboardSegue.Main.statsSegue.rawValue),
        MenuItem(key: .achievements, title: L10n.Titles.achievements, segue: StoryboardSegue.Main.achievementsSegue.rawValue),
        MenuItem(key: .market, title: L10n.Locations.market, segue: StoryboardSegue.Main.showMarketSegue.rawValue),
        MenuItem(key: .questShop, title: L10n.Locations.questShop, segue: StoryboardSegue.Main.showQuestShopSegue.rawValue),
        MenuItem(key: .seasonalShop, title: L10n.Locations.seasonalShop, segue: StoryboardSegue.Main.showSeasonalShopSegue.rawValue, isHidden: true),
        MenuItem(key: .timeTravelersShop, title: L10n.Locations.timeTravelersShop, segue: StoryboardSegue.Main.showTimeTravelersSegue.rawValue),
        MenuItem(key: .customizeAvatar, title: L10n.Menu.customizeAvatar, segue: StoryboardSegue.Main.customizationSegue.rawValue),
        MenuItem(key: .equipment, title: L10n.Titles.equipment, segue: StoryboardSegue.Main.equipmentSegue.rawValue),
        MenuItem(key: .items, title: L10n.Titles.items, segue: StoryboardSegue.Main.itemSegue.rawValue),
        MenuItem(key: .stable, title: L10n.Titles.petsAndMounts, segue: StoryboardSegue.Main.stableSegue.rawValue),
        MenuItem(key: .gems, title: L10n.Menu.gems, segue: StoryboardSegue.Main.purchaseGemsSegue.rawValue),
        MenuItem(key: .subscription, title: L10n.Menu.subscription, segue: StoryboardSegue.Main.subscriptionSegue.rawValue),
        MenuItem(key: .tavern, title: L10n.Titles.tavern, segue: StoryboardSegue.Main.tavernSegue.rawValue),
        MenuItem(key: .party, title: L10n.Titles.party, segue: StoryboardSegue.Main.partySegue.rawValue),
        MenuItem(key: .questDetail, title: L10n.quest, vcInstantiator: StoryboardScene.Social.questDetailViewController.instantiate),
        MenuItem(key: .guilds, title: L10n.Titles.guilds, segue: StoryboardSegue.Main.guildsSegue.rawValue),
        MenuItem(key: .challenges, title: L10n.Titles.challenges, segue: StoryboardSegue.Main.challengesSegue.rawValue),
        MenuItem(key: .news, title: L10n.Titles.news, segue: StoryboardSegue.Main.newsSegue.rawValue),
        MenuItem(key: .support, title: L10n.Menu.support, segue: StoryboardSegue.Main.showSupportSegue.rawValue),
        MenuItem(key: .about, title: L10n.Titles.about, segue: StoryboardSegue.Main.aboutSegue.rawValue),
        MenuItem(key: .settings, title: L10n.Titles.settings, segue: StoryboardSegue.Main.settingsSegue.rawValue),
        MenuItem(key: .messages, title: L10n.Titles.messages, segue: StoryboardSegue.Main.inboxSegue.rawValue),
        MenuItem(key: .notifications, title: L10n.Titles.notifications, vcInstantiator: StoryboardScene.Main.notificationsNavigationController.instantiate)
    ]
}

struct MenuSection {
    enum Key: String {
        case user
        case inventory
        case shops
        case social
        case about
    }
    let key: Key
    let title: String?
    let iconAsset: ImageAsset?
    var isHidden: Bool = false
    var items: [MenuItem]
    
    var visibleItems: [MenuItem] {
        return items.filter({ (item) -> Bool in return !item.isHidden })
    }
}

class MainMenuViewController: BaseTableViewController {
    
    private var navbarColor = ThemeService.shared.theme.navbarHiddenColor {
        didSet {
            topHeaderCoordinator.navbarVisibleColor = navbarColor
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
    private let configRepository = ConfigRepository()
    
    private var disposable = ScopedDisposable(CompositeDisposable())
    private var seasonalShopTimer: Timer?
    
    private var menuSections = [MenuSection]()
    var visibleSections: [MenuSection] {
        return menuSections.filter { (section) in (!section.isHidden && !section.visibleItems.isEmpty) }
    }
    private var giftRecipientUsername = ""
    
    private var activePromo: HabiticaPromotion?

    private var user: UserProtocol? {
        didSet {
            if let user = self.user {
                navbarView.configure(user: user)
            }
            let statsItem = menuItem(withKey: .stats)
            if user?.preferences?.disableClasses == true {
                statsItem.isHidden = true
            } else {
                statsItem.isHidden = false
                if user?.stats?.level ?? 0 < 10 || user?.flags?.classSelected == false {
                    statsItem.subtitle = L10n.unlocksLevelTen
                    statsItem.isDisabled = true
                } else {
                    statsItem.subtitle = nil
                    statsItem.isDisabled = false
                }
            }
            menuItem(withKey: .news).showIndicator = user?.flags?.hasNewStuff == true
            
            if let partyID = user?.party?.id {
                let hasPartActivity = user?.hasNewMessages.first(where: { (newMessages) -> Bool in
                    return newMessages.id == partyID
                })
                menuItem(withKey: .party).showIndicator = hasPartActivity?.hasNewMessages ?? false
            } else {
                menuItem(withKey: .party).showIndicator = false
            }
            
            menuItem(withKey: .tavern).subtitle = user?.preferences?.sleep == true ? L10n.damagePaused : nil
            
            tableView.reloadData()
            
            if user?.isSubscribed == true && activePromo == nil {
                tableView.tableFooterView = nil
            }
            if user?.isSubscribed == true {
                menuItem(withKey: .subscription).subtitle = nil
            } else {
                menuItem(withKey: .subscription).subtitle = L10n.getMoreHabitica
            }
            if user?.achievements?.hasCompletedOnboarding == true || configRepository.bool(variable: .moveAdventureGuide) {
                tableView.tableHeaderView = nil
            } else {
                let view = AdventureGuideBannerView(frame: CGRect(x: 0, y: -10, width: tableView.frame.size.width, height: 103))
                view.onTapped = { [weak self] in
                    self?.perform(segue: StoryboardSegue.Main.showAdventureGuide)
                }
                if let achievements = user?.achievements?.onboardingAchievements {
                    view.setProgress(earned: achievements.filter({ $0.value }).count, total: achievements.count)
                }
                tableView.tableHeaderView = view
            }
            
            if let promo = activePromo {
                if promo.promoType == .gemsPrice || promo.promoType == .gemsAmount {
                    menuItem(withKey: .gems).pillText = L10n.sale
                    menuItem(withKey: .gems).pillBuilder = promo.configurePill
                }
                if promo.promoType == .subscription {
                    menuItem(withKey: .subscription).pillText = L10n.sale
                    menuItem(withKey: .subscription).pillBuilder = promo.configurePill
                }
            }
            
            let customMenu = configRepository.array(variable: .customMenu)
            // swiftlint:disable:next empty_count
            if customMenu.count > 0 {
                reorderMenu(customMenu)
            }
            
            menuItem(withKey: .challenges).isHidden = configRepository.bool(variable: .disableChallenges)
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
                    }
                    newOrder.append(existingSection)
                }
            }
        }
        menuSections = newOrder
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MainTableviewCell", bundle: nil), forCellReuseIdentifier: "Cell")

        topHeaderCoordinator?.hideNavBar = true
        topHeaderCoordinator?.alternativeHeader = navbarView
        topHeaderCoordinator?.navbarVisibleColor = navbarColor
        topHeaderCoordinator?.followScrollView = false
        navbarView.backgroundColor = navbarColor
        
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
        
        #if !targetEnvironment(macCatalyst)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        #endif
        
        setupMenu()
        
        activePromo = configRepository.activePromotion()
        
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
            } else {
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
            } else {
                self?.tableView.tableHeaderView = nil
            }
        })
        .start())
        disposable.inner.add(userRepository.getUnreadNotificationCount().on(value: {[weak self] notificationCount in
            if notificationCount > 0 {
                self?.navbarView.notificationsBadge.text = String(notificationCount)
                self?.navbarView.notificationsBadge.isHidden = false
            } else {
                self?.navbarView.notificationsBadge.isHidden = true
            }
        }).start())
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        if configRepository.bool(variable: .showSubscriptionBanner) {
            let view = SubscriptionPromoView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 148))
            view.onButtonTapped = { [weak self] in self?.performSegue(withIdentifier: StoryboardSegue.Main.subscriptionSegue.rawValue, sender: self) }
            tableView.tableFooterView = view
        } else if let promo = activePromo {
            if !UserDefaults.standard.bool(forKey: "hide\(promo.identifier)") {
                let view = PromoMenuView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 148))
                promo.configurePromoMenuView(view: view)
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
                tableView.tableFooterView = view
            }
        }
        
        disposable.inner.add(contentRepository.getWorldState()
                                .combineLatest(with: inventoryRepository.getCurrentTimeLimitedItems())
                                .on(value: {[weak self] (worldState, items) in
            self?.seasonalShopTimer?.invalidate()
                                    self?.updateSeasonalEntries(worldState: worldState, items: items)
            self?.seasonalShopTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: {[weak self] _ in
                self?.updateSeasonalEntries(worldState: worldState, items: items)
            })
        }).start())
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
        if worldState.isValid && worldState.isSeasonalShopOpen {
            menuItem(withKey: .seasonalShop).pillText = L10n.isOpen
            menuItem(withKey: .seasonalShop).subtitle = L10n.openFor(worldState.seasonalShopEvent?.end?.getShortRemainingString() ?? "")
            menuItem(withKey: .seasonalShop).isHidden = false
        } else {
            menuItem(withKey: .seasonalShop).isHidden = true
        }
        tableView.reloadData()
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        navbarColor = theme.navbarHiddenColor
        tableView.reloadData()
    }
    
    private func setupMenu() {
        menuSections = [
            MenuSection(key: .user, title: L10n.Settings.user, iconAsset: nil, items: [
                menuItem(withKey: .skills),
                menuItem(withKey: .stats),
                menuItem(withKey: .achievements)
                ]),
            MenuSection(key: .shops, title: L10n.Menu.shops, iconAsset: Asset.iconInventory, items: [
                menuItem(withKey: .market),
                menuItem(withKey: .questShop),
                menuItem(withKey: .seasonalShop),
                menuItem(withKey: .timeTravelersShop)
            ]),
            MenuSection(key: .inventory, title: L10n.Menu.inventory, iconAsset: Asset.iconInventory, items: [
                menuItem(withKey: .customizeAvatar),
                menuItem(withKey: .equipment),
                menuItem(withKey: .items),
                menuItem(withKey: .stable),
                menuItem(withKey: .gems),
                menuItem(withKey: .subscription)
                ]),
            MenuSection(key: .social, title: L10n.Menu.social, iconAsset: Asset.iconSocial, items: [
                menuItem(withKey: .tavern),
                menuItem(withKey: .party),
                menuItem(withKey: .guilds),
                menuItem(withKey: .challenges)
                ]),
            MenuSection(key: .about, title: L10n.Titles.about, iconAsset: Asset.iconHelp, items: [
                menuItem(withKey: .news),
                menuItem(withKey: .support),
                menuItem(withKey: .about)
                ])
        ]
        menuItem(withKey: .tavern).subtitleColor = UIColor.orange10
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
        if section == 0 {
            return nil
        }
        
        let view = UIView()
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 14)
        label.textColor = ThemeService.shared.theme.primaryTextColor
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        view.addSubview(label)
        let iconView = UIImageView()
        iconView.tintColor = ThemeService.shared.theme.primaryTextColor
        view.addSubview(iconView)
        iconView.pin.start(4).size(16)
        label.pin.after(of: iconView).top(14).marginStart(6).sizeToFit(.heightFlexible)
        view.pin.width(view.frame.size.width).height(label.frame.size.height + 14)
        iconView.pin.vCenter(to: label.edge.vCenter)
        
        if let iconAsset = visibleSections[section].iconAsset {
            iconView.image = UIImage(asset: iconAsset)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        } else {
            let font = CustomFontMetrics.scaledSystemFont(ofSize: 14)
            return 20 + font.lineHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = visibleSections[indexPath.section].visibleItems[indexPath.item]
        if item.isDisabled {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if let instantiator = item.vcInstantiator, let vc = instantiator() {
            if let nc = vc as? UINavigationController {
                nc.present(vc, animated: true, completion: nil)
            } else {
                if splitViewController != nil {
                    splitViewController?.showDetailViewController(vc, sender: self)
                } else {
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            performSegue(withIdentifier: item.segue, sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = visibleItemAt(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: item?.cellName ?? "Cell", for: indexPath)
        cell.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        
        if item?.accessibilityLabel?.isEmpty != true {
            cell.accessibilityLabel = accessibilityLabel
        } else {
            cell.accessibilityLabel = title
        }
        
        let label = cell.viewWithTag(1) as? UILabel
        label?.text = item?.title
        label?.font = CustomFontMetrics.scaledSystemFont(ofSize: 17)
        if item?.isDisabled == true {
            label?.textColor = ThemeService.shared.theme.dimmedTextColor
        } else {
            label?.textColor = ThemeService.shared.theme.primaryTextColor
        }
        label?.backgroundColor = .clear

        let indicatorView = cell.viewWithTag(2)
        indicatorView?.isHidden = item?.showIndicator == false
        indicatorView?.layer.cornerRadius = (indicatorView?.frame.size.height ?? 0) / 2
        indicatorView?.backgroundColor = ThemeService.shared.theme.backgroundTintColor
        
        let pillView = cell.viewWithTag(3) as? PillView
        pillView?.text = item?.pillText
        pillView?.isHidden = item?.pillText == nil
        if let builder = item?.pillBuilder, let pill = pillView {
            builder(pill)
        } else {
            pillView?.pillColor = item?.pillColor ?? UIColor.purple300
        }
        
        let subtitleLabel = cell.viewWithTag(4) as? UILabel
        subtitleLabel?.text = item?.subtitle
        subtitleLabel?.isHidden = item?.subtitle == nil
        subtitleLabel?.font = CustomFontMetrics.scaledSystemFont(ofSize: 11)
        subtitleLabel?.textColor = item?.subtitleColor ?? ThemeService.shared.theme.secondaryTextColor
        
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
        let alertController = HabiticaAlertController(title: L10n.giftRecipientTitle, message: L10n.giftRecipientSubtitle)
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.borderColor = UIColor.gray300
        textField.borderWidth = 1
        textField.tintColor = ThemeService.shared.theme.tintColor
        alertController.contentView = textField
        alertController.addCancelAction()
        alertController.addAction(title: L10n.continue, style: .default, isMainAction: true, closeOnTap: true, handler: { _ in
            if let username = textField.text, username.isEmpty == false {
                self.giftRecipientUsername = username
                self.perform(segue: StoryboardSegue.Main.openGiftSubscriptionDialog)
            }
        })
        alertController.containerViewSpacing = 4
        alertController.show()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.openGiftSubscriptionDialog.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let giftSubscriptionController = navigationController?.topViewController as? GiftSubscriptionViewController
            giftSubscriptionController?.giftRecipientUsername = giftRecipientUsername
        } else if segue.identifier == StoryboardSegue.Main.showMarketSegue.rawValue {
            (segue.destination as? HRPGShopViewController)?.shopIdentifier = Constants.MarketKey
        } else if segue.identifier == StoryboardSegue.Main.showQuestShopSegue.rawValue {
            (segue.destination as? HRPGShopViewController)?.shopIdentifier = Constants.QuestShopKey
        } else if segue.identifier == StoryboardSegue.Main.showSeasonalShopSegue.rawValue {
            (segue.destination as? HRPGShopViewController)?.shopIdentifier = Constants.SeasonalShopKey
        } else if segue.identifier == StoryboardSegue.Main.showTimeTravelersSegue.rawValue {
            (segue.destination as? HRPGShopViewController)?.shopIdentifier = Constants.TimeTravelersShopKey
        } else if segue.identifier == StoryboardSegue.Main.showUserProfileSegue.rawValue {
            (segue.destination as? UserProfileViewController)?.username = user?.username
            (segue.destination as? UserProfileViewController)?.userID = user?.id
        }
    }
}
