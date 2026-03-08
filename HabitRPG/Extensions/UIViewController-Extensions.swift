//
//  UIViewController-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.02.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//
import UIKit

extension UIViewController {
    func showFullscreen(retry: Bool = true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if var topController = UIApplication.topViewController() {
                if let tabBarController = topController.tabBarController {
                    topController = tabBarController
                }
                if (topController.isBeingDismissed || topController.isBeingPresented) && retry {
                    self.showFullscreen(retry: false)
                }
                self.modalTransitionStyle = .crossDissolve
                self.modalPresentationStyle = .overCurrentContext
                topController.present(self, animated: true) {
                }
            }
        }
    }
}
