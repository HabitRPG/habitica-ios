//
//  ThemedNavigationController.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class ThemedNavigationController: UINavigationController, Themeable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        navigationBar.tintColor = theme.tintColor
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: theme.primaryTextColor
        ]
        navigationBar.backgroundColor = theme.contentBackgroundColor
        navigationBar.barTintColor = theme.contentBackgroundColor
    }
}
