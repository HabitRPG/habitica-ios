//
//  MainVCSelectionSegue.swift
//  Habitica
//
//  Created by Phillip Thelen on 04.01.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import UIKit

class MainVCSelectionSegue: UIStoryboardSegue {
    
    override var destination: UIViewController {
        if #available(iOS 14.0, *), ConfigRepository.shared.enableIPadUI() {
            let viewController = StoryboardScene.Main.mainSplitViewController.instantiate()
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .crossDissolve
            return viewController
        } else {
            let viewController = StoryboardScene.Main.mainTabBarController.instantiate()
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .crossDissolve
            return viewController
        }
    }
}
