//
//  FeedViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

@objc
public protocol FeedViewDataSourceProtocol {
    @objc weak var tableView: UITableView? { get set }
    
    @objc
    func food(at indexPath: IndexPath?) -> FoodProtocol?
}

@objc
class FeedViewDataSourceInstantiator: NSObject {
    @objc
    static func instantiate() -> FeedViewDataSourceProtocol {
        return FeedViewDataSource()
    }
}

class FeedViewDataSource: BaseReactiveTableViewDataSource<FoodProtocol>, FeedViewDataSourceProtocol {

    private let inventoryRepository = InventoryRepository()
    private var ownedItems = [String: Int]()

    override init() {
        super.init()
        sections.append(ItemSection<FoodProtocol>())
        
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
                return self.inventoryRepository.getFood(keys: keys)
            })
            .on(value: { (food) in
                self.sections[0].items = food.value
                self.notify(changes: food.changes)
            })
            .start()
        )
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
    
    func food(at indexPath: IndexPath?) -> FoodProtocol? {
        return item(at: indexPath)
    }
}
