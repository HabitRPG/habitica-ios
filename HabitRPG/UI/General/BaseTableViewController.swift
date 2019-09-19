//
//  BaseTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.03.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class BaseTableViewController: HRPGBaseViewController, Themeable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        if #available(iOS 13.0, *) {
            if ThemeService.shared.themeMode == "dark" {
                self.overrideUserInterfaceStyle = .dark
            } else if ThemeService.shared.themeMode == "light" {
                self.overrideUserInterfaceStyle = .light
            } else {
                self.overrideUserInterfaceStyle = .unspecified
            }
        }
        tableView.backgroundColor = theme.windowBackgroundColor
        tableView.separatorColor = theme.tableviewSeparatorColor
        tableView.reloadData()
    }
}
