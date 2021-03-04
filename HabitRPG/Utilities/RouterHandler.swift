//
//  RouterHandler.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.11.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import DeepLinkKit
import Habitica_Models

@objc
class RouterHandler: NSObject {
    
    @objc public static let shared = RouterHandler()

    private let router = DPLDeepLinkRouter()
    
    // swiftlint:disable:next function_body_length
    func register() {
        router.register("/groups/guild/:groupID") { link in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Social.groupTableViewController.instantiate()
            viewController.groupID = link?.routeParameters["groupID"] as? String
            self.push(viewController)
        }
        router.register("/groups/myGuilds") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.guildsOverviewViewController.instantiate())
        }
        router.register("/groups/discovery") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.guildsOverviewViewController.instantiate())
        }
        router.register("/challenges/:challengeID") { link in
            let viewController = StoryboardScene.Social.challengeDetailViewController.instantiate()
            let viewModel = ChallengeDetailViewModel(challengeID: (link?.routeParameters["challengeID"] as? String) ?? "")
            viewController.viewModel = viewModel
            self.push(viewController)
        }
        router.register("/challenges/myChallenges") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.guildsOverviewViewController.instantiate())
        }
        router.register("/challenges/findChallenges") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.guildsOverviewViewController.instantiate())
        }
        router.register("/tavern") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.tavernViewController.instantiate())
        }
        router.register("/party") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.partyViewController.instantiate())
        }
        router.register("/inventory/market") { _ in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Shop.initialScene.instantiate()
            viewController.shopIdentifier = Constants.MarketKey
            self.push(viewController)
        }
        router.register("/inventory/quests") { _ in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Shop.initialScene.instantiate()
            viewController.shopIdentifier = Constants.QuestShopKey
            self.push(viewController)
        }
        router.register("/inventory/seasonal") { _ in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Shop.initialScene.instantiate()
            viewController.shopIdentifier = Constants.SeasonalShopKey
            self.push(viewController)
        }
        router.register("/inventory/time") { _ in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Shop.initialScene.instantiate()
            viewController.shopIdentifier = Constants.TimeTravelersShopKey
            self.push(viewController)
        }
        router.register("/inventory/items") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.itemsViewController.instantiate())
        }
        router.register("/inventory/equipment") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.equipmentOverviewViewController.instantiate())
        }
        router.register("/inventory/stable") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.stableViewController.instantiate())
        }
        router.register("/inventory/stable/pets/:petType") { link in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.stableViewController.instantiate())
            let viewController = StoryboardScene.Main.petDetailViewController.instantiate()
            viewController.searchKey = (link?.routeParameters["petType"] as? String) ?? ""
            self.push(viewController)
        }
        router.register("/inventory/stable/mounts/:mountType") { link in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.stableViewController.instantiate())
            let viewController = StoryboardScene.Main.mountDetailViewController.instantiate()
            viewController.searchKey = (link?.routeParameters["mountType"] as? String) ?? ""
            self.push(viewController)
        }
        router.register("/static/new-stuff") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.newsViewController.instantiate())
        }
        router.register("/static/faq") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Support.mainSupportViewController.instantiate())
        }
        router.register("/static/about") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.aboutViewController.instantiate())
        }
        router.register("/static/faq/:index") { link in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Support.faqDetailViewController.instantiate()
            viewController.index = Int(string: (link?.routeParameters["index"] as? String) ?? "0") ?? 0
            self.push(viewController)
        }
        router.register("/user/settings.*") { _ in
            self.displayTab(index: 4)
            self.present(StoryboardScene.Settings.initialScene.instantiate())
        }
        router.register("/user/settings/subscription") { _ in
            self.displayTab(index: 4)
            self.present(StoryboardScene.Main.subscriptionNavController.instantiate())
        }
        router.register("/user/settings/gems") { _ in
            self.displayTab(index: 4)
            self.present(StoryboardScene.Main.purchaseGemNavController.instantiate())
        }
        router.register("/promo") { _ in
            self.displayTab(index: 4)
            self.present(StoryboardScene.Main.promotionInfoNavController.instantiate())
        }
        router.register("/private-messages") { _ in
            self.displayTab(index: 4)
            self.present(StoryboardScene.Social.inboxNavigationViewController.instantiate())
        }
        router.register("/user/notifications") { _ in
            self.displayTab(index: 4)
            self.present(StoryboardScene.Main.notificationsNavigationController.instantiate())
        }
        router.register("/user/stats") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.User.attributePointsViewController.instantiate())
        }
        router.register("/user/skills") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.User.spellsViewController.instantiate())
        }
        router.register("/user/achievements") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.User.achievementsCollectionViewController.instantiate())
        }
        router.register("/user/avatar") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.avatarOverviewViewController.instantiate())
        }
        router.register("/user/onboarding") { _ in
            self.present(StoryboardScene.Main.adventureGuideNavigationViewController.instantiate())
        }
        router.register("/profile/:userID") { link in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Social.userProfileViewController.instantiate()
            viewController.userID = link?.routeParameters["userID"] as? String
            self.push(viewController)
        }
        
        router.register("/user/tasks/:taskType") { link in
            let type = link?.routeParameters["taskType"] as? String ?? ""
            switch type {
            case "habit", "habits":
                self.displayTab(index: 0)
            case "daily", "dailies":
                self.displayTab(index: 1)
            case "todo", "todos":
                self.displayTab(index: 2)
            case "reward", "rewards":
                self.displayTab(index: 3)
            default:
                return
            }
        }
        
        router.register("/user/tasks/:taskType/add") { link in
            let navigationController = StoryboardScene.Tasks.taskFormViewController.instantiate()
            guard let formController = navigationController.topViewController as? TaskFormViewController else {
                return
            }
            formController.isCreating = true
            formController.taskType = TaskType(rawValue: link?.routeParameters["taskType"] as? String ?? "habit") ?? TaskType.habit
            self.present(navigationController)
        }
        router.register("/menu") { _ in
            self.displayTab(index: 4)
        }
    }
    
    @objc
    @discardableResult
    func handle(url: URL) -> Bool {
        return router.handle(url) { (_, _) in
        }
    }
    
    @objc
    @discardableResult
    func handle(urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return handle(url: url)
        }
        return false
    }
    
    func handleOrOpen(url: URL) {
        if !handle(url: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc
    func handle(userActivity: NSUserActivity) -> Bool {
        return router.handle(userActivity, withCompletion: { (_, _) in
        })
    }
    
    private func displayTab(index: Int) {
        if let presentedController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? MainTabBarController {
            presentedController.selectedIndex = index
        }
    }
    
    private var tabbarController: MainTabBarController? {
        var viewController = UIApplication.shared.keyWindow?.rootViewController
        while viewController != nil && viewController as? MainTabBarController == nil {
            viewController = viewController?.presentedViewController
        }
        return viewController as? MainTabBarController
    }
    
    private var selectedNavigationController: UINavigationController? {
        return tabbarController?.selectedViewController as? UINavigationController
    }
    
    private func present(_ viewController: UIViewController) {
        if let tabbarController = self.tabbarController {
            tabbarController.present(viewController, animated: true, completion: nil)
        }
    }
    
    private func push(_ viewController: UIViewController) {
        if let navigationController = selectedNavigationController {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    private func push(_ viewControllers: [UIViewController]) {
        if let navigationController = selectedNavigationController {
            var existingControllers = navigationController.viewControllers
            existingControllers.append(contentsOf: viewControllers)
            navigationController.setViewControllers(existingControllers, animated: true)
        }
    }
}
