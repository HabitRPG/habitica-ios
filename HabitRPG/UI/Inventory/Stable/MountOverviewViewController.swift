//
//  MountOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class MountOverviewViewController: StableOverviewViewController<MountOverviewDataSource> {
    
    override func viewDidLoad() {
        datasource = MountOverviewDataSource()
        datasource?.collectionView = self.collectionView
        super.viewDidLoad()
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.mounts
        navigationItem.rightBarButtonItem?.title = L10n.groupBy
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.mountDetailSegue.rawValue {
            let destination = segue.destination as? MountDetailViewController
            guard let cell = sender as? UICollectionViewCell else {
                return
            }
            let indexPath = collectionView?.indexPath(for: cell)
            destination?.eggType = datasource?.item(at: indexPath)?.eggType ?? ""
            destination?.mountType = datasource?.item(at: indexPath)?.type ?? ""
        }
    }
}
