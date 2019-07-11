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
        
        disposable.inner.add(stableRepository.getOwnedPets()
            .map({ data -> [String] in
                return data.value.map({ (ownedPet) -> String in
                    return ownedPet.key ?? ""
                }).filter({ (key) -> Bool in
                    return !key.isEmpty
                })
            })
            .combineLatest(with: self.stableRepository.getPets())
            .map({[weak self] (ownedPets, pets) in
                return self?.mapData(owned: ownedPets, animals: pets.value) ?? [:]
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
            }).start())
    }
}
