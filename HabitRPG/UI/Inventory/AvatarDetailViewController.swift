//
//  AvatarDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import SwiftUI

class AvatarDetailViewController: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var customizationDataSource: AvatarDetailViewDataSource?
    private var gearDataSource: AvatarGearDetailViewDataSource?
    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    private let customizationRepository = CustomizationRepository()
    private let configRepository = ConfigRepository.shared
    var customizationGroup: String?
    var customizationType: String?
    
    private let headerView = AvatarHeaderView()
    
    private var newCustomizationLayout = false
    
    override func viewDidLoad() {
        topHeaderCoordinator?.hideNavBar = false
        super.viewDidLoad()
        topHeaderCoordinator?.alternativeHeader = headerView
        topHeaderCoordinator?.followScrollView = false
        
        newCustomizationLayout = configRepository.bool(variable: .enableCustomizationShop) || configRepository.testingLevel.isDeveloper
        
        if let type = customizationType {
            if type == "eyewear" || type == "headAccessory" || type == "back" || type == "animalTails" {
                gearDataSource = AvatarGearDetailViewDataSource(type: type, newCustomizationLayout: newCustomizationLayout)
                gearDataSource?.collectionView = collectionView
            } else {
                customizationDataSource = AvatarDetailViewDataSource(type: type, group: customizationGroup, newCustomizationLayout: newCustomizationLayout)
                customizationDataSource?.collectionView = collectionView
                
                customizationDataSource?.purchaseSet = {[weak self] set in
                    self?.showPurchaseDialog(customizationSet: set, withSource: nil)
                 }
            }
        }
        HabiticaAnalytics.shared.logNavigationEvent("navigated \(customizationType ?? "") screen")
        
        userRepository.getUser().on(value: { [weak self] user in
            self?.headerView.setAvatar(avatar: user)
        }).start()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == collectionView.numberOfSections - 1 && newCustomizationLayout {
            return CGSize(width: collectionView.frame.width, height: 200)
        } else if newCustomizationLayout {
            return CGSize(width: collectionView.frame.width, height: 20)
        }
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        collectionView.backgroundColor = theme.contentBackgroundColor
        collectionView.layer.cornerRadius = 22
        topHeaderCoordinator?.navbarVisibleColor = theme.windowBackgroundColor
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let datasource = customizationDataSource {
            return datasource.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        } else if let datasource = gearDataSource {
            return datasource.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let width = 80
        let viewWidth = Int(collectionView.frame.size.width)
        var count = 3
        if let dataSource = gearDataSource {
            let inSection = dataSource.collectionView(collectionView, numberOfItemsInSection: section)
            if inSection < count {
                count = inSection
            }
        } else if let dataSource = customizationDataSource {
            let inSection = dataSource.collectionView(collectionView, numberOfItemsInSection: section)
            if inSection < count {
                count = inSection
            }
        }
        let totalWidth = width * count + (10 * (count-1))
        let spacing = CGFloat(viewWidth - totalWidth) / 2
        return UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let datasource = customizationDataSource, let customization = datasource.item(at: indexPath) {
            if !customization.isPurchasable || datasource.owns(customization: customization) == true {
                var key = customization.key ?? ""
                if customization.key == datasource.equippedKey {
                    if customization.type == "background" {
                        key = datasource.equippedKey ?? ""
                        customizationRepository.unlock(path: "background.\(key)", value: 0, text: "")
                            .flatMap(.latest, { _ in
                                return self.userRepository.retrieveUser(forced: true)
                            })
                            .observeCompleted {}
                    } else if customization.type == "hair" && customizationGroup != "color" {
                        key = "0"
                    } else {
                        return
                    }
                }
                userRepository.updateUser(key: customization.userPath, value: key).observeCompleted {}
            } else {
                if customization.set?.key?.contains("timeTravel") == true {
                    showTimeTravelDialog()
                } else {
                    showPurchaseDialog(customization: customization, withSource: cell)
                }
            }
        } else if let datasource = gearDataSource, let gear = datasource.item(at: indexPath) {
            if datasource.owns(gear: gear) {
                inventoryRepository.equip(type: datasource.preferences?.useCostume == true ? "costume" : "equipped", key: gear.key ?? "").observeCompleted {}
            } else {
                showPurchaseDialog(gear: gear, withSource: cell)
            }
        }
    }
    
    private func showPurchaseDialog(customization: CustomizationProtocol, withSource sourceView: UIView?) {
        let sheet = HostingBottomSheetController(rootView: BottomSheetMenu(Text(customization.titleText), iconName: customization.iconName(forUserPreferences: nil) ?? "", menuItems: {
            BottomSheetMenuitem(title: HStack {
                Text(L10n.purchaseForWithoutCurrency(Int(customization.price)))
                Image(uiImage: HabiticaIcons.imageOfGem)
            }) {[weak self] in
                if self?.customizationDataSource?.canAfford(price: customization.price) != true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        HRPGBuyItemModalViewController.displayInsufficientGemsModal(reason: "customization", delayDisplay: false)
                    })
                    return
                }
                self?.customizationRepository.unlock(customization: customization, value: customization.price).observeCompleted {}
            }
            })
        )
        present(sheet, animated: true)
    }
    
    private func showPurchaseDialog(gear: GearProtocol, withSource sourceView: UIView?) {
        var value = Int(gear.value)
        if gear.gearSet == "animal" {
            value = 2
        }
        let sheet = HostingBottomSheetController(rootView: BottomSheetMenu(menuItems: {
            BottomSheetMenuitem(title: HStack {
                Text(L10n.purchaseForWithoutCurrency(value))
                Image(uiImage: HabiticaIcons.imageOfGem)
            }) {[weak self] in
                self?.customizationRepository.unlock(gear: gear, value: value).observeCompleted {}
            }
            })
        )
        present(sheet, animated: true)
    }
    
    private func showPurchaseDialog(customizationSet: CustomizationSetProtocol, withSource sourceView: UIView?) {
        var text = customizationSet.text ?? ""
        if customizationType == "background", let key = customizationSet.key?.replacingOccurrences(of: "backgrounds", with: "") {
            let index = key.index(key.startIndex, offsetBy: 2)
            let month = Int(key[..<index]) ?? 0
            let year = Int(key[index...]) ?? 0
            let dateFormatter = DateFormatter()
            let monthName = month > 0 ? dateFormatter.monthSymbols[month-1] : ""
            text = "\(monthName) \(year) Backgrounds"
        }
        let sheet = HostingBottomSheetController(rootView: BottomSheetMenu(Text(text), menuItems: {
            BottomSheetMenuitem(title: HStack {
                Text(L10n.purchaseForWithoutCurrency(Int(customizationSet.setPrice)))
                Image(uiImage: HabiticaIcons.imageOfGem)
            }) {[weak self] in
                if self?.customizationDataSource?.canAfford(price: customizationSet.setPrice) != true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        HRPGBuyItemModalViewController.displayInsufficientGemsModal(reason: "customization", delayDisplay: false)
                    })
                    return
                }
                self?.customizationRepository.unlock(customizationSet: customizationSet, value: customizationSet.setPrice).observeCompleted {}
            }
            })
        )
        present(sheet, animated: true)
    }
    
    private func showTimeTravelDialog() {
        let alertController = HabiticaAlertController(title: L10n.purchaseCustomization, message: L10n.purchaseFromTimeTravelersShop)
        alertController.addAction(title: L10n.goShopping, isMainAction: true) { _ in
            let storyboard = UIStoryboard(name: "Shop", bundle: nil)
            if let viewController = storyboard.instantiateInitialViewController() as? ShopViewController {
                viewController.shopIdentifier = Constants.TimeTravelersShopKey
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        alertController.addCancelAction()
        alertController.show()
    }
}

extension CustomizationProtocol {
    var titleText: String {
        if type == "background" {
            return text ?? ""
        } else {
            if path.contains("skin") {
                return L10n.Inventory.avatarSkinCustomization
            } else if path.contains("shirt") {
                return L10n.Inventory.avatarShirtCustomization
            } else if path.contains("color") {
                return L10n.Inventory.avatarHairColorCustomization
            } else if path.contains("base") {
                return L10n.Inventory.avatarHairStyleCustomization
            } else if path.contains("bangs") {
                return L10n.Inventory.avatarBangsCustomization
            } else if path.contains("beard") {
                return L10n.Inventory.avatarBeardCustomization
            } else if path.contains("mustache") {
                return L10n.Inventory.avatarMustacheCustomization
            }
        }
        return ""
    }
}
