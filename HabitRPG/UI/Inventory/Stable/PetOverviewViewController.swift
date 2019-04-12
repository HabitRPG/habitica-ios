//
//  PetOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class PetOverviewViewController: StableOverviewViewController<PetOverviewDataSource> {
    
    override func viewDidLoad() {
        datasource = PetOverviewDataSource()
        datasource?.collectionView = self.collectionView
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.petDetailSegue.rawValue {
            let destination = segue.destination as? PetDetailViewController
            guard let cell = sender as? UICollectionViewCell else {
                return
            }
            let indexPath = collectionView?.indexPath(for: cell)
            destination?.eggType = datasource?.item(at: indexPath)?.eggType ?? ""
            destination?.petType = datasource?.item(at: indexPath)?.type ?? ""
        }
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.pets
        navigationItem.rightBarButtonItem?.title = L10n.groupBy
    }
}
