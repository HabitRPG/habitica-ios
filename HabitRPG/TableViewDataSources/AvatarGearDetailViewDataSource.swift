//
//  AvatarGearDetailViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class AvatarGearDetailViewDataSource: BaseReactiveCollectionViewDataSource<GearProtocol> {
    
    private let inventoryRepository = InventoryRepository()
    private let userRepository = UserRepository()
    
    var gearType: String
    
    private var ownedGear: [OwnedGearProtocol] = []
    
    private var equippedKey: String?
    
    var preferences: PreferencesProtocol?
    
    init(type: String) {
        gearType = type
        super.init()
        sections.append(ItemSection<GearProtocol>())

        var predicate = NSPredicate(format: "gearSet != nil && type == 'headAccessory'")
        if gearType == "eyewear" {
            predicate = NSPredicate(format: "gearSet == 'glasses' && type == 'eyewear'")
        }
        disposable.add(inventoryRepository.getGear(predicate: predicate)
            .combineLatest(with: inventoryRepository.getOwnedGear())
            .on(value: {[weak self](gear, ownedGear) in
                self?.ownedGear = ownedGear.value
                self?.configureSections(gear.value)
            }).start())
        disposable.add(userRepository.getUser().on(value: {[weak self]user in
            self?.preferences = user.preferences
            let outfit = (user.preferences?.useCostume ?? false) ? user.items?.gear?.costume : user.items?.gear?.equipped
            switch self?.gearType {
            case "eyewear":
                self?.equippedKey = outfit?.eyewear
            case "headAccessory":
                self?.equippedKey = outfit?.headAccessory
            default:
                return
            }
            self?.collectionView?.reloadData()
        }).start())
    }
    
    func owns(gear: GearProtocol) -> Bool {
        return ownedGear.contains(where: { (ownedGear) -> Bool in
            return ownedGear.key == gear.key
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let gear = item(at: indexPath), let customizationCell = cell as? CustomizationDetailCell {
            customizationCell.configure(gear: gear)
            customizationCell.isCustomizationSelected = gear.key == equippedKey
            customizationCell.currencyView.isHidden = owns(gear: gear)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let gear = item(at: indexPath) {
            if !owns(gear: gear) {
                return CGSize(width: 80, height: 108)
            } else {
                return CGSize(width: 80, height: 108)
            }
        }
        return CGSize.zero
    }
    
    private func configureSections(_ gear: [GearProtocol]) {
        sections.removeAll()
        sections.append(ItemSection<GearProtocol>())
        for gear in gear {
            if let set = gear.gearSet {
                if let index = sections.firstIndex(where: { (section) -> Bool in
                    return section.key == set
                }) {
                    sections[index].items.append(gear)
                } else {
                    sections.append(ItemSection<GearProtocol>(key: set, title: sectionTitle(set)))
                    sections.last?.items.append(gear)
                }
            } else {
                sections[0].items.append(gear)
            }
        }
        collectionView?.reloadData()
    }
    
    private func sectionTitle(_ sectionKey: String) -> String {
        switch sectionKey {
        case "glasses":
            return L10n.glasses
        case "animal":
            return L10n.animalEars
        case "headband":
            return L10n.headband
        default:
            return ""
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        let section = visibleSections[indexPath.section]
        
        if let headerView = view as? CustomizationHeaderView {
            headerView.label.text = section.title
            headerView.label.textColor = ThemeService.shared.theme.primaryTextColor
            headerView.purchaseButton.isHidden = true
        }
        
        return view
    }
}
