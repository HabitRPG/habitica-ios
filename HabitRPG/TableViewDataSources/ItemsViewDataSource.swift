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

    var itemType: String? {
        didSet {
            if itemType != nil {
            sections.forEach { section in
                section.isHidden = section.key != itemType
            }
            } else {
                sections.forEach { section in
                    section.isHidden = false
                }
            }
            tableView?.reloadData()
        }
    }
    
    private let inventoryRepository = InventoryRepository()
    private let stableRepository = StableRepository()
    private var fetchDisposable: Disposable?
    
    private var ownedItems = [String: Int]()
    private var ownedPets = [String]()
    
    var hatchingItem: ItemProtocol?
    var isHatching = false {
        didSet {
            if isHatching {
                if hatchingItem?.itemType == ItemType.eggs.rawValue {
                    sections[0].isHidden = true
                    sections[2].isHidden = false
                } else if hatchingItem?.itemType == ItemType.hatchingPotions.rawValue {
                    sections[0].isHidden = false
                    sections[2].isHidden = true
                }
                sections[1].isHidden = true
                sections[3].isHidden = true
            } else {
                sections[0].isHidden = false
                sections[1].isHidden = false
                sections[2].isHidden = false
                sections[3].isHidden = false
            }
            self.tableView?.reloadData()
        }
    }
    
    override init() {
        super.init()
        sections.append(ItemSection<ItemProtocol>(key: "eggs", title: L10n.eggs))
        sections.append(ItemSection<ItemProtocol>(key: "food", title: L10n.food))
        sections.append(ItemSection<ItemProtocol>(key: "hatchingPotions", title: L10n.hatchingPotions))
        sections.append(ItemSection<ItemProtocol>(key: "quests", title: L10n.quests))
        
        fetchItems()
        
        disposable.inner.add(stableRepository.getOwnedPets()
            .map({ pets -> [String] in
                return pets.value.filter({ ownedPet -> Bool in
                    return ownedPet.isOwned
                }).map({ (ownedPet) in
                    return ownedPet.key ?? ""
                })
            })
            .on(value: { ownedPets in
                self.ownedPets = ownedPets
        }).start())
        
    }
    
    private func fetchItems() {
        if let disposable = fetchDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
        fetchDisposable = inventoryRepository.getOwnedItems()
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
            .start()
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
            
            imageView?.alpha = 1.0
            label?.alpha = 1.0
            if isHatching, let hatchingItem = self.hatchingItem {
                if ownsPet(ownedItem, otherItem: hatchingItem) {
                    imageView?.alpha = 0.3
                    label?.alpha = 0.3
                }
            }
        }
        return cell
    }
    
    func ownsPet(_ firstItem: ItemProtocol, otherItem: ItemProtocol) -> Bool {
        if let egg = firstItem as? EggProtocol, let potion = otherItem as? HatchingPotionProtocol {
            return ownedPets.contains("\(egg.key ?? "")-\(potion.key ?? "")")
        } else if let egg = otherItem as? EggProtocol, let potion = firstItem as? HatchingPotionProtocol {
            return ownedPets.contains("\(egg.key ?? "")-\(potion.key ?? "")")
        }
        return false
    }
}
