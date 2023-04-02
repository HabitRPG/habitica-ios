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
import Habitica_Models

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
    
    static let gryphatriceIdentifier = "com.habitrpg.ios.Habitica.pets.Gryphatrice_Jubilant"
    
    static let habiticaSubMapping = [
        "subscription1month": "basic_earned",
        "com.habitrpg.ios.habitica.subscription.3month": "basic_3mo",
        "com.habitrpg.ios.habitica.subscription.6month": "basic_6mo",
        "com.habitrpg.ios.habitica.subscription.12month": "basic_12mo"
    ]
    
    static let habiticaSubMappingReversed = [
        "basic_earned": "subscription1month",
        "basic_3mo": "com.habitrpg.ios.habitica.subscription.3month",
        "basic_6mo": "com.habitrpg.ios.habitica.subscription.6month",
        "basic_12mo": "com.habitrpg.ios.habitica.subscription.12month"
    ]
    
    private let itunesSharedSecret = Secrets.itunesSharedSecret
    private let appleValidator: AppleReceiptValidator
    private let userRepository = UserRepository()
    
    var pendingGifts = [String: String]()
    var wasSubscriptionCancelled: Bool?

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
        
        // Workaround for SwiftyStoreKit.completeTransactions not correctly returning consumable IAPs
        SKPaymentQueue.default().add(self)
        SwiftyStoreKit.completeTransactions(atomically: false) { _ in
        }
        
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            if results.restoreFailedPurchases.isEmpty == false {
                logger.log("Restore Failed: \(results.restoreFailedPurchases)", level: .error)
            } else if results.restoredPurchases.isEmpty == false {
                for purchase in results.restoredPurchases {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                logger.log("Restore Success: \(results.restoredPurchases)")
            } else {
                logger.log("Nothing to Restore")
            }
            self.userRepository.getUser().take(first: 1)
                .on(value: { user in
                    if user.isSubscribed && user.purchased?.subscriptionPlan?.dateTerminated == nil && user.purchased?.subscriptionPlan?.paymentMethod == "Apple" {
                        self.checkForCancellation(user: user)
                    }
                })
                .start()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        if transactions.isEmpty == false {
            for product in transactions {
                logger.log(format: "Purchase: %@", level: .warning, arguments: getVaList([product.payment.productIdentifier]))
            }
        }
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            switch result {
            case .success(let receiptData):
                self.userRepository.getUser().take(first: 1).on(value: {[weak self] user in
                    for transaction in transactions {
                        self?.handleUnfinished(transaction: transaction, user: user, receiptData: receiptData)
                    }
                }).start()
            case .error(let error):
                self.handle(error: error)
            }
        }
    }
    
    func handleUnfinished(transaction: SKPaymentTransaction, user: UserProtocol, receiptData: Data) {
        let productIdentifier = transaction.payment.productIdentifier
        if transaction.transactionState == .purchased || transaction.transactionState == .restored {
            if self.isInAppPurchase(productIdentifier) {
                self.activatePurchase(productIdentifier, receipt: receiptData) { status in
                    if status {
                        SwiftyStoreKit.finishTransaction(transaction)
                    }
                }
            } else if self.isSubscription(productIdentifier) {
                if !user.isSubscribed || user.purchased?.subscriptionPlan?.dateCreated == nil ||
                    (user.purchased?.subscriptionPlan?.customerId == transaction.original?.transactionIdentifier
                     && transaction.original?.transactionIdentifier != transaction.transactionIdentifier
                     && PurchaseHandler.habiticaSubMapping[transaction.payment.productIdentifier] != user.purchased?.subscriptionPlan?.planId) {
                    applySubscription(transaction: transaction)
                }
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
        if !isAllowedToMakePurchases() {
            return
        }
        SwiftyStoreKit.purchaseProduct(identifier, quantity: 1, atomically: false, applicationUsername: applicationUsername) { (result) in
            switch result {
            case .success(let product):
                self.verifyPurchase(product)
                completion(true)
            case .error(let error):
                self.handle(error: error)
                completion(false)
            case .deferred:
                return
            }
        }
    }
    
    func giftGems(_ identifier: String, applicationUsername: String, recipientID: String, completion: @escaping (Bool) -> Void) {
        if !isAllowedToMakePurchases() {
            return
        }
        pendingGifts[identifier] = recipientID
        SwiftyStoreKit.purchaseProduct(identifier, quantity: 1, atomically: false, applicationUsername: applicationUsername) { (result) in
            switch result {
            case .success(let product):
                self.verifyPurchase(product)
                completion(true)
            case .error(let error):
                self.handle(error: error)
                completion(false)
            case .deferred:
                return
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
                self.handle(error: error)
                logger.log("Receipt verification failed: \(error)", level: .error)
            }
        }
    }
    
    func activatePurchase(_ identifier: String, receipt: Data, completion: @escaping (Bool) -> Void) {
        var recipientID: String?
        if let id = pendingGifts[identifier] {
            recipientID = id
        }
        userRepository.purchaseGems(receipt: ["receipt": receipt.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))], recipient: recipientID)
            .observeValues {[weak self] (result) in
                if result?.error?.isEmpty != true || result?.error == "RECEIPT_ALREADY_USED" {
                    if recipientID != nil {
                        self?.pendingGifts.removeValue(forKey: identifier)
                    }
                    completion(true)
                    self?.userRepository.retrieveUser().observeCompleted {}
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
                self?.userRepository.retrieveUser().observeCompleted {}
            } else {
                completion(false)
            }
        }
    }
    
    func isInAppPurchase(_ identifier: String) -> Bool {
        return PurchaseHandler.IAPIdentifiers.contains(identifier)
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
    
    func isAllowedToMakePurchases() -> Bool {
        let testinglevel = ConfigRepository.shared.testingLevel
        if HabiticaAppDelegate.isRunningLive() || testinglevel.isTrustworthy {
            return true
        }
        return false
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
        if SwiftyStoreKit.localReceiptData == nil {
            return
        }
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
                self?.handle(error: error)
            }
        })
    }
    
    private func cancelSubscription(purchaseItem: ReceiptItem) {
        if let expirationDate = purchaseItem.subscriptionExpirationDate, expirationDate < Date() {
            userRepository.cancelSubscription().observeCompleted {}
        }
        Purchases.shared
        wasSubscriptionCancelled = true
    }
    
    private func checkForCancellation(user: UserProtocol) {
        let searchedID = user.purchased?.subscriptionPlan?.customerId
        SwiftyStoreKit.verifyReceipt(using: self.appleValidator) { result in
            switch result {
            case .success(let receipt):
                let sku = PurchaseHandler.habiticaSubMappingReversed[user.purchased?.subscriptionPlan?.planId ?? ""] ?? ""
                let verifyResult = SwiftyStoreKit.verifySubscriptions(productIds: Set(sku), inReceipt: receipt)
                switch verifyResult {
                case .expired(expiryDate: _, items: let items):
                    self.processItemsForCancellation(items: items, searchedID: searchedID)
                default:
                    return
                }
            case .error:
                return
            }
        }
    }
    
    private func processItemsForCancellation(items: [ReceiptItem], searchedID: String?) {
        var latestItem: ReceiptItem?
        for item in items where (item.originalTransactionId == searchedID || item.transactionId == searchedID) {
            if let latest = latestItem?.purchaseDate, latest > item.purchaseDate {
                continue
            }
            latestItem = item
        }
        if let item = latestItem, item.subscriptionExpirationDate != nil {
            self.cancelSubscription(purchaseItem: item)
        }
    }
    
    private func handle(error: SKError) {
        logger.record(error: error)
    }
    
    private func handle(error: ReceiptError) {
        logger.record(error: error)
    }
}
