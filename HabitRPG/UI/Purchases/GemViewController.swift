//
//  GemViewController.swift
//  Habitica
//
//  Created by Phillip on 13.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import SeedsSDK
import SwiftyStoreKit
import StoreKit
import Keys
import ReactiveSwift
import Habitica_Models

class GemViewController: BaseCollectionViewController {
    
    var products: [SKProduct]?
    var user: UserProtocol?
    var expandedList = [Bool](repeating: false, count: 4)
    
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    var isSubscribed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib.init(nibName: "GemPurchaseView", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "Cell")
        
        if let navigationController = self.navigationController as? HRPGGemHeaderNavigationController {
            let inset = UIEdgeInsets(top: navigationController.getContentInset(), left: 0, bottom: 0, right: 0)
            self.collectionView?.contentInset = inset
            self.collectionView?.scrollIndicatorInsets = inset
        }
        retrieveProductList()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
        }).start())
    }
    
    func retrieveProductList() {
        SwiftyStoreKit.retrieveProductsInfo(Set(PurchaseHandler.IAPIdentifiers)) { (result) in
            self.products = Array(result.retrievedProducts)
            self.products?.sort(by: { (product1, product2) -> Bool in
                guard let firstIndex = PurchaseHandler.IAPIdentifiers.index(of: product1.productIdentifier) else {
                    return false
                }
                guard let secondIndex = PurchaseHandler.IAPIdentifiers.index(of: product2.productIdentifier) else {
                    return true
                }
                return firstIndex < secondIndex
            })
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let navigationController = self.navigationController as? HRPGGemHeaderNavigationController {
            navigationController.start(following: self.collectionView)
        }
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let navigationController = self.navigationController as? HRPGGemHeaderNavigationController {
            navigationController.stopFollowingScrollView()
        }
        super.viewWillDisappear(animated)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let navigationController = self.navigationController as? HRPGGemHeaderNavigationController {
            navigationController.scrollview(scrollView, scrolledToPosition: scrollView.contentOffset.y)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        purchaseGems(identifier: PurchaseHandler.IAPIdentifiers[indexPath.item])
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let product = self.products?[indexPath.item], let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? HRPGGemPurchaseView else {
            return UICollectionViewCell()
        }
        cell.setPrice(product.localizedPrice)
        cell.showSeedsPromo(false)

        if product.productIdentifier == "com.habitrpg.ios.Habitica.4gems" {
            cell.setGemAmount(4)
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.21gems" {
            cell.setGemAmount(21)
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.42gems" {
            cell.setGemAmount(42)
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.84gems" {
            cell.setGemAmount(84)
            cell.showSeedsPromo(false)
        }
        
        cell.setPurchaseTap {[weak self] (purchaseButton) in
            switch purchaseButton?.state {
            case .some(HRPGPurchaseButtonStateError), .some(HRPGPurchaseButtonStateLabel):
                purchaseButton?.state = HRPGPurchaseButtonStateLoading
                self?.purchaseGems(identifier: product.productIdentifier)
            case .some(HRPGPurchaseButtonStateDone):
                self?.dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var identifier = "nil"
        
        if kind == UICollectionView.elementKindSectionHeader {
            identifier = "HeaderView"
        }
        
        if kind == UICollectionView.elementKindSectionFooter {
            identifier = "FooterView"
        }
        
        let view = collectionView .dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        
        if kind == UICollectionView.elementKindSectionHeader {
            if let imageView = view.viewWithTag(1) as? UIImageView {
                imageView.image = HabiticaIcons.imageOfHeartLarge
            }
            if let label = view.viewWithTag(2) as? UILabel {
                label.text = L10n.gemsSupportDevelopers
            }
        }
        
        return view
    }

    func purchaseGems(identifier: String) {
        guard let user = self.user else {
            return
        }
        PurchaseHandler.shared.purchaseGems(identifier, applicationUsername: String(user.id?.hashValue ?? 0)) { _ in
            self.collectionView?.reloadData()
        }
    }
    
}
