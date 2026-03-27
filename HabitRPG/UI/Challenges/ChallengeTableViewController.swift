//
//  ChallengeTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 22/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Habitica_Models
import SwiftUI
import SwiftUIX

struct ChallengeFilterState {
    var showOwned: Bool = true
    var showNotOwned: Bool = true
    
    var showParticipating: Bool = true
    var showNotParticipating: Bool = true
    
    func cleared() -> ChallengeFilterState {
        return ChallengeFilterState()
    }
}

class ChallengeTableViewController: BaseTableViewController, UISearchBarDelegate {
    
    var selectedChallenge: ChallengeProtocol?

    var dataSource = ChallengeTableViewDataSource()
    var joinInteractor: JoinChallengeInteractor?
    var leaveInteractor: LeaveChallengeInteractor?
    private let (lifetime, token) = Lifetime.make()
    private var disposable: CompositeDisposable = CompositeDisposable()
    private var filterButton = UIButton()
    var searchBar = UISearchBar()
    var searchBarWrapper = UIVisualEffectView()
    var searchBarCancelButton = UIButton()

    @objc var showOnlyUserChallenges = true

    var displayedAlert: ChallengeDetailAlert?
    
    let segmentedWrapper = UIVisualEffectView()
    let segmentedFilterControl = UISegmentedControl(items: [L10n.myChallenges, L10n.discover])
    
    let emptyView = UIHostingView(rootView: NoContentView(icon: Image(Asset.Empty.challenges.name), title: Text(L10n.Empty.challenges), content: Text(L10n.Empty.challengesDescription)))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.joinInteractor = JoinChallengeInteractor()
        self.leaveInteractor = LeaveChallengeInteractor(presentingViewController: self)
        
        tableView.register(UINib(nibName: "ChallengeTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        searchBar.placeholder = L10n.search
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBarCancelButton.setTitle(L10n.cancel, for: .normal)
        searchBarCancelButton.addTarget(self, action: #selector(searchBarCancelButtonClicked), for: .touchUpInside)
        searchBarWrapper.contentView.addSubview(searchBar)
        searchBarWrapper.contentView.addSubview(searchBarCancelButton)
        
        if #available(iOS 26.0, *) {
            let glassEffect = UIGlassEffect()
            searchBarWrapper.effect = glassEffect
            searchBarWrapper.layer.cornerRadius = UIConstants.largeCornerRadius
            searchBarWrapper.clipsToBounds = true
            segmentedWrapper.effect = glassEffect
            segmentedWrapper.cornerConfiguration = .capsule()
        }
        
        filterButton.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        filterButton.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChallengeAction))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped(_:)))
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: filterButton), searchButton, addButton]

        self.segmentedFilterControl.addTarget(self, action: #selector(ChallengeTableViewController.switchFilter(_:)), for: .valueChanged)
        segmentedWrapper.contentView.addSubview(self.segmentedFilterControl)
        topHeaderCoordinator?.alternativeHeader = segmentedWrapper
        topHeaderCoordinator?.hideHeader = false
        topHeaderCoordinator?.followScrollView = false
        layoutHeader()
        
        #if !targetEnvironment(macCatalyst)
        self.tableView?.refreshControl = HabiticaRefresControl()
        self.tableView?.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        #endif
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.keyboardDismissMode = .interactive
        
        dataSource.initialDataLoad()
        dataSource.tableView = self.tableView
        
        segmentedFilterControl.selectedSegmentIndex = 0
        
        view.addSubview(emptyView)
        emptyView.isHidden = true
        dataSource.emptyView = emptyView
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        searchBar.barStyle = .black
        searchBar.isTranslucent = true
        searchBar.backgroundColor = .clear
        navigationItem.rightBarButtonItem?.tintColor = theme.tintColor
        if #unavailable(iOS 26.0) {
            searchBarWrapper.backgroundColor = theme.contentBackgroundColor
        }
        searchBarCancelButton.setTitleColor(theme.tintColor, for: .normal)
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
        removeSearchBar(isAnimated: false)
        super.viewWillDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        layoutHeader()
        emptyView.pin.left().right().top(40).sizeToFit(.width)
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
        segmentedFilterControl.frame = CGRect(x: 4, y: 4, width: view.frame.width-24, height: size.height)
        segmentedWrapper.frame = CGRect(x: 8, y: 0, width: view.frame.width - 16, height: 8+size.height)
    }
    
    private func removeSearchBar(isAnimated: Bool) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
        dataSource.searchText = nil
        if isAnimated {
            UIView.animate(withDuration: 0.3, animations: {
                self.searchBarWrapper.alpha = 0
            }, completion: { _ in
                self.searchBarWrapper.removeFromSuperview()
            })
        } else {
            self.searchBarWrapper.removeFromSuperview()
        }
        self.navigationItem.rightBarButtonItems?.forEach { item in
            item.isHidden = false
        }
        self.navigationItem.leftBarButtonItems?.forEach { item in
            item.isHidden = false
        }
        tableView.reloadData()
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
        searchBar.setShowsCancelButton(false, animated: true)
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
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        
        dataSource.searchText = nil
        removeSearchBar(isAnimated: true)
        tableView.reloadData()
    }
    
    @objc
    func filterTapped(_ sender: UIButton!) {
        let sheet = HostingBottomSheetController(rootView: ChallengeFilterView(filterState: dataSource.filterState, updateFilterState: {[weak self] newState in
            self?.dataSource.filterState = newState
            self?.dataSource.updatePredicate()
        }))
        sheet.modalPresentationStyle = .popover
        sheet.popoverPresentationController?.sourceView = sender
        sheet.show()
    }
    
    @IBAction func addChallengeAction(_ sender: Any) {
        let viewController = CreateChallengeViewController()
        viewController.modalPresentationStyle = .formSheet
        viewController.isModalInPresentation = true
        self.present(viewController, animated: true)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        navigationController?.navigationBar.addSubview(searchBarWrapper)
        searchBarWrapper.frame = CGRect(x: 66, y: -4, width: tableView.bounds.size.width - 84, height: navigationController?.navigationBar.frame.size.height ?? 48)
        searchBarCancelButton.pin.top().end(8).bottom().sizeToFit(.height)
        searchBar.pin.start(6).before(of: searchBarCancelButton).marginRight(6).top().bottom()
        searchBar.becomeFirstResponder()
        searchBarWrapper.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.searchBarWrapper.alpha = 1
            self.navigationItem.rightBarButtonItems?.forEach { item in
                item.isHidden = true
            }
            self.navigationItem.leftBarButtonItems?.forEach { item in
                item.isHidden = true
            }
        }
    }
}
