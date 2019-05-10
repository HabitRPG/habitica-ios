//
//  FixedSizeTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class MultiModelTableViewController: BaseTableViewController {
    let dataSource: MultiModelDataSource = MultiModelDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.tableView = tableView
        tableView.dataSource = dataSource
    }

}
