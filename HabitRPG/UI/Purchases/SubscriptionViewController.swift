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

class SubscriptionViewController: HRPGBaseViewController {

    var products: [SKProduct]?
    var selectedSubscriptionPlan: SKProduct?
    var user: User?
    
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
            } else {
                restorePurchases()
            }
        }
    }
    
    func retrieveProductList() {
        let identifiers = ["subscription1month", "com.habitrpg.ios.habitica.subscription.3month",
                           "com.habitrpg.ios.habitica.subscription.6month", "com.habitrpg.ios.habitica.subscription.12month"
        ]
        SwiftyStoreKit.retrieveProductsInfo(Set(identifiers)) { (result) in
            self.products = Array(result.retrievedProducts)
            self.products?.sort(by: { (product1, product2) -> Bool in
                return identifiers.index(of: product1.productIdentifier)! < identifiers.index(of: product2.productIdentifier)!
            })
            self.tableView.reloadData()
        }
    }
    
    func restorePurchases() {
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            if results.restoreFailedProducts.count > 0 {
                print("Restore Failed: \(results.restoreFailedProducts)")
            }
            else if results.restoredProducts.count > 0 {
                for product in results.restoredProducts {
                    // fetch content from your server, then:
                    if product.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                }
                print("Restore Success: \(results.restoredProducts)")
            }
            else {
                print("Nothing to Restore")
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
            return 500;
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
                let appleValidator = AppleReceiptValidator(service: .sandbox)
                SwiftyStoreKit.verifyReceipt(using: appleValidator, password: "your-shared-secret") { result in
                    switch result {
                    case .success(let receipt):
                        // Verify the purchase of a Subscription
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            productId: identifier,
                            inReceipt: receipt,
                            validUntil: Date()
                        )
                        switch purchaseResult {
                        case .purchased(let expiresDate):
                            print("Product is valid until \(expiresDate)")
                        case .expired(let expiresDate):
                            print("Product is expired since \(expiresDate)")
                        case .notPurchased:
                            print("The user has never purchased this product")
                        }
                        
                    case .error(let error):
                        print("Receipt verification failed: \(error)")
                    }
                }
                print("Purchase Success: \(product.productId)")
            case .error(let error):
                print("Purchase Failed: \(error)")
            }
        }
    }
}
