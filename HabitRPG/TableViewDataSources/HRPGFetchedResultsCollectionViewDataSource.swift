//
//  HRPGFetchedResultsCollectionViewDataSource.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/31/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGFetchedResultsCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    var collectionView: UICollectionView?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    // MARK: Collection view data source and delegate methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    //MARK: FetchedResultsController delegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex) as IndexSet
        switch type {
        case NSFetchedResultsChangeType.insert:
            collectionView?.insertSections(indexSet)
            break
            
        case NSFetchedResultsChangeType.delete:
            collectionView?.deleteSections(indexSet)
            break
            
        case NSFetchedResultsChangeType.update:
            collectionView?.reloadSections(indexSet)
            break
            
        case NSFetchedResultsChangeType.move:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.insert:
            if let newPath = newIndexPath {
                collectionView?.insertItems(at: [newPath])
            }
            break
        case NSFetchedResultsChangeType.delete:
            if let path = indexPath {
                collectionView?.deleteItems(at: [path])
            }
            break
        case NSFetchedResultsChangeType.update:
            if let path = indexPath {
                collectionView?.reloadItems(at: [path])
            }
            break
        case NSFetchedResultsChangeType.move:
            if let path = indexPath, let newPath = newIndexPath {
                collectionView?.deleteItems(at: [path])
                collectionView?.insertItems(at: [newPath])
            }
            break
        }
    }
}
