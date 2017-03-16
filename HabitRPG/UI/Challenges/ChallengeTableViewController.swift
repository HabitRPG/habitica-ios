//
//  ChallengeTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 22/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit
import PopupDialog
import ReactiveSwift
import ReactiveCocoa

class ChallengeTableViewController: HRPGBaseViewController, UISearchBarDelegate, ChallengeFilterChangedDelegate {

    var selectedChallenge: Challenge?
    var searchText: String?
    
    var dataSource: HRPGCoreDataDataSource?
    var joinInteractor: JoinChallengeInteractor?
    var leaveInteractor: LeaveChallengeInteractor?
    private let (lifetime, token) = Lifetime.make()
    private var disposable: CompositeDisposable = CompositeDisposable()
    
    var showOnlyUserChallenges = true
    
    var displayedAlert: ChallengeDetailAlert?
    
    var isFiltering = false
    var showOwned = true
    var showNotOwned = true
    var shownGuilds: [String]?
    
    
    let segmentedFilterControl = UISegmentedControl(items: [NSLocalizedString("My Challenges", comment: ""), NSLocalizedString("Public Challenges", comment: "")])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.joinInteractor = JoinChallengeInteractor(self.sharedManager)
        self.leaveInteractor = LeaveChallengeInteractor(self.sharedManager, presentingViewController: self)
        
        self.configureTableView()
        self.sharedManager.fetchChallenges(nil, onError: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let subscriber = Observer<Bool, NSError>(value: {[weak self] in
            self?.handleJoinLeave(isMember: $0)
        })
        disposable = CompositeDisposable()
        disposable.add(self.joinInteractor?.reactive.observe(subscriber, during: self.lifetime))
        disposable.add(self.leaveInteractor?.reactive.observe(subscriber, during: self.lifetime))
        
        self.segmentedFilterControl.selectedSegmentIndex = 0
        self.segmentedFilterControl.tintColor = UIColor.purple300()
        self.segmentedFilterControl.addTarget(self, action: #selector(ChallengeTableViewController.switchFilter(_:)), for: .valueChanged)

        let segmentedWrapper = PaddedView()
        segmentedWrapper.containedView = self.segmentedFilterControl
        
        let navController = self.navigationController as! HRPGTopHeaderNavigationController
        navController.setAlternativeHeaderView(segmentedWrapper)
        self.tableView.contentInset = UIEdgeInsets(top: navController.getContentInset(), left: 0 as CGFloat, bottom: 0 as CGFloat, right: 0 as CGFloat)
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: navController.getContentInset(), left: 0 as CGFloat, bottom: 0 as CGFloat, right: 0 as CGFloat)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80))
        let searchbar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        searchbar.placeholder = NSLocalizedString("Search", comment: "")
        searchbar.delegate = self
        headerView.addSubview(searchbar)
        let filterView = UIButton(frame: CGRect(x: 0, y: 40, width: self.view.frame.size.width, height: 40))
        filterView.setTitle(NSLocalizedString("Filter", comment: ""), for: .normal)
        filterView.backgroundColor = .gray500()
        filterView.setTitleColor(.purple300(), for: .normal)
        filterView.addTarget(self, action: #selector(self.filterTapped), for: .touchUpInside)
        headerView.addSubview(filterView)
        
        self.tableView.tableHeaderView = headerView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let navController = self.navigationController as! HRPGTopHeaderNavigationController
        navController.removeAlternativeHeaderView()
        disposable.dispose()
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
            
            if weakSelf.showOwned != weakSelf.showNotOwned {
                let userId = weakSelf.sharedManager.getUser().id
                if weakSelf.showOwned {
                    searchFormat.append("leaderId == \'\(userId!)\'")
                } else {
                    searchFormat.append("leaderId != \'\(userId!)\'")
                }
            }
            if let shownGuilds = weakSelf.shownGuilds {
                if searchFormat.characters.count > 0 {
                    searchFormat.append(" && ")
                }
                searchFormat.append("group.id IN {")
                if shownGuilds.count > 0 {
                    searchFormat.append("\'\(shownGuilds[0])\'")
                }
                for id in shownGuilds.dropFirst() {
                    searchFormat.append(", \'\(id)\'")
                }
                searchFormat.append("}")
            }
            if let searchText = weakSelf.searchText {
                if searchText.characters.count > 0 {
                    if searchFormat.characters.count > 0 {
                    searchFormat.append(" && ")
                    }
                    searchFormat.append("((name CONTAINS[cd] \'\(searchText)\') OR (notes CONTAINS[cd] \'\(searchText)\'))")
                }
            }
            if weakSelf.showOnlyUserChallenges {
                if searchFormat.characters.count > 0 {
                    searchFormat.append(" && user.id == %@")
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
            let viewController = ChallengeDetailAlert(nibName: "ChallengeDetailAlert", bundle: Bundle.main)
            self.sharedManager.fetchChallengeTasks(self.selectedChallenge, onSuccess: {[weak self] () in
                viewController.challenge = self?.selectedChallenge
            }, onError: nil)
            viewController.challenge = self.selectedChallenge
            viewController.joinLeaveAction = {[weak self] isMember in
                guard let challenge = self?.selectedChallenge else {
                    return;
                }
                if let weakSelf = self {
                    if isMember {
                        weakSelf.joinInteractor?.run(with: challenge)
                    } else {
                        weakSelf.leaveInteractor?.run(with: challenge)
                    }
                }
            }
            let popup = PopupDialog(viewController: viewController) {[weak self] in
                self?.displayedAlert = nil
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
            self.displayedAlert = viewController
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    func handleJoinLeave(isMember: Bool) {
        if let alert = displayedAlert {
            alert.isMember = isMember
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
    
    func filterTapped(_ sender: UIButton!) {
        let viewController = ChallengeFilterAlert()
        viewController.showOwned = showOwned
        viewController.showNotOwned = showNotOwned
        if shownGuilds == nil {
            viewController.initShownGuilds = true
        } else {
            viewController.shownGuilds = shownGuilds!
        }
        viewController.delegate = self
        viewController.managedObjectContext = self.managedObjectContext
        let popup = PopupDialog(viewController: viewController)
        self.present(popup, animated: true, completion: nil)
    }
    
    func challengeFilterChanged(showOwned: Bool, showNotOwned: Bool, shownGuilds: [String]) {
        self.showOwned = showOwned
        self.showNotOwned = showNotOwned
        self.shownGuilds = shownGuilds
        self.dataSource?.reconfigureFetchRequest()
        self.tableView.reloadData()
    }
}
