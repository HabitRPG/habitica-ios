//
//  UIApplication-Extensions.swift
//  Habitica
//
//  Created by Phillip on 29.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftUI
import StoreKit

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.findKeyWindow()?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            if nav.visibleViewController is HostingViewController {
                return nav
            }
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if tab.presentedViewController == nil {
                return tab
            }
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    func findKeyWindow() -> UIWindow? {
        let scenes = connectedScenes.map { $0 as? UIWindowScene }.filter { $0 != nil }
        let windows = (foregroundActiveScene ?? scenes.first ?? nil)?.windows
        return windows?.first(where: { $0.isKeyWindow }) ?? windows?.first
    }
    
    var foregroundActiveScene: UIWindowScene? {
        connectedScenes.lazy
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
    
    class func requestReview() {
        let defaults = UserDefaults.standard
        guard canRequestReview(defaults: defaults, config: ConfigRepository.shared) else {
            return
        }
        
        #if os(macOS)
            SKStoreReviewController.requestReview()
        #else
        guard let scene = UIApplication.shared.foregroundActiveScene else {
            return
        }
            SKStoreReviewController.requestReview(in: scene)
        #endif
        recordReviewRequest(defaults: defaults)
    }
    
    static func canRequestReview(defaults: UserDefaults, config: ConfigRepository) -> Bool {
        let checkinCount = defaults.integer(forKey: "loginIncentives")
        if checkinCount < 10 {
            return false
        }
        
        var initialCheckinCount = defaults.integer(forKey: "initialLoginIncentives")
        if initialCheckinCount == 0 {
            initialCheckinCount = checkinCount
            defaults.set(checkinCount, forKey: "initialLoginIncentives")
        }
        
        if checkinCount - initialCheckinCount > config.value(for: .reviewMaxCheckinsSinceFirstRequest) {
            return false
        }
        if defaults.integer(forKey: "reviewRequestCount") >= config.value(for: .reviewMaxRequests) {
            return false
        }
        if let lastCheckin = defaults.object(forKey: "lastReviewCheckin") as? Int,
           checkinCount - lastCheckin < config.value(for: .reviewMinCheckinsBetweenRequests) {
            return false
        }
        return true
    }
    
    static func recordReviewRequest(defaults: UserDefaults) {
        // iOS doesn't say whether the prompt was shown, so like Android this counts requests
        defaults.set(defaults.integer(forKey: "reviewRequestCount") + 1, forKey: "reviewRequestCount")
        defaults.set(defaults.integer(forKey: "loginIncentives"), forKey: "lastReviewCheckin")
    }
}

extension EnvironmentValues {
    @Entry var safeAreaInsets: EdgeInsets =
        UIApplication.shared.findKeyWindow()?.safeAreaInsets.edgeInsets ?? EdgeInsets()
}

extension UIEdgeInsets {
    var edgeInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
