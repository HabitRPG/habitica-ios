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
        tableView.backgroundColor = theme.windowBackgroundColor
        tableView.separatorColor = theme.tableviewSeparatorColor
        //tableView.reloadData()
    }
    
}
