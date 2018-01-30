//
//  FixedSizeDataSource.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/17/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

protocol MultiModelDataSourceItem {
    func cellIdentifier() -> String
    func cellClass() -> UITableViewCell.Type
    func configureCell(_ cell: UITableViewCell)
}

class ConcreteMultiModelDataSourceItem<T>: MultiModelDataSourceItem where T: UITableViewCell {
    private let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    func cellIdentifier() -> String {
        return identifier
    }
    
    func cellClass() -> UITableViewCell.Type {
        return T.self
    }
    
    func configureCell(_ cell: UITableViewCell) {
        // NO OP: override me!
    }
}

// MARK: -

class MultiModelDataSourceSection {
    var title: String?
    var items: [MultiModelDataSourceItem]?
}

// MARK: -

class MultiModelDataSource: NSObject, UITableViewDataSource {
    var tableView: UITableView? {
        didSet {
            registerCells()
        }
    }
    var sections: [MultiModelDataSourceSection]? {
        didSet {
            registerCells()
        }
    }
    
    func registerCells() {
        if let sections = self.sections, let tableView = self.tableView {
            for section in sections {
                if let items = section.items {
                    for item in items {
                        let className = String(describing: item.cellClass())
                        if Bundle.main.path(forResource: className, ofType: "nib") != nil {
                            tableView.register(UINib(nibName: className, bundle: nil), forCellReuseIdentifier: item.cellIdentifier())
                        } else {
                            tableView.register(item.cellClass(), forCellReuseIdentifier: item.cellIdentifier())
                        }
                        
                    }
                }
            }
        }
    }
    
    // MARK: TableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let isSectionView = tableView.delegate?.tableView?(tableView, viewForHeaderInSection: section) != nil
        return isSectionView ? nil : sections?[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections?[section].items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = sections?[indexPath.section].items?[indexPath.row] {
            if let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier()) {
                item.configureCell(cell)
                return cell
            }
        }
        return UITableViewCell()
    }
    
}
