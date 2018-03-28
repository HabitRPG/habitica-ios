//
//  HRPGFetchedResultsCollectionViewDataSource.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/31/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

@objc protocol HRPGFetchedResultsCollectionViewDataSourceDelegate {
    func onEmptyFetchedResults()
}

class HRPGFetchedResultsCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    @objc var collectionView: UICollectionView?
    var contentChangeWasUpdate = false
    @objc weak var fetchedResultsDelegate: HRPGFetchedResultsCollectionViewDataSourceDelegate?
    @objc var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            if let results = fetchedResultsController, let sections = results.sections, sections.count == 0 {
                fetchedResultsDelegate?.onEmptyFetchedResults()
            }
            fetchedResultsController?.delegate = self
        }
    }
    
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
    
    // MARK: FetchedResultsController delegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if !contentChangeWasUpdate {
            collectionView?.reloadData()
        }
        contentChangeWasUpdate = false
    }
}
