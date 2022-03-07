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
        
        #if !targetEnvironment(macCatalyst)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        #endif
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.keyboardDismissMode = .onDrag
        
        dataSource.tableView = tableView
        dataSource.invitationListView = invitationListView

        tableHeaderWrapper.addSubview(invitationListView)
        tableView.tableHeaderView = tableHeaderWrapper
        
        dataSource.retrieveData(completed: nil)
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
        searchBar.setShowsCancelButton(true, animated: true)
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
        navigationController?.navigationBar.addSubview(searchBar)
        searchBar.frame = CGRect(x: 12, y: 0, width: tableView.bounds.size.width - 24, height: navigationController?.navigationBar.frame.size.height ?? 48)
        searchBar.becomeFirstResponder()
        searchBar.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.searchBar.alpha = 1
        }
    }
}
