//
//  AvatarDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class AvatarDetailViewController: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var customizationDataSource: AvatarDetailViewDataSource?
    private var gearDataSource: AvatarGearDetailViewDataSource?
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    private let customizationRepository = CustomizationRepository()
    var customizationGroup: String?
    var customizationType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let type = customizationType {
            if type == "eyewear" || type == "headAccessory" {
                gearDataSource = AvatarGearDetailViewDataSource(type: type)
                gearDataSource?.collectionView = self.collectionView
            } else {
                customizationDataSource = AvatarDetailViewDataSource(type: type, group: customizationGroup)
                customizationDataSource?.collectionView = self.collectionView
                
                customizationDataSource?.purchaseSet = { set in
                    self.showPurchaseDialog(customizationSet: set, withSource: nil)
                 }
            }
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        collectionView.backgroundColor = theme.contentBackgroundColor
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let datasource = customizationDataSource {
            return datasource.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        } else if let datasource = gearDataSource {
            return datasource.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
        return CGSize.zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let datasource = customizationDataSource, let customization = datasource.item(at: indexPath) {
            if !customization.isPurchasable || datasource.owns(customization: customization) == true {
                userRepository.updateUser(key: customization.userPath, value: customization.key ?? "").observeCompleted {}
            } else {
                showPurchaseDialog(customization: customization, withSource: cell)
            }
        } else if let datasource = gearDataSource, let gear = datasource.item(at: indexPath) {
            if datasource.owns(gear: gear) {
                inventoryRepository.equip(type: "equipped", key: gear.key ?? "").observeCompleted {}
            } else {
                showPurchaseDialog(gear: gear, withSource: cell)
            }
        }
    }
    
    private func showPurchaseDialog(customization: CustomizationProtocol, withSource sourceView: UIView?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction.cancelAction())
        alertController.addAction(UIAlertAction(title: L10n.purchaseForGems(Int(customization.price)), style: .default, handler: {[weak self] (_) in
            self?.customizationRepository.unlock(customization: customization, value: customization.price).observeCompleted {}
        }))
        if let sourceView = sourceView {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        } else {
            alertController.setSourceInCenter(view)
        }
        alertController.show()
    }
    
    private func showPurchaseDialog(gear: GearProtocol, withSource sourceView: UIView?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction.cancelAction())
        var value = Int(gear.value)
        if gear.gearSet == "animal" {
            value = 2
        }
        alertController.addAction(UIAlertAction(title: L10n.purchaseForGems(value), style: .default, handler: {[weak self] (_) in
            self?.customizationRepository.unlock(gear: gear, value: value).observeCompleted {}
        }))
        if let sourceView = sourceView {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        } else {
            alertController.setSourceInCenter(view)
        }
        alertController.show()
    }
    
    private func showPurchaseDialog(customizationSet: CustomizationSetProtocol, withSource sourceView: UIView?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction.cancelAction())
        alertController.addAction(UIAlertAction(title: L10n.purchaseForGems(Int(customizationSet.setPrice)), style: .default, handler: {[weak self] (_) in
            self?.customizationRepository.unlock(customizationSet: customizationSet, value: customizationSet.setPrice).observeCompleted {}
        }))
        if let sourceView = sourceView {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        } else {
            alertController.setSourceInCenter(view)
        }
        alertController.show()
    }
}
