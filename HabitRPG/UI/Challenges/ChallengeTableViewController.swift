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

class ChallengeTableViewController: BaseTableViewController, UISearchBarDelegate, ChallengeFilterChangedDelegate {
    
    var selectedChallenge: ChallengeProtocol?

    var dataSource = ChallengeTableViewDataSource()
    var joinInteractor: JoinChallengeInteractor?
    var leaveInteractor: LeaveChallengeInteractor?
    private let (lifetime, token) = Lifetime.make()
    private var disposable: CompositeDisposable = CompositeDisposable()
    private var filterButton = UIButton()
    var searchBar = UISearchBar()

    @objc var showOnlyUserChallenges = true

    var displayedAlert: ChallengeDetailAlert?
    
    let segmentedWrapper = UIView()
    let segmentedFilterControl = UISegmentedControl(items: [L10n.myChallenges, L10n.discover])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.joinInteractor = JoinChallengeInteractor()
        self.leaveInteractor = LeaveChallengeInteractor(presentingViewController: self)
        
        tableView.register(UINib(nibName: "ChallengeTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        searchBar.placeholder = L10n.search
        searchBar.delegate = self
                
        filterButton.setImage(HabiticaIcons.imageOfFilterIcon().withRenderingMode(.alwaysTemplate), for: .normal)
        filterButton.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChallengeAction))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped(_:)))
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: filterButton), searchButton, addButton]

        self.segmentedFilterControl.addTarget(self, action: #selector(ChallengeTableViewController.switchFilter(_:)), for: .valueChanged)
        segmentedWrapper.addSubview(self.segmentedFilterControl)
        topHeaderCoordinator?.alternativeHeader = segmentedWrapper
        topHeaderCoordinator?.hideHeader = false
        topHeaderCoordinator?.followScrollView = false
        layoutHeader()
        
        #if !targetEnvironment(macCatalyst)
        self.tableView?.refreshControl = UIRefreshControl()
        self.tableView?.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        #endif
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.keyboardDismissMode = .interactive
        
        dataSource.initialDataLoad()
        dataSource.tableView = self.tableView
        
        segmentedFilterControl.selectedSegmentIndex = 0
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        if theme.isDark {
            searchBar.barStyle = .black
            searchBar.isTranslucent = true
        } else {
            searchBar.barStyle = .default
            searchBar.isTranslucent = false
        }
        searchBar.backgroundColor = theme.contentBackgroundColor
        navigationItem.rightBarButtonItem?.tintColor = theme.tintColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let subscriber = Signal<Bool, NSError>.Observer(value: {[weak self] in
            self?.handleJoinLeave(isMember: $0)
        })
        disposable = CompositeDisposable()
        disposable.add(self.joinInteractor?.reactive.take(during: self.lifetime).observe(subscriber))
        disposable.add(self.leaveInteractor?.reactive.take(during: self.lifetime).observe(subscriber))
    }

    override func viewWillDisappear(_ animated: Bool) {
        disposable.dispose()
        super.viewWillDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        layoutHeader()
        super.viewWillLayoutSubviews()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.item == dataSource.tableView(tableView, numberOfRowsInSection: indexPath.section)-1 {
            dataSource.retrieveData(forced: false) {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func layoutHeader() {
        let size = segmentedFilterControl.intrinsicContentSize
        segmentedFilterControl.frame = CGRect(x: 8, y: 4, width: view.frame.width-16, height: size.height)
        segmentedWrapper.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 8+size.height)
    }
    
    @objc
    private func refresh() {
        dataSource.retrieveData(forced: true) {
            self.refreshControl?.endRefreshing()
        }
    }

    @objc
    func switchFilter(_ segmentedControl: UISegmentedControl) {
        self.dataSource.isShowingJoinedChallenges = segmentedControl.selectedSegmentIndex == 0
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
        if let viewController = segue.destination as? ChallengeDetailsTableViewController {
            if let selectedChallenge = self.selectedChallenge {
                let viewModel = ChallengeDetailViewModel(challenge: selectedChallenge)
                viewController.viewModel = viewModel
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.dataSource.searchText = searchText
        dataSource.updatePredicate()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
        dataSource.searchText = nil
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBar.alpha = 0
        }) { _ in
            self.searchBar.removeFromSuperview()
        }
        tableView.reloadData()
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
    
    @IBAction func addChallengeAction(_ sender: Any) {
        let alert = HabiticaAlertController(title: L10n.createChallenge, message: L10n.createChallengeDescription)
        alert.addAction(title: L10n.openWebsite, style: .default, isMainAction: true) { _ in
            guard let url = URL(string: "https://habitica.com/challenges/myChallenges") else {
                return
            }
            UIApplication.shared.open(url)
        }
        alert.addCloseAction()
        alert.show()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        navigationController?.navigationBar.addSubview(searchBar)
        searchBar.frame = CGRect(x: 12, y: 0, width: tableView.bounds.size.width - 24, height: navigationController?.navigationBar.frame.size.height ?? 48)
        searchBar.becomeFirstResponder()
        searchBar.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.searchBar.alpha = 1
        }
    }
}
