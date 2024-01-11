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
            return (category1.items.first?.currency == "gold" ? 1 : 0) > (category2.items.first?.currency == "gold" ? 1 : 0)
        }) {
            let newSection = ItemSection<InAppRewardProtocol>(title: category.text)
            newSection.items = category.items
            sections.append(newSection)
        }
        collectionView?.reloadData()
    }
}
