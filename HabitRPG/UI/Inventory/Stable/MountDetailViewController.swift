//
//  MountDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import SwiftUI

class MountDetailViewController: StableDetailViewController<MountDetailDataSource> {

    private var stableRepository = StableRepository()
    private let userRepository = UserRepository()
    
    private var user: UserProtocol?
    
    override func viewDidLoad() {
        datasource = MountDetailDataSource(searchEggs: searchEggs, searchKey: searchKey)
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
        if let item = datasource?.item(at: indexPath), item.owned == true {
            showActionSheet(forStableItem: item, withSource: collectionView.cellForItem(at: indexPath))
        }
    }
    
    private func showActionSheet(forStableItem stableItem: MountStableItem, withSource sourceView: UIView?) {
        let sheet = HostingBottomSheetController(rootView: BottomSheetMenu(Text(stableItem.mount?.text ?? ""), iconName: "stable_Mount-Icon-\(stableItem.mount?.key ?? "")",  menuItems: {
            BottomSheetMenuitem(title: user?.items?.currentMount == stableItem.mount?.key ? L10n.unequip : L10n.equip) {[weak self] in
                self?.inventoryRepository.equip(type: "mount", key: stableItem.mount?.key ?? "").observeCompleted {}
            }
        }))
        present(sheet, animated: true)
    }
}
