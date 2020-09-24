//
//  PetOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class PetOverviewViewController: StableOverviewViewController<PetOverviewDataSource> {
    
    override var organizeByColor: Bool {
        didSet {
            datasource?.organizeByColor = organizeByColor
        }
    }
    
    override func viewDidLoad() {
        datasource = PetOverviewDataSource()
        datasource?.collectionView = collectionView
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.petDetailSegue.rawValue {
            let destination = segue.destination as? PetDetailViewController
            guard let cell = sender as? UICollectionViewCell else {
                return
            }
            let indexPath = collectionView?.indexPath(for: cell)
            destination?.searchKey = datasource?.item(at: indexPath)?.searchKey ?? ""
            destination?.searchEggs = !organizeByColor
            destination?.animalType = datasource?.item(at: indexPath)?.type ?? ""
        }
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.pets
        navigationItem.rightBarButtonItem?.title = L10n.groupBy
    }
}
