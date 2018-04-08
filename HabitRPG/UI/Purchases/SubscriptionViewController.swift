//
//  SubscriptionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 07/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import Keys

class SubscriptionViewController: HRPGBaseViewController {

    @IBOutlet weak private var restorePurchaseButton: UIButton!
    let identifiers = ["subscription1month", "com.habitrpg.ios.habitica.subscription.3month",
                       "com.habitrpg.ios.habitica.subscription.6month", "com.habitrpg.ios.habitica.subscription.12month"
    ]

    var products: [SKProduct]?
    var selectedSubscriptionPlan: SKProduct?
    var user: User?
    let appleValidator: AppleReceiptValidator
    let itunesSharedSecret = HabiticaKeys().itunesSharedSecret
    var expandedList = [Bool](repeating: false, count: 4)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        #if DEBUG
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #else
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #endif
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        #if DEBUG
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #else
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #endif
        super.init(coder: aDecoder)
    }

    var isSubscribed = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let termsView = self.tableView.tableFooterView?.viewWithTag(2) as? UITextView {
            let termsAttributedText = NSMutableAttributedString(string: "Once we've confirmed your purchase, the payment will be charged to your iTunes Account! Thank you so much for your support.\n\nPlease note that subscriptions automatically renew unless your auto-renew is turned off at least 24-hours before the end of the current period, which you can do by going to your Account Settings page after you've made your purchase. You can also manage subscriptions from the Account Settings page. If you have an active subscription, your account will be charged for renewal within 24-hours prior to the end of your current subscription period. When your subscription renews, you will be charged the same price that you initially paid. If you have any questions, feel free to ask in the Habitica Help Guild\nBy continuing you accept the Terms of Use and Privacy Policy")
            termsAttributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray50(), range: NSRange(location: 0, length: termsAttributedText.length))
            let termsRange = termsAttributedText.mutableString.range(of: "Terms of Use")
            termsAttributedText.addAttributes([NSAttributedStringKey.link: "https://habitica.com/static/terms"], range: termsRange)
            let privacyRange = termsAttributedText.mutableString.range(of: "Privacy Policy")
            termsAttributedText.addAttributes([NSAttributedStringKey.link: "https://habitica.com/static/privacy"], range: privacyRange)
            termsView.attributedText = termsAttributedText
        }
        let optionNib = UINib.init(nibName: "SubscriptionOptionView", bundle: nil)
        self.tableView.register(optionNib, forCellReuseIdentifier: "OptionCell")
        let detailNib = UINib.init(nibName: "SubscriptionDetailView", bundle: nil)
        self.tableView.register(detailNib, forCellReuseIdentifier: "DetailCell")
        let infoNib = UINib.init(nibName: "SubscriptionInformationCell", bundle: nil)
        self.tableView.register(infoNib, forCellReuseIdentifier: "InformationCell")

        if let navigationController = self.navigationController as? HRPGGemHeaderNavigationController {
            let inset = UIEdgeInsets(top: navigationController.getContentInset(), left: 0, bottom: 0, right: 0)
            self.tableView.contentInset = inset
            self.tableView.scrollIndicatorInsets = inset
        }
        retrieveProductList()

        self.user = HRPGManager.shared().getUser()

        if let user = self.user {
            if user.subscriptionPlan == nil {
                return
            }
            if user.subscriptionPlan.isActive() {
                isSubscribed = true
                restorePurchaseButton.isHidden = true
            }
        }
    }

    func retrieveProductList() {
        SwiftyStoreKit.retrieveProductsInfo(Set(PurchaseHandler.subscriptionIdentifiers)) { (result) in
            self.products = Array(result.retrievedProducts)
            self.products?.sort(by: { (product1, product2) -> Bool in
                guard let firstIndex = PurchaseHandler.subscriptionIdentifiers.index(of: product1.productIdentifier) else {
                    return false
                }
                guard let secondIndex = PurchaseHandler.subscriptionIdentifiers.index(of: product2.productIdentifier) else {
                    return true
                }
                return firstIndex < secondIndex
            })
            self.tableView.reloadData()
        }
    }

    @IBAction func checkForExistingSubscription(_ sender: Any) {
        SwiftyStoreKit.verifyReceipt(using: self.appleValidator, forceRefresh: true) { result in
            switch result {
            case .success(let verifiedReceipt):
                guard let purchases = verifiedReceipt["latest_receipt_info"] as? [ReceiptInfo] else {
                    return
                }
                for purchase in purchases {
                    if let identifier = purchase["product_id"] as? String {
                        if self.isValidSubscription(identifier, receipt: verifiedReceipt) {
                            self.activateSubscription(identifier, receipt: verifiedReceipt) {status in
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
        if isInformationSection(section) {
            return 4
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
                return 1
            }
        }

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isInformationSection(indexPath.section) {
            if self.expandedList[indexPath.item] {
                let description = SubscriptionInformation.descriptions[indexPath.item] as NSString
                let height = 90 + description.boundingRect(with: CGSize.init(width: self.viewWidth-80, height: CGFloat.infinity),
                                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                     attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .body)],
                                                     context: nil).size.height
                return height
            } else {
                return 50
            }
        } else if isOptionSection(indexPath.section) {
            return 96
        } else if isDetailSection(indexPath.section) {
            return 550
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
        self.selectedSubscriptionPlan = (self.products?[indexPath.item])
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnedCell: UITableViewCell?
        if self.isInformationSection(indexPath.section) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath) as? SubscriptionInformationCell else {
                fatalError()
            }
            cell.title = SubscriptionInformation.titles[indexPath.item]
            cell.descriptionText = SubscriptionInformation.descriptions[indexPath.item]
            cell.isExpanded = self.expandedList[indexPath.item]
            cell.setExpandIcon(self.expandedList[indexPath.item])
            cell.expandButtonPressedAction = { [weak self] isExpanded in
                self?.expandedList[indexPath.item] = isExpanded
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
            returnedCell = cell
        } else if self.isOptionSection(indexPath.section) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as? SubscriptionOptionView else {
                fatalError()
            }

            let product = self.products?[indexPath.item]
            cell.priceLabel.text = product?.localizedPrice
            cell.titleLabel.text = product?.localizedTitle
            returnedCell = cell
        } else if self.isDetailSection(indexPath.section) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as? SubscriptionDetailView else {
                fatalError()
            }
            if let user = self.user {
                cell.setPlan(user.subscriptionPlan)
                cell.cancelSubscriptionAction = {
                    var url: URL?
                    if user.subscriptionPlan.paymentMethod == "Apple" {
                        url = URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")
                    } else {
                        url = URL(string: "https://habitica.com")
                    }
                    if let applicationUrl = url {
                        UIApplication.shared.openURL(applicationUrl)
                    }
                }
            }
            returnedCell = cell
        } else if indexPath.section == tableView.numberOfSections-1 {
            returnedCell = tableView.dequeueReusableCell(withIdentifier: "SubscribeButtonCell", for: indexPath)
        }
        returnedCell?.selectionStyle = .none
        return returnedCell ?? UITableViewCell()
    }

    func isInformationSection(_ section: Int) -> Bool {
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
            return
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

    func verifyAndSubscribe(_ product: PurchaseDetails) {
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                if self.isValidSubscription(product.productId, receipt: receipt) {
                    self.activateSubscription(product.productId, receipt: receipt) { status in
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

    func activateSubscription(_ identifier: String, receipt: ReceiptInfo, completion: @escaping (Bool) -> Void) {
        if let lastReceipt = receipt["latest_receipt"] as? String {
            HRPGManager.shared().subscribe(identifier, withReceipt: lastReceipt, onSuccess: {
                completion(true)
                self.isSubscribed = true
                self.tableView.reloadData()
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
