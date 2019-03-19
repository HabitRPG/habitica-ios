//
//  RouterHandler.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.11.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import DeepLinkKit

@objc
class RouterHandler: NSObject {
    
    @objc public static let shared = RouterHandler()

    private let router = DPLDeepLinkRouter()
    
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
        router.register("/static/faq") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Main.faqOverviewViewController.instantiate())
        }
        router.register("user/settings.*") { _ in
            self.displayTab(index: 4)
            self.push(StoryboardScene.Settings.initialScene.instantiate())
        }
        router.register("profile/:userID") { link in
            self.displayTab(index: 4)
            let viewController = StoryboardScene.Social.userProfileViewController.instantiate()
            viewController.userID = link?.routeParameters["userID"] as? String
            self.push(viewController)
        }
    }
    
    @objc
    func handle(url: URL) -> Bool {
        return router.handle(url) { (_, _) in
        }
    }
    
    @objc
    func handle(urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return handle(url: url)
        }
        return false
    }
    
    func handleOrOpen(url: URL) {
        if !handle(url: url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
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
        return UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? MainTabBarController
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
