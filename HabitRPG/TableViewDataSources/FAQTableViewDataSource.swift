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

class FAQTableViewDataSource: BaseReactiveTableViewDataSource<FAQEntryProtocol>, UISearchBarDelegate {
    
    var searchQuery = "" {
        didSet {
            fetchEntries()
        }
    }
    
    private let contentRepository = ContentRepository()
    private var fetchDisposable: Disposable?
    
    override init() {
        super.init()
        sections.append(ItemSection<FAQEntryProtocol>())
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
        DispatchQueue.main.async {[weak self] in
        self?.fetchDisposable = self?.contentRepository.getFAQEntries(search: self?.searchQuery).on(value: {[weak self] (entries, changes) in
            self?.sections[0].items = entries
            self?.notify(changes: changes)
        }).start()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let entry = item(at: indexPath)
        cell.textLabel?.text = entry?.question
        cell.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        cell.textLabel?.textColor = ThemeService.shared.theme.primaryTextColor
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        fetchEntries()
    }
}
