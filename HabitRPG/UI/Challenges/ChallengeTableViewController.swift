//
//  ChallengeTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 22/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
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

    @objc var showOnlyUserChallenges = true

    var displayedAlert: ChallengeDetailAlert?

    var isFiltering = false
    var showOwned = true
    var showNotOwned = true
    @objc var shownGuilds: [String]?
    
    let segmentedWrapper = PaddedView()
    let segmentedFilterControl = UISegmentedControl(items: [NSLocalizedString("My Challenges", comment: ""), NSLocalizedString("Discover", comment: "")])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.joinInteractor = JoinChallengeInteractor()
        self.leaveInteractor = LeaveChallengeInteractor(presentingViewController: self)

        self.configureTableView()
        HRPGManager.shared().fetchChallenges({
            HRPGManager.shared().fetchUser(nil, onError: nil)
        }, onError: nil)
        
        self.segmentedFilterControl.selectedSegmentIndex = 0
        self.segmentedFilterControl.tintColor = UIColor.purple300()
        self.segmentedFilterControl.addTarget(self, action: #selector(ChallengeTableViewController.switchFilter(_:)), for: .valueChanged)
        segmentedWrapper.containedView = self.segmentedFilterControl
        topHeaderCoordinator?.alternativeHeader = segmentedWrapper
        topHeaderCoordinator.hideHeader = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let subscriber = Signal<Bool, NSError>.Observer(value: {[weak self] in
            self?.handleJoinLeave(isMember: $0)
        })
        disposable = CompositeDisposable()
        disposable.add(self.joinInteractor?.reactive.take(during: self.lifetime).observe(subscriber))
        disposable.add(self.leaveInteractor?.reactive.take(during: self.lifetime).observe(subscriber))
        
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
        disposable.dispose()
        super.viewWillDisappear(animated)
    }

    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        let configureCell = {[weak self]  (tableViewCell, object, indexPath) in
            guard let cell = tableViewCell as? ChallengeTableViewCell else {
                return
            }
            guard let challenge = object as? Challenge else {
                return
            }
            guard let weakSelf = self else {
                return
            }
            weakSelf.configureCell(cell, challenge: challenge)
            } as TableViewCellConfigureBlock
        let configureFetchRequest = {[weak self] fetchRequest in
            guard let weakSelf = self else {
                return
            }
            if let fetchRequest = fetchRequest as? NSFetchRequest<Challenge> {
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "memberCount", ascending: false)]
                let predicateString = weakSelf.assemblePredicateString()
                if let predicateString = predicateString {
                    fetchRequest.predicate = NSPredicate(format: predicateString)
                } else {
                    fetchRequest.predicate = nil
                }
            }
            } as FetchRequestConfigureBlock
        self.dataSource = HRPGCoreDataDataSource(managedObjectContext: self.managedObjectContext,
                                                 entityName: "Challenge",
                                                 cellIdentifier: "Cell",
                                                 configureCellBlock: configureCell,
                                                 fetchRequest: configureFetchRequest,
                                                 asDelegateFor: self.tableView)
    }

    @objc
    func switchFilter(_ segmentedControl: UISegmentedControl) {
        self.showOnlyUserChallenges = self.segmentedFilterControl.selectedSegmentIndex == 0
        self.dataSource?.reconfigureFetchRequest()
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedChallenge = self.dataSource?.item(at: indexPath) as? Challenge else {
            return
        }
        self.selectedChallenge = selectedChallenge
        
        self.performSegue(withIdentifier: "challengeDetailsSegue", sender: self)
    }

    func handleJoinLeave(isMember: Bool) {
        if let alert = displayedAlert {
            alert.isMember = isMember
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChallengeDetailsTableViewController {
            if let selectedChallenge = self.selectedChallenge {
                let viewModel = ChallengeDetailViewModel(challenge: selectedChallenge)
                vc.viewModel = viewModel
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.dataSource?.reconfigureFetchRequest()
        self.tableView.reloadData()
    }

    @objc
    func filterTapped(_ sender: UIButton!) {
        let viewController = ChallengeFilterAlert()
        viewController.showOwned = showOwned
        viewController.showNotOwned = showNotOwned
        if shownGuilds == nil {
            viewController.initShownGuilds = true
        } else {
            viewController.shownGuilds = shownGuilds ?? [String]()
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

    func assemblePredicateString() -> String? {
        var searchComponents = [String]()

        if self.showOwned != self.showNotOwned {
            let userId = HRPGManager.shared().getUser().id ?? ""
            if self.showOwned {
                searchComponents.append("leaderId == \'\(userId)\'")
            } else {
                searchComponents.append("leaderId != \'\(userId)\'")
            }
        }
        if let shownGuilds = self.shownGuilds {
            var component = "group.id IN {"
            if shownGuilds.count > 0 {
                component.append("\'\(shownGuilds[0])\'")
            }
            for id in shownGuilds.dropFirst() {
                component.append(", \'\(id)\'")
            }
            component.append("}")
            searchComponents.append(component)
        }
        if let searchText = self.searchText {
            if searchText.count > 0 {
                searchComponents.append("((name CONTAINS[cd] \'\(searchText)\') OR (notes CONTAINS[cd] \'\(searchText)\'))")
            }
        }
        if self.showOnlyUserChallenges {
            let userId = HRPGManager.shared().getUser().id ?? ""
            searchComponents.append("user.id == \'\(userId)\'")
        }

        if searchComponents.count > 0 {
            return searchComponents.joined(separator: " && ")
        } else {
            return nil
        }
    }

    func configureCell(_ cell: ChallengeTableViewCell, challenge: Challenge) {
        cell.setChallenge(challenge)

        if self.showOnlyUserChallenges {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
    }
}
