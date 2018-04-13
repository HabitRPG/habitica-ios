//
//  ItemsViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class ItemsViewDataSource: BaseReactiveTableViewDataSource<ItemProtocol> {

    private let inventoryRepository = InventoryRepository()
    private var fetchDisposable: Disposable?
    
    private var ownedItems = [String: Int]()
    
    override init() {
        super.init()
        sections.append(ItemSection<ItemProtocol>(title: L10n.eggs))
        sections.append(ItemSection<ItemProtocol>(title: L10n.food))
        sections.append(ItemSection<ItemProtocol>(title: L10n.hatchingPotions))
        sections.append(ItemSection<ItemProtocol>(title: L10n.quests))
        
        disposable.inner.add(inventoryRepository.getOwnedItems()
            .on(value: { ownedItems in
                self.ownedItems.removeAll()
                ownedItems.value.forEach({ (item) in
                    self.ownedItems[(item.key ?? "") + (item.itemType ?? "")] = item.numberOwned
                })
            })
            .map({ (data) -> [String] in
                return data.value.map({ (ownedItem) -> String in
                    return ownedItem.key ?? ""
                }).filter({ (key) -> Bool in
                    return !key.isEmpty
                })
            })
            .flatMap(.latest, { (keys) in
                return self.inventoryRepository.getItems(keys: keys)
            })
            .on(value: { (eggs, food, hatchingPotions, quests) in
                self.sections[0].items = eggs.value
                self.notify(changes: eggs.changes)
                self.sections[1].items = food.value
                self.notify(changes: food.changes, section: 1)
                self.sections[2].items = hatchingPotions.value
                self.notify(changes: hatchingPotions.changes, section: 2)
                self.sections[3].items = quests.value
                self.notify(changes: quests.changes, section: 3)
            })
            .start())
    }
    
    deinit {
        if let disposable = fetchDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let ownedItem = item(at: indexPath) {
            let label = cell.viewWithTag(1) as? UILabel
            label?.text = ownedItem.text
            let detailLabel = cell.viewWithTag(2) as? UILabel
            detailLabel?.text = "\(ownedItems[(ownedItem.key ?? "") + (ownedItem.itemType ?? "")] ?? 0)"
            let imageView = cell.viewWithTag(3) as? UIImageView
            imageView?.setImagewith(name: ownedItem.imageName)
        }
        return cell
    }
}
