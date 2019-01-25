//
//  HabitTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 6/7/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class HabitTableViewController: TaskTableViewController {
    var emptyDataSource = SingleItemTableViewDataSource<EmptyTableViewCell>(cellIdentifier: "emptyCell", styleFunction: EmptyTableViewCell.habitsStyle)
    
    override func viewDidLoad() {
        readableName = NSLocalizedString("Habit", comment: "")
        typeName = "habit"
        dataSource = HabitTableViewDataSource(predicate: self.getPredicate())
        
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "emptyCell")
        
        self.tutorialIdentifier = "habits"
        configureTitle(L10n.Tasks.habits)
    }
    
    override func getDefinitonForTutorial(_ tutorialIdentifier: String) -> [AnyHashable: Any]! {
        if tutorialIdentifier == "habits" {
            let localizedStringArray = [NSLocalizedString("First up is Habits. They can be positive Habits you want to improve or negative Habits you want to quit.", comment: ""),
                                        NSLocalizedString("Every time you do a positive Habit, tap the + to get experience and gold!", comment: ""),
                                        NSLocalizedString("If you slip up and do a negative Habit, tapping the - will reduce your avatar’s health to help you stay accountable.", comment: ""),
                                        NSLocalizedString("Give it a shot! You can explore the other task types through the bottom navigation.", comment: "")]
            return ["textList" : localizedStringArray]
        }
        return super.getDefinitonForTutorial(tutorialIdentifier)
    }
    
    override func getCellNibName() -> String {
        return "HabitTableViewCell"
    }
    
    override func dataSourceIsEmpty() {
        tableView.dataSource = emptyDataSource
        tableView.reloadData()
        tableView.backgroundColor = UIColor.gray700()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }

}
