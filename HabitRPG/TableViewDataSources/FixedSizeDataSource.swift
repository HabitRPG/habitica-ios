//
//  FixedSizeDataSource.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/17/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

protocol FixedSizeDataSourceItem {
    func cellIdentifier() -> String
    func cellClass() -> UITableViewCell.Type
    func configureCell(_ cell: UITableViewCell)
}

// MARK: -

class FixedSizeDataSourceSection {
    var title: String?
    var items: [FixedSizeDataSourceItem]?
}

// MARK: -

class FixedSizeDataSource: NSObject, UITableViewDataSource {
    var tableView: UITableView? {
        didSet {
            registerCells()
        }
    }
    var sections: [FixedSizeDataSourceSection]? {
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
        return sections?[section].title
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
