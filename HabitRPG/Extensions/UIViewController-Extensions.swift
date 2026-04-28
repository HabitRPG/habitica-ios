//
//  UIViewController-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.02.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//
import UIKit

extension UIViewController {
    func showFullscreen(retry: Bool = true, delay: CGFloat = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if var topController = UIApplication.topViewController() {
                if let tabBarController = topController.tabBarController {
                    topController = tabBarController
                }
                while topController.presentedViewController != nil {
                    topController = topController.presentedViewController ?? topController
                }
                if (topController.isBeingDismissed || topController.isBeingPresented) && retry {
                    self.showFullscreen(retry: false)
                    return
                }
                self.modalTransitionStyle = .crossDissolve
                self.modalPresentationStyle = .overFullScreen
                topController.present(self, animated: true) {
                }
            }
        }
    }
}
