//
//  AvatarDetailViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import SwiftUIX

class AvatarDetailViewDataSource: BaseReactiveCollectionViewDataSource<CustomizationProtocol> {
    
    private let customizationRepository = CustomizationRepository()
    private let userRepository = UserRepository()
    
    var customizationGroup: String?
    var customizationType: String
    var newCustomizationLayout: Bool = false
    
    var purchaseSet: ((CustomizationSetProtocol) -> Void)?
    
    private var ownedCustomizations: [OwnedCustomizationProtocol] = []
    private var customizationSets: [String: CustomizationSetProtocol] = [:]
    
    private var equippedKey: String?
    
    private var preferences: PreferencesProtocol?
    
    private var gemCount = 0
    
    init(type: String, group: String?, newCustomizationLayout: Bool) {
        self.customizationType = type
        self.customizationGroup = group
        self.newCustomizationLayout = newCustomizationLayout
        super.init()
        
        disposable.add(customizationRepository.getCustomizations(type: customizationType, group: customizationGroup)
            .combineLatest(with: customizationRepository.getOwnedCustomizations(type: customizationType, group: customizationGroup))
            .on(value: {[weak self](customizations, ownedCustomizations) in
                self?.ownedCustomizations = ownedCustomizations.value
                self?.configureSections(customizations.value)
        }).start())
        disposable.add(userRepository.getUser().on(value: {[weak self]user in
            self?.preferences = user.preferences
            self?.gemCount = user.gemCount
            
            self?.updateEquippedKey(user: user)
            self?.collectionView?.reloadData()
        }).start())
    }
    
    func canAfford(price: Float) -> Bool {
        return Float(gemCount) >= price
    }
    
    func updateEquippedKey(user: UserProtocol) {
        switch customizationType {
        case "shirt":
            equippedKey = user.preferences?.shirt
        case "skin":
            equippedKey = user.preferences?.skin
        case "chair":
            equippedKey = user.preferences?.chair
        case "background":
            equippedKey = user.preferences?.background
        case "hair":
            switch customizationGroup {
            case "bangs":
                equippedKey = String(user.preferences?.hair?.bangs ?? 0)
            case "base":
                equippedKey = String(user.preferences?.hair?.base ?? 0)
            case "mustache":
                equippedKey = String(user.preferences?.hair?.mustache ?? 0)
            case "beard":
                equippedKey = String(user.preferences?.hair?.beard ?? 0)
            case "color":
                equippedKey = String(user.preferences?.hair?.color ?? "")
            case "flower":
                equippedKey = String(user.preferences?.hair?.flower ?? 0)
            default:
                return
            }
        default:
            return
        }
    }
    
    func getCustomizationTitle() -> String {
        switch customizationType {
        case "shirt":
            return L10n.Avatar.shirts
        case "skin":
            return L10n.Avatar.skins
        case "chair":
            return L10n.Avatar.wheelchairs
        case "background":
            return L10n.monthlyBackgrounds
        case "hair":
            switch customizationGroup {
            case "bangs":
                return L10n.Avatar.bangs
            case "base":
                return L10n.Avatar.hairStyles
            case "mustache":
                return L10n.Avatar.mustaches
            case "beard":
                return L10n.Avatar.beards
            case "color":
                return L10n.Avatar.hairColors
            case "flower":
                return L10n.Avatar.extras
            default:
                return ""
            }
        default:
            return ""
        }
    }
    
    func owns(customization: CustomizationProtocol) -> Bool {
        if customization.key == "0" || customization.key?.isEmpty == true {
            return true
        }
        return ownedCustomizations.contains(where: { (ownedCustomization) -> Bool in
            return ownedCustomization.key == customization.key
        })
    }
    
