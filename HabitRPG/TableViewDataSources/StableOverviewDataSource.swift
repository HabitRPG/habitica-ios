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
}

class StableOverviewDataSource<ANIMAL: AnimalProtocol>: BaseReactiveCollectionViewDataSource<StableOverviewItem> {
    
    internal let stableRepository = StableRepository()
    internal var fetchDisposable: Disposable?
    
    var organizeByColor = false {
        didSet {
            fetchData()
        }
    }
    
    deinit {
        if let disposable = fetchDisposable {
            disposable.dispose()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let animalItem = item(at: indexPath), let overviewCell = cell as? StableOverviewCell {
            overviewCell.configure(item: animalItem)
        }
        
        return cell
    }
    
    internal func fetchData() {
        if let disposable = fetchDisposable {
            disposable.dispose()
        }
    }
    
    internal func mapData(owned: [String], animals: [AnimalProtocol]) -> [String: [StableOverviewItem]] {
        var data = ["drop": [StableOverviewItem](), "quest": [StableOverviewItem](), "special": [StableOverviewItem](), "wacky": [StableOverviewItem]()]
        animals.forEach { (animal) in
            let type = (animal.type == "premium" ? "drop" : animal.type) ?? ""
            var item = data[type]?.last
            let isOwned = owned.contains(animal.key ?? "")
            
            if animal.type == "special" && !isOwned {
                return
            }
            
            let searchText = ((animal.type == "special" || animal.type == "wacky") ? animal.key : (organizeByColor ? animal.potion : animal.egg)) ?? ""
            
            if item?.text == nil || item?.text != searchText {
                item = StableOverviewItem(imageName: getImageName(animal), text: searchText, numberOwned: 0, totalNumber: 0, searchKey: searchText, type: animal.type ?? "")
                if let item = item {
                    data[type]?.append(item)
                }
            }
            if animal.type != "premium" || isOwned {
                item?.totalNumber += 1
            }
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
            return "Pet-\(animal.key ?? "")"
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
            let countLabel = view.viewWithTag(2) as? UILabel
            countLabel?.textColor = ThemeService.shared.theme.ternaryTextColor
            view.viewWithTag(3)?.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            var ownedCount = 0
            visibleSections[indexPath.section].items.forEach { ownedCount += $0.numberOwned }
            var totalCount = 0
            visibleSections[indexPath.section].items.forEach { totalCount += $0.totalNumber }
            countLabel?.text = "\(ownedCount)/\(totalCount)"
        }
        
        return view
    }
}
