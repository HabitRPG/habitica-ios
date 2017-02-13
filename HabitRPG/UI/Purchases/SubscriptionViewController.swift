//
//  SubscriptionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 07/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import Keys

class SubscriptionViewController: HRPGBaseViewController {

    @IBOutlet weak var restorePurchaseButton: UIButton!
    let identifiers = ["subscription1month", "com.habitrpg.ios.habitica.subscription.3month",
                       "com.habitrpg.ios.habitica.subscription.6month", "com.habitrpg.ios.habitica.subscription.12month"
    ]
    
    var products: [SKProduct]?
    var selectedSubscriptionPlan: SKProduct?
    var user: User?
    let appleValidator: AppleReceiptValidator
    let itunesSharedSecret = HabiticaKeys().itunesSharedSecret()
    
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

        let optionNib = UINib.init(nibName: "SubscriptionOptionView", bundle: nil)
        self.tableView.register(optionNib, forCellReuseIdentifier: "OptionCell")
        let detailNib = UINib.init(nibName: "SubscriptionDetailView", bundle: nil)
        self.tableView.register(detailNib, forCellReuseIdentifier: "DetailCell")
        
        let navigationController = self.navigationController as! HRPGGemHeaderNavigationController
        let inset = UIEdgeInsets(top: navigationController.getContentInset(), left: 0, bottom: 0, right: 0)
        self.tableView.contentInset = inset
        self.tableView.scrollIndicatorInsets = inset
        
        retrieveProductList()
        
        self.user = self.sharedManager.getUser()
        
        if let user = self.user {
            if user.subscriptionPlan.isActive() {
                isSubscribed = true
                restorePurchaseButton.isHidden = true
            }
        }
        
        SwiftyStoreKit.completeTransactions(atomically: false) { products in
            SwiftyStoreKit.verifyReceipt(using: self.appleValidator, password: self.itunesSharedSecret) { result in
                switch result {
                case .success(let receipt):
                    for product in products {
                        if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
                            if product.needsFinishTransaction {
                                if self.isSubscription(product.productId) {
                                    if self.isValidSubscription(product.productId, receipt: receipt) {
                                        self.activateSubscription(product.productId, receipt: receipt) { status in
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
                return self.identifiers.index(of: product1.productIdentifier)! < self.identifiers.index(of: product2.productIdentifier)!
            })
            self.tableView.reloadData()
        }
    }
    
    @IBAction func checkForExistingSubscription(_ sender: Any) {
        SwiftyStoreKit.refreshReceipt { (result) in
            switch result {
            case .success( _):
                SwiftyStoreKit.verifyReceipt(using: self.appleValidator, password: self.itunesSharedSecret) { result in
                    switch result {
                    case .success(let verifiedReceipt):
                        guard let purchases = verifiedReceipt["latest_receipt_info"] as? [ReceiptInfo] else {
                            return
                        }
                        for purchase in purchases {
                            let identifier = purchase["product_id"] as! String
                            if self.isValidSubscription(identifier, receipt: verifiedReceipt) {
                                self.activateSubscription(identifier, receipt: verifiedReceipt) {status in
                                    if status {
                                        return
                                    }
                                }
                            }
                        }
                    case .error(let error):
                        print("Receipt verification failed: \(error)")
                    }
                }
            case .error(let error):
                print("Receipt refreshing failed: \(error)")
            }

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let navigationController = self.navigationController as? HRPGGemHeaderNavigationController {
            navigationController.start(following: self.tableView)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDescriptionSection(section) {
            return 0
        } else if isOptionSection(section) {
            guard let products = self.products else {
                return 0
            }
            return products.count
        } else if isDetailSection(section) {
            return 1
        } else {
            if isSubscribed || self.products == nil || self.products?.count == 0 {
                return 0
            } else {
                return 1;
            }
        }
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isDescriptionSection(indexPath.section) {
            return 50
        } else if isOptionSection(indexPath.section) {
            return 96
        } else if isDetailSection(indexPath.section) {
            return 550;
        }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if !isOptionSection(indexPath.section) {
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSubscriptionPlan = (self.products?[indexPath.item]);
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if self.isOptionSection(indexPath.section) {
            let c = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! SubscriptionOptionView
            let product = self.products?[indexPath.item]
            c.priceLabel.text = product?.localizedPrice
            c.titleLabel.text = product?.localizedTitle
            cell = c
        } else if self.isDetailSection(indexPath.section) {
            let c = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! SubscriptionDetailView
            if let user = self.user {
                c.setPlan(user.subscriptionPlan)
                c.cancelSubscriptionAction = {
                    var url: URL?
                    if user.subscriptionPlan.paymentMethod == "Apple" {
                        url = URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")
                    } else {
                        url = URL(string: "https://habitica.com")
                    }
                    if url != nil {
                        UIApplication.shared.openURL(url!)
                    }
                }
            }
            cell = c
        } else if indexPath.section == tableView.numberOfSections-1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SubscribeButtonCell", for: indexPath)
        }
        cell?.selectionStyle = .none
        return cell!;
    }
    
    func isDescriptionSection(_ section: Int) -> Bool {
        return section == 0
    }
    
    func isOptionSection(_ section: Int) -> Bool {
        return !isSubscribed && section == 1
    }
    
    func isDetailSection(_ section: Int) -> Bool {
        return isSubscribed && section == 1
    }
    
    @IBAction func subscribeButtonPressed(_ sender: Any) {
        self.subscribeToPlan()
    }
    
    func subscribeToPlan() {
        guard let identifier = self.selectedSubscriptionPlan?.productIdentifier else {
            return;
        }
        SwiftyStoreKit.purchaseProduct(identifier, atomically: false) { result in
            switch result {
            case .success(let product):
                self.verifyAndSubscribe(product)
                print("Purchase Success: \(product.productId)")
            case .error(let error):
                print("Purchase Failed: \(error)")
            }
        }
    }
    
    func verifyAndSubscribe(_ product: Product) {
        SwiftyStoreKit.verifyReceipt(using: appleValidator, password: self.itunesSharedSecret) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                if self.isValidSubscription(product.productId, receipt: receipt) {
                    self.activateSubscription(product.productId, receipt: receipt) { status in
                        if (status) {
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
    
    func activateSubscription(_ identifier: String, receipt: ReceiptInfo, completion: @escaping (Bool) -> Void) {
        self.sharedManager.subscribe(identifier, withReceipt:receipt["latest_receipt"] as! String!, onSuccess: {
            completion(true)
            self.isSubscribed = true
            self.tableView.reloadData()
        }, onError: {
            completion(false)
        })
    }
    
    func isSubscription(_ identifier: String) -> Bool {
        return  self.identifiers.contains(identifier)
    }
    
    func isValidSubscription(_ identifier: String, receipt: ReceiptInfo) -> Bool {
        if !isSubscription(identifier) {
            return false
        }
        let purchaseResult = SwiftyStoreKit.verifySubscription(
            productId: identifier,
            inReceipt: receipt,
            validUntil: Date()
        )
        switch purchaseResult {
        case .purchased(_):
            return true
        case .expired(_):
            return false
        case .notPurchased:
            return false
        }
    }
}
