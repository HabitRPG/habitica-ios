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
    func showGearSelection()
}

class HRPGShopCollectionViewDataSource: HRPGFetchedResultsCollectionViewDataSource {
    @objc weak var delegate: HRPGShopCollectionViewDataSourceDelegate?
    
    @objc var ownedItems = [String: Item]()
    @objc var pinnedItems = [String: InAppReward]()
    
    @objc var needsGearSection: Bool = false
    @objc var selectedGearCategory: String?
    
    // MARK: Collection view data source and delegate methods
    
    func titleFor(section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if needsGearSection && !hasGearSection() {
            return super.numberOfSections(in: collectionView) + 1
        } else {
            return super.numberOfSections(in: collectionView)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if needsGearSection && !hasGearSection() {
            if section == 0 {
                return 0
            } else {
                return super.collectionView(collectionView, numberOfItemsInSection: section-1)
            }
        } else {
            return super.collectionView(collectionView, numberOfItemsInSection: section)
        }
    }
    
    func itemAt(indexPath: IndexPath) -> ShopItem? {
        if needsGearSection && !hasGearSection() {
            return fetchedResultsController?.sections?[indexPath.section-1].objects?[indexPath.item] as? ShopItem
        } else {
            return fetchedResultsController?.sections?[indexPath.section].objects?[indexPath.item] as? ShopItem
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: "sectionHeader", for: indexPath
            ) as? HRPGShopSectionHeaderCollectionReusableView
        
        if let headerView = view {
            headerView.gearCategoryButton.isHidden = true
            headerView.otherClassDisclaimer.isHidden = true
            if indexPath.section == 0 && needsGearSection {
                headerView.titleLabel.text = NSLocalizedString("Class Equipment", comment: "")
                headerView.gearCategoryLabel.text = selectedGearCategory?.capitalized
                headerView.gearCategoryButton.isHidden = false
                headerView.onGearCategoryLabelTapped = {[weak self] in
                    self?.delegate?.showGearSelection()
                }
                let userClass = HRPGManager.shared().getUser().hclass
                headerView.otherClassDisclaimer.isHidden = userClass == selectedGearCategory
            } else if needsGearSection && !hasGearSection() {
                headerView.titleLabel.text = titleFor(section: indexPath.section-1)
            } else {
                headerView.titleLabel.text = titleFor(section: indexPath.section)
            }
            
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 && needsGearSection {
            let userClass = HRPGManager.shared().getUser().hclass
            if userClass != selectedGearCategory {
                return CGSize(width: collectionView.bounds.width, height: 75)
            }
        }
        return CGSize(width: collectionView.bounds.width, height: 50)
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
    
    private func hasGearSection() -> Bool {
        if let firstSection = fetchedResultsController?.sections?.first {
            if let firstObject = firstSection.objects?.first as? ShopItem {
                return firstObject.pinType == "marketGear"
            }
        }
        return false
    }
}
