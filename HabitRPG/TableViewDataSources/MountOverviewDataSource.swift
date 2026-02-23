//
//  MountOverviewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class MountOverviewDataSource: StableOverviewDataSource<MountProtocol> {
    
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
            .combineLatest(with: stableRepository.getMounts(sortKey: (organizeByColor ? "potion" : "egg")))
            .combineLatest(with: inventoryRepository.getItems(type: ItemType.hatchingPotions)
                            .combineLatest(with: inventoryRepository.getItems(type: ItemType.eggs))
            )
            .map({[weak self] (mounts, items) -> [String: [StableOverviewItem]] in
                var sortedItems = [String: String]()
                items.0.value.forEach { $0.isValid ? sortedItems["potion-\($0.key ?? "")"] = $0.text : () }
                items.1.value.forEach { $0.isValid ? sortedItems["egg-\($0.key ?? "")"] = ($0 as? EggProtocol)?.mountText : () }
                let sortedMounts: [AnimalProtocol]
                if self?.organizeByColor == true {
                    sortedMounts = mounts.1.value.sorted(by: { first, second in
                        return (first.potion ?? "") < (second.potion ?? "")
                    })
                } else {
                    sortedMounts = mounts.1.value.sorted(by: { first, second in
                        return (first.egg ?? "") < (second.egg ?? "")
                    })
                }
                return self?.mapData(owned: mounts.0, animals: sortedMounts, items: sortedItems) ?? [:]
            })
            .on(value: {[weak self]overviewItems in
                guard !UserManager.shared.isLoggingOut else {
                    return
                }
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
        
        disposable.add(userRepository.getUser().map { $0.items?.currentMount }
            .on(value: {[weak self] mount in
                if self?.currentSelected != mount {
                    self?.currentSelected = mount
                }
            })
            .start())
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
