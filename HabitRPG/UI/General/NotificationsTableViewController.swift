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

    @IBOutlet weak var doneButton: UIBarButtonItem!
    private let dataSource = NotificationsDataSource()
    private var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.Titles.notifications
        doneButton.title = L10n.done
        
        dataSource.tableView = tableView
        dataSource.viewController = self
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "emptyCell")
        dataSource.emptyDataSource = SingleItemTableViewDataSource<EmptyTableViewCell>(cellIdentifier: "emptyCell", styleFunction: EmptyTableViewCell.notificationsStyle)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        tableView.register(AchievementNotificationCell.self, forCellReuseIdentifier: "ACHIEVEMENT")
        tableView.register(UnallocatedPointsNotificationCell.self, forCellReuseIdentifier: HabiticaNotificationType.unallocatedStatsPoints.rawValue)
        tableView.register(NewsNotificationCell.self, forCellReuseIdentifier: HabiticaNotificationType.newStuff.rawValue)
        tableView.register(UnreadGroupNotificationCell.self, forCellReuseIdentifier: HabiticaNotificationType.newChatMessage.rawValue)
        tableView.register(NewMysteryItemNotificationCell.self, forCellReuseIdentifier: HabiticaNotificationType.newMysteryItem.rawValue)
        tableView.register(QuestInviteNotificationCell.self, forCellReuseIdentifier: HabiticaNotificationType.questInvite.rawValue)
        tableView.register(GroupInviteNotificationCell.self, forCellReuseIdentifier: HabiticaNotificationType.groupInvite.rawValue)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource.didSelectedNotificationAt(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dataSource.headerView(forSection: section, frame: view.frame)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
}