    private func configureSections(_ customizations: [CustomizationProtocol]) {
        customizationSets.removeAll()
        sections.removeAll()
        sections.append(ItemSection<CustomizationProtocol>())
        sections[0].title = getCustomizationTitle()
        for customization in customizations {
            if newCustomizationLayout {
                if customization.price > 0 && !owns(customization: customization) || (customization.key?.lowercased().contains("birthday_bash") == true && !owns(customization: customization)) {
                    continue
                }
            } else {
                if (customization.price > 0 && !customization.isPurchasable)
                    || customization.key?.lowercased().contains("birthday_bash") == true {
                    if !owns(customization: customization) {
                        continue
                    }
                }
            }
            if let set = customization.set, (
                customizationType == "background" && (set.key?.contains("incentive") == true || set.key?.contains("timeTravel") == true || set.key?.contains("event") == true)
            ) || (customizationType != "background" && !newCustomizationLayout) {
                if let index = sections.firstIndex(where: { (section) -> Bool in
                    return section.key == set.key
                }) {
                    sections[index].items.append(customization)
                } else {
                    customizationSets[set.key ?? ""] = set
                    sections.append(ItemSection<CustomizationProtocol>(key: set.key, title: set.text))
                    sections.last?.items.append(customization)
                }
            } else {
                sections[0].items.append(customization)
            }
        }
        
        if customizationType == "background" {
            sections = sections.filter({ section -> Bool in
                return section.items.isEmpty == false
            }).sorted { (firstSection, secondSection) -> Bool in
                if firstSection.key == nil {
                    return false
                } else if secondSection.key == nil {
                    return true
                }
                if firstSection.key?.contains("incentive") == true {
                    return true
                } else if secondSection.key?.contains("incentive") == true {
                    return false
                }
                return firstSection.key ?? "" < secondSection.key ?? ""
            }
        }
        self.collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let customization = item(at: indexPath), let customizationCell = cell as? CustomizationDetailCell {
            customizationCell.isCustomizationSelected = customization.key == equippedKey
            customizationCell.currencyView.isHidden = customization.isPurchasable == false || owns(customization: customization)
            customizationCell.configure(customization: customization, preferences: preferences)
            if customization.set?.key?.contains("incentive") == true {
                customizationCell.imageView.alpha = owns(customization: customization) ? 1.0 : 0.3
            } else {
                customizationCell.imageView.alpha = 1.0
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let customization = item(at: indexPath) {
            if customization.isPurchasable == true && !owns(customization: customization) {
                return CGSize(width: 80, height: 108)
            } else {
                return CGSize(width: 80, height: 80)
            }
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        let section = sections[indexPath.section]
        
        if let footerView = view as? CustomizationFooterView {
            if newCustomizationLayout && indexPath.section == collectionView.numberOfSections - 1 {
                footerView.purchaseButton.isHidden = true
                footerView.hostingView.isHidden = false
                let hostView = UIHostingView(rootView: CTAFooterView(type: customizationType, hasItems: !ownedCustomizations.isEmpty))
                footerView.hostingView.addSubview(hostView)
                hostView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 200)
            } else {
                footerView.hostingView.isHidden = true
                if let set = customizationSets[section.key ?? ""] {
                    footerView.configure(customizationSet: set)
                    let individualPrice = set.setItems?.filter { (customization) -> Bool in
                        return !self.owns(customization: customization)
                    }.map { $0.price }.reduce(0, +) ?? 0
                    if individualPrice >= set.setPrice && set.setPrice != 0 && set.key?.contains("timeTravel") != true && set.key?.contains("incentive") != true {
                        footerView.purchaseButton.isHidden = false
                    } else {
                        footerView.purchaseButton.isHidden = true
                    }
                    
                    footerView.purchaseButtonTapped = {
                        if let action = self.purchaseSet {
                            action(set)
                        }
                    }
                } else {
                    footerView.purchaseButton.isHidden = true
                }
            }
        } else if let headerView = view as? CustomizationHeaderView {
            if let set = customizationSets[section.key ?? ""] {
                headerView.configure(customizationSet: set, isBackground: customizationType == "background")
            } else {
                headerView.label.text = section.title?.localizedUppercase
                headerView.label.textColor = ThemeService.shared.theme.quadTextColor
            }
        }
        
        return view
    }
}
