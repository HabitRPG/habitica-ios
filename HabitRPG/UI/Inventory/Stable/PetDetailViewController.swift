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
    
    var eggType: String = ""
    
    private let inventoryRepository = InventoryRepository()
    private let userRepository = UserRepository()
    
    private var user: UserProtocol?
    
    override func viewDidLoad() {
        datasource = PetDetailDataSource(eggType: eggType)
        datasource?.collectionView = self.collectionView
        super.viewDidLoad()
        
        disposable.inner.add(userRepository.getUser().on(value: { user in
            self.user = user
        }).start())
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = datasource?.item(at: indexPath), item.trained > 0 {
            showActionSheet(forStableItem: item)
        }
    }
    
    private func showActionSheet(forStableItem stableItem: PetStableItem) {
        let actionSheet = UIAlertController(title: stableItem.pet?.text, message: nil, preferredStyle: .actionSheet)
        if stableItem.trained > 0 && stableItem.pet?.type != "special" && !stableItem.mountOwned {
            actionSheet.addAction(UIAlertAction(title: L10n.Stable.feed, style: .default, handler: { (_) in
                self.perform(segue: StoryboardSegue.Main.feedSegue)
            }))
        }
        if stableItem.trained > 0 {
            var equipString = L10n.equip
            if user?.items?.currentPet == stableItem.pet?.key {
                equipString = L10n.unequip
            }
            actionSheet.addAction(UIAlertAction(title: equipString, style: .default, handler: { (_) in
                self.inventoryRepository.equip(type: "pet", key: stableItem.pet?.key ?? "").observeCompleted {}
            }))
        }
        actionSheet.addAction(UIAlertAction.cancelAction())
        actionSheet.show()
    }
}
