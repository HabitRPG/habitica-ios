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

class MountDetailViewController: StableDetailViewController<MountProtocol, MountStableItem, MountDetailDataSource> {

    private var stableRepository = StableRepository()
    private let userRepository = UserRepository()
    
    private var user: UserProtocol?
    
    override func viewDidLoad() {
        showMounts = true
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if animalType == "special" || animalType == "wacky" {
            if let firstItem = datasource?.sections.first?.items.first, firstItem.owned == true {
                showActionSheet(forStableItem: firstItem, withSource: nil)
            }
        }
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
        guard let mount = stableItem.mount else {
            return
        }
        let sheet = HostingBottomSheetController(rootView: MountBottomSheetView(mount: mount,
                                                                                owned: stableItem.owned,
                                                                                isCurrentMount: user?.items?.currentMount == stableItem.mount?.key,
                                                                                onEquip: {[weak self] in
            self?.inventoryRepository.equip(type: "mount", key: mount.key ?? "").observeCompleted {}
        }))
        sheet.show()
    }
}
