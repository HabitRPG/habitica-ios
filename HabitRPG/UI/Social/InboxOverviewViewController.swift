//
//  InboxOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class InboxOverviewViewController: BaseTableViewController {
    
    private let dataSource = InboxOverviewDataSource()
    
    override func viewDidLoad() {
        tutorialIdentifier = "inbox"
        super.viewDidLoad()
        dataSource.tableView = tableView
        clearsSelectionOnViewWillAppear = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        navigationItem.leftBarButtonItem = nil
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        tableView.backgroundColor = theme.contentBackgroundColor
        view.backgroundColor = theme.contentBackgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.markInboxSeen()
    }
    
    @objc
    private func refresh() {
        dataSource.refresh {[weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    override func getDefinitonForTutorial(_ tutorialIdentifier: String!) -> [AnyHashable : Any]! {
        if tutorialIdentifier == self.tutorialIdentifier {
            return [
                "text": L10n.Tutorials.inbox
            ]
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.chatSegue.rawValue {
            if let chatViewController = segue.destination as? InboxChatViewController {
                if let cell = sender as? UITableViewCell {
                    guard let indexPath = tableView.indexPath(for: cell) else {
                        return
                    }
                    let message = dataSource.item(at: indexPath)
                    chatViewController.userID = message?.uuid
                    chatViewController.displayName = message?.displayName
                }
            }
        }
    }
}
