//
//  GuildOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import Habitica_Models
import PinLayout

class GuildOverviewViewController: BaseTableViewController, UISearchBarDelegate {
    
    let segmentedWrapper = UIView()
    let segmentedFilterControl = UISegmentedControl(items: [L10n.myGuilds, L10n.discover])
    var searchBar = UISearchBar()
    var searchBarWrapper = UIView()
    var searchBarCancelButton = UIButton()

    var dataSource = GuildsOverviewDataSource()
    
    let tableHeaderWrapper = UIView()
    let invitationListView = GroupInvitationListView()
    
    var isShowingPrivateGuilds: Bool {
        return segmentedFilterControl.selectedSegmentIndex == 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = L10n.Titles.guilds
        
        segmentedFilterControl.selectedSegmentIndex = 0
        segmentedFilterControl.addTarget(self, action: #selector(switchFilter), for: .valueChanged)
        segmentedWrapper.addSubview(segmentedFilterControl)
        layoutHeader()
        topHeaderCoordinator?.alternativeHeader = segmentedWrapper
        topHeaderCoordinator?.hideHeader = false
        topHeaderCoordinator?.followScrollView = false
        
        searchBar.placeholder = L10n.search
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBarCancelButton.setTitle(L10n.cancel, for: .normal)
        searchBarCancelButton.addTarget(self, action: #selector(searchBarCancelButtonClicked), for: .touchUpInside)
        searchBarWrapper.addSubview(searchBar)
        searchBarWrapper.addSubview(searchBarCancelButton)
        
        #if !targetEnvironment(macCatalyst)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        #endif
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.keyboardDismissMode = .interactive
        
        dataSource.tableView = tableView
        dataSource.invitationListView = invitationListView

        tableHeaderWrapper.addSubview(invitationListView)
        tableView.tableHeaderView = tableHeaderWrapper
        
        dataSource.retrieveData(completed: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeSearchBar(isAnimated: false)
        super.viewWillDisappear(animated)
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
        tableView.backgroundColor = theme.contentBackgroundColor
        searchBarWrapper.backgroundColor = theme.contentBackgroundColor
        searchBarCancelButton.setTitleColor(theme.tintColor, for: .normal)
    }
    
    override func viewWillLayoutSubviews() {
        layoutHeader()
        let height = invitationListView.intrinsicContentSize.height
        invitationListView.pin.top().horizontally().height(height)
        tableHeaderWrapper.pin.top().horizontally().height(14 + height)
        super.viewWillLayoutSubviews()
    }
    
    private func layoutHeader() {
        segmentedFilterControl.pin.top().horizontally(8).sizeToFit(.width)
        segmentedWrapper.pin.horizontally().top().height(segmentedFilterControl.frame.origin.y + segmentedFilterControl.frame.size.height + 8)
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
        tableView.reloadData()
    }
    
    @objc
    private func refresh() {
        dataSource.retrieveData(completed: {[weak self] in
            self?.refreshControl?.endRefreshing()
        })
    }
    
    @objc
    private func switchFilter() {
        dataSource.isShowingPrivateGuilds = isShowingPrivateGuilds
        dataSource.retrieveData(completed: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSource.searchText = searchText
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.showGuildSegue.rawValue, let cell = sender as? UITableViewCell {
            let destViewController = segue.destination as? SplitSocialViewController
            let indexPath = tableView.indexPath(for: cell)
            destViewController?.groupID = dataSource.item(at: indexPath)?.id
        }
    }
    
    @IBAction func createGuildAction(_ sender: Any) {
        let alert = HabiticaAlertController(title: L10n.createGuild, message: L10n.createGuildDescription)
        alert.addAction(title: L10n.openWebsite, style: .default, isMainAction: true) { _ in
            guard let url = URL(string: "https://habitica.com/groups/myGuilds") else {
                return
            }
            UIApplication.shared.open(url)
        }
        alert.addCloseAction()
        alert.show()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        navigationController?.navigationBar.addSubview(searchBarWrapper)
        searchBarWrapper.frame = CGRect(x: 12, y: 0, width: tableView.bounds.size.width - 24, height: navigationController?.navigationBar.frame.size.height ?? 48)
        searchBarCancelButton.pin.top().end().bottom().sizeToFit(.height)
        searchBar.pin.start().before(of: searchBarCancelButton).top().bottom()
        searchBar.becomeFirstResponder()
        searchBarWrapper.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.searchBarWrapper.alpha = 1
        }
    }
}
