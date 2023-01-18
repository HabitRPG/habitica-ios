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
import ReactiveSwift
import Habitica_Models
import PinLayout
import FirebaseAnalytics
import SwiftUIX

// swiftlint:disable:next type_body_length
class SubscriptionViewController: BaseTableViewController {

    @IBOutlet weak private var restorePurchaseButton: UIButton!
    let identifiers = ["subscription1month", "com.habitrpg.ios.habitica.subscription.3month",
                       "com.habitrpg.ios.habitica.subscription.6month", "com.habitrpg.ios.habitica.subscription.12month"
    ]

    private let userRepository = UserRepository()
    private let inventoryRepository = InventoryRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    private let configRepository = ConfigRepository.shared
    
    @IBOutlet weak var giftSubscriptionExplanationLabel: UILabel!
    @IBOutlet weak var giftSubscriptionButton: UIButton!
    @IBOutlet weak var subscriptionSupportLabel: UILabel!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var promoBannerView: PromoBannerView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var activePromo: HabiticaPromotion?

    var products: [SKProduct]?
    var selectedSubscriptionPlan: SKProduct?
    var isSubscribing = false
    var user: UserProtocol? {
        didSet {
            if user?.purchased?.subscriptionPlan?.isActive == true {
                isSubscribed = true
                showSubscribeOptions = false
                restorePurchaseButton.isHidden = true
                if ThemeService.shared.theme.isDark {
                    headerImage.image = Asset.subscriberHeaderDark.image
                } else {
                    headerImage.image = Asset.subscriberHeader.image
                }
            }
            hasTerminationDate = user?.purchased?.subscriptionPlan?.dateTerminated != nil
            tableView.reloadData()
        }
    }
    var mysteryGear: GearProtocol?
    let appleValidator: AppleReceiptValidator
    let itunesSharedSecret = Secrets.itunesSharedSecret

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
        doneButton.title = L10n.done
        
        activePromo = configRepository.activePromotion()
        
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
        
        navigationController?.navigationBar.standardAppearance.shadowColor = .clear
        navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
        
        disposable.inner.add(inventoryRepository.getLatestMysteryGear().on(value: { gear in
            self.mysteryGear = gear
        }).start())
        let width: CGFloat = view.bounds.width - 32

        if let promo = activePromo, promo.promoType == .gemsAmount || promo.promoType == .gemsPrice || promo.promoType == .subscription {
            if let header = tableView.tableHeaderView {
                header.frame = CGRect(x: header.frame.origin.x, y: header.frame.origin.y, width: header.frame.size.width, height: 205)
                if let promoView = header.viewWithTag(2) as? PromoBannerView {
                    promoView.isHidden = false
                    promo.configurePurchaseBanner(view: promoView)
                    promoView.onTapped = { [weak self] in self?.performSegue(withIdentifier: StoryboardSegue.Main.showPromoInfoSegue.rawValue, sender: self) }
                    header.frame = CGRect(x: 0, y: 0, width: width, height: 188)

                }
            }
        }
        
        if let birthdayEvent = configRepository.getBirthdayEvent() {
            if let header = tableView.tableHeaderView, let wrapperView = header.viewWithTag(7) {
                header.translatesAutoresizingMaskIntoConstraints = false
                wrapperView.isHidden = false
                let hostingView = UIHostingView(rootView: BirthdayBannerview(width: width, endDate: birthdayEvent.end).onTapGesture {[weak self] in
                    self?.present(BirthdayViewController(), animated: true)
                })
                wrapperView.addSubview(hostingView)
                hostingView.frame = CGRect(x: 0, y: 0, width: width, height: 100)
                wrapperView.frame = CGRect(x: 0, y: 0, width: wrapperView.bounds.width, height: 100)
                header.frame = CGRect(x: 0, y: 0, width: width, height: 208)
            }
        }
        if let header = tableView.tableHeaderView, let stackView = header.viewWithTag(6) {
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.pin.left(16).top().right(16).height(header.bounds.height)
        }
        
