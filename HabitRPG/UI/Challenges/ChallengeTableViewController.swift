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
import Habitica_Models

class ChallengeTableViewController: HRPGBaseViewController, UISearchBarDelegate, ChallengeFilterChangedDelegate {
    
    var selectedChallenge: ChallengeProtocol?

    var dataSource = ChallengeTableViewDataSource()
    var joinInteractor: JoinChallengeInteractor?
    var leaveInteractor: LeaveChallengeInteractor?
    private let (lifetime, token) = Lifetime.make()
    private var disposable: CompositeDisposable = CompositeDisposable()

    @objc var showOnlyUserChallenges = true

    var displayedAlert: ChallengeDetailAlert?
    
    let segmentedWrapper = PaddedView()
    let segmentedFilterControl = UISegmentedControl(items: [NSLocalizedString("My Challenges", comment: ""), NSLocalizedString("Discover", comment: "")])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.joinInteractor = JoinChallengeInteractor()
        self.leaveInteractor = LeaveChallengeInteractor(presentingViewController: self)
        dataSource.tableView = self.tableView
        
        self.segmentedFilterControl.selectedSegmentIndex = 0
        self.segmentedFilterControl.addTarget(self, action: #selector(ChallengeTableViewController.switchFilter(_:)), for: .valueChanged)
        segmentedWrapper.containedView = self.segmentedFilterControl
        topHeaderCoordinator?.alternativeHeader = segmentedWrapper
        topHeaderCoordinator.hideHeader = false
        
        dataSource.retrieveData {
        }
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

    @objc
    func switchFilter(_ segmentedControl: UISegmentedControl) {
        self.showOnlyUserChallenges = self.segmentedFilterControl.selectedSegmentIndex == 0
        self.dataSource.isShowingJoinedChallenges = showOnlyUserChallenges
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedChallenge = self.dataSource.item(at: indexPath) else {
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
        self.dataSource.searchText = searchText
        dataSource.updatePredicate()
    }

    @objc
    func filterTapped(_ sender: UIButton!) {
        let viewController = ChallengeFilterAlert()
        viewController.showOwned = dataSource.showOwned
        viewController.showNotOwned = dataSource.showNotOwned
        if dataSource.shownGuilds == nil {
            viewController.initShownGuilds = true
        } else {
            viewController.shownGuilds = dataSource.shownGuilds ?? [String]()
        }
        viewController.delegate = self
        let popup = PopupDialog(viewController: viewController)
        self.present(popup, animated: true, completion: nil)
    }

    func challengeFilterChanged(showOwned: Bool, showNotOwned: Bool, shownGuilds: [String]) {
        self.dataSource.showOwned = showOwned
        self.dataSource.showNotOwned = showNotOwned
        self.dataSource.shownGuilds = shownGuilds
        self.dataSource.updatePredicate()
    }
}
