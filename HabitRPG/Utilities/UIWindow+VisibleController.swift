//
//  UIWindow+VisibleController.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit

extension UIWindow {
    func visibleController() -> UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(rootViewController)
    }
    
    static func getVisibleViewControllerFrom(_ viewController: UIViewController?) -> UIViewController? {
        if let navController = viewController as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(navController.visibleViewController)
        } else if let tabController = viewController as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tabController.selectedViewController)
        } else {
            if viewController?.presentedViewController != nil {
                return UIWindow.getVisibleViewControllerFrom(viewController?.presentedViewController)
            } else {
                return viewController
            }
        }
    }
}
