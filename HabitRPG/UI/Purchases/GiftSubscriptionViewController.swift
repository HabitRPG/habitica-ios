//
//  GiftSubscriptionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.12.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import Keys
import ReactiveSwift
import Habitica_Models

class GiftSubscriptionViewController: HRPGBaseViewController {
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var displayNameLabel: UsernameLabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    private let socialRepository = SocialRepository()
    private let configRepository = ConfigRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    var products: [SKProduct]?
    var selectedSubscriptionPlan: SKProduct?
    public var giftRecipientUsername: String? = nil
    var giftedUser: MemberProtocol? {
        didSet {
            if let user = giftedUser {
                avatarView.avatar = AvatarViewModel(avatar: user)
                displayNameLabel.text = giftedUser?.profile?.name
                displayNameLabel.contributorLevel = user.contributor?.level ?? 0
                usernameLabel.text = "@\(user.username ?? "")"
            }
        }
    }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let optionNib = UINib.init(nibName: "SubscriptionOptionView", bundle: nil)
        self.tableView.register(optionNib, forCellReuseIdentifier: "OptionCell")
        retrieveProductList()
        
        avatarView.showPet = false
        avatarView.showMount = false
        avatarView.showBackground = false
        
        if let username = giftRecipientUsername {
            disposable.inner.add(socialRepository.retrieveMemberWithUsername(username).observeValues({ member in
                self.giftedUser = member
            }))
        }
        
        if !configRepository.bool(variable: .enableGiftOneGetOne) {
            tableView.tableFooterView = nil
        }
    }
    
    func retrieveProductList() {
        SwiftyStoreKit.retrieveProductsInfo(Set(PurchaseHandler.noRenewSubscriptionIdentifiers)) { (result) in
            self.products = Array(result.retrievedProducts)
            self.products?.sort(by: { (product1, product2) -> Bool in
                guard let firstIndex = PurchaseHandler.noRenewSubscriptionIdentifiers.index(of: product1.productIdentifier) else {
                    return false
                }
                guard let secondIndex = PurchaseHandler.noRenewSubscriptionIdentifiers.index(of: product2.productIdentifier) else {
                    return true
                }
                return firstIndex < secondIndex
            })
            self.selectedSubscriptionPlan = self.products?.first
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let products = self.products else {
            return 0
        }

        if section == 0 {
            return products.count
        } else {
                return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 96
        }
        return 70
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section != 0 {
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSubscriptionPlan = (self.products?[indexPath.item])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnedCell: UITableViewCell?
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as? SubscriptionOptionView else {
                fatalError()
            }
            
            let product = self.products?[indexPath.item]
            cell.priceLabel.text = product?.localizedPrice
            cell.titleLabel.text = product?.localizedTitle
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
            /*userRepository.subscribe(sku: identifier, receipt: lastReceipt).observeResult { (result) in
                switch result {
                case .success(_):
                    completion(true)
                    self.tableView.reloadData()
                case .failure(_):
                    completion(false)
                }
            }*/
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

