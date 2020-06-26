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

struct MenuItem {
    var title: String
    var subtitle: String?
    var subtitleColor: UIColor?
    var pillText: String?
    var pillColor: UIColor?
    var accessibilityLabel: String?
    var segue: String
    var cellName = "Cell"
    var showIndicator = false
    var isHidden = false
    
    init(title: String, subtitle: String? = nil, pillText: String? = nil, accessibilityLabel: String? = nil, segue: String, cellName: String = "Cell", showIndicator: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.pillText = pillText
        self.accessibilityLabel = accessibilityLabel
        self.segue = segue
        self.cellName = cellName
        self.showIndicator = showIndicator
    }
}

struct MenuSection {
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
    private var worldBossTintColor: UIColor?
    private var navbarView = MenuNavigationBarView()
    private var worldBossHeaderView: WorldBossMenuHeader?
    
    private var userRepository = UserRepository()
    private let configRepository = ConfigRepository()
    
    private var disposable = ScopedDisposable(CompositeDisposable())
    
    private var menuSections = [MenuSection]()
    var visibleSections: [MenuSection] {
        return menuSections.filter { (section) in !section.isHidden }
    }
    private var giftRecipientUsername = ""

    private var user: UserProtocol? {
        didSet {
            if let user = self.user {
                navbarView.configure(user: user)
            }
            if user?.stats?.habitClass == "wizard" || user?.stats?.habitClass == "healer" {
                menuSections[0].items[0].title = L10n.Menu.castSpells
            } else {
                menuSections[0].items[0].title = L10n.Menu.useSkills
            }
            menuSections[0].items[0].isHidden = user?.canUseSkills == false
            menuSections[0].items[1].isHidden = user?.needsToChooseClass == true
            menuSections[4].items[0].showIndicator = user?.flags?.hasNewStuff == true
            
            if let partyID = user?.party?.id {
                let hasPartActivity = user?.hasNewMessages.first(where: { (newMessages) -> Bool in
                    return newMessages.id == partyID
                })
                menuSections[1].items[1].showIndicator = hasPartActivity?.hasNewMessages ?? false
            } else {
                menuSections[1].items[1].showIndicator = false
            }
            
            menuSections[1].items[0].subtitle = user?.preferences?.sleep == true ? L10n.damagePaused : nil
            
            tableView.reloadData()
            
            if user?.isSubscribed == true && !configRepository.bool(variable: .enableGiftOneGetOne) {
                tableView.tableFooterView = nil
            }
            if user?.isSubscribed == true {
                menuSections[3].items[6].subtitle = nil
            } else {
                menuSections[3].items[6].subtitle = L10n.getMoreHabitica
            }
            if configRepository.bool(variable: .enableAdventureGuide) {
                if user?.achievements?.hasCompletedOnboarding == true {
                    tableView.tableHeaderView = nil                } else {
                    let view = AdventureGuideBannerView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 103))
                    view.onTapped = { [weak self] in
                        self?.perform(segue: StoryboardSegue.Main.showAdventureGuide)
                    }
                    if let achievements = user?.achievements?.onboardingAchievements {
                        view.setProgress(earned: achievements.filter({ $0.value }).count, total:  achievements.count)
                    }
                    tableView.tableHeaderView = view
                }
            } else {
                tableView.tableHeaderView = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        
        setupMenu()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start())
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
        
