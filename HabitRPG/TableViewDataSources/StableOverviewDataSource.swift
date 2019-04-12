//
//  StableOverviewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

struct StableOverviewItem {
    var imageName: String
    var text: String
    var numberOwned: Int
    var totalNumber: Int
    var eggType: String
    var type: String
}

class StableOverviewDataSource<ANIMAL: AnimalProtocol>: BaseReactiveCollectionViewDataSource<StableOverviewItem> {
    
    internal let stableRepository = StableRepository()
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let animalItem = item(at: indexPath), let overviewCell = cell as? StableOverviewCell {
            overviewCell.configure(item: animalItem)
        }
        
        return cell
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
            
            if item?.text == nil || item?.text != animal.egg {
                item = StableOverviewItem(imageName: getImageName(animal), text: animal.egg ?? "", numberOwned: 0, totalNumber: 0, eggType: animal.egg ?? animal.key ?? "", type: animal.type ?? "")
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
            return "Pet_Egg_\(animal.egg ?? "")"
        }
    }
    
}
