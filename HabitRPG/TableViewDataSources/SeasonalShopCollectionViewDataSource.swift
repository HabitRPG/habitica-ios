//
//  SeasonalShopCollectionViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.03.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class SeasonalShopCollectionViewDataSource: ShopCollectionViewDataSource {
    
    override func loadCategories(_ categories: [ShopCategoryProtocol]) {
        sections.removeAll()
        for category in categories.sorted(by: { category1, category2 in
            return (category1.items.first?.currency == "gold" ? 1 : 0, category1.identifier == "quests" ? 10000 : findReleaseYear(key: category1.items.first?.key ?? "")) > (category2.items.first?.currency == "gold" ? 1 : 0, category1.identifier == "quests" ? 10000 : findReleaseYear(key: category2.items.first?.key ?? ""))
        }) {
            let newSection = ItemSection<InAppRewardProtocol>(title: category.text)
            newSection.items = category.items
            newSection.endDate = category.endDate
            sections.append(newSection)
        }
        collectionView?.reloadData()
    }
    
    private func findReleaseYear(key: String) -> Int {
        let result = key.filter({ $0.isNumber })
        if result.isEmpty {
            return 2014
        } else {
            return Int(result) ?? 0
        }
    }
}
