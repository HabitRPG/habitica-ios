//
//  FAQTableViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
import Result

class FAQTableViewDataSource: BaseReactiveDataSource, UITableViewDataSource, UISearchBarDelegate {
    
    var searchQuery = "" {
        didSet {
            fetchEntries()
        }
    }
    @objc weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.reloadData()
        }
    }
    
    private let contentRepository = ContentRepository()
    private var entries = [FAQEntryProtocol]()
    private var fetchDisposable: Disposable?
    
    override init() {
        super.init()
        fetchEntries()
    }
    
    deinit {
        if let disposable = fetchDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
    }
    
    private func fetchEntries() {
        if let disposable = fetchDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
        fetchDisposable = contentRepository.getFAQEntries(search: searchQuery).on(value: { (entries, changes) in
            self.entries = entries
            self.notifyDataUpdate(tableView: self.tableView, changes: changes)
        }).start()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let entry = self.entries[indexPath.item]
        cell.textLabel?.text = entry.question
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        fetchEntries()
    }
}
