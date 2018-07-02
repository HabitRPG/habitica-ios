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
        readableName = NSLocalizedString("Daily", comment: "")
        typeName = "daily"
        dataSource = DailyTableViewDataSourceInstantiator.instantiate(predicate: self.getPredicate())
        
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "emptyCell")
        
        self.tutorialIdentifier = "dailies"
    }
    
    override func getDefinitonForTutorial(_ tutorialIdentifier: String) -> [AnyHashable: Any]? {
        if tutorialIdentifier == "dailies" {
            let localizedStringArray = [NSLocalizedString("Make Dailies for time-sensitive tasks that need to be done on a regular schedule.", comment: ""),
                                        NSLocalizedString("Be careful — if you miss one, your avatar will take damage overnight. Checking them off consistently brings great rewards!", comment: "")]
            return ["textList" : localizedStringArray]
        }
        return super.getDefinitonForTutorial(tutorialIdentifier)
    }
    
    override func getCellNibName() -> String {
        return "DailyTableViewCell"
    }
    
    override func dataSourceIsEmpty() {
        tableView.dataSource = emptyDataSource
        tableView.reloadData()
        tableView.backgroundColor = UIColor.gray700()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
}
