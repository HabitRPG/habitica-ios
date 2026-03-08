//
//  PetOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import SwiftUI

class PetOverviewViewController: StableOverviewViewController<PetProtocol, PetOverviewDataSource> {

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
        datasource = PetOverviewDataSource()
        datasource?.collectionView = collectionView
        super.viewDidLoad()

        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start())
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == StoryboardSegue.Stable.petDetailSegue.rawValue {
            guard let cell = sender as? UICollectionViewCell,
                  let indexPath = collectionView?.indexPath(for: cell),
                  let item = datasource?.item(at: indexPath) else {
                return true
            }
            if (item.type == "special" || item.type == "wacky") && item.numberOwned > 0 {
                showPetBottomSheet(for: item)
                return false
            }
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Stable.petDetailSegue.rawValue {
            let destination = segue.destination as? PetDetailViewController
            guard let cell = sender as? UICollectionViewCell else {
                return
            }
            let indexPath = collectionView?.indexPath(for: cell)
            destination?.searchKey = datasource?.item(at: indexPath)?.searchKey ?? ""
            destination?.searchEggs = !organizeByColor
            destination?.animalType = datasource?.item(at: indexPath)?.type ?? ""
        }
    }

    override func populateText() {
        navigationItem.title = L10n.Titles.pets
        navigationItem.rightBarButtonItem?.title = L10n.groupBy
    }

    private func showPetBottomSheet(for item: StableOverviewItem) {
        disposable.inner.add(
            SignalProducer.combineLatest(
                stableRepository.getPet(key: item.searchKey),
                stableRepository.getOwnedPets(query: "key == '\(item.searchKey)'"),
                stableRepository.getOwnedMounts(query: "key == '\(item.searchKey)'"),
                stableRepository.getMounts(query: "key == '\(item.searchKey)'")
            )
            .take(first: 1)
            .on(value: {[weak self] (pet, ownedPets, ownedMounts, mounts) in
                guard let pet = pet else {
                    return
                }
                let trained = ownedPets.value.first?.trained ?? 0
                let mountExists = mounts.value.first != nil
                let mountOwned = ownedMounts.value.first?.owned ?? false
                let canRaise = mountExists && !mountOwned
                let sheet = HostingBottomSheetController(rootView: PetBottomSheetView(
                    pet: pet,
                    trained: trained,
                    canRaise: canRaise,
                    isCurrentPet: self?.user?.items?.currentPet == pet.key,
                    onEquip: {[weak self] in
                        self?.inventoryRepository.equip(type: "pet", key: pet.key ?? "").observeCompleted {}
                    }
                ))
                sheet.show()
            })
            .start()
        )
    }
}
