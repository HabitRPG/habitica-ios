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
import ReactiveSwift
import Habitica_Models
import PinLayout

class SubscriptionViewController: BaseTableViewController {

    @IBOutlet weak private var restorePurchaseButton: UIButton!
    let identifiers = ["subscription1month", "com.habitrpg.ios.habitica.subscription.3month",
                       "com.habitrpg.ios.habitica.subscription.6month", "com.habitrpg.ios.habitica.subscription.12month"
    ]

    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    private let configRepository = ConfigRepository()
    
    @IBOutlet weak var giftSubscriptionExplanationLabel: UILabel!
    @IBOutlet weak var giftSubscriptionButton: UIButton!
    @IBOutlet weak var subscriptionSupportLabel: UILabel!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var giftOneGetOnePromoView: GiftOneGetOnePromoView!
    
    var products: [SKProduct]?
    var selectedSubscriptionPlan: SKProduct?
    var user: UserProtocol? {
        didSet {
            if user?.purchased?.subscriptionPlan?.isActive == true {
                isSubscribed = true
                showSubscribeOptions = false
                restorePurchaseButton.isHidden = true
                headerImage.image = Asset.subscriberHeader.image
            }
            hasTerminationDate = user?.purchased?.subscriptionPlan?.dateTerminated != nil
        }
    }
    var mysteryGear: GearProtocol?
    let appleValidator: AppleReceiptValidator
    let itunesSharedSecret = HabiticaKeys().itunesSharedSecret

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
    var hasTerminationDate = false
    var showSubscribeOptions = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let termsView = self.tableView.tableFooterView?.viewWithTag(2) as? UITextView {
            let termsAttributedText = NSMutableAttributedString(string: "Once we’ve confirmed your purchase, the payment will be charged to your Apple ID.\n\nSubscriptions automatically renew unless auto-renewal is turned off at least 24-hours before the end of the current period. You can manage subscription renewal from your Apple IDSettings. If you have an active subscription, your account will be charged for renewal within 24-hours prior to the end of your current subscription period and you will be charged the same price you initially paid.\n\nBy continuing you accept the Terms of Use and Privacy Policy.")
            termsAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: ThemeService.shared.theme.primaryTextColor, range: NSRange(location: 0, length: termsAttributedText.length))
            let termsRange = termsAttributedText.mutableString.range(of: "Terms of Use")
            termsAttributedText.addAttributes([NSAttributedString.Key.link: "https://habitica.com/static/terms"], range: termsRange)
            let privacyRange = termsAttributedText.mutableString.range(of: "Privacy Policy")
            termsAttributedText.addAttributes([NSAttributedString.Key.link: "https://habitica.com/static/privacy"], range: privacyRange)
            termsView.attributedText = termsAttributedText
        }
        let optionNib = UINib.init(nibName: "SubscriptionOptionView", bundle: nil)
        self.tableView.register(optionNib, forCellReuseIdentifier: "OptionCell")
        let detailNib = UINib.init(nibName: "SubscriptionDetailView", bundle: nil)
        self.tableView.register(detailNib, forCellReuseIdentifier: "DetailCell")
        let infoNib = UINib.init(nibName: "SubscriptionInformationCell", bundle: nil)
        self.tableView.register(infoNib, forCellReuseIdentifier: "InformationCell")

        retrieveProductList()

        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
        }).start())
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 106
        
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.shadowColor = .clear
            navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
        }
        
        disposable.inner.add(inventoryRepository.getLatestMysteryGear().on(value: { gear in
            self.mysteryGear = gear
        }).start())
        
        if configRepository.bool(variable: .enableGiftOneGetOne) {
            if let header = tableView.tableHeaderView {
                header.frame = CGRect(x: header.frame.origin.x, y: header.frame.origin.y, width: header.frame.size.width, height: 165)
            }
            giftOneGetOnePromoView.isHidden = false
            giftOneGetOnePromoView.onTapped = {[weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.giftSubscriptionButtonTapped(weakSelf.giftOneGetOnePromoView)
            }
        }
    }
        
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        tableView.backgroundColor = theme.contentBackgroundColor
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.backgroundColor = theme.contentBackgroundColor
        } else {
            navigationController?.navigationBar.backgroundColor = theme.contentBackgroundColor
        }
        navigationController?.navigationBar.shadowImage = UIImage()
        giftSubscriptionExplanationLabel.textColor = theme.ternaryTextColor
        subscriptionSupportLabel.textColor = theme.secondaryTextColor
        
        if theme.isDark {
            headerImage.image = Asset.subscribeHeaderDark.image
        } else {
            headerImage.image = Asset.subscribeHeader.image
        }
    }
    
    override func populateText() {
        giftSubscriptionExplanationLabel.text = L10n.subscriptionGiftExplanation
        giftSubscriptionButton.setTitle(L10n.subscriptionGiftButton, for: .normal)
        subscriptionSupportLabel.text = L10n.subscriptionSupportDevelopers
    }

    func retrieveProductList() {
        SwiftyStoreKit.retrieveProductsInfo(Set(PurchaseHandler.subscriptionIdentifiers)) { (result) in
            self.products = Array(result.retrievedProducts)
            self.products?.sort(by: { (product1, product2) -> Bool in
                guard let firstIndex = PurchaseHandler.subscriptionIdentifiers.firstIndex(of: product1.productIdentifier) else {
                    return false
                }
                guard let secondIndex = PurchaseHandler.subscriptionIdentifiers.firstIndex(of: product2.productIdentifier) else {
                    return true
                }
                return firstIndex < secondIndex
            })
            self.selectedSubscriptionPlan = self.products?.first
            self.tableView.reloadData()
            self.tableView.selectRow(at: IndexPath(item: 0, section: self.isSubscribed ? 2 : 1), animated: true, scrollPosition: .none)
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSubscribed && hasTerminationDate {
            return 4
        } else {
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isInformationSection(section) {
            return 5
        } else if isOptionSection(section) {
            guard let products = self.products else {
                return 0
            }
            if isSubscribed && hasTerminationDate && !showSubscribeOptions {
                return 0
            }
            return products.count
        } else if isDetailSection(section) {
            return 1
        } else {
            if (isSubscribed && !hasTerminationDate) || (isSubscribed && hasTerminationDate && !showSubscribeOptions) || self.products == nil || self.products?.isEmpty == true {
                return 0
            } else {
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        if isInformationSection(section) {
            let separatorView = UIImageView(image: Asset.separatorFancy.image)
            separatorView.contentMode = .center
            view.addSubview(separatorView)
            let titleView = UILabel()
            titleView.numberOfLines = 0
            titleView.textColor = ThemeService.shared.theme.tintColor
            titleView.font = CustomFontMetrics.scaledSystemFont(ofSize: 17, ofWeight: .semibold)
            titleView.textAlignment = .center
            if isSubscribed {
                titleView.text = L10n.subscriptionBenefitsTitleSubscribed
            } else {
                titleView.text = L10n.subscriptionBenefitsTitle
            }
            view.addSubview(titleView)
            titleView.pin.start(20%).end(20%).top().sizeToFit(.width)
            separatorView.pin.start().end().below(of: titleView).marginTop(16).height(16)
            view.pin.height(separatorView.frame.origin.y + separatorView.frame.size.height + 16)
        } else if isOptionSection(section) && showSubscribeOptions {
            let separatorView = UIImageView(image: Asset.separatorFancy.image)
            separatorView.contentMode = .center
            view.addSubview(separatorView)
            let titleView = UILabel()
            titleView.numberOfLines = 0
            titleView.textColor = ThemeService.shared.theme.tintColor
            titleView.font = CustomFontMetrics.scaledSystemFont(ofSize: 17, ofWeight: .semibold)
            titleView.textAlignment = .center
            titleView.text = L10n.subscriptionOptionsTitle
            view.addSubview(titleView)
            separatorView.pin.start().end().top(16).height(16)
            titleView.pin.start(20%).end(20%).below(of: separatorView).marginTop(16).sizeToFit(.width)
            view.pin.height(titleView.frame.origin.y + titleView.frame.size.height + 8)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, viewForHeaderInSection: section)?.frame.size.height ?? 0
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
            if indexPath.item == 2 && mysteryGear != nil {
                cell.descriptionText = L10n.subscriptionInfo3DescriptionNew(mysteryGear?.text ?? "")
                ImageManager.getImage(name: "shop_set_mystery_\(mysteryGear?.key?.split(separator: "_").last ?? "")") { (image, _) in
                    cell.iconView.image = image
                }
            } else {
                cell.descriptionText = SubscriptionInformation.descriptions[indexPath.item]
                cell.iconView.image = SubscriptionInformation.images[indexPath.item]
            }
            returnedCell = cell
        } else if self.isOptionSection(indexPath.section) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as? SubscriptionOptionView else {
                fatalError()
            }

            let product = self.products?[indexPath.item]
            cell.priceLabel.text = product?.localizedPrice
            cell.titleLabel.text = product?.localizedTitle

            cell.flagView.isHidden = true
            switch product?.productIdentifier {
            case PurchaseHandler.subscriptionIdentifiers[0]:
                cell.setMonthCount(1)
            case PurchaseHandler.subscriptionIdentifiers[1]:
                cell.setMonthCount(3)
            case PurchaseHandler.subscriptionIdentifiers[2]:
                cell.setMonthCount(6)
            case PurchaseHandler.subscriptionIdentifiers[3]:
                cell.setMonthCount(12)
                cell.flagView.text = "Save 20%"
                cell.flagView.textColor = .white
                cell.flagView.isHidden = false
            default: break
            }
            DispatchQueue.main.async {
                cell.setSelected(product?.productIdentifier == self.selectedSubscriptionPlan?.productIdentifier, animated: true)
            }
            returnedCell = cell
        } else if self.isDetailSection(indexPath.section) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as? SubscriptionDetailView else {
                fatalError()
            }
            if let subscriptionPlan = self.user?.purchased?.subscriptionPlan {
                cell.setPlan(subscriptionPlan)
                cell.cancelSubscriptionAction = {[weak self] in
                    if self?.hasTerminationDate == true {
                        self?.showSubscribeOptions = true
                        tableView.reloadData()
                        tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .top, animated: true)
                    } else {
                        var url: URL?
                        if subscriptionPlan.paymentMethod == "Apple" {
                            url = URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")
                        } else {
                            url = URL(string: "https://habitica.com")
                        }
                        if let applicationUrl = url {
                            UIApplication.shared.open(applicationUrl, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
            returnedCell = cell
        } else if indexPath.section == tableView.numberOfSections-1 {
            returnedCell = tableView.dequeueReusableCell(withIdentifier: "SubscribeButtonCell", for: indexPath)
            (returnedCell?.viewWithTag(1) as? UIButton)?.setTitle(L10n.subscribe, for: .normal)
        }
        returnedCell?.selectionStyle = .none
        return returnedCell ?? UITableViewCell()
    }

    func isInformationSection(_ section: Int) -> Bool {
        return (section == 0 && !isSubscribed) || (section == 1 && isSubscribed)
    }

    func isOptionSection(_ section: Int) -> Bool {
        return (isSubscribed && section == 2) || (!isSubscribed && section == 1)
    }

    func isDetailSection(_ section: Int) -> Bool {
        return isSubscribed && section == 0
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
            userRepository.subscribe(sku: identifier, receipt: lastReceipt).observeResult { (result) in
                switch result {
                case .success:
                    completion(true)
                    self.isSubscribed = true
                    self.tableView.reloadData()
                case .failure:
                    completion(false)
                }
            }
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
    
    private var giftRecipientUsername = ""
    
    @IBAction func giftSubscriptionButtonTapped(_ sender: Any) {
        let alertController = HabiticaAlertController(title: L10n.giftRecipientTitle, message: L10n.giftRecipientSubtitle)
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.borderColor = UIColor.gray300
        textField.borderWidth = 1
        textField.tintColor = ThemeService.shared.theme.tintColor
        alertController.contentView = textField
        alertController.addAction(title: L10n.continue, style: .default, isMainAction: true, closeOnTap: true, handler: { _ in
            if let username = textField.text, username.isEmpty == false {
                self.giftRecipientUsername = username
                self.perform(segue: StoryboardSegue.Main.openGiftSubscriptionDialog)
            }
        })
        alertController.addCancelAction()
        alertController.containerViewSpacing = 8
        alertController.show()
        textField.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.openGiftSubscriptionDialog.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let giftSubscriptionController = navigationController?.topViewController as? GiftSubscriptionViewController
            giftSubscriptionController?.giftRecipientUsername = giftRecipientUsername
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
