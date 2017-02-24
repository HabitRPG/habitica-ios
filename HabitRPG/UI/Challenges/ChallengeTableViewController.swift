//
//  ChallengeTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 22/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class ChallengeTableViewController: HRPGBaseViewController {

    var dataSource: HRPGCoreDataDataSource?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.sharedManager.fetchChallenges(nil, onError: nil)
    }
    
    func configureTableView() {
        let configureCell = { (c, object, indexPath) in
            guard let cell = c as! ChallengeTableViewCell? else {
                return;
            }
            guard let challenge = object as! Challenge? else {
                return;
            }
            cell.setChallenge(challenge)
            } as TableViewCellConfigureBlock
        let configureFetchRequest = { fetchRequest in
            fetchRequest?.sortDescriptors = [NSSortDescriptor(key: "memberCount", ascending: false)]
            } as FetchRequestConfigureBlock
        self.dataSource = HRPGCoreDataDataSource(managedObjectContext: self.managedObjectContext, entityName: "Challenge", cellIdentifier: "Cell", configureCellBlock: configureCell, fetchRequest: configureFetchRequest, asDelegateFor: self.tableView)
    }

}
