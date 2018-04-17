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
    var title: String?
    var isHidden = false
    var items = [MODEL]()
    
    var isVisible: Bool {
        return !isHidden && items.count > 0
    }
    
    init(title: String? = nil) {
        self.title = title
    }
}

class BaseReactiveDataSource<MODEL>: NSObject {
    
    let disposable = ScopedDisposable(CompositeDisposable())
    
    var sections = [ItemSection<MODEL>]()
    var visibleSections: [ItemSection<MODEL>] {
        return sections.filter({ (section) -> Bool in
            return section.isVisible
        })
    }
    
    @objc var userDrivenDataUpdate = false
    
    func item(at indexPath: IndexPath?) -> MODEL? {
        guard let indexPath = indexPath else {
            return nil
        }
        if indexPath.item < 0 || indexPath.section < 0 {
            return nil
        }
        let sections = visibleSections
        if indexPath.section < sections.count {
            if indexPath.item < sections[indexPath.section].items.count {
                return sections[indexPath.section].items[indexPath.item]
            }
        }
        return nil
    }
    
    @objc
    func retrieveData(completed: (() -> Void)?) {}
    
    func notify(changes: ReactiveChangeset?, section: Int = 0) {}
}

class BaseReactiveTableViewDataSource<MODEL>: BaseReactiveDataSource<MODEL>, UITableViewDataSource {
    
    @objc weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.reloadData()
        }
    }
    
    override func notify(changes: ReactiveChangeset?, section: Int = 0) {
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
            tableView?.insertRows(at: changes.inserted.map({ IndexPath(row: $0, section: section) }), with: .automatic)
            tableView?.deleteRows(at: changes.deleted.map({ IndexPath(row: $0, section: section) }), with: .automatic)
            tableView?.reloadRows(at: changes.updated.map({ IndexPath(row: $0, section: section) }), with: .automatic)
            tableView?.endUpdates()
        }
    }
    
    @objc
    func numberOfSections(in tableView: UITableView) -> Int {
        return visibleSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleSections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return visibleSections[section].title
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

class BaseReactiveCollectionViewDataSource<MODEL>: BaseReactiveDataSource<MODEL>, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @objc weak var collectionView: UICollectionView? {
        didSet {
            collectionView?.dataSource = self
            collectionView?.reloadData()
        }
    }
    
    override func notify(changes: ReactiveChangeset?, section: Int = 0) {
        if userDrivenDataUpdate {
            return
        }
        collectionView?.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleSections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath)
        let label = headerView.viewWithTag(1) as? UILabel
        label?.text = visibleSections[indexPath.section].title
        return headerView
    }
}
