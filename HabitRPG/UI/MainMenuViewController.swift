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
    var accessibilityLabel: String?
    var segue: String
    var cellName = "Cell"
    var showIndicator = false
    
    init(title: String, accessibilityLabel: String? = nil, segue: String, cellName: String = "Cell", showIndicator: Bool = false) {
        self.title = title
        self.accessibilityLabel = accessibilityLabel
        self.segue = segue
        self.cellName = cellName
        self.showIndicator = showIndicator
    }
}

struct MenuSection {
    let title: String?
    let iconAsset: ImageAsset?
    let items: [MenuItem]
}

class MainMenuViewController: HRPGBaseViewController {
    
    private var navbarColor = UIColor.purple300() {
        didSet {
            topHeaderCoordinator.navbarVisibleColor = navbarColor
            navbarView?.backgroundColor = navbarColor
        }
    }
    private var worldBossTintColor: UIColor?
    private var navbarView = MenuNavigationBarView.loadFromNib(nibName: "MenuNavigationBarView") as? MenuNavigationBarView
    private var worldBossHeaderView: WorldBossMenuHeader?
    
    private var userRepository = UserRepository()
    
    private var disposable = ScopedDisposable(CompositeDisposable())
    
    private var menuSections = [MenuSection]()
    
    private var user: UserProtocol? {
        didSet {
            if let user = self.user {
                navbarView?.configure(user: user)
            }
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
        
        navbarView?.messagesAction = {
            self.perform(segue: StoryboardSegue.Main.inboxSegue)
        }
        navbarView?.settingsAction = {
            self.perform(segue: StoryboardSegue.Main.settingsSegue)
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.purple300()
        self.refreshControl = refreshControl
        
        setupMenu()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start())
        
    }
    
    private func setupMenu() {
        menuSections = [
            MenuSection(title: nil, iconAsset: nil, items: [
                MenuItem(title: L10n.Menu.castSpells, segue: StoryboardSegue.Main.spellsSegue.rawValue),
                MenuItem(title: L10n.Menu.stats, segue: StoryboardSegue.Main.statsSegue.rawValue)
                ]),
            MenuSection(title: L10n.Menu.social, iconAsset: Asset.iconSocial, items: [
                MenuItem(title: L10n.Menu.tavern, segue: StoryboardSegue.Main.tavernSegue.rawValue),
                MenuItem(title: L10n.Menu.party, segue: StoryboardSegue.Main.partySegue.rawValue),
                MenuItem(title: L10n.Menu.guilds, segue: StoryboardSegue.Main.guildsSegue.rawValue),
                MenuItem(title: L10n.Menu.challenges, segue: StoryboardSegue.Main.challengesSegue.rawValue)
                ]),
            MenuSection(title: L10n.Menu.inventory, iconAsset: Asset.iconInventory, items: [
                MenuItem(title: L10n.Menu.shops, segue: StoryboardSegue.Main.shopsSegue.rawValue),
                MenuItem(title: L10n.Menu.customizeAvatar, segue: StoryboardSegue.Main.customizationSegue.rawValue),
                MenuItem(title: L10n.Menu.equipment, segue: StoryboardSegue.Main.equipmentSegue.rawValue),
                MenuItem(title: L10n.Menu.items, segue: StoryboardSegue.Main.itemSegue.rawValue),
                MenuItem(title: L10n.Menu.pets, segue: StoryboardSegue.Main.petSegue.rawValue),
                MenuItem(title: L10n.Menu.mounts, segue: StoryboardSegue.Main.mountSegue.rawValue),
                MenuItem(title: L10n.Menu.gemsSubscriptions, segue: StoryboardSegue.Main.gemSubscriptionSegue.rawValue)
                ]),
            MenuSection(title: L10n.Menu.about, iconAsset: Asset.iconHelp, items: [
                MenuItem(title: L10n.Menu.news, segue: StoryboardSegue.Main.newsSegue.rawValue),
                MenuItem(title: L10n.Menu.helpFaq, segue: StoryboardSegue.Main.helpSegue.rawValue),
                MenuItem(title: L10n.Menu.about, segue: StoryboardSegue.Main.aboutSegue.rawValue)
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
        return menuSections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menuSections[section].title
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
        label.textColor = .darkGray
        view.addSubview(label)
        let iconView = UIImageView(frame: iconFrame)
        iconView.tintColor = .darkGray
        view.addSubview(iconView)
        
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        if let iconAsset = menuSections[section].iconAsset {
            iconView.image = UIImage(asset: iconAsset)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: menuSections[indexPath.section].items[indexPath.item].segue, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = menuSections[indexPath.section].items[indexPath.item]
        let cell = tableView .dequeueReusableCell(withIdentifier: item.cellName, for: indexPath)
        
        if item.accessibilityLabel?.isEmpty != true {
            cell.accessibilityLabel = accessibilityLabel
        } else {
            cell.accessibilityLabel = title
        }
        
        let label = cell.viewWithTag(1) as? UILabel
        label?.text = item.title
        label?.font = CustomFontMetrics.scaledSystemFont(ofSize: 17)
        
        let indicatorView = cell.viewWithTag(2)
        indicatorView?.isHidden = !item.showIndicator
        indicatorView?.layer.cornerRadius = (indicatorView?.frame.size.height ?? 0) / 2
        return cell
    }
}
