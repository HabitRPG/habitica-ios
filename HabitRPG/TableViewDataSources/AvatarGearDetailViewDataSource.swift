//
//  AvatarGearDetailViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import SwiftUIX

private class BlankGear: GearProtocol {
    var key: String?
    var text: String?
    var notes: String?
    var value: Float = 0
    var type: String?
    var set: String?
    var gearSet: String?
    var habitClass: String?
    var specialClass: String?
    var index: String?
    var twoHanded: Bool = false
    var strength: Int = 0
    var intelligence: Int = 0
    var perception: Int = 0
    var constitution: Int = 0
    var released: Bool = true
}

class AvatarGearDetailViewDataSource: BaseReactiveCollectionViewDataSource<GearProtocol> {
    
    private let inventoryRepository = InventoryRepository()
    private let userRepository = UserRepository()
    
    var gearType: String
    var newCustomizationLayout: Bool = false

    private var ownedGear: [OwnedGearProtocol] = []
    
    var equippedKey: String?
    
    var preferences: PreferencesProtocol?
    
    init(type: String, newCustomizationLayout: Bool) {
        gearType = type
        self.newCustomizationLayout = newCustomizationLayout
        super.init()
        sections.append(ItemSection<GearProtocol>())

        var predicate: NSPredicate
        if gearType == "headAccessory" {
            predicate = NSPredicate(format: "gearSet == 'animal' && type == 'headAccessory'")
        } else {
            predicate = NSPredicate(format: "gearSet == 'animal' && type == 'back'")
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
            case "back":
                self?.equippedKey = outfit?.back
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
            customizationCell.isCustomizationSelected = gear.key == equippedKey
            customizationCell.currencyView.isHidden = owns(gear: gear)
            customizationCell.configure(gear: gear)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let gear = item(at: indexPath) {
            if !owns(gear: gear) && !newCustomizationLayout {
                return CGSize(width: 80, height: 108)
            } else {
                return CGSize(width: 80, height: 80)
            }
        }
        return CGSize.zero
    }
    
    func getTitle() -> String {
        switch gearType {
        case "headAccessory":
            return L10n.animalEars
        case "back":
            return L10n.Avatar.animalTails
        default:
            return ""
        }
    }
    
    private func configureSections(_ gear: [GearProtocol]) {
        sections.removeAll()
        sections.append(ItemSection<GearProtocol>())
        sections[0].title = getTitle()
        for gear in gear {
            if newCustomizationLayout {
                if !owns(gear: gear) {
                    continue
                }
            }
            sections[0].items.append(gear)
        }
        sections[0].showIfEmpty = true
        if !sections[0].items.isEmpty {
            let gear = BlankGear()
            gear.key = "\(gearType)_base_0"
            gear.type = gearType
            sections[0].items.insert(gear, at: 0)
        }
        collectionView?.reloadData()
    }
    
    private func sectionTitle(_ sectionKey: String) -> String {
        switch sectionKey {
        case "glasses":
            return L10n.glasses
        case "animal":
            if gearType == "back" {
                return L10n.Avatar.animalTails
            } else {
                return L10n.animalEars
            }
        case "headband":
            return L10n.headband
        default:
            return ""
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        let section = visibleSections[indexPath.section]
        
        if let headerView = view as? CustomizationHeaderView {
            headerView.label.text = section.title?.localizedUppercase
            headerView.label.textColor = ThemeService.shared.theme.quadTextColor
        }
        if let footerView = view as? CustomizationFooterView {
            if newCustomizationLayout && indexPath.section == collectionView.numberOfSections - 1 {
                footerView.purchaseButton.isHidden = true
                footerView.hostingView.isHidden = false
                let hostView = UIHostingView(rootView: CTAFooterView(type: gearType, hasItems: !sections[0].items.isEmpty))
                footerView.hostingView.addSubview(hostView)
                hostView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 200)
            } else {
                footerView.isHidden = true
            }
        }
        
        return view
    }
}
