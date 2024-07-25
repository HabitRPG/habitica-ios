//
//  UIApplication-Extensions.swift
//  Habitica
//
//  Created by Phillip on 29.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import StoreKit

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.findKeyWindow()?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
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
        return windows.first(where: { $0.isKeyWindow }) ?? windows.first
    }
    
    var foregroundActiveScene: UIWindowScene? {
        connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
    
    class func requestReview() {
        let configRepository = ConfigRepository.shared
        if configRepository.bool(variable: .enableReviewRequest) {
            
            let defaults = UserDefaults.standard
            
            let checkinCount = defaults.integer(forKey: "loginIncentives")
            if checkinCount < 10 {
                return
            }
            
            let initialCheckinCount = defaults.integer(forKey: "initialLoginIncentives")
            if initialCheckinCount == 0 {
                defaults.set(checkinCount, forKey: "initialLoginIncentives")
            }
            
            if (checkinCount - initialCheckinCount) > 75 {
                return
            }
            
            #if os(macOS)
                SKStoreReviewController.requestReview()
            #else
                guard let scene = UIApplication.shared.foregroundActiveScene else { return }
                SKStoreReviewController.requestReview(in: scene)
            #endif
        }
    }
}
