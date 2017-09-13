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

class GemViewController : UICollectionViewController, SeedsInAppMessageDelegate {
    
    let identifiers = ["com.habitrpg.ios.Habitica.4gems", "com.habitrpg.ios.Habitica.21gems",
                        "com.habitrpg.ios.Habitica.42gems", "com.habitrpg.ios.Habitica.84gems"
    ]
    
    var products: [SKProduct]?
    var user: User?
    let appleValidator: AppleReceiptValidator
    let itunesSharedSecret = HabiticaKeys().itunesSharedSecret
    var expandedList = [Bool](repeating: false, count: 4)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        #if DEBUG
            appleValidator = AppleReceiptValidator(service: .sandbox)
        #else
            appleValidator = AppleReceiptValidator(service: .production)
        #endif
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        #if DEBUG
            appleValidator = AppleReceiptValidator(service: .sandbox)
        #else
            appleValidator = AppleReceiptValidator(service: .production)
        #endif
        super.init(coder: aDecoder)
    }
    
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
        completionHandler()
        
        self.user = HRPGManager.shared().getUser()
    }
    
    func completionHandler() {
        SwiftyStoreKit.completeTransactions(atomically: false) { products in
            SwiftyStoreKit.verifyReceipt(using: self.appleValidator, password: self.itunesSharedSecret) { result in
                switch result {
                case .success(let receipt):
                    for product in products {
                        if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
                            if product.needsFinishTransaction {
                                if self.isInAppPurchase(product.productId) {
                                    if self.isValidPurchase(product.productId, receipt: receipt) {
                                        self.activatePurchase(product.productId, receipt: receipt) { status in
                                            if status {
                                                SwiftyStoreKit.finishTransaction(product.transaction)
                                            }
                                        }
                                    } else {
                                        SwiftyStoreKit.finishTransaction(product.transaction)
                                    }
                                }
                            }
                        }
                    }
                default:
                    return
                }
            }
        }
    }
    
    func retrieveProductList() {
        SwiftyStoreKit.retrieveProductsInfo(Set(identifiers)) { (result) in
            self.products = Array(result.retrievedProducts)
            self.products?.sort(by: { (product1, product2) -> Bool in
                guard let firstIndex = self.identifiers.index(of: product1.productIdentifier) else {
                    return false
                }
                guard let secondIndex = self.identifiers.index(of: product2.productIdentifier) else {
                    return true
                }
                return firstIndex < secondIndex
            })
            self.collectionView?.reloadData()
        }
    }
    
    @IBAction func checkForExistingSubscription(_ sender: Any) {
        SwiftyStoreKit.verifyReceipt(using: self.appleValidator, password: self.itunesSharedSecret) { result in
            switch result {
            case .success(let verifiedReceipt):
                guard let purchases = verifiedReceipt["latest_receipt_info"] as? [ReceiptInfo] else {
                    return
                }
                for purchase in purchases {
                    if let identifier = purchase["product_id"] as? String {
                        if self.isValidPurchase(identifier, receipt: verifiedReceipt) {
                            self.activatePurchase(identifier, receipt: verifiedReceipt) {status in
                                if status {
                                    return
                                }
                            }
                        }
                    }
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
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
        purchaseGems(identifier: self.identifiers[indexPath.item])
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
            cell.showSeedsPromo(true)
        }
        
        cell.setPurchaseTap {[weak self] (purchaseButton) in
            switch purchaseButton?.state {
            case .some(HRPGPurchaseButtonStateError), .some(HRPGPurchaseButtonStateLabel):
                purchaseButton?.state = HRPGPurchaseButtonStateLoading
                self?.purchaseGems(identifier: product.productIdentifier)
                break
            case .some(HRPGPurchaseButtonStateDone):
                self?.dismiss(animated: true, completion: nil)
                break
            default:
                break
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var identifier = "nil"
        
        if kind == UICollectionElementKindSectionHeader {
            identifier = "HeaderView"
        }
        
        if kind == UICollectionElementKindSectionFooter {
            identifier = "FooterView"
        }
        
        let view = collectionView .dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        
        if kind == UICollectionElementKindSectionHeader {
            if let imageView = view.viewWithTag(1) as? UIImageView {
                imageView.image = HabiticaIcons.imageOfHeartLarge
            }
        }
        
        return view
    }

    func purchaseGems(identifier: String) {
        guard let user = self.user else {
            return
        }
        SwiftyStoreKit.purchaseProduct(identifier, quantity: 1, atomically: false, applicationUsername: user.hashedValueForAccountName()) { (result) in
            switch result {
            case .success(let product):
                self.verifyPurchase(product)
                print("Purchase Success: \(product.productId)")
            case .error(let error):
                print("Purchase Failed: \(error)")
            }
        }
    }
    
    func verifyPurchase(_ product: PurchaseDetails) {
        SwiftyStoreKit.verifyReceipt(using: appleValidator, password: self.itunesSharedSecret) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                if self.isValidPurchase(product.productId, receipt: receipt) {
                    self.activatePurchase(product.productId, receipt: receipt) { status in
                        if status {
                            if product.needsFinishTransaction {
                                SwiftyStoreKit.finishTransaction(product.transaction)
                            }
                        }
                    }
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    func activatePurchase(_ identifier: String, receipt: ReceiptInfo, completion: @escaping (Bool) -> Void) {
        if let lastReceipt = receipt["latest_receipt"] as? String {
            HRPGManager.shared().purchaseGems(["transaction": ["receipt": lastReceipt]], onSuccess: {
                completion(true)
                self.collectionView?.reloadData()
            }, onError: {
                completion(false)
            })
        }
    }
    
    func isInAppPurchase(_ identifier: String) -> Bool {
        return  self.identifiers.contains(identifier)
    }
    
    func isValidPurchase(_ identifier: String, receipt: ReceiptInfo) -> Bool {
        if !isInAppPurchase(identifier) {
            return false
        }
        let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: identifier, inReceipt: receipt)
        switch purchaseResult {
        case .purchased:
            return true
        case .notPurchased:
            return false
        }
    }
}