        if configRepository.bool(variable: .enableGiftOneGetOne) {
            let view = GiftOneGetOnePromoView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 148))
            view.size = .large
            view.cornerRadius = 0
            view.onTapped = { [weak self] in self?.giftSubscriptionButtonTapped() }
            tableView.tableFooterView = view
        } else if configRepository.bool(variable: .showSubscriptionBanner) {
            let view = SubscriptionPromoView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 148))
            view.onButtonTapped = { [weak self] in self?.performSegue(withIdentifier: StoryboardSegue.Main.subscriptionSegue.rawValue, sender: self) }
            tableView.tableFooterView = view
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        navbarColor = theme.navbarHiddenColor
        tableView.reloadData()
    }
    
    private func setupMenu() {
        menuSections = [
            MenuSection(title: nil, iconAsset: nil, items: [
                MenuItem(title: L10n.Menu.castSpells, segue: StoryboardSegue.Main.spellsSegue.rawValue),
                //MenuItem(title: L10n.Menu.selectClass, segue: StoryboardSegue.Main.selectClassSegue.rawValue),
                MenuItem(title: L10n.Titles.stats, segue: StoryboardSegue.Main.statsSegue.rawValue),
                MenuItem(title: L10n.Titles.achievements, segue: StoryboardSegue.Main.achievementsSegue.rawValue)
                ]),
            MenuSection(title: L10n.Menu.social, iconAsset: Asset.iconSocial, items: [
                MenuItem(title: L10n.Titles.tavern, segue: StoryboardSegue.Main.tavernSegue.rawValue),
                MenuItem(title: L10n.Titles.party, segue: StoryboardSegue.Main.partySegue.rawValue),
                MenuItem(title: L10n.Titles.guilds, segue: StoryboardSegue.Main.guildsSegue.rawValue),
                MenuItem(title: L10n.Titles.challenges, segue: StoryboardSegue.Main.challengesSegue.rawValue)
                ]),
            MenuSection(title: L10n.Menu.shops, iconAsset: Asset.iconInventory, items: [
                MenuItem(title: L10n.Locations.market, segue: StoryboardSegue.Main.showMarketSegue.rawValue),
                MenuItem(title: L10n.Locations.questShop, segue: StoryboardSegue.Main.showQuestShopSegue.rawValue),
                MenuItem(title: L10n.Locations.seasonalShop, segue: StoryboardSegue.Main.showSeasonalShopSegue.rawValue),
                MenuItem(title: L10n.Locations.timeTravelersShop, segue: StoryboardSegue.Main.showTimeTravelersSegue.rawValue)
            ]),
            MenuSection(title: L10n.Menu.inventory, iconAsset: Asset.iconInventory, items: [
                MenuItem(title: L10n.Titles.shops, segue: StoryboardSegue.Main.shopsSegue.rawValue),
                MenuItem(title: L10n.Menu.customizeAvatar, segue: StoryboardSegue.Main.customizationSegue.rawValue),
                MenuItem(title: L10n.Titles.equipment, segue: StoryboardSegue.Main.equipmentSegue.rawValue),
                MenuItem(title: L10n.Titles.items, segue: StoryboardSegue.Main.itemSegue.rawValue),
                MenuItem(title: L10n.Titles.petsAndMounts, segue: StoryboardSegue.Main.stableSegue.rawValue),
                MenuItem(title: L10n.Menu.gems, segue: StoryboardSegue.Main.purchaseGemsSegue.rawValue),
                MenuItem(title: L10n.Menu.subscription, segue: StoryboardSegue.Main.subscriptionSegue.rawValue)
                ]),
            MenuSection(title: L10n.Titles.about, iconAsset: Asset.iconHelp, items: [
                MenuItem(title: L10n.Titles.news, segue: StoryboardSegue.Main.newsSegue.rawValue),
                MenuItem(title: L10n.Menu.helpFaq, segue: StoryboardSegue.Main.faqSegue.rawValue),
                MenuItem(title: L10n.Titles.about, segue: StoryboardSegue.Main.aboutSegue.rawValue)
                ])
        ]
        menuSections[1].items[0].subtitleColor = UIColor.orange10
        
        if configRepository.bool(variable: .enableGiftOneGetOne) {
            menuSections[2].items[6].pillText = L10n.sale
            menuSections[2].items[6].pillColor = .teal50
        }
        
        if configRepository.bool(variable: .raiseShops) {
            menuSections[3].items[0].isHidden = true
            menuSections[2].isHidden = false
        } else {
            menuSections[2].isHidden = true
            menuSections[3].items[0].isHidden = false
        }
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
        iconView.pin.start(9).size(16)
        label.pin.after(of: iconView).top(14).marginStart(6).sizeToFit(.heightFlexible)
        view.pin.width(view.frame.size.width).height(label.frame.size.height + 14)
        iconView.pin.vCenter(to: label.edge.vCenter)
        
        if let iconAsset = visibleSections[section].iconAsset {
            iconView.image = UIImage(asset: iconAsset)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: visibleSections[indexPath.section].visibleItems[indexPath.item].segue, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = visibleItemAt(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: item?.cellName ?? "", for: indexPath)
        cell.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        
        if item?.accessibilityLabel?.isEmpty != true {
            cell.accessibilityLabel = accessibilityLabel
        } else {
            cell.accessibilityLabel = title
        }
        
        let label = cell.viewWithTag(1) as? UILabel
        label?.text = item?.title
        label?.font = CustomFontMetrics.scaledSystemFont(ofSize: 17)
        label?.textColor = ThemeService.shared.theme.primaryTextColor
        label?.backgroundColor = .clear

        let indicatorView = cell.viewWithTag(2)
        indicatorView?.isHidden = item?.showIndicator == false
        indicatorView?.layer.cornerRadius = (indicatorView?.frame.size.height ?? 0) / 2
        indicatorView?.backgroundColor = ThemeService.shared.theme.backgroundTintColor
        
        let pillView = cell.viewWithTag(3) as? PillView
        pillView?.text = item?.pillText
        pillView?.isHidden = item?.pillText == nil
        pillView?.pillColor = item?.pillColor ?? UIColor.purple300
        
        let subtitleLabel = cell.viewWithTag(4) as? UILabel
        subtitleLabel?.text = item?.subtitle
        subtitleLabel?.isHidden = item?.subtitle == nil
        subtitleLabel?.font = CustomFontMetrics.scaledSystemFont(ofSize: 11)
        subtitleLabel?.textColor = item?.subtitleColor ?? ThemeService.shared.theme.secondaryTextColor
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
        } else if (segue.identifier == StoryboardSegue.Main.showMarketSegue.rawValue) {
            (segue.destination as? HRPGShopViewController)?.shopIdentifier = Constants.MarketKey
        } else if (segue.identifier == StoryboardSegue.Main.showQuestShopSegue.rawValue) {
            (segue.destination as? HRPGShopViewController)?.shopIdentifier = Constants.QuestShopKey
        } else if (segue.identifier == StoryboardSegue.Main.showSeasonalShopSegue.rawValue) {
            (segue.destination as? HRPGShopViewController)?.shopIdentifier = Constants.SeasonalShopKey
        } else if (segue.identifier == StoryboardSegue.Main.showTimeTravelersSegue.rawValue) {
            (segue.destination as? HRPGShopViewController)?.shopIdentifier = Constants.TimeTravelersShopKey
        }
    }
}
