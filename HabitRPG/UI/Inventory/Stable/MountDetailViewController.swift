//
//  MountDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class MountDetailViewController: StableDetailViewController<MountDetailDataSource> {
    
    var eggType: String = ""
    var mountType: String = "drop"
    
    private var inventoryRepository = InventoryRepository()
    private var stableRepository = StableRepository()
    private let userRepository = UserRepository()
    
    private var user: UserProtocol?
    
    override func viewDidLoad() {
        datasource = MountDetailDataSource(eggType: eggType)
        if mountType == "drop" || mountType == "premium" {
            datasource?.types = ["drop", "premium"]
        } else {
            datasource?.types = [mountType]
        }
        datasource?.collectionView = self.collectionView
        super.viewDidLoad()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
        }).start())
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.mounts
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = datasource?.item(at: indexPath), item.owned == true {
            showActionSheet(forStableItem: item, withSource: collectionView.cellForItem(at: indexPath))
        }
    }
    
    private func showActionSheet(forStableItem stableItem: MountStableItem, withSource sourceView: UIView?) {
        let actionSheet = UIAlertController(title: stableItem.mount?.text, message: nil, preferredStyle: .actionSheet)
        var equipString = L10n.equip
        if user?.items?.currentMount == stableItem.mount?.key {
            equipString = L10n.unequip
        }
        actionSheet.addAction(UIAlertAction(title: equipString, style: .default, handler: {[weak self] (_) in
            self?.inventoryRepository.equip(type: "mount", key: stableItem.mount?.key ?? "").observeCompleted {}
        }))
        actionSheet.addAction(UIAlertAction.cancelAction())
        if let sourceView = sourceView {
            actionSheet.popoverPresentationController?.sourceView = sourceView
            actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
        } else {
            actionSheet.setSourceInCenter(view)
        }
        actionSheet.show()
    }
}
