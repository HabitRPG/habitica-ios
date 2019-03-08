//
//  MountDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class MountDetailViewController: StableDetailViewController<MountDetailDataSource> {
    
    var eggType: String = ""
    
    private var inventoryRepository = InventoryRepository()
    private var stableRepository = StableRepository()
    
    override func viewDidLoad() {
        datasource = MountDetailDataSource(eggType: eggType)
        datasource?.collectionView = self.collectionView
        super.viewDidLoad()
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
        actionSheet.addAction(UIAlertAction(title: L10n.equip, style: .default, handler: {[weak self] (_) in
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
