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

    var showOnlyUserChallenges = true
    
    let segmentedFilterControl = UISegmentedControl(items: [NSLocalizedString("My Challenges", comment: ""), NSLocalizedString("Public Challenges", comment: "")])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.sharedManager.fetchChallenges(nil, onError: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.segmentedFilterControl.selectedSegmentIndex = 0
        self.segmentedFilterControl.tintColor = UIColor.purple300()
        self.segmentedFilterControl.addTarget(self, action: #selector(ChallengeTableViewController.switchFilter(_:)), for: .valueChanged)

        let segmentedWrapper = PaddedView()
        segmentedWrapper.containedView = self.segmentedFilterControl
        
        let navController = self.navigationController as! HRPGTopHeaderNavigationController
        navController.setAlternativeHeaderView(segmentedWrapper)
        self.tableView.contentInset = UIEdgeInsets(top: navController.getContentInset(), left: 0 as CGFloat, bottom: 0 as CGFloat, right: 0 as CGFloat)
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: navController.getContentInset(), left: 0 as CGFloat, bottom: 0 as CGFloat, right: 0 as CGFloat)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let navController = self.navigationController as! HRPGTopHeaderNavigationController
        navController.removeAlternativeHeaderView()
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        let configureCell = {[weak self]  (c, object, indexPath) in
            guard let cell = c as! ChallengeTableViewCell? else {
                return;
            }
            guard let challenge = object as! Challenge? else {
                return;
            }
            cell.setChallenge(challenge)
            if (self?.showOnlyUserChallenges)! {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
            }
            } as TableViewCellConfigureBlock
        let configureFetchRequest = {[weak self] fetchRequest in
            fetchRequest?.sortDescriptors = [NSSortDescriptor(key: "memberCount", ascending: false)]
            guard let weakSelf = self else {
                return;
            }
            if weakSelf.showOnlyUserChallenges {
                fetchRequest?.predicate = NSPredicate(format: "user.id == %@", weakSelf.sharedManager.getUser().id)
            } else {
                fetchRequest?.predicate = nil
            }
            } as FetchRequestConfigureBlock
        self.dataSource = HRPGCoreDataDataSource(managedObjectContext: self.managedObjectContext, entityName: "Challenge", cellIdentifier: "Cell", configureCellBlock: configureCell, fetchRequest: configureFetchRequest, asDelegateFor: self.tableView)
    }
    
    func switchFilter(_ segmentedControl: UISegmentedControl) {
        self.showOnlyUserChallenges = self.segmentedFilterControl.selectedSegmentIndex == 0
        self.dataSource?.reconfigureFetchRequest()
        self.tableView.reloadData()
    }

}
