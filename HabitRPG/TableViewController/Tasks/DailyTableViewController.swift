//
//  DailyTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 6/6/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class DailyTableViewController: TaskTableViewController {
    var emptyDataSource = SingleItemTableViewDataSource<EmptyTableViewCell>(cellIdentifier: "emptyCell", styleFunction: EmptyTableViewCell.dailiesStyle)
    
    override func viewDidLoad() {
        readableName = L10n.Tasks.daily
        typeName = "daily"
        dataSource = DailyTableViewDataSource(predicate: self.getPredicate())
        
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "emptyCell")
        
        self.tutorialIdentifier = "dailies"
        configureTitle(L10n.Tasks.dailies)
    }
    
    override func getDefinitonForTutorial(_ tutorialIdentifier: String) -> [AnyHashable: Any]? {
        if tutorialIdentifier == "dailies" {
            let localizedStringArray = [L10n.Tutorials.dailies1, L10n.Tutorials.dailies2]
            return ["textList": localizedStringArray]
        }
        return super.getDefinitonForTutorial(tutorialIdentifier)
    }
    
    override func getCellNibName() -> String {
        return "DailyTableViewCell"
    }
    
    override func dataSourceIsEmpty() {
        tableView.dataSource = emptyDataSource
        tableView.reloadData()
        tableView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
}
