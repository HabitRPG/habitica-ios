//
//  BaseUIViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 06.05.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class BaseUIViewController: HRPGUIViewController, Themeable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.contentBackgroundColor
    }
    
}
