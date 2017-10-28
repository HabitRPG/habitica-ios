//
//  FixedSizeTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class FixedSizeTableViewController: HRPGBaseViewController {
    let dataSource = FixedSizeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.tableView = tableView
        tableView.dataSource = dataSource
    }

}
