//
//  BaseSettingsViewController.swift
//  Habitica
//
//  Created by Phillip on 20.10.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

class BaseSettingsViewController: BaseTableViewController {

    let disposable = ScopedDisposable(CompositeDisposable())
    
    let userRepository = UserRepository()
    var user: UserProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 45
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
            self?.tableView.reloadData()
        }).start())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ThemeService.shared.themeMode == "dark" {
            self.overrideUserInterfaceStyle = .dark
        } else if ThemeService.shared.themeMode == "light" {
            self.overrideUserInterfaceStyle = .light
        } else {
            self.overrideUserInterfaceStyle = .unspecified
        }
    }
}
