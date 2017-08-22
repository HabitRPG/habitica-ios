//
//  RewardViewController.swift
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class RewardViewController: HRPGBaseCollectionViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var fetchRequest: NSFetchRequest<MetaReward> = {
        return NSFetchRequest<MetaReward>(entityName: "MetaReward")
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<MetaReward> = {
        self.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "type", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: self.fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "type",
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customRewardNib = UINib.init(nibName: "CustomRewardCell", bundle: .main)
        collectionView?.register(customRewardNib, forCellWithReuseIdentifier: "CustomRewardCell")
        let inAppRewardNib = UINib.init(nibName: "InAppRewardCell", bundle: .main)
        collectionView?.register(inAppRewardNib, forCellWithReuseIdentifier: "InAppRewardCell")
        
        collectionView?.alwaysBounceVertical = true
        refreshControl.tintColor = UIColor.purple400()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
        
        do {
            try? self.fetchedResultsController.performFetch()
        }
    }
    
    func refresh() {
        self.sharedManager.fetchBuyableRewards({[weak self] in
            self?.refreshControl.endRefreshing()
        }) {[weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomRewardCell", for: indexPath)
            if let rewardCell = cell as? CustomRewardCell, let reward = self.fetchedResultsController.object(at: indexPath) as? Reward {
                rewardCell.configure(reward: reward)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InAppRewardCell", for: indexPath)
            if let rewardCell = cell as? InAppRewardCell {
                rewardCell.configure(reward: self.fetchedResultsController.object(at: indexPath), manager: sharedManager)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: self.view.frame.size.width, height: 60)
        } else {
            return CGSize(width: 80, height: 108)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 8
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 8
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }
    }
}
