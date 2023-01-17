//
//  StableOverviewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

struct StableOverviewItem {
    var imageName: String
    var text: String
    var numberOwned: Int
    var totalNumber: Int
    var searchKey: String
    var type: String
    var animal: String
    var color: String
}

class StableOverviewDataSource<ANIMAL: AnimalProtocol>: BaseReactiveCollectionViewDataSource<StableOverviewItem> {
    
    internal let stableRepository = StableRepository()
    internal let inventoryRepository = InventoryRepository()
    internal var fetchDisposable: Disposable?
    
    var organizeByColor = false {
        didSet {
            fetchData()
        }
    }
    
    var ownedItems = [String: OwnedItemProtocol]()
    
    deinit {
        if let disposable = fetchDisposable {
            disposable.dispose()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let animalItem = item(at: indexPath), let overviewCell = cell as? StableOverviewCell {
            var ownsItem = false
            if animalItem.type != "special" {
                if organizeByColor || animalItem.type == "wacky"{
                    ownsItem = ownedItems["\(animalItem.color)-hatchingPotions"] != nil
                } else {
                    ownsItem = ownedItems["\(animalItem.animal)-eggs"] != nil
                }
            } else {
                ownsItem = true
            }
            overviewCell.configure(item: animalItem, ownsItem: ownsItem)
        }
        
        return cell
    }
    
    internal func fetchData() {
        if let disposable = fetchDisposable {
            disposable.dispose()
        }
    }
    
    internal func mapData(owned: [String], animals: [AnimalProtocol], items: [String: String]) -> [String: [StableOverviewItem]] {
        var data = ["drop": [StableOverviewItem](), "quest": [StableOverviewItem](), "special": [StableOverviewItem](), "wacky": [StableOverviewItem]()]
        animals.forEach { (animal) in
            if !animal.isValid {
                return
            }
            let type = (animal.type == "premium" ? "drop" : animal.type) ?? ""
            var item = data[type]?.last
            let isOwned = owned.contains(animal.key ?? "")
            
            if animal.type == "special" && !isOwned {
                return
            }
            
            var displayText = (organizeByColor ? animal.potion : animal.egg) ?? ""
            if animal.type == "special" && animal.text?.isEmpty != false {
                let split = animal.key?.split(separator: "-")
                displayText = split?.reversed().joined(separator: " ") ?? ""
            } else if animal.type == "special", let text = animal.text {
                displayText = text
            } else if animal.type == "wacky" {
                displayText = "\(items["potion-" + (animal.potion ?? "")] ?? "") \(items["egg-" + (animal.egg ?? "")] ?? "")"
            } else if let text = items[(organizeByColor ? "potion-\(animal.potion ?? "")" : "egg-\(animal.egg ?? "")")] {
                displayText = text
            }
            let searchText = ((animal.type == "special" || animal.type == "wacky") ? animal.key : (organizeByColor ? animal.potion : animal.egg)) ?? ""
            
            if item?.text == nil || item?.text != displayText {
                item = StableOverviewItem(imageName: getImageName(animal),
                                          text: displayText,
                                          numberOwned: 0,
                                          totalNumber: 0,
                                          searchKey: searchText,
                                          type: animal.type ?? "",
                                          animal: animal.egg ?? "",
                                          color: animal.potion ?? "")
                if let item = item {
                    data[type]?.append(item)
                }
            }
            item?.totalNumber += 1
            if isOwned {
                item?.numberOwned += 1
            }
            if let item = item {
                let lastIndex = (data[type]?.count ?? 1) - 1
                data[type]?[lastIndex] = item
            }
        }
        return data
    }
    
    internal func getImageName(_ animal: AnimalProtocol) -> String {
        if animal.type == "special" || animal.type == "wacky" {
            return "stable_Pet-\(animal.key ?? "")"
        } else {
            if organizeByColor {
                return "Pet_HatchingPotion_\(animal.potion ?? "")"
            } else {
                return "Pet_Egg_\(animal.egg ?? "")"
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reuseIdentifier = (kind == UICollectionView.elementKindSectionFooter) ? "SectionFooter" : "SectionHeader"
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if kind == UICollectionView.elementKindSectionHeader {
            let label = view.viewWithTag(1) as? UILabel
            label?.text = visibleSections[indexPath.section].title
            label?.textColor = ThemeService.shared.theme.secondaryTextColor
            let countLabel = view.viewWithTag(2) as? UILabel
            countLabel?.textColor = ThemeService.shared.theme.ternaryTextColor
            view.viewWithTag(3)?.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            var ownedCount = 0
            visibleSections[indexPath.section].items.forEach { ownedCount += $0.numberOwned }
            var totalCount = 0
            visibleSections[indexPath.section].items.forEach { totalCount += $0.totalNumber }
            countLabel?.text = "\(ownedCount)/\(totalCount)"
            
            view.shouldGroupAccessibilityChildren = true
            view.isAccessibilityElement = true
            view.accessibilityLabel = visibleSections[indexPath.section].title ?? "" + " " + L10n.Accessibility.xofx(ownedCount, totalCount)
        }
        
        return view
    }
}
