//
//  AvatarDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class AvatarDetailViewController: HRPGCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var datasource: AvatarDetailViewDataSource?
    private let userRepository = UserRepository()
    private let customizationRepository = CustomizationRepository()
    var customizationGroup: String?
    var customizationType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let type = customizationType {
            datasource = AvatarDetailViewDataSource(type: type, group: customizationGroup)
            datasource?.collectionView = self.collectionView
            
            datasource?.purchaseSet = { set in
                self.showPurchaseDialog(customizationSet: set)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return datasource?.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? CGSize.zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let customization = datasource?.item(at: indexPath) {
            if !customization.isPurchasable || datasource?.owns(customization: customization) == true {
                userRepository.updateUser(key: customization.userPath, value: customization.key ?? "").observeCompleted {}
            } else {
                showPurchaseDialog(customization: customization)
            }
        }
    }
    
    private func showPurchaseDialog(customization: CustomizationProtocol) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction.cancelAction())
        alertController.addAction(UIAlertAction(title: L10n.purchaseForGems(Int(customization.price)), style: .default, handler: {[weak self] (_) in
            self?.customizationRepository.unlock(customization: customization).observeCompleted {}
        }))
        alertController.show()
    }
    
    private func showPurchaseDialog(customizationSet: CustomizationSetProtocol) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction.cancelAction())
        alertController.addAction(UIAlertAction(title: L10n.purchaseForGems(Int(customizationSet.setPrice)), style: .default, handler: {[weak self] (_) in
            self?.customizationRepository.unlock(customizationSet: customizationSet).observeCompleted {}
        }))
        alertController.show()
    }
}
