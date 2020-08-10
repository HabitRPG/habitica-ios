//
//  FeedViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

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
        
        disposable.add(inventoryRepository.getOwnedItems()
            .map({ (items) -> [OwnedItemProtocol] in
                let filteredItems = items.value.filter({ (ownedItem) -> Bool in
                    return ownedItem.itemType == "food"
                })
                return filteredItems
            })
            .on(value: {[weak self] ownedItems in
                self?.ownedItems.removeAll()
                ownedItems.forEach({ (item) in
                    self?.ownedItems[(item.key ?? "") + (item.itemType ?? "")] = item.numberOwned
                })
            })
            .map({ (data) -> [String] in
                return data.map({ ownedItem -> String in
                    return ownedItem.key ?? ""
                }).filter({ (key) -> Bool in
                    return !key.isEmpty
                })
            })
            .flatMap(.latest, {[weak self] (keys) in
                return self?.inventoryRepository.getFood(keys: keys) ?? SignalProducer.empty
            })
            .on(value: {[weak self](food) in
                self?.sections[0].items = food.value
                self?.notify(changes: food.changes)
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
            let imageView = cell.viewWithTag(3) as? NetworkImageView
            imageView?.setImagewith(name: ownedItem.imageName)
        }
        return cell
    }
    
    func food(at indexPath: IndexPath?) -> FoodProtocol? {
        return item(at: indexPath)
    }
}
