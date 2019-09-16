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
    var canRaise: Bool
}

class PetDetailDataSource: BaseReactiveCollectionViewDataSource<PetStableItem> {
    
    private let stableRepsository = StableRepository()
    var types = ["drop", "premium"]
    
    init(searchEggs: Bool, searchKey: String) {
        super.init()
        sections.append(ItemSection<PetStableItem>(title: L10n.Stable.standard))
        sections.append(ItemSection<PetStableItem>(title: L10n.Stable.premium))
        var query = ""
        if searchKey.contains("-") {
            query = "key == '\(searchKey)'"
        } else if searchEggs {
            query = "egg == '\(searchKey)'"
        } else {
            query = "potion == '\(searchKey)'"
        }
        disposable.inner.add(SignalProducer.combineLatest(stableRepsository.getOwnedPets(query: "key CONTAINS '\(searchKey)'")
            .map({ data -> [String: Int] in
                var ownedPets = [String: Int]()
                data.value
                    .forEach({ (ownedPet) in
                    ownedPets[ownedPet.key ?? ""] = ownedPet.trained
                })
                return ownedPets
            }), stableRepsository.getOwnedMounts(query: "key CONTAINS '\(searchKey)'")
                .map({ data -> [String: Bool] in
                    var ownedMounts = [String: Bool]()
                    data.value.forEach({ (ownedMount) in
                        ownedMounts[ownedMount.key ?? ""] = !ownedMount.owned
                    })
                    return ownedMounts
                }), stableRepsository.getPets(query: query)
                    .map({ pets in
                        return pets.value.filter({ pet -> Bool in
                            return self.types.contains(pet.type ?? "")
                            })
                    }), stableRepsository.getMounts(query: query)
                        .map({ data -> [String: Bool] in
                            var mounts = [String: Bool]()
                            data.value.forEach({ mount in
                                mounts[mount.key ?? ""] = true
                            })
                            return mounts
                        }))

            .on(value: {[weak self](ownedPets, ownedMounts, pets, mounts) in
                self?.sections[0].items.removeAll()
                self?.sections[1].items.removeAll()
                pets.forEach({ (pet) in
                    let item = PetStableItem(pet: pet, trained: ownedPets[pet.key ?? ""] ?? 0, canRaise: ownedMounts[pet.key ?? ""] ?? mounts[pet.key ?? ""] ?? false)
                    if pet.type == "premium" {
                        self?.sections[1].items.append(item)
                    } else {
                        self?.sections[0].items.append(item)
                    }
                })
                if self?.visibleSections.count == 1 {
                    self?.visibleSections[0].title = nil
                }
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reuseIdentifier = (kind == UICollectionView.elementKindSectionFooter) ? "SectionFooter" : "SectionHeader"
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if kind == UICollectionView.elementKindSectionHeader {
            let label = view.viewWithTag(1) as? UILabel
            label?.text = visibleSections[indexPath.section].title
            let countLabel = view.viewWithTag(2) as? UILabel
            countLabel?.textColor = ThemeService.shared.theme.ternaryTextColor
            view.viewWithTag(3)?.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            let ownedCount = visibleSections[indexPath.section].items.filter { $0.trained > 0 }.count
            let totalCount = visibleSections[indexPath.section].items.count
            countLabel?.text = "\(ownedCount)/\(totalCount)"
        }
        
        return view
    }

}
