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

class BaseReactiveDataSource: NSObject {
    
    let disposable = ScopedDisposable(CompositeDisposable())
    
    @objc
    var userDrivenDataUpdate = false
}


extension UITableViewDataSource where Self: BaseReactiveDataSource {
    
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
    
}
