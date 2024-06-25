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
    
    override func loadCategories(_ categories: [ShopCategoryProtocol]) {
        sections.removeAll()
        let mysterySection = ItemSection<InAppRewardProtocol>()
        mysterySection.key = "mystery_sets"
        mysterySection.title = L10n.mysterySets
        mysterySection.items = [InAppRewardProtocol]()
        mysterySection.showIfEmpty = true
        for category in categories {
            for item in category.items {
                if item.category?.pinType != "mystery_set" {
                    if let lastSection = sections.last, lastSection.key == item.key || item.purchaseType == lastSection.key {
                        lastSection.items.append(item)
                    } else {
                        let section = ItemSection<InAppRewardProtocol>()
                        section.title = item.category?.text
                        section.key = item.category?.identifier
                        section.items = [item]
                        sections.append(section)
                    }
                } else {
                    if mysterySection.items.isEmpty || mysterySection.items.last?.key != item.category?.identifier {
                        let newItem = inventoryRepository.getNewInAppReward()
                        let key = item.category?.identifier ?? ""
                        newItem.text = item.category?.text
                        newItem.notes = item.category?.notes ?? item.notes
                        newItem.key = key
                        newItem.pinType = item.pinType ?? "mystery_set"
                        newItem.purchaseType = newItem.pinType
                        newItem.path = item.path ?? "mystery."+key
                        newItem.value = item.value
                        newItem.currency = item.currency
                        newItem.imageName = "shop_set_mystery_"+key
                        newItem.endDate = item.endDate
                        mysterySection.items.append(newItem)
                        mysterySection.endDate = newItem.endDate
                    }
                }
            }
        }
        sections.append(mysterySection)
        collectionView?.reloadData()
    }
}
