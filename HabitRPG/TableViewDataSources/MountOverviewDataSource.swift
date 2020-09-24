//
//  MountOverviewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class MountOverviewDataSource: StableOverviewDataSource<PetProtocol> {
    
    override init() {
        super.init()
        sections.append(ItemSection<StableOverviewItem>(title: L10n.Stable.standardMounts))
        sections.append(ItemSection<StableOverviewItem>(title: L10n.Stable.questMounts))
        sections.append(ItemSection<StableOverviewItem>(title: L10n.Stable.wackyMounts))
        sections.append(ItemSection<StableOverviewItem>(title: L10n.Stable.specialMounts))
        fetchData()
    }
    
    override func fetchData() {
        super.fetchData()
        fetchDisposable = stableRepository.getOwnedMounts()
            .map({ data -> [String] in
                return data.value.map({ (ownedMount) -> String in
                    return ownedMount.key ?? ""
                }).filter({ (key) -> Bool in
                    return !key.isEmpty
                })
            })
            .combineLatest(with: self.stableRepository.getMounts(sortKey: (organizeByColor ? "potion" : "egg")))
            .combineLatest(with: self.inventoryRepository.getItems(type: (organizeByColor ? ItemType.hatchingPotions : ItemType.eggs)))
            .map({[weak self] (mounts, items) -> [String: [StableOverviewItem]] in
                var sortedItems = [String: String]()
                items.value.forEach { sortedItems[$0.key ?? ""] = $0.text }
                return self?.mapData(owned: mounts.0, animals: mounts.1.value, items: sortedItems) ?? [:]
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
    }
    
    override func getImageName(_ animal: AnimalProtocol) -> String {
        if animal.type == "special" {
            return "stable_Mount_Icon_\(animal.key ?? "")"
        } else {
            if organizeByColor {
                return "Pet_HatchingPotion_\(animal.potion ?? "")"
            } else {
                return "stable_Mount_Icon_\(animal.egg ?? "")-Base"
            }
        }
    }
}
