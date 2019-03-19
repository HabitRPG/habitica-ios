//
//  TimeTravelersCollectionViewDataSource.swift
//  Habitica
//
//  Created by Phillip on 21.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class TimeTravelersCollectionViewDataSource: ShopCollectionViewDataSource {
    
    override func loadCategories(_ categories: [ShopCategoryProtocol], isSubscribed: Bool) {
        sections.removeAll()
        for category in categories {
            for item in category.items {
                if item.purchaseType == "pets" || item.purchaseType == "mounts" {
                    if let lastSection = sections.last, lastSection.key == item.key {
                        lastSection.items.append(item)
                    } else {
                        let section = ItemSection<InAppRewardProtocol>()
                        section.title = item.category?.text
                        section.key = item.category?.identifier
                        section.items = [item]
                        sections.append(section)
                    }
                } else {
                    if sections.isEmpty || !sections.contains(where: { (section) -> Bool in section.key == "mystery_sets" }) {
                        let section = ItemSection<InAppRewardProtocol>()
                        section.key = "mystery_sets"
                        section.title = L10n.mysterySets
                        section.items = [InAppRewardProtocol]()
                        sections.append(section)
                    }
                    if let setSection = sections.first(where: { (section) -> Bool in
                        section.key == "mystery_sets"
                    }) {
                        if setSection.items.isEmpty || setSection.items.last?.key != item.category?.identifier {
                            let newItem = inventoryRepository.getNewInAppReward()
                            let key = item.category?.identifier ?? ""
                            newItem.text = item.category?.text
                            newItem.key = key
                            newItem.pinType = item.pinType ?? "mystery_set"
                            newItem.purchaseType = newItem.pinType
                            newItem.path = item.path ?? "mystery."+key
                            newItem.value = item.value
                            newItem.currency = item.currency
                            newItem.imageName = "shop_set_mystery_"+key
                            setSection.items.append(newItem)
                        }
                    }
                }
            }
        }
        //Flip the order to have pets and mounts first
        sections.reverse()
        self.collectionView?.reloadData()
    }
}
