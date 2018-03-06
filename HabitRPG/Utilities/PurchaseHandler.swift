//
//  PurchaseHandler.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit
import Keys
import Crashlytics

class PurchaseHandler: NSObject {
    @objc static let shared = PurchaseHandler()

    static let IAPIdentifiers = ["com.habitrpg.ios.Habitica.4gems", "com.habitrpg.ios.Habitica.21gems",
                              "com.habitrpg.ios.Habitica.42gems", "com.habitrpg.ios.Habitica.84gems"
    ]
    static let subscriptionIdentifiers = ["subscription1month", "com.habitrpg.ios.habitica.subscription.3month",
                       "com.habitrpg.ios.habitica.subscription.6month", "com.habitrpg.ios.habitica.subscription.12month"
    ]
    
    private let itunesSharedSecret = HabiticaKeys().itunesSharedSecret
    private let appleValidator: AppleReceiptValidator

    private var hasCompletionHandler = false
    override private init() {
        #if DEBUG
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #else
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #endif
    }
    
    @objc
    func completionHandler() {
        if hasCompletionHandler {
            return
        }
        hasCompletionHandler = true
        SwiftyStoreKit.completeTransactions(atomically: false) { products in
            if products.count > 0 {
                for product in products {
                    CLSLogv("Purchase: %@ %@", getVaList([product.productId, NSNumber(value: product.needsFinishTransaction)]))
                }
                let error = NSError(domain: SKErrorDomain, code: -1001, userInfo: nil)
                Crashlytics.sharedInstance().recordError(error)
            }
            SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
                switch result {
                case .success(let receiptData):
                    for product in products {
                        if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
                            if product.needsFinishTransaction {
                                
                                if self.isInAppPurchase(product.productId) {
                                    self.activatePurchase(product.productId, receipt: receiptData) { status in
                                        if status {
                                            SwiftyStoreKit.finishTransaction(product.transaction)
                                        }
                                    }
                                } else if self.isSubscription(product.productId) {
                                    if !HRPGManager.shared().getUser().isSubscribed() {
                                        SwiftyStoreKit.verifyReceipt(using: self.appleValidator, completion: { (verificationResult) in
                                            switch verificationResult {
                                            case .success(let receipt):
                                                if self.isValidSubscription(product.productId, receipt: receipt) {
                                                    self.activateSubscription(product.productId, receipt: receipt) { status in
                                                        if status {
                                                            SwiftyStoreKit.finishTransaction(product.transaction)
                                                        }
                                                    }
                                                } else {
                                                    SwiftyStoreKit.finishTransaction(product.transaction)
                                                }
                                            case .error(let error):
                                                Crashlytics.sharedInstance().recordError(error)
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    }
                case .error(let error):
                    Crashlytics.sharedInstance().recordError(error)
                }
            }
        }
    }
    
    func purchaseGems(_ identifier: String, applicationUsername: String, completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.purchaseProduct(identifier, quantity: 1, atomically: false, applicationUsername: applicationUsername) { (result) in
            switch result {
            case .success(let product):
                self.verifyPurchase(product)
                completion(true)
            case .error(let error):
                Crashlytics.sharedInstance().recordError(error)
                completion(false)
            }
        }
    }
    
    func verifyPurchase(_ product: PurchaseDetails) {
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            switch result {
            case .success(let receiptData):
                // Verify the purchase of a Subscription
                self.activatePurchase(product.productId, receipt: receiptData) { status in
                    if status {
                        if product.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(product.transaction)
                        }
                    }
                }
            case .error(let error):
                Crashlytics.sharedInstance().recordError(error)
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    func activatePurchase(_ identifier: String, receipt: Data, completion: @escaping (Bool) -> Void) {
        HRPGManager.shared().purchaseGems(["transaction": ["receipt": receipt.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))]], onSuccess: {
            completion(true)
        }, onError: {
            completion(false)
        })
    }
    
    func isInAppPurchase(_ identifier: String) -> Bool {
        return PurchaseHandler.IAPIdentifiers.contains(identifier)
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
    
    func activateSubscription(_ identifier: String, receipt: ReceiptInfo, completion: @escaping (Bool) -> Void) {
        if let lastReceipt = receipt["latest_receipt"] as? String {
            HRPGManager.shared().subscribe(identifier, withReceipt: lastReceipt, onSuccess: {
                completion(true)
            }, onError: {
                completion(false)
            })
        }
    }
    
    func isSubscription(_ identifier: String) -> Bool {
        return  PurchaseHandler.subscriptionIdentifiers.contains(identifier)
    }
    
    func isValidSubscription(_ identifier: String, receipt: ReceiptInfo) -> Bool {
        if !isSubscription(identifier) {
            return false
        }
        let purchaseResult = SwiftyStoreKit.verifySubscription(
            ofType: .autoRenewable,
            productId: identifier,
            inReceipt: receipt,
            validUntil: Date()
        )
        switch purchaseResult {
        case .purchased:
            return true
        case .expired:
            return false
        case .notPurchased:
            return false
        }
    }
}
