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
import Shared

class PurchaseHandler: NSObject, SKPaymentTransactionObserver {
    @objc static let shared = PurchaseHandler()

    static let IAPIdentifiers = ["com.habitrpg.ios.Habitica.4gems", "com.habitrpg.ios.Habitica.21gems",
                              "com.habitrpg.ios.Habitica.42gems", "com.habitrpg.ios.Habitica.84gems"
    ]
    static let subscriptionIdentifiers = ["subscription1month", "com.habitrpg.ios.habitica.subscription.3month",
                       "com.habitrpg.ios.habitica.subscription.6month", "com.habitrpg.ios.habitica.subscription.12month"
    ]
    static let noRenewSubscriptionIdentifiers = ["com.habitrpg.ios.habitica.norenew_subscription.1month", "com.habitrpg.ios.habitica.norenew_subscription.3month",
                                          "com.habitrpg.ios.habitica.norenew_subscription.6month", "com.habitrpg.ios.habitica.norenew_subscription.12month"
    ]
    
    private let itunesSharedSecret = HabiticaKeys().itunesSharedSecret
    private let appleValidator: AppleReceiptValidator
    private let userRepository = UserRepository()
    
    var pendingGifts = [String: String]()

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
        if !SKPaymentQueue.canMakePayments() {
            return
        }
        if hasCompletionHandler {
            return
        }
        hasCompletionHandler = true
        
        //Workaround for SwiftyStoreKit.completeTransactions not correctly returning consumable IAPs
        SKPaymentQueue.default().add(self)
        SwiftyStoreKit.completeTransactions(atomically: false) { _ in
        }
        
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            if results.restoreFailedPurchases.isEmpty == false {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            } else if results.restoredPurchases.isEmpty == false {
                for purchase in results.restoredPurchases {
                    // fetch content from your server, then:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                print("Restore Success: \(results.restoredPurchases)")
            } else {
                print("Nothing to Restore")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        if transactions.isEmpty == false {
            for product in transactions {
                RemoteLogger.shared.log(format: "Purchase: %@", arguments: getVaList([product.payment.productIdentifier]))
            }
        }
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            switch result {
            case .success(let receiptData):
                for transaction in transactions {
                    self.handleUnfinished(transaction: transaction, receiptData: receiptData)
                }
            case .error(let error):
                RemoteLogger.shared.record(error: error)
            }
        }
    }
    
    func handleUnfinished(transaction: SKPaymentTransaction, receiptData: Data) {
        let productIdentifier = transaction.payment.productIdentifier
        if transaction.transactionState == .purchased || transaction.transactionState == .restored {
            if self.isInAppPurchase(productIdentifier) {
                self.activatePurchase(productIdentifier, receipt: receiptData) { status in
                    if status {
                        SwiftyStoreKit.finishTransaction(transaction)
                    }
                }
            } else if self.isSubscription(productIdentifier) {
                self.userRepository.getUser().take(first: 1).on(value: {[weak self] user in
                    if !user.isSubscribed || user.purchased?.subscriptionPlan?.dateCreated == nil {
                        self?.applySubscription(transaction: transaction)
                    }
                }).start()
            } else if self.isNoRenewSubscription(productIdentifier) {
                self.activateNoRenewSubscription(productIdentifier, receipt: receiptData, recipientID: self.pendingGifts[productIdentifier]) { status in
                    if status {
                        self.pendingGifts.removeValue(forKey: productIdentifier)
                        SwiftyStoreKit.finishTransaction(transaction)
                    }
                }
            }
        } else if transaction.transactionState == .failed {
            SwiftyStoreKit.finishTransaction(transaction)
        }
    }
    
    func purchaseGems(_ identifier: String, applicationUsername: String, completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.purchaseProduct(identifier, quantity: 1, atomically: false, applicationUsername: applicationUsername) { (result) in
            switch result {
            case .success(let product):
                self.verifyPurchase(product)
                completion(true)
            case .error(let error):
                RemoteLogger.shared.record(error: error)
                completion(false)
            }
        }
    }
    
    func giftGems(_ identifier: String, applicationUsername: String, recipientID: String, completion: @escaping (Bool) -> Void) {
        pendingGifts[identifier] = recipientID
        SwiftyStoreKit.purchaseProduct(identifier, quantity: 1, atomically: false, applicationUsername: applicationUsername) { (result) in
            switch result {
            case .success(let product):
                self.verifyPurchase(product)
                completion(true)
            case .error(let error):
                RemoteLogger.shared.record(error: error)
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
                RemoteLogger.shared.record(error: error)
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    func activatePurchase(_ identifier: String, receipt: Data, completion: @escaping (Bool) -> Void) {
        var recipientID: String? = nil
        if let id = pendingGifts[identifier] {
            recipientID = id
        }
        userRepository.purchaseGems(receipt: ["receipt": receipt.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))], recipient: recipientID).observeValues {[weak self] (result) in
            if result != nil {
                if recipientID != nil {
                    self?.pendingGifts.removeValue(forKey: identifier)
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func activateNoRenewSubscription(_ identifier: String, receipt: Data, recipientID: String?, completion: @escaping (Bool) -> Void) {
        pendingGifts[identifier] = recipientID
        if recipientID == nil {
            completion(false)
            return
        }
        userRepository.purchaseNoRenewSubscription(identifier: identifier,
                                                   receipt: ["receipt": receipt.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))],
                                                   recipient: recipientID).observeValues {[weak self] (result) in
            if result != nil {
                self?.pendingGifts.removeValue(forKey: identifier)
                completion(true)
            } else {
                completion(false)
            }
        }
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
            userRepository.subscribe(sku: identifier, receipt: lastReceipt).observeResult { (result) in
                switch result {
                case .success:
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    func isSubscription(_ identifier: String) -> Bool {
        return  PurchaseHandler.subscriptionIdentifiers.contains(identifier)
    }
    
    func isNoRenewSubscription(_ identifier: String) -> Bool {
        return  PurchaseHandler.noRenewSubscriptionIdentifiers.contains(identifier)
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
    
    private func applySubscription(transaction: SKPaymentTransaction) {
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: {[weak self] (verificationResult) in
            switch verificationResult {
            case .success(let receipt):
                if self?.isValidSubscription(transaction.payment.productIdentifier, receipt: receipt) == true {
                    self?.activateSubscription(transaction.payment.productIdentifier, receipt: receipt) { status in
                        if status {
                            SwiftyStoreKit.finishTransaction(transaction)
                        }
                    }
                } else {
                    SwiftyStoreKit.finishTransaction(transaction)
                }
            case .error(let error):
                RemoteLogger.shared.record(error: error)
            }
        })
    }
}
