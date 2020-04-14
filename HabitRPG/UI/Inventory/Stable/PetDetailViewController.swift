//
//  PetDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class PetDetailViewController: StableDetailViewController<PetDetailDataSource> {
    
    var searchEggs = true
    var searchKey: String = ""
    var petType: String = "drop"
    
    private let inventoryRepository = InventoryRepository()
    private let userRepository = UserRepository()
    
    private var user: UserProtocol?
    
    private var selectedPet: PetProtocol?
    
    override func viewDidLoad() {
        datasource = PetDetailDataSource(searchEggs: searchEggs, searchKey: searchKey)
        if petType == "drop" || petType == "premium" {
            datasource?.types = ["drop", "premium"]
        } else {
            datasource?.types = [petType]
        }
        datasource?.collectionView = collectionView
        super.viewDidLoad()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
        }).start())
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.pets
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = datasource?.item(at: indexPath), item.trained > 0 {
            showActionSheet(forStableItem: item, withSource: collectionView.cellForItem(at: indexPath))
        }
    }
    
    private func showActionSheet(forStableItem stableItem: PetStableItem, withSource sourceView: UIView?) {
        let actionSheet = UIAlertController(title: stableItem.pet?.text, message: nil, preferredStyle: .actionSheet)
        if stableItem.trained > 0 && stableItem.pet?.type != "special" && stableItem.canRaise {
            actionSheet.addAction(UIAlertAction(title: L10n.Stable.feed, style: .default, handler: {[weak self] (_) in
                self?.selectedPet = stableItem.pet
                self?.perform(segue: StoryboardSegue.Main.feedSegue)
            }))
        }
        if stableItem.trained > 0 {
            var equipString = L10n.equip
            if user?.items?.currentPet == stableItem.pet?.key {
                equipString = L10n.unequip
            }
            actionSheet.addAction(UIAlertAction(title: equipString, style: .default, handler: {[weak self] (_) in
                self?.inventoryRepository.equip(type: "pet", key: stableItem.pet?.key ?? "").observeCompleted {}
            }))
        }
        actionSheet.addAction(UIAlertAction.cancelAction())
        if let sourceView = sourceView {
            actionSheet.popoverPresentationController?.sourceView = sourceView
            actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
        } else {
            actionSheet.setSourceInCenter(view)
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func unwindToList(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToFeed(_ segue: UIStoryboardSegue) {
        let feedViewController = segue.source as? HRPGFeedViewController
        if let pet = selectedPet, let food = feedViewController?.selectedFood {
            inventoryRepository.feed(pet: pet, food: food).observeCompleted {}
        }
    }
    
    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let stableItem = datasource?.item(at: indexPath) else {
            return nil
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            var actions = [UIAction]()
            if stableItem.trained > 0 && stableItem.pet?.type != "special" && stableItem.canRaise {
                actions.append(UIAction(title: L10n.Stable.feed, handler: {[weak self] (_) in
                    self?.selectedPet = stableItem.pet
                    self?.perform(segue: StoryboardSegue.Main.feedSegue)
                }))
            }
            if stableItem.trained > 0 {
                var equipString = L10n.equip
                actions.append(UIAction(title: equipString, handler: {[weak self] _ in
                    self?.inventoryRepository.equip(type: "pet", key: stableItem.pet?.key ?? "").observeCompleted {}
                }))
            }
            return UIMenu(title: stableItem.pet?.text ?? "", children: actions)
        })
    }
}
