//
//  HabitTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 6/7/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Crashlytics

class HabitTableViewController: TaskTableViewController {
    var lastLoggedPredicate: String?
    
    override func viewDidLoad() {
        readableName = L10n.Tasks.habit
        typeName = "habit"
        dataSource = HabitTableViewDataSource(predicate: self.getPredicate())
        super.viewDidLoad()
        dataSource?.emptyDataSource = SingleItemTableViewDataSource<EmptyTableViewCell>(cellIdentifier: "emptyCell", styleFunction: EmptyTableViewCell.habitsStyle)
                
        self.tutorialIdentifier = "habits"
        configureTitle(L10n.Tasks.habits)
    }
    
    override func getDefinitonForTutorial(_ tutorialIdentifier: String) -> [AnyHashable: Any]! {
        if tutorialIdentifier == "habits" {
            let localizedStringArray = [L10n.Tutorials.habits1, L10n.Tutorials.habits2, L10n.Tutorials.habits3, L10n.Tutorials.habits4]
            return ["textList": localizedStringArray]
        }
        return super.getDefinitonForTutorial(tutorialIdentifier)
    }
    
    override func getCellNibName() -> String {
        return "HabitTableViewCell"
    }
}
