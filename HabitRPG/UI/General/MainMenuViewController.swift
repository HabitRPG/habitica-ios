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
    var accessibilityLabel: String?
    var segue: String
    var cellName = "Cell"
    var showIndicator = false
    var isHidden = false
    
    init(title: String, subtitle: String? = nil, accessibilityLabel: String? = nil, segue: String, cellName: String = "Cell", showIndicator: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.accessibilityLabel = accessibilityLabel
        self.segue = segue
        self.cellName = cellName
        self.showIndicator = showIndicator
    }
}

struct MenuSection {
    let title: String?
    let iconAsset: ImageAsset?
    var items: [MenuItem]
    
    var visibleItems: [MenuItem] {
        return items.filter({ (item) -> Bool in return !item.isHidden })
    }
}

class MainMenuViewController: BaseTableViewController {
    
    private var navbarColor = ThemeService.shared.theme.navbarHiddenColor {
        didSet {
            topHeaderCoordinator.navbarVisibleColor = navbarColor
            navbarView?.backgroundColor = navbarColor
        }
    }
    private var worldBossTintColor: UIColor?
    private var navbarView = MenuNavigationBarView.loadFromNib(nibName: "MenuNavigationBarView") as? MenuNavigationBarView
    private var worldBossHeaderView: WorldBossMenuHeader?
    
    private var userRepository = UserRepository()
    private let configRepository = ConfigRepository()
    
    private var disposable = ScopedDisposable(CompositeDisposable())
    
    private var menuSections = [MenuSection]()
    
    private var user: UserProtocol? {
        didSet {
            if let user = self.user {
                navbarView?.configure(user: user)
            }
            if user?.stats?.habitClass == "wizard" || user?.stats?.habitClass == "healer" {
                menuSections[0].items[0].title = L10n.Menu.castSpells
            } else {
                menuSections[0].items[0].title = L10n.Menu.useSkills
            }
            menuSections[0].items[0].isHidden = user?.canUseSkills == false
            menuSections[0].items[1].isHidden = user?.needsToChooseClass == true
            menuSections[3].items[0].showIndicator = user?.flags?.hasNewStuff == true
            
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideNavBar = true
        topHeaderCoordinator?.alternativeHeader = navbarView
        topHeaderCoordinator?.navbarVisibleColor = navbarColor
        topHeaderCoordinator?.followScrollView = false
        navbarView?.backgroundColor = navbarColor
        
        navbarView?.messagesAction = {[weak self] in
            self?.perform(segue: StoryboardSegue.Main.inboxSegue)
        }
        navbarView?.settingsAction = {[weak self] in
            self?.perform(segue: StoryboardSegue.Main.settingsSegue)
        }
        navbarView?.notificationsAction = {[weak self] in
            self?.perform(segue: StoryboardSegue.Main.notificationsSegue)
        }
        navbarView?.notificationsButton.isHidden = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
        
        setupMenu()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start())
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        navbarColor = theme.navbarHiddenColor
        tableView.reloadData()
    }
    
    private func setupMenu() {
        var stableName = configRepository.string(variable: .stableName) ?? ""
        if stableName.isEmpty != false {
            stableName = L10n.Titles.stable
        }
        menuSections = [
            MenuSection(title: nil, iconAsset: nil, items: [
                MenuItem(title: L10n.Menu.castSpells, segue: StoryboardSegue.Main.spellsSegue.rawValue),
                //MenuItem(title: L10n.Menu.selectClass, segue: StoryboardSegue.Main.selectClassSegue.rawValue),
                MenuItem(title: L10n.Titles.stats, segue: StoryboardSegue.Main.statsSegue.rawValue)
                ]),
            MenuSection(title: L10n.Menu.social, iconAsset: Asset.iconSocial, items: [
                MenuItem(title: L10n.Titles.tavern, segue: StoryboardSegue.Main.tavernSegue.rawValue),
                MenuItem(title: L10n.Titles.party, segue: StoryboardSegue.Main.partySegue.rawValue),
                MenuItem(title: L10n.Titles.guilds, segue: StoryboardSegue.Main.guildsSegue.rawValue),
                MenuItem(title: L10n.Titles.challenges, segue: StoryboardSegue.Main.challengesSegue.rawValue)
                ]),
            MenuSection(title: L10n.Menu.inventory, iconAsset: Asset.iconInventory, items: [
                MenuItem(title: L10n.Titles.shops, segue: StoryboardSegue.Main.shopsSegue.rawValue),
                MenuItem(title: L10n.Menu.customizeAvatar, segue: StoryboardSegue.Main.customizationSegue.rawValue),
                MenuItem(title: L10n.Titles.equipment, segue: StoryboardSegue.Main.equipmentSegue.rawValue),
                MenuItem(title: L10n.Titles.items, segue: StoryboardSegue.Main.itemSegue.rawValue),
                MenuItem(title: stableName, segue: StoryboardSegue.Main.stableSegue.rawValue),
                MenuItem(title: L10n.Menu.gemsSubscriptions, segue: StoryboardSegue.Main.gemSubscriptionSegue.rawValue)
                ]),
            MenuSection(title: L10n.Titles.about, iconAsset: Asset.iconHelp, items: [
                MenuItem(title: L10n.Titles.news, segue: StoryboardSegue.Main.newsSegue.rawValue),
                MenuItem(title: L10n.Menu.helpFaq, segue: StoryboardSegue.Main.faqSegue.rawValue),
                MenuItem(title: L10n.Titles.about, segue: StoryboardSegue.Main.aboutSegue.rawValue)
                ])
        ]
    }
    
    @objc
    private func refresh() {
        disposable.inner.add(userRepository.retrieveUser().observeCompleted {
            self.refreshControl?.endRefreshing()
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return menuSections.count
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
        
        let labelFrame = CGRect(x: 30, y: 14, width: 290, height: 17)
        let iconFrame = CGRect(x: 9, y: 14, width: 16, height: 16)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 37.5))
        let label = UILabel(frame: labelFrame)
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 14)
        label.textColor = ThemeService.shared.theme.primaryTextColor
        view.addSubview(label)
        let iconView = UIImageView(frame: iconFrame)
        iconView.tintColor = ThemeService.shared.theme.primaryTextColor
        view.addSubview(iconView)
        
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        if let iconAsset = menuSections[section].iconAsset {
            iconView.image = UIImage(asset: iconAsset)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: menuSections[indexPath.section].visibleItems[indexPath.item].segue, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = visibleItemAt(indexPath: indexPath)
        let cell = tableView .dequeueReusableCell(withIdentifier: item?.cellName ?? "", for: indexPath)
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
        label?.backgroundColor = cell.backgroundColor
        
        let indicatorView = cell.viewWithTag(2)
        indicatorView?.isHidden = item?.showIndicator == false
        indicatorView?.layer.cornerRadius = (indicatorView?.frame.size.height ?? 0) / 2
        indicatorView?.backgroundColor = ThemeService.shared.theme.backgroundTintColor
        
        let subtitleLabel = cell.viewWithTag(3) as? UILabel
        subtitleLabel?.text = item?.subtitle
        subtitleLabel?.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
        subtitleLabel?.textColor = UIColor.orange50()
        return cell
    }
    
    private func sectionAt(index: Int) -> MenuSection? {
        if menuSections.count <= index {
            return nil
        }
        return menuSections[index]
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
}
