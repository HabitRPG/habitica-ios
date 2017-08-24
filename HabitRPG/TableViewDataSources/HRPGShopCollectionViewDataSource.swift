//
//  HRPGShopCollectionViewDataSource.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/29/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

@objc protocol HRPGShopCollectionViewDataSourceDelegate {
    func didSelectItem(_ item: ShopItem?)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

class HRPGShopCollectionViewDataSource: HRPGFetchedResultsCollectionViewDataSource {
    weak var delegate: HRPGShopCollectionViewDataSourceDelegate?
    
    // MARK: Collection view data source and delegate methods
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: "sectionHeader", for: indexPath
            ) as? HRPGShopSectionHeaderCollectionReusableView
        
        if let headerView = view {
            headerView.titleLabel.text = fetchedResultsController?.sections?[indexPath.section].name
            return headerView
        }
        return UICollectionReusableView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath)
        if let item = fetchedResultsController?.sections?[indexPath.section].objects?[indexPath.item] as? ShopItem {
            if let itemCell = cell as? InAppRewardCell {
                itemCell.configure(item: item)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem(fetchedResultsController?.sections?[indexPath.section].objects?[indexPath.item] as? ShopItem)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
}
