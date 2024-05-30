//
//  SceneDelegate.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.11.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import UIKit
import Firebase
#if !targetEnvironment(macCatalyst)
import FirebaseAnalytics
#endif
import WidgetKit
import ReactiveSwift

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?
    var savedShortcutItem: UIApplicationShortcutItem?

    private let configRepository = ConfigRepository.shared
    private let contentRepository = ContentRepository()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = StoryboardScene.Intro.initialScene.instantiate()
        window?.makeKeyAndVisible()
        
        connectionOptions.urlContexts.forEach { context in
            RouterHandler.shared.handle(url: context.url)
        }
        
        if let shortcutItem = connectionOptions.shortcutItem {
            savedShortcutItem = shortcutItem
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        let handled = handleShortcutItem(shortcutItem: shortcutItem)
        return handled
    }
    
    private func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        if shortcutItem.type == "com.habitrpg.habitica.ios.newhabit" {
            return RouterHandler.shared.handle(urlString: "/user/tasks/habit/add")
        } else if shortcutItem.type == "com.habitrpg.habitica.ios.newdaily" {
            return RouterHandler.shared.handle(urlString: "/user/tasks/daily/add")
        } else if shortcutItem.type == "com.habitrpg.habitica.ios.newtodo" {
            return RouterHandler.shared.handle(urlString: "/user/tasks/todo/add")
        }
        return false
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach { context in
            RouterHandler.shared.handle(url: context.url)
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        setupUserManager()
        setupTheme()
        cleanAndRefresh()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        if let shortcutItem = savedShortcutItem {
            _ = handleShortcutItem(shortcutItem: shortcutItem)
            savedShortcutItem = nil
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        reloadWidgetData()
    }
    
    @objc
    func setupUserManager() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UserManager.shared.beginListening()
        }
    }
    
    @objc
    func setupTheme() {
        ThemeService.shared.updateDarkMode()
        let defaults = UserDefaults.standard
        let themeName = ThemeName(rawValue: defaults.string(forKey: "theme") ?? "") ?? ThemeName.defaultTheme
        #if !targetEnvironment(macCatalyst)
        Analytics.setUserProperty(themeName.rawValue, forName: "theme")
        #endif
    }
    
    private func cleanAndRefresh() {
        retrieveContent()
        configRepository.fetchremoteConfig()
    }
    
    private func retrieveContent() {
        contentRepository.getFAQEntries()
            .take(first: 1)
            .flatMap(.latest) {[weak self] (entries) in
                return self?.contentRepository.retrieveContent(force: entries.value.isEmpty) ?? Signal.empty
            }
            .start()
        contentRepository.retrieveWorldState(force: true).observeCompleted {}
    }
    
    func reloadWidgetData() {
        #if arch(arm64) || arch(i386) || arch(x86_64)
        WidgetCenter.shared.reloadTimelines(ofKind: "DailiesCountWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "StatsWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "TaskListWidget")
        
        WidgetCenter.shared.getCurrentConfigurations { result in
            switch result {
            case let .success(info):
                #if !targetEnvironment(macCatalyst)
                Analytics.setUserProperty(String(info.count), forName: "widgetCount")
                #endif
            case let .failure(error):
                logger.log(error)
            }
        }
        #endif
    }
}
