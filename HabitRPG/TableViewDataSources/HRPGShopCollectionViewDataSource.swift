//
//  HRPGShopCollectionViewDataSource.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/29/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

@objc protocol HRPGShopCollectionViewDataSourceDelegate {
    func didSelectItem(_ item: ShopItem?)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

class HRPGShopCollectionViewDataSource: HRPGFetchedResultsCollectionViewDataSource {
    @objc weak var delegate: HRPGShopCollectionViewDataSourceDelegate?
    
    @objc var ownedItems = [String: Item]()
    @objc var pinnedItems = [String: InAppReward]()
    
    // MARK: Collection view data source and delegate methods
    
    func titleFor(section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name
    }
    
    func itemAt(indexPath: IndexPath) -> ShopItem? {
        return fetchedResultsController?.sections?[indexPath.section].objects?[indexPath.item] as? ShopItem
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: "sectionHeader", for: indexPath
            ) as? HRPGShopSectionHeaderCollectionReusableView
        
        if let headerView = view {
            headerView.titleLabel.text = titleFor(section: indexPath.section)
            return headerView
        }
        return UICollectionReusableView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath)
        if let item = itemAt(indexPath: indexPath) {
            if let itemCell = cell as? InAppRewardCell {
                itemCell.configure(item: item)
                if let ownedItem = ownedItems[item.key ?? ""] {
                    itemCell.itemsLeft = ownedItem.owned.intValue
                }
                itemCell.isPinned = pinnedItems.contains(where: { (key, _) -> Bool in
                    return key == item.key ?? ""
                })
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem(itemAt(indexPath: indexPath))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
}
