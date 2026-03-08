//
//  MountOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import SwiftUI

class MountOverviewViewController: StableOverviewViewController<MountProtocol, MountOverviewDataSource> {

    private let stableRepository = StableRepository()
    private let inventoryRepository = InventoryRepository()
    private let userRepository = UserRepository()
    private var user: UserProtocol?
    private let disposable = ScopedDisposable(CompositeDisposable())

    override var organizeByColor: Bool {
        didSet {
            datasource?.organizeByColor = organizeByColor
        }
    }

    override func viewDidLoad() {
        datasource = MountOverviewDataSource()
        datasource?.collectionView = collectionView
        super.viewDidLoad()

        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start())
    }

    override func populateText() {
        navigationItem.title = L10n.Titles.mounts
        navigationItem.rightBarButtonItem?.title = L10n.groupBy
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == StoryboardSegue.Stable.mountDetailSegue.rawValue {
            guard let cell = sender as? UICollectionViewCell,
                  let indexPath = collectionView?.indexPath(for: cell),
                  let item = datasource?.item(at: indexPath) else {
                return true
            }
            if (item.type == "special" || item.type == "wacky") && item.numberOwned > 0 {
                showMountBottomSheet(for: item)
                return false
            }
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Stable.mountDetailSegue.rawValue {
            let destination = segue.destination as? MountDetailViewController
            guard let cell = sender as? UICollectionViewCell else {
                return
            }
            let indexPath = collectionView?.indexPath(for: cell)
            destination?.searchKey = datasource?.item(at: indexPath)?.searchKey ?? ""
            destination?.searchEggs = !organizeByColor
            destination?.animalType = datasource?.item(at: indexPath)?.type ?? ""
        }
    }

    private func showMountBottomSheet(for item: StableOverviewItem) {
        disposable.inner.add(
            stableRepository.getMount(key: item.searchKey)
                .take(first: 1)
                .on(value: {[weak self] mount in
                    guard let mount = mount else {
                        return
                    }
                    let sheet = HostingBottomSheetController(rootView: MountBottomSheetView(
                        mount: mount,
                        owned: true,
                        isCurrentMount: self?.user?.items?.currentMount == mount.key,
                        onEquip: {[weak self] in
                            self?.inventoryRepository.equip(type: "mount", key: mount.key ?? "").observeCompleted {}
                        }
                    ))
                    sheet.show()
                })
                .start()
        )
    }
}
