//
//  GemViewController.swift
//  Habitica
//
//  Created by Phillip on 13.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
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
    private let configRepository = ConfigRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
 
    var isSubscribed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib.init(nibName: "GemPurchaseView", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "Cell")
        retrieveProductList()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
        }).start())
        
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.shadowColor = .clear
            navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.backgroundColor = theme.contentBackgroundColor
        } else {
            navigationController?.navigationBar.backgroundColor = theme.contentBackgroundColor
        }
    }
    
    func retrieveProductList() {
        SwiftyStoreKit.retrieveProductsInfo(Set(PurchaseHandler.IAPIdentifiers)) { (result) in
            self.products = Array(result.retrievedProducts)
            self.products?.sort(by: { (product1, product2) -> Bool in
                guard let firstIndex = PurchaseHandler.IAPIdentifiers.firstIndex(of: product1.productIdentifier) else {
                    return false
                }
                guard let secondIndex = PurchaseHandler.IAPIdentifiers.firstIndex(of: product2.productIdentifier) else {
                    return true
                }
                return firstIndex < secondIndex
            })
            self.collectionView?.reloadData()
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

        if product.productIdentifier == "com.habitrpg.ios.Habitica.4gems" {
            cell.setGemAmount(4)
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.21gems" {
            cell.setGemAmount(21)
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.42gems" {
            cell.setGemAmount(42)
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.84gems" {
            cell.setGemAmount(84)
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
        
        if kind == UICollectionView.elementKindSectionFooter {
            if let imageView = view.viewWithTag(1) as? UIImageView {
                imageView.image = HabiticaIcons.imageOfHeartLarge
            }
            if let label = view.viewWithTag(2) as? UILabel {
                label.text = L10n.gemsSupportDevelopers
            }
            if let promoView = view.viewWithTag(3) as? SubscriptionPromoView {
                promoView.onButtonTapped = {[weak self] in self?.performSegue(withIdentifier: StoryboardSegue.Main.subscriptionSegue.rawValue, sender: self) }
            }
        } else if kind == UICollectionView.elementKindSectionHeader {
            if let headerImage = view.viewWithTag(1) as? UIImageView {
                headerImage.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
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
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
