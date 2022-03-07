//
//  ThemedNavigationController.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit

class ThemedNavigationController: UINavigationController, Themeable {
    var navigationBarColor: UIColor?
    var textColor: UIColor?
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        navigationBar.tintColor = textColor ?? theme.tintColor
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: textColor ?? theme.primaryTextColor,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            NSAttributedString.Key.kern: 0.6
        ]
        navigationBar.backgroundColor = navigationBarColor ?? theme.contentBackgroundColor
        navigationBar.barTintColor = navigationBarColor ?? theme.contentBackgroundColor
    }
}
