//
//  PetOverviewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class PetOverviewDataSource: StableOverviewDataSource<PetProtocol> {

    override init() {
        super.init()
        sections.append(ItemSection<StableOverviewItem>(title: L10n.Stable.standardPets))
        sections.append(ItemSection<StableOverviewItem>(title: L10n.Stable.questPets))
        sections.append(ItemSection<StableOverviewItem>(title: L10n.Stable.wackyPets))
        sections.append(ItemSection<StableOverviewItem>(title: L10n.Stable.specialPets))
        fetchData()
    }
    
    override func fetchData() {
        super.fetchData()
        fetchDisposable = stableRepository.getOwnedPets()
            .map({ data -> [String] in
                return data.value.map({ (ownedPet) -> String in
                    return ownedPet.key ?? ""
                }).filter({ (key) -> Bool in
                    return !key.isEmpty
                })
            })
            .combineLatest(with: self.stableRepository.getPets(sortKey: (organizeByColor ? "potion" : "egg")))
            .combineLatest(with: self.inventoryRepository.getItems(type: ItemType.hatchingPotions)
                            .combineLatest(with: self.inventoryRepository.getItems(type: ItemType.eggs))
            )
            .map({[weak self] (pets, items) -> [String: [StableOverviewItem]] in
                var sortedItems = [String: String]()
                items.0.value.forEach {
                    if $0.isValid {
                        sortedItems["potion-\($0.key ?? "")"] = $0.text
                    }
                }
                items.1.value.forEach {
                    if $0.isValid {
                        sortedItems["egg-\($0.key ?? "")"] = $0.text
                    }
                }
                return self?.mapData(owned: pets.0, animals: pets.1.value, items: sortedItems) ?? [:]
            })
            .on(value: {[weak self]overviewItems in
                self?.sections[0].items.removeAll()
                self?.sections[0].items.append(contentsOf: overviewItems["drop"] ?? [])
                self?.sections[1].items.removeAll()
                self?.sections[1].items.append(contentsOf: overviewItems["quest"] ?? [])
                self?.sections[2].items.removeAll()
                self?.sections[2].items.append(contentsOf: overviewItems["wacky"] ?? [])
                self?.sections[3].items.removeAll()
                self?.sections[3].items.append(contentsOf: overviewItems["special"] ?? [])
                self?.collectionView?.reloadData()
            }).start()
        
        disposable.add(inventoryRepository.getOwnedItems()
                        .map({ items -> [String: OwnedItemProtocol] in
                            var itemMap = [String: OwnedItemProtocol]()
                            items.value.forEach { ownedItem in
                                itemMap["\(ownedItem.key ?? "")-\(ownedItem.itemType ?? "")"] = ownedItem
                            }
                            return itemMap
                        })
                        .on(value: { ownedItems in
                            self.ownedItems = ownedItems
                            self.collectionView?.reloadData()
                        }).start())
    }
}
