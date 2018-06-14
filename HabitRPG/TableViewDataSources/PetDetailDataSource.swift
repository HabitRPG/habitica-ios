//
//  StableDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

struct PetStableItem {
    var pet: PetProtocol?
    var trained: Int
    var mountOwned: Bool
}

class PetDetailDataSource: BaseReactiveCollectionViewDataSource<PetStableItem> {
    
    private let stableRepsository = StableRepository()
    
    init(eggType: String) {
        super.init()
        sections.append(ItemSection<PetStableItem>(title: L10n.Stable.standard))
        sections.append(ItemSection<PetStableItem>(title: L10n.Stable.premium))
        var query = "egg == '\(eggType)'"
        if eggType.contains("-") {
            query = "key == '\(eggType)'"
        }
        disposable.inner.add(SignalProducer.combineLatest(stableRepsository.getOwnedPets(query: "key CONTAINS '\(eggType)'")
            .map({ data -> [String: Int] in
                var ownedPets = [String: Int]()
                data.value.forEach({ (ownedPet) in
                    ownedPets[ownedPet.key ?? ""] = ownedPet.trained
                })
                return ownedPets
            }), stableRepsository.getOwnedMounts(query: "key CONTAINS '\(eggType)'")
                .map({ data -> [String: Bool] in
                    var ownedMounts = [String: Bool]()
                    data.value.forEach({ (ownedMount) in
                        ownedMounts[ownedMount.key ?? ""] = ownedMount.owned
                    })
                    return ownedMounts
                }), stableRepsository.getPets(query: query))

            .on(value: {[weak self](ownedPets, ownedMounts, pets) in
                self?.sections[0].items.removeAll()
                self?.sections[1].items.removeAll()
                pets.value.forEach({ (pet) in
                    let item = PetStableItem(pet: pet, trained: ownedPets[pet.key ?? ""] ?? 0, mountOwned: ownedMounts[pet.key ?? ""] ?? false)
                    if pet.type == "premium" {
                        self?.sections[1].items.append(item)
                    } else {
                        self?.sections[0].items.append(item)
                    }
                })
                self?.collectionView?.reloadData()
            }).start())
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let petItem = item(at: indexPath), let petCell = cell as? PetDetailCell {
            petCell.configure(petItem: petItem)
        }
        
        return cell
    }
}
