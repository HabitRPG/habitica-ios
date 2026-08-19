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

class RouterHandler {
    public static let shared = RouterHandler()

    private var directRoutes = [String: (() async -> Void)]()
    private var parameterRoutes = [RegexRoute]()
    
    private func register(_ route: String, call: @escaping (() async -> Void)) {
        directRoutes[route] = call
    }
    
    private func register(_ route: Route, call: @escaping (() async -> Void)) {
        directRoutes[route.url] = call
    }
    
    private func register(_ route: String, call: @escaping (([String: String]) async -> Void)) {
        parameterRoutes.append(RegexRoute(route: route, call: call))
    }
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func register() {
        let configRepository = ConfigRepository.shared
        register("/groups/guild/:groupID") { link in
            await self.displayTab(index: 4)
            let viewController = await StoryboardScene.Social.groupTableViewController.asyncInstantiate()
            await MainActor.run {
                viewController.groupID = link["groupID"]
            }
            await self.push(viewController)
        }
        if !configRepository.bool(variable: .hideChallenges) {
            register("/challenges/:challengeID") { link in
                await self.displayTab(index: 4)
                let viewController = await StoryboardScene.Social.challengeDetailViewController.asyncInstantiate()
                await MainActor.run {
                    let viewModel = ChallengeDetailViewModel(challengeID: (link["challengeID"]) ?? "")
                    viewController.viewModel = viewModel
                }
                await self.push(viewController)
            }
            register("/challenges") {
                await self.displayTab(index: 4)
                await self.push(await StoryboardScene.Social.challengeTableViewController.asyncInstantiate())
            }
            register("/challenges/myChallenges") {
                await self.displayTab(index: 4)
                await self.push(await StoryboardScene.Social.challengeTableViewController.asyncInstantiate())
            }
            register("/challenges/findChallenges") {
                await self.displayTab(index: 4)
                await self.push(await StoryboardScene.Social.challengeTableViewController.asyncInstantiate())
            }
        }
        register("/party") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Social.partyViewController.asyncInstantiate())
        }
        register(.market) {
            await self.displayTab(index: 4)
            let viewController = await StoryboardScene.Shop.shopViewController.asyncInstantiate()
            await MainActor.run { viewController.shopIdentifier = Constants.MarketKey }
            await self.push(viewController)
        }
        register("/inventory/market/:section") { link in
            await self.displayTab(index: 4)
            let viewController = await StoryboardScene.Shop.shopViewController.asyncInstantiate()
            await MainActor.run {
                viewController.shopIdentifier = Constants.MarketKey
                viewController.openToSection = link["section"]
            }
            await self.push(viewController)
        }
        register(.questShop) {
            await self.displayTab(index: 4)
            let viewController = await StoryboardScene.Shop.shopViewController.asyncInstantiate()
            await MainActor.run { viewController.shopIdentifier = Constants.QuestShopKey }
            await self.push(viewController)
        }
        register(.seasonalShop) {
            await self.displayTab(index: 4)
            let viewController = await StoryboardScene.Shop.shopViewController.asyncInstantiate()
            await MainActor.run { viewController.shopIdentifier = Constants.SeasonalShopKey }
            await self.push(viewController)
        }
        register(.timeTravelers) {
            await self.displayTab(index: 4)
            let viewController = await StoryboardScene.Shop.shopViewController.asyncInstantiate()
            await MainActor.run { viewController.shopIdentifier = Constants.TimeTravelersShopKey }
            await self.push(viewController)
        }
        register(.customizationShop) {
            await self.displayTab(index: 4)
            let viewController = await StoryboardScene.Shop.shopViewController.asyncInstantiate()
            await MainActor.run { viewController.shopIdentifier = Constants.CustomizationShopKey }
            await self.push(viewController)
        }
        register("/inventory/items") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Main.itemsViewController.asyncInstantiate())
        }
        register("/inventory/equipment") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Main.equipmentOverviewViewController.asyncInstantiate())
        }
        register("/inventory/stable") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Stable.stableViewController.asyncInstantiate())
        }
        register("/inventory/customizations/:type/:group") { link in
            await self.displayTab(index: 4)
            let viewController = await StoryboardScene.Main.avatarDetailViewController.asyncInstantiate()
            await MainActor.run {
                viewController.customizationType = link["type"]
                viewController.customizationGroup = link["group"]
            }
            await self.push(viewController)
        }
        register("/inventory/customizations/:type") { link in
            await self.displayTab(index: 4)
            let viewController = await StoryboardScene.Main.avatarDetailViewController.asyncInstantiate()
            await MainActor.run {
                viewController.customizationType = link["type"]
            }
            await self.push(viewController)
        }
        register("/inventory/stable/pets/:petType") { link in
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Stable.stableViewController.asyncInstantiate())
            let viewController = await StoryboardScene.Stable.petDetailViewController.asyncInstantiate()
            await MainActor.run {
                viewController.searchKey = link["petType"] ?? ""
            }
            await self.push(viewController)
        }
        register("/inventory/stable/mounts/:mountType") { link in
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Stable.stableViewController.asyncInstantiate())
            let viewController = await StoryboardScene.Stable.mountDetailViewController.asyncInstantiate()
            await MainActor.run {
                viewController.searchKey = link["mountType"] ?? ""
            }
            await self.push(viewController)
        }
        register("/static/new-stuff") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Main.newsViewController.asyncInstantiate())
        }
        register("/static/support") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Support.mainSupportViewController.asyncInstantiate())
        }
        register("/static/report-bug") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Support.reportBugViewController.asyncInstantiate())
        }
        register("/static/faq") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Support.mainSupportViewController.asyncInstantiate())
            await self.push(await StoryboardScene.Support.faqViewController.asyncInstantiate())
        }
        register("/static/about") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Main.aboutViewController.asyncInstantiate())
        }
        register("/static/faq/:index") { link in
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Support.mainSupportViewController.asyncInstantiate())
            await self.push(await StoryboardScene.Support.faqViewController.asyncInstantiate())
            let viewController = await StoryboardScene.Support.faqDetailViewController.asyncInstantiate()
            await MainActor.run { viewController.index = Int(string: link["index"] ?? "0") ?? 0 }
            await self.push(viewController)
        }
        register("/static/community-guidelines") {
            let viewController = await StoryboardScene.Social.guidelinesNavigationViewController.asyncInstantiate()
            await self.present(viewController)
        }
        register("/user/settings.*") {
            await self.displayTab(index: 4)
            await self.present(await StoryboardScene.Settings.initialScene.asyncInstantiate())
        }
        register(.subscription) {
            await self.present(await StoryboardScene.Main.subscriptionNavController.asyncInstantiate())
        }
        register("/user/settings/subscription/gift/:username") { link in
            let viewController = await StoryboardScene.Main.giftSubscriptionViewController.asyncInstantiate()
            let navController = await MainActor.run {
                viewController.giftRecipientUsername = link["username"]
                return UINavigationController(rootViewController: viewController)
            }
            await self.present(navController)
        }
        register(.purchaseGems) {
            await self.present(await StoryboardScene.Main.purchaseGemNavController.asyncInstantiate())
        }
        register("/private-messages") {
            await self.displayTab(index: 4)
            await self.present(await StoryboardScene.Social.inboxNavigationViewController.asyncInstantiate())
        }
        register("/user/notifications") {
            await self.displayTab(index: 4)
            await self.present(await StoryboardScene.Main.notificationsNavigationController.asyncInstantiate())
        }
        register("/user/stats") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.User.attributePointsViewController.asyncInstantiate())
        }
        register("/user/skills") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.User.spellsViewController.asyncInstantiate())
        }
        register(.achievements) {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.User.achievementsCollectionViewController.asyncInstantiate())
        }
        register("/user/avatar") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Main.avatarOverviewViewController.asyncInstantiate())
        }
        register("/avatar/backgrounds") {
            await self.displayTab(index: 4)
            await self.push(await StoryboardScene.Main.avatarOverviewViewController.asyncInstantiate())
            let detailController = await StoryboardScene.Main.avatarDetailViewController.asyncInstantiate()
            await MainActor.run { detailController.customizationType = "background" }
            await self.push(detailController)
        }
        register("/user/onboarding") {
            await self.present(await StoryboardScene.Main.adventureGuideNavigationViewController.asyncInstantiate())
        }
        register(.promoInfo) {
            await self.present(await StoryboardScene.Main.promotionInfoNavController.asyncInstantiate())
        }
        register("/promo/web") {
            await self.present(await StoryboardScene.Main.promoWebNavController.asyncInstantiate())
        }
        register("/profile/:userID") { link in
            await self.displayTab(index: 4)
            let viewController = await StoryboardScene.Social.userProfileViewController.asyncInstantiate()
            await MainActor.run { viewController.userID = link["userID"] }
            await self.push(viewController)
        }
        register("/user/tasks/:taskType/add") { link in
            let type = link["taskType"] ?? ""
            switch type {
            case "habit", "habits":
                await self.displayTab(index: 0)
            case "daily", "dailies":
                await self.displayTab(index: 1)
            case "todo", "todos":
                await self.displayTab(index: 2)
            case "reward", "rewards":
                await self.displayTab(index: 3)
            default:
                return
            }
            let navigationController = await StoryboardScene.Tasks.taskFormViewController.asyncInstantiate()
            await MainActor.run {
                guard let formController = navigationController.topViewController as? TaskFormController else {
                    return
                }
                formController.taskType = TaskType(rawValue: link["taskType"] ?? "habit") ?? TaskType.habit
                formController.editedTask = nil
            }
            await self.present(navigationController)
        }
        register("/user/tasks/:taskType") { link in
            let type = link["taskType"] ?? ""
            switch type {
            case "habit", "habits":
                await self.displayTab(index: 0)
            case "daily", "dailies":
                await self.displayTab(index: 1)
            case "todo", "todos":
                await self.displayTab(index: 2)
            case "reward", "rewards":
                await self.displayTab(index: 3)
            default:
                return
            }
        }
        
        register("/menu") {
            await self.displayTab(index: 4)
        }
    }
    
    @discardableResult
    func handle(_ route: Route) -> Bool {
        return handle(urlString: route.url)
    }
    
    @discardableResult
    func handle(url: URL) -> Bool {
        if url.host == AuthenticatedCall.defaultConfiguration.host {
            return handle(urlString: url.relativePath)
        }
        let path = url.relativePath
        if let call = directRoutes[path] {
            Task.detached {
                await call()
            }
            return true
        }
        for route in parameterRoutes {
            if let match = route.matches(path) {
                Task.detached {
                    await route.call(match.parameters)
                }
                return true
            }
        }
        return false
    }
    
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
    
    func handleOrOpen(urlString: String) {
        if let url = URL(string: urlString) {
            handleOrOpen(url: url)
        }
    }
    
    func handle(userActivity: NSUserActivity) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            return handle(url: url)
        }
        return false
    }
    
    private func displayTab(index: Int) async {
        if let tabbarController = await MainActor.run(body: { self.tabbarController }) {
            if await tabbarController.presentedViewController != nil {
                await tabbarController.presentedViewController?.dismiss(animated: true)
            }
            await MainActor.run {
                tabbarController.selectedIndex = index
            }
        } else {
            await MainActor.run {
                loadingController?.loadingFinishedAction = {[weak self] in
                    await MainActor.run {
                        self?.tabbarController?.selectedIndex = index
                    }
                }
            }
        }
    }
    
    private weak var cachedTabBarController: MainTabBarController?
    
    private var tabbarController: MainTabBarController? {
        if cachedTabBarController == nil {
            cachedTabBarController = UIWindow.findViewController()
        }
        return cachedTabBarController
    }
    
    private func getSelectedNavigationController() async -> UINavigationController? {
        return await MainActor.run {
            tabbarController?.selectedViewController as? UINavigationController
        }
    }
    
    private var loadingController: LoadingViewController? {
        return UIWindow.findViewController()
    }
    
    private func present(_ viewController: UIViewController) async {
        if let tabbarController = await MainActor.run(body: { self.tabbarController }) {
            var presenter: UIViewController = tabbarController
            while presenter.isPresenting, let presented = await presenter.presentedViewController {
                presenter = presented
            }
            if await presenter.isBeingDismissed {
                await self.present(viewController)
                return
            }
            await presenter.present(viewController, animated: true, completion: nil)
        } else {
            await MainActor.run {
                loadingController?.loadingFinishedAction = {[weak self] in
                    await MainActor.run {
                        self?.tabbarController?.present(viewController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func push(_ viewController: UIViewController) async {
        if let navigationController = await getSelectedNavigationController() {
            await navigationController.pushViewController(viewController, animated: true)
        } else {
            await MainActor.run {
                loadingController?.loadingFinishedAction = {[weak self] in
                    await self?.getSelectedNavigationController()?.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
    private func asyncPop() async {
        if let navigationController = await getSelectedNavigationController() {
            await navigationController.popViewController(animated: true)
        }
    }
    
    func pop() {
        Task.detached {
            await self.asyncPop()
        }
    }
    
    private func push(_ viewControllers: [UIViewController]) async {
        if let navigationController = await getSelectedNavigationController() {
            await MainActor.run {
                var existingControllers = navigationController.viewControllers
                existingControllers.append(contentsOf: viewControllers)
                navigationController.setViewControllers(existingControllers, animated: true)
            }
        }
    }
}

extension SceneType {
    func asyncInstantiate() async -> T {
        return await MainActor.run {
            instantiate()
        }
    }
}

extension InitialSceneType {
    func asyncInstantiate() async -> T {
        return await MainActor.run {
            instantiate()
        }
    }
}
