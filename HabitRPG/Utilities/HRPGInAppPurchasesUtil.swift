//
//  HRPGInAppPurchasesUtil.swift
//  Habitica
//
//  Created by Keith Holliday on 2/10/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftyStoreKit

@objc class HRPGInAppPurchasesUtil: NSObject {
    @objc public func registerTransactionObserver () {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
    }
}
