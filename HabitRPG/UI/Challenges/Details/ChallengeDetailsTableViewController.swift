//
//  ChallengeDetailsTableViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class ChallengeDetailsTableViewController: MultiModelTableViewController {
    var viewModel: ChallengeDetailViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Details"

        viewModel?.cellModelsSignal.observeValues({ (sections) in
            self.dataSource.sections = sections
            self.tableView.reloadData()
        })
        
        viewModel?.reloadTableSignal.observeValues {
            self.tableView.reloadData()
        }
        
        viewModel?.animateUpdatesSignal.observeValues({ _ in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        })
        
        viewModel?.joinLeaveStyleProvider.promptProperty.signal.observeValues({ (prompt) in
            if let alertController = prompt {
                self.present(alertController, animated: true, completion: nil)
            }
        })
        
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "ChallengeTableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        
        self.viewModel?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.topHeaderNavigationController.setShouldHideTopHeader(true, animated: false)
        self.topHeaderNavigationController.stopFollowingScrollView()
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.topHeaderNavigationController.setShouldHideTopHeader(true, animated: false)
        self.topHeaderNavigationController.stopFollowingScrollView()
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let dataSourceSection = dataSource.sections?[section] {
            if let sectionTitleString = dataSourceSection.title {
                if let itemCount = dataSourceSection.items?.count {
                    
                    let header: ChallengeTableViewHeaderView? = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ChallengeTableViewHeaderView
                    
                    header?.titleLabel.text = sectionTitleString
                    header?.countLabel.text = "\(itemCount)"

                    return header
                }
            }
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource.sections?[section].title != nil ? 55 : 0
    }
}
