//
//  ChallengeTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 22/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class ChallengeTableViewController: HRPGBaseViewController, UISearchBarDelegate {

    var selectedChallenge: Challenge?
    var searchText: String?
    
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
        let searchbar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        searchbar.placeholder = NSLocalizedString("Search", comment: "")
        searchbar.delegate = self
        self.tableView.tableHeaderView = searchbar
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let navController = self.navigationController as! HRPGTopHeaderNavigationController
        navController.removeAlternativeHeaderView()
        super.viewWillDisappear(animated)
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
            var searchFormat: String = ""
            if let searchText = weakSelf.searchText {
                if searchText.characters.count > 0 {
                    searchFormat = "((name CONTAINS[cd] \'\(searchText)\') OR (notes CONTAINS[cd] \'\(searchText)\'))"
                }
            }
            if weakSelf.showOnlyUserChallenges {
                if searchFormat.characters.count > 0 {
                    searchFormat = searchFormat.appending(" && user.id == %@")
                } else {
                    searchFormat = "user.id == %@"
                }
                fetchRequest?.predicate = NSPredicate(format: searchFormat, weakSelf.sharedManager.getUser().id)
            } else {
                if searchFormat.characters.count > 0 {
                    fetchRequest?.predicate = NSPredicate(format: searchFormat)
                } else {
                    fetchRequest?.predicate = nil
                }
            }
            } as FetchRequestConfigureBlock
        self.dataSource = HRPGCoreDataDataSource(managedObjectContext: self.managedObjectContext, entityName: "Challenge", cellIdentifier: "Cell", configureCellBlock: configureCell, fetchRequest: configureFetchRequest, asDelegateFor: self.tableView)
    }
    
    func switchFilter(_ segmentedControl: UISegmentedControl) {
        self.showOnlyUserChallenges = self.segmentedFilterControl.selectedSegmentIndex == 0
        self.dataSource?.reconfigureFetchRequest()
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedChallenge = self.dataSource?.item(at: indexPath) as! Challenge?
        if (showOnlyUserChallenges) {
            self.performSegue(withIdentifier: "ChallengeDetailSegue", sender: self)
        } else {
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let challengeDetailViewController = segue.destination as! ChallengeDetailTableViewController
        challengeDetailViewController.challengeId = self.selectedChallenge?.id
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText;
        self.dataSource?.reconfigureFetchRequest()
        self.tableView.reloadData()
    }
}
