//
//  BaseReactiveDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Habitica_Database
import Habitica_Models

class ItemSection<MODEL> {
    var items = [MODEL]()
}

class BaseReactiveDataSource<MODEL>: NSObject {
    
    let disposable = ScopedDisposable(CompositeDisposable())
    
    var sections = [ItemSection<MODEL>]()
    
    @objc var userDrivenDataUpdate = false
    
    func item(at indexPath: IndexPath?) -> MODEL? {
        guard let indexPath = indexPath else {
            return nil
        }
        if indexPath.item < 0 || indexPath.section < 0 {
            return nil
        }
        if indexPath.section < sections.count {
            if indexPath.item < sections[indexPath.section].items.count {
                return sections[indexPath.section].items[indexPath.item]
            }
        }
        return nil
    }
    
    @objc
    func retrieveData(completed: (() -> Void)?) {}
}

class BaseReactiveTableViewDataSource<MODEL>: BaseReactiveDataSource<MODEL>, UITableViewDataSource {
    
    @objc weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.reloadData()
        }
    }
    
    func notifyDataUpdate(tableView: UITableView?, changes: ReactiveChangeset?) {
        guard let changes = changes else {
            return
        }
        if userDrivenDataUpdate {
            return
        }
        if changes.initial == true {
            tableView?.reloadData()
        } else {
            tableView?.beginUpdates()
            tableView?.insertRows(at: changes.inserted.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
            tableView?.deleteRows(at: changes.deleted.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
            tableView?.reloadRows(at: changes.updated.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
            tableView?.endUpdates()
        }
    }
    
    @objc
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
