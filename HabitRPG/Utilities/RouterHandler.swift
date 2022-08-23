//
//  RouterHandler.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.11.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import Habitica_API_Client

@objc
class RouterHandler: NSObject {
    
    @objc public static let shared = RouterHandler()

    private var directRoutes = [String:(() -> Void)]()
    private var parameterRoutes = [String:(([String: String]) -> Void)]()
    
    private func register(_ route: String, call: @escaping (() -> Void)) {
        directRoutes[route] = call
    }
    
    private func register(_ route: String, call: @escaping (([String: String]) -> Void)) {
        parameterRoutes[route] = call
    }
    
    // swiftlint:disable:next function_body_length
    func register() {
        register("/groups/guild/:groupID") { link in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Social.groupTableViewController.instantiate()
            viewController.groupID = link["groupID"]
            self.push(viewController)
        }
        register("/groups/myGuilds") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.guildsOverviewViewController.instantiate())
        }
        register("/groups/discovery") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.guildsOverviewViewController.instantiate())
        }
        register("/challenges/:challengeID") { link in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Social.challengeDetailViewController.instantiate()
            let viewModel = ChallengeDetailViewModel(challengeID: (link["challengeID"]) ?? "")
            viewController.viewModel = viewModel
            self.push(viewController)
        }
        register("/challenges/myChallenges") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.guildsOverviewViewController.instantiate())
        }
        register("/challenges/findChallenges") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.guildsOverviewViewController.instantiate())
        }
        register("/tavern") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.tavernViewController.instantiate())
        }
        register("/party") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Social.partyViewController.instantiate())
        }
        register("/inventory/market") {
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Shop.initialScene.instantiate()
            viewController.shopIdentifier = Constants.MarketKey
            self.push(viewController)
        }
        register("/inventory/quests") {
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Shop.initialScene.instantiate()
            viewController.shopIdentifier = Constants.QuestShopKey
            self.push(viewController)
        }
        register("/inventory/seasonal") {
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Shop.initialScene.instantiate()
            viewController.shopIdentifier = Constants.SeasonalShopKey
            self.push(viewController)
        }
        register("/inventory/time") {
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Shop.initialScene.instantiate()
            viewController.shopIdentifier = Constants.TimeTravelersShopKey
            self.push(viewController)
        }
        register("/inventory/items") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.itemsViewController.instantiate())
        }
        register("/inventory/equipment") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.equipmentOverviewViewController.instantiate())
        }
        register("/inventory/stable") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.stableViewController.instantiate())
        }
        register("/inventory/stable/pets/:petType") { link in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.stableViewController.instantiate())
            let viewController = StoryboardScene.Main.petDetailViewController.instantiate()
            viewController.searchKey = link["petType"] ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.push(viewController)
            }
        }
        register("/inventory/stable/mounts/:mountType") { link in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.stableViewController.instantiate())
            let viewController = StoryboardScene.Main.mountDetailViewController.instantiate()
            viewController.searchKey = link["mountType"] ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.push(viewController)
            }
        }
        register("/static/new-stuff") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.newsViewController.instantiate())
        }
        register("/static/faq") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Support.mainSupportViewController.instantiate())
        }
        register("/static/about") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.aboutViewController.instantiate())
        }
        register("/static/faq/:index") { link in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Support.faqDetailViewController.instantiate()
            viewController.index = Int(string: link["index"] ?? "0") ?? 0
            self.push(viewController)
        }
        register("/user/settings.*") {
            self.displayTab(index: 4)
            self.present(StoryboardScene.Settings.initialScene.instantiate())
        }
        register("/user/settings/subscription") {
            self.displayTab(index: 4)
            self.present(StoryboardScene.Main.subscriptionNavController.instantiate())
        }
        register("/user/settings/gems") {
            self.displayTab(index: 4)
            self.present(StoryboardScene.Main.purchaseGemNavController.instantiate())
        }
        register("/promo") {
            self.displayTab(index: 4)
            self.present(StoryboardScene.Main.promotionInfoNavController.instantiate())
        }
        register("/private-messages") {
            self.displayTab(index: 4)
            self.present(StoryboardScene.Social.inboxNavigationViewController.instantiate())
        }
        register("/user/notifications") {
            self.displayTab(index: 4)
            self.present(StoryboardScene.Main.notificationsNavigationController.instantiate())
        }
        register("/user/stats") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.User.attributePointsViewController.instantiate())
        }
        register("/user/skills") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.User.spellsViewController.instantiate())
        }
        register("/user/achievements") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.User.achievementsCollectionViewController.instantiate())
        }
        register("/user/avatar") {
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.avatarOverviewViewController.instantiate())
        }
        register("/user/onboarding") {
            self.present(StoryboardScene.Main.adventureGuideNavigationViewController.instantiate())
        }
        register("/promo/info") {
            self.present(StoryboardScene.Main.promotionInfoNavController.instantiate())
        }
        register("/promo/web") {
            self.present(StoryboardScene.Main.promoWebNavController.instantiate())
        }
        register("/profile/:userID") { link in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Social.userProfileViewController.instantiate()
            viewController.userID = link["userID"]
            self.push(viewController)
        }
        
        register("/user/tasks/:taskType") { link in
            let type = link["taskType"] ?? ""
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
        
        register("/user/tasks/:taskType/add") { link in
            let type = link["taskType"] ?? ""
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
            let navigationController = StoryboardScene.Tasks.taskFormViewController.instantiate()
            guard let formController = navigationController.topViewController as? TaskFormController else {
                return
            }
            formController.taskType = TaskType(rawValue: link["taskType"] ?? "habit") ?? TaskType.habit
            formController.editedTask = nil
            self.present(navigationController)
        }
        register("/menu") {
            self.displayTab(index: 4)
        }
    }
    
    @objc
    @discardableResult
    func handle(url: URL) -> Bool {
        if url.host == AuthenticatedCall.defaultConfiguration.host {
            return handle(urlString: url.relativePath)
        }
        let path = url.relativePath
        if let call = directRoutes[path] {
            call()
            return true
        }
        return false
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
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            return handle(url: url)
        }
        return false
    }
    
    private func displayTab(index: Int) {
        if let tabbarController = self.tabbarController {
            tabbarController.selectedIndex = index
        } else {
            loadingController?.loadingFinishedAction = {[weak self] in
                self?.tabbarController?.selectedIndex = index
            }
        }
    }
    
    private var tabbarController: MainTabBarController? {
        var viewController = UIApplication.shared.findKeyWindow()?.rootViewController
        while viewController != nil && viewController as? MainTabBarController == nil {
            viewController = viewController?.presentedViewController
        }
        return viewController as? MainTabBarController
    }
    
    private var selectedNavigationController: UINavigationController? {
        return tabbarController?.selectedViewController as? UINavigationController
    }
    
    private var loadingController: LoadingViewController? {
        return UIApplication.shared.findKeyWindow()?.rootViewController as? LoadingViewController
    }
    
    private func present(_ viewController: UIViewController) {
        if let tabbarController = self.tabbarController {
            tabbarController.present(viewController, animated: true, completion: nil)
        } else {
            loadingController?.loadingFinishedAction = {[weak self] in
                self?.tabbarController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    private func push(_ viewController: UIViewController) {
        if let navigationController = selectedNavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            loadingController?.loadingFinishedAction = {[weak self] in
                self?.selectedNavigationController?.pushViewController(viewController, animated: true)
            }
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
