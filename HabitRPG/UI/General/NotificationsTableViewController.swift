//
//  NotificationsTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class NotificationsTableViewController: BaseTableViewController {
    
    private let dataSource = NotificationsDataSource()
    private var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.Titles.notifications
        
        dataSource.tableView = tableView

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        tableView.register(UnallocatedPointsNotificationCell.self, forCellReuseIdentifier: HabiticaNotificationType.unallocatedStatsPoints.rawValue)
        tableView.register(NewsNotificationCell.self, forCellReuseIdentifier: HabiticaNotificationType.newStuff.rawValue)
    }
}
