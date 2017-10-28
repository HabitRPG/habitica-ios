//
//  ChallengeDetailsTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class ChallengeDetailsTableViewController: FixedSizeTableViewController {
    var viewModel: ChallengeDetailViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Details"

        viewModel?.cellModelsSignal.observeValues({ (sections) in
            self.dataSource.sections = sections
            self.tableView.reloadData()
        })
        
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        tableView.tableFooterView = UIView()
        
        self.viewModel?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.topHeaderNavigationController.shouldHideTopHeader = true
        self.topHeaderNavigationController.stopFollowingScrollView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
