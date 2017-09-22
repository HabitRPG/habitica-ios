//
//  TimeTravelersCollectionViewDataSource.swift
//  Habitica
//
//  Created by Phillip on 21.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

class TimeTravelersCollectionViewDataSource: HRPGShopCollectionViewDataSource {

    var categories = [ShopCategory]()
    
    override var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            if let results = fetchedResultsController, let sections = results.sections, sections.count == 0 {
                fetchedResultsDelegate?.onEmptyFetchedResults()
            }
            fetchedResultsController?.delegate = self
            loadCategories()
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < categories.count {
            return categories[section].items?.count ?? 0
        }
        return 0
    }
    
    override func titleFor(section: Int) -> String? {
        if section < categories.count {
            return categories[section].text
        }
        return ""
    }
    
    override func itemAt(indexPath: IndexPath) -> ShopItem? {
        if indexPath.section < categories.count {
            return categories[indexPath.section].items?[indexPath.item] as? ShopItem
        }
        return nil
    }
    
    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                             didChange anObject: Any,
                             at indexPath: IndexPath?,
                             for type: NSFetchedResultsChangeType,
                             newIndexPath: IndexPath?) {
        //pass
    }
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadCategories()
    }
    
    private func loadCategories() {
        categories = [ShopCategory]()
        if let items = self.fetchedResultsController?.fetchedObjects as? [ShopItem],
            let categoryEntity = NSEntityDescription.entity(forEntityName: "ShopCategory", in: HRPGManager.shared().getManagedObjectContext()) ,
            let itemEntity = NSEntityDescription.entity(forEntityName: "ShopItem", in: HRPGManager.shared().getManagedObjectContext()) {
            for item in items {
                if item.type == "pets" || item.type == "mounts" {
                    if let lastCategory = categories.last, lastCategory.identifier == item.category?.identifier {
                        lastCategory.addItemsObject(item)
                    } else {
                        if let category = NSManagedObject(entity: categoryEntity, insertInto: nil) as? ShopCategory {
                            category.text = item.category?.text
                            category.identifier = item.category?.identifier
                            category.items = NSOrderedSet()
                            category.addItemsObject(item)
                            categories.append(category)
                        }
                    }
                } else {
                    if categories.count == 0 || categories.last?.identifier != "mystery_sets" {
                        if let category = NSManagedObject(entity: categoryEntity, insertInto: nil) as? ShopCategory {
                            categories.append(category)
                        }
                    }
                    if let lastCategory = categories.last {
                        if lastCategory.identifier == nil {
                            lastCategory.text = NSLocalizedString("Mystery Sets", comment: "")
                            lastCategory.identifier = "mystery_sets"
                            lastCategory.items = NSOrderedSet()
                        }
                        if lastCategory.items?.count == 0 || (lastCategory.items?.lastObject as? ShopItem)?.key != item.category?.identifier {
                            if let newItem = NSManagedObject(entity: itemEntity, insertInto: nil) as? ShopItem {
                                let key = item.category?.identifier ?? ""
                                newItem.text = item.category?.text
                                newItem.key = key
                                newItem.pinType = item.category?.pinType ?? "mystery_set"
                                newItem.purchaseType = newItem.pinType
                                newItem.path = item.category?.path ?? "mystery."+key
                                newItem.value = item.value
                                newItem.currency = item.currency
                                newItem.imageName = "shop_set_mystery_"+key
                                lastCategory.addItemsObject(newItem)
                            }
                        }
                    }
                }
            }
        }
        self.collectionView?.reloadData()
    }
}
