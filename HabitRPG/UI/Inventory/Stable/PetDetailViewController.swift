//
//  PetDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import SwiftUI

class PetDetailViewController: StableDetailViewController<PetDetailDataSource> {
    private let userRepository = UserRepository()
    
    private var user: UserProtocol?
    
    private var selectedPet: PetProtocol?
    
    override func viewDidLoad() {
        datasource = PetDetailDataSource(searchEggs: searchEggs, searchKey: searchKey)
        if animalType == "drop" || animalType == "premium" {
            datasource?.types = ["drop", "premium"]
        } else {
            datasource?.types = [animalType]
        }
        datasource?.collectionView = collectionView
        super.viewDidLoad()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
        }).start())
    }
    
    deinit {
        datasource?.dispose()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = datasource?.item(at: indexPath) {
            if item.trained > 0 {
                showActionSheet(forStableItem: item, withSource: collectionView.cellForItem(at: indexPath))
            } else {
                showHatchingDialog(forStableItem: item)
            }
        }
    }
    
    private func showActionSheet(forStableItem stableItem: PetStableItem, withSource sourceView: UIView?) {
        guard let pet = stableItem.pet else {
            return
        }
        if #available(iOS 16.0, *) {
            let sheet = HostingBottomSheetController(rootView: PetBottomSheetView(pet: pet,
                                                                                  trained: stableItem.trained,
                                                                                  canRaise: stableItem.canRaise,
                                                                                  isCurrentPet: user?.items?.currentPet == stableItem.pet?.key,
                                                                                  onEquip: {[weak self] in
                self?.inventoryRepository.equip(type: "pet", key: pet.key ?? "").observeCompleted {}
            }))
            present(sheet, animated: true)
        } else {
            let sheet = HostingBottomSheetController(rootView: BottomSheetMenu(Text(stableItem.pet?.text ?? ""), iconName: "stable_Pet-\(stableItem.pet?.key ?? "")", menuItems: {
                if stableItem.trained > 0 && stableItem.pet?.type != "special" && stableItem.canRaise {
                    BottomSheetMenuitem(title: L10n.Stable.feed) {[weak self] in
                        self?.selectedPet = stableItem.pet
                        DispatchQueue.main.async {
                            self?.perform(segue: StoryboardSegue.Main.feedSegue)
                        }
                    }
                }
                if stableItem.trained > 0 {
                    BottomSheetMenuitem(title: user?.items?.currentPet == stableItem.pet?.key ? L10n.unequip : L10n.equip) {[weak self] in
                        self?.inventoryRepository.equip(type: "pet", key: stableItem.pet?.key ?? "").observeCompleted {}
                    }
                }
            }))
            present(sheet, animated: true)
        }
    }
    
    private func showHatchingDialog(forStableItem item: PetStableItem) {
        let ownedItems = datasource?.ownedItemsFor(pet: item)
        let alert = PetHatchingAlertController(item: item, ownedEggs: ownedItems?.eggs, ownedPotions: ownedItems?.potions)
        alert.show()
    }
    
    @IBAction func unwindToList(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToFeed(_ segue: UIStoryboardSegue) {
        let feedViewController = segue.source as? FeedViewController
        if let pet = selectedPet, let food = feedViewController?.selectedFood {
            inventoryRepository.feed(pet: pet, food: food).observeCompleted {}
        }
    }
    
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
                let equipString = L10n.equip
                actions.append(UIAction(title: equipString, handler: {[weak self] _ in
                    self?.inventoryRepository.equip(type: "pet", key: stableItem.pet?.key ?? "").observeCompleted {}
                }))
            }
            return UIMenu(title: stableItem.pet?.text ?? "", children: actions)
        })
    }
}
