//
//  DailyTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 6/6/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class DailyTableViewController: TaskTableViewController {
    
    override func viewDidLoad() {
        readableName = L10n.Tasks.daily
        typeName = "daily"
        super.viewDidLoad()
        dataSource?.emptyDataSource = TaskEmptyTableViewDataSource<EmptyTableViewCell>(tableView: tableView, cellIdentifier: "emptyCell", styleFunction: EmptyTableViewCell.dailiesStyle)
        
        self.tutorialIdentifier = "dailies"
        configureTitle(L10n.Tasks.dailies)
    }
    
    override func createDataSource() {
        dataSource = DailyTableViewDataSource(predicate: self.getPredicate())
    }
    
    override func getDefinitionFor(tutorial: String) -> [String] {
        if tutorial == tutorialIdentifier {
            return [L10n.Tutorials.dailies1, L10n.Tutorials.dailies2]
        }
        return super.getDefinitionFor(tutorial: tutorial)
    }
    
    override func getCellNibName() -> String {
        return "DailyTableViewCell"
    }
}
