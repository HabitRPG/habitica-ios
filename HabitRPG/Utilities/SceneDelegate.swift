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

    private let configRepository = ConfigRepository.shared
    private let contentRepository = ContentRepository()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = StoryboardScene.Intro.initialScene.instantiate()
        window?.makeKeyAndVisible()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        setupUserManager()
        setupTheme()
        cleanAndRefresh()
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
        let defaults = UserDefaults.standard
        let lastContentFetch = defaults.object(forKey: "lastContentFetch") as? NSDate
        let lastContentFetchVersion = defaults.object(forKey: "lastContentFetchVersion") as? String
        let currentBuildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        if lastContentFetch == nil || (lastContentFetch?.timeIntervalSinceNow ?? 0) < -3600 || lastContentFetchVersion != currentBuildNumber {
            contentRepository.getFAQEntries()
                .take(first: 1)
                .flatMap(.latest) {[weak self] (entries) in
                    return self?.contentRepository.retrieveContent(force: entries.value.isEmpty) ?? Signal.empty
                }
                .on(completed: {
                    defaults.setValue(Date(), forKey: "lastContentFetch")
                    defaults.setValue(currentBuildNumber, forKey: "lastContentFetchVersion")
                })
                .start()
        }
        
        let lastWorldStateFetch = defaults.object(forKey: "lastWorldStateFetch") as? NSDate
        if lastWorldStateFetch == nil || (lastWorldStateFetch?.timeIntervalSinceNow ?? 0) < -1800 {
            contentRepository.retrieveWorldState().observeCompleted {
                defaults.setValue(Date(), forKey: "lastWorldStateFetch")
            }
        }
    }
    
    func reloadWidgetData() {
        #if arch(arm64) || arch(i386) || arch(x86_64)
        if #available(iOS 14.0, *) {
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
        }
        #endif
    }
}