        HabiticaAnalytics.shared.logNavigationEvent("subscription screen")
    }
        
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        tableView.backgroundColor = theme.contentBackgroundColor
        navigationController?.navigationBar.standardAppearance.backgroundColor = theme.contentBackgroundColor
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let header = tableView.tableHeaderView, let stackView = header.viewWithTag(6) {
            header.pin.height(208)
            stackView.pin.left(16).top().right(16).height(208)
        }
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
                logger.log("Receipt verification failed: \(error)", level: .error)
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSubscribed && hasTerminationDate {
            return 4
        } else if isSubscribed && !hasTerminationDate {
            return 2
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
            if (isSubscribed && !hasTerminationDate) || (isSubscribed && hasTerminationDate && !showSubscribeOptions) || products?.isEmpty != false {
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
            if ThemeService.shared.theme.isDark {
                titleView.textColor = ThemeService.shared.theme.tintColor
            } else {
                titleView.textColor = ThemeService.shared.theme.backgroundTintColor
            }
            titleView.font = UIFontMetrics.default.scaledSystemFont(ofSize: 17, ofWeight: .semibold)
            titleView.textAlignment = .center
            if isSubscribed {
                titleView.text = L10n.subscriptionBenefitsTitleSubscribed
            } else {
                titleView.text = L10n.subscriptionBenefitsTitle
            }
            view.addSubview(titleView)
            titleView.pin.start(10%).end(10%).top().sizeToFit(.width)
            separatorView.pin.start().end().below(of: titleView).marginTop(16).height(16)
            view.pin.height(separatorView.frame.origin.y + separatorView.frame.size.height + 16)
        } else if isOptionSection(section) && showSubscribeOptions {
            let separatorView = UIImageView(image: Asset.separatorFancy.image)
            separatorView.contentMode = .center
            view.addSubview(separatorView)
            let titleView = UILabel()
            titleView.numberOfLines = 0
            if ThemeService.shared.theme.isDark {
                titleView.textColor = ThemeService.shared.theme.tintColor
            } else {
                titleView.textColor = ThemeService.shared.theme.backgroundTintColor
            }
            titleView.font = UIFontMetrics.default.scaledSystemFont(ofSize: 17, ofWeight: .semibold)
            titleView.textAlignment = .center
            titleView.text = L10n.subscriptionOptionsTitle
            view.addSubview(titleView)
            separatorView.pin.start().end().top(4).height(16)
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
        if self.isOptionSection(indexPath.section), let product = (self.products?[indexPath.item]) {
            self.selectedSubscriptionPlan = product
        } else if indexPath.section == tableView.numberOfSections-1 {
            subscribeToPlan()
        }
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
            cell.set(product: product)
            cell.setSelected(product?.productIdentifier == self.selectedSubscriptionPlan?.productIdentifier, animated: true)
            returnedCell = cell
        } else if self.isDetailSection(indexPath.section) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as? SubscriptionDetailView else {
                fatalError()
            }
            if let subscriptionPlan = self.user?.purchased?.subscriptionPlan {
                cell.setPlan(subscriptionPlan)
                cell.cancelSubscriptionAction = {[weak self] in
                    self?.cancelSubscription(subscriptionPlan: subscriptionPlan)
                }
            }
            returnedCell = cell
        } else if indexPath.section == tableView.numberOfSections-1 {
            returnedCell = tableView.dequeueReusableCell(withIdentifier: "SubscribeButtonCell", for: indexPath)
            (returnedCell?.viewWithTag(1) as? UIButton)?.setTitle(L10n.subscribe, for: .normal)
            returnedCell?.viewWithTag(1)?.isHidden = isSubscribing
            returnedCell?.viewWithTag(2)?.isHidden = !isSubscribing
        }
        returnedCell?.selectionStyle = .none
        return returnedCell ?? UITableViewCell()
    }

    func isInformationSection(_ section: Int) -> Bool {
        return (section == 0 && !isSubscribed) || (section == 1 && isSubscribed)
    }

    func optionSectionIndex() -> Int {
        return isSubscribed ? 2 : 1
    }
    
    func isOptionSection(_ section: Int) -> Bool {
        return section == optionSectionIndex()
    }

    func isDetailSection(_ section: Int) -> Bool {
        return isSubscribed && section == 0
    }

    @IBAction func subscribeButtonPressed(_ sender: Any) {
        self.subscribeToPlan()
    }

    func subscribeToPlan() {
        if !PurchaseHandler.shared.isAllowedToMakePurchases() {
            return
        }
        isSubscribing = true
        tableView.reloadSections(IndexSet(integer: tableView.numberOfSections-1), with: .fade)
        guard let identifier = self.selectedSubscriptionPlan?.productIdentifier else {
            return
        }
        SwiftyStoreKit.purchaseProduct(identifier, atomically: false) { result in
            self.isSubscribing = false
            self.tableView.reloadSections(IndexSet(integer: self.tableView.numberOfSections-1), with: .fade)
            switch result {
            case .success(let product):
                self.verifyAndSubscribe(product)
                logger.log("Purchase Success: \(product.productId)")
            case .error(let error):
                Analytics.logEvent("purchase_failed", parameters: ["error": error.localizedDescription, "code": error.errorCode])

                logger.log("Purchase Failed: \(error)", level: .error)
            case .deferred:
                return
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
                logger.log("Receipt verification failed: \(error)", level: .error)
            }
        }
    }
    
    func cancelSubscription(subscriptionPlan: SubscriptionPlanProtocol) {
        if hasTerminationDate == true {
            showSubscribeOptions = true
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .top, animated: true)
        } else {
            var url: URL?
            if subscriptionPlan.paymentMethod == "Apple" {
                if #available(iOS 15.0, *) {
                    if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        Task {
                            do {
                                try await AppStore.showManageSubscriptions(in: window)
                            } catch {
                                
                            }
                        }
                        return
                    }
                }
                url = URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")
            } else if subscriptionPlan.paymentMethod == "Google" {
                url = URL(string: "http://support.google.com/googleplay?p=cancelsubsawf")
            } else {
                url = URL(string: "https://habitica.com")
            }
            if let applicationUrl = url {
                UIApplication.shared.open(applicationUrl, options: [:], completionHandler: nil)
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
        let navController = EditingFormViewController.buildWithUsernameField(title: L10n.giftRecipientTitle, subtitle: L10n.giftRecipientSubtitle, onSave: { username in
            self.giftRecipientUsername = username
            self.perform(segue: StoryboardSegue.Main.openGiftSubscriptionDialog)
        }, saveButtonTitle: L10n.continue)
        present(navController, animated: true, completion: nil)
        
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
