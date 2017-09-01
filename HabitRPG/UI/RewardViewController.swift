//
//  RewardViewController.swift
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class RewardViewController: HRPGBaseCollectionViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var fetchRequest: NSFetchRequest<MetaReward> = {
        return NSFetchRequest<MetaReward>(entityName: "MetaReward")
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<MetaReward> = {
        self.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "type", ascending: false),
        NSSortDescriptor(key: "order", ascending: true)]
        
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
        HRPGManager.shared().fetchBuyableRewards({[weak self] in
            self?.refreshControl.endRefreshing()
        }) {[weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private var editedReward: Reward?
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let reward = self.fetchedResultsController.object(at: indexPath) as? Reward {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomRewardCell", for: indexPath)
            if let rewardCell = cell as? CustomRewardCell {
                rewardCell.configure(reward: reward)
                rewardCell.canAfford = reward.value.floatValue < HRPGManager.shared().getUser().gold.floatValue
                rewardCell.onBuyButtonTapped = {
                    HRPGManager.shared().getReward(reward.key, withText: reward.text, onSuccess: nil, onError: nil)
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InAppRewardCell", for: indexPath)
            if let rewardCell = cell as? InAppRewardCell, let reward = self.fetchedResultsController.object(at: indexPath) as? InAppReward {
                rewardCell.configure(reward: reward)
            }
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let reward = self.fetchedResultsController.object(at: indexPath) as? Reward {
            editedReward = reward
            performSegue(withIdentifier: "FormSegue", sender: self)
        } else {
            let storyboard = UIStoryboard(name: "BuyModal", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "HRPGBuyItemModalViewController") as? HRPGBuyItemModalViewController {
                viewController.modalTransitionStyle = .crossDissolve
                viewController.reward = self.fetchedResultsController.object(at: indexPath)
                if let tabbarController = self.tabBarController {
                    tabbarController.present(viewController, animated: true, completion: nil)
                } else {
                    present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isCustomRewardsSection(indexPath.section) {
            return CGSize(width: self.view.frame.size.width, height: 60)
        } else {
            return CGSize(width: 90, height: 120)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if isCustomRewardsSection(section) {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 12, left: 6, bottom: 12, right: 6)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //TODO: Implement correctly
        /*guard let indexPath = indexPath else {
            return
        }
        switch type {
        case .delete:
            collectionView?.deleteItems(at: [indexPath])
            break
        case .insert:
            collectionView?.insertItems(at: [indexPath])
            break
        case .move:
            guard let newIndexPath = newIndexPath else {
                return
            }
            collectionView?.moveItem(at: indexPath, to: newIndexPath)
            break
        case .update:
            collectionView?.reloadItems(at: [indexPath])
            break
        }*/
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.reloadData()
    }
    
    func isCustomRewardsSection(_ section: Int) -> Bool {
        if let section = self.fetchedResultsController.sections?[section], section.numberOfObjects > 0 {
            if section.objects?.first as? Reward != nil {
                return true
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FormSegue", let reward = self.editedReward {
            guard let destinationController = segue.destination as? UINavigationController else {
                return
            }
            guard let formController = destinationController.topViewController as? RewardFormController else {
                return
            }

            formController.editReward = true
            formController.reward = reward
            self.editedReward = nil
        }
    }
    
    @IBAction func undindToList(segue: UIStoryboardSegue) {}
    
    @IBAction func unwindToSaveReward(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? RewardFormController {
            if sourceViewController.editReward {
                HRPGManager.shared().update(sourceViewController.reward, onSuccess: nil, onError: nil)
            } else {
                HRPGManager.shared().createReward(sourceViewController.reward, onSuccess: nil, onError: nil)
            }
        }
    }
}
