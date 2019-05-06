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
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 45
        
        disposable.inner.add(userRepository.getUser().on(value: {user in
            self.user = user
            self.tableView.reloadData()
        }).start())
    }
    
}
