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
        
        if let item = fetchedResultsController?.sections?[indexPath.section].objects?[indexPath.item] as? ShopItem {
            //set currency
            var cell: HRPGCurrencyItemCollectionViewCell!
            if item.currency == "gems" {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gemItemCell", for: indexPath) as? HRPGCurrencyItemCollectionViewCell
            } else if item.currency == "gold" {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "goldItemCell", for: indexPath) as? HRPGCurrencyItemCollectionViewCell
            } else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourglassItemCell", for: indexPath) as? HRPGCurrencyItemCollectionViewCell
            }
            if let value = item.value {
                cell.currencyCountView.countLabel.text = String(describing: value.intValue)
            }
            
            //set image
            if let imageName = item.imageName {
                if imageName.contains(" ") {
                    HRPGManager.shared().setImage(imageName.components(separatedBy: " ")[1], withFormat: "png", on: cell.itemImageView)
                } else {
                    HRPGManager.shared().setImage(imageName, withFormat: "png", on: cell.itemImageView)
                }
            }
            
            //set optional corner image
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem(fetchedResultsController?.sections?[indexPath.section].objects?[indexPath.item] as? ShopItem)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
}
