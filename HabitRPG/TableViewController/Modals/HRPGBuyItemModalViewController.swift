//
//  HRPGBuyItemModalViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/3/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import Habitica_Database

// swiftlint:disable:next type_body_length
class HRPGBuyItemModalViewController: UIViewController, Themeable {
    @objc var reward: InAppRewardProtocol?
    @objc var shopIdentifier: String?
    var onInventoryRefresh: (() -> Void)?
    private let inventoryRepository = InventoryRepository()
    private let customizationRepository = CustomizationRepository()
    private let userRepository = UserRepository()
    private let stableRepository = StableRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
        
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var bottomButtons: UIView!
    
    @IBOutlet weak var hourglassCountView: CurrencyCountView!
    @IBOutlet weak var gemCountView: CurrencyCountView!
    @IBOutlet weak var goldCountView: CurrencyCountView!
    @IBOutlet weak var buyButton: UIView!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var currencyCountView: CurrencyCountView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closableShopModal: HRPGCloseableShopModalView!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var buttonSeparatorView: UIView!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    
    @objc public weak var shopViewController: ShopViewController?
    
    private var bulkView: HRPGBulkPurchaseView?
    var itemView: UIView?
    
    private var isPurchasing = false {
        didSet {
            updateBuyButton()
        }
    }

    private var user: UserProtocol? {
        didSet {
            refreshBalances()
            updateBuyButton()
            
            if reward?.isValid == true && reward?.key == "gem" {
                bulkView?.maxValue = user?.purchased?.subscriptionPlan?.gemsRemaining ?? 0
                (itemView as? HRPGSimpleShopItemView)?.setGemsLeft(user?.purchased?.subscriptionPlan?.gemsRemaining ?? 0,
                                      gemsTotal: user?.purchased?.subscriptionPlan?.gemCapTotal ?? 0)
            }
        }
    }

    private var isPinned: Bool = false {
        didSet {
            if isPinned {
                pinButton.setTitle(L10n.unpin, for: .normal)
                pinButton.setTitleColor(.red10, for: .normal)
                pinButton.setImage(HabiticaIcons.imageOfUnpinItem.withRenderingMode(.alwaysTemplate), for: .normal)
                pinButton.tintColor = .red10
            } else {
                pinButton.setTitle(L10n.pin, for: .normal)
                pinButton.setTitleColor(ThemeService.shared.theme.tintColor, for: .normal)
                pinButton.setImage(HabiticaIcons.imageOfPinItem.withRenderingMode(.alwaysTemplate), for: .normal)
                pinButton.tintColor = ThemeService.shared.theme.tintColor
            }
        }
    }
    
    private var purchaseQuantity = 1 {
        didSet {
            updateBuyButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topContentView.superview?.bringSubviewToFront(topContentView)
        bottomButtons.superview?.bringSubviewToFront(bottomButtons)
        styleViews()
        setupItem()
        
        closeButton.addTarget(self, action: #selector(closePressed), for: UIControl.Event.touchUpInside)
        buyButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyPressed)))
        let inAppReward = reward
        pinButton.isHidden = inAppReward?.pinType == "armoire" || inAppReward?.pinType == "potion"

        ThemeService.shared.addThemeable(themable: self)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
        closableShopModal.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(modalTapped)))
        
        populateText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
            (self?.itemView as? AvatarShopItemView)?.setAvatar(user)
        }).start())
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
     }
    
    func populateText() {
        closeButton.setTitle(L10n.close, for: .normal)
        buyLabel.text = L10n.buy.localizedCapitalized
        pinButton.setTitle(L10n.pin, for: .normal)
    }
    
    func applyTheme(theme: Theme) {
        pinButton.setTitleColor(theme.tintColor, for: .normal)
        pinButton.backgroundColor = theme.windowBackgroundColor
        buyButton.backgroundColor = theme.contentBackgroundColor
        if UIAccessibility.buttonShapesEnabled {
            closeButton.setTitleColor(theme.tintedMainText, for: .normal)
            closeButton.backgroundColor = theme.lightlyTintedBackgroundColor
        } else {
            closeButton.setTitleColor(theme.tintColor, for: .normal)
            closeButton.backgroundColor = theme.contentBackgroundColor
        }
        closableShopModal.shopModalBgView.backgroundColor = theme.contentBackgroundColor
        closableShopModal.shopModalBgView.contentView.backgroundColor = theme.contentBackgroundColor
        buttonSeparatorView.backgroundColor = theme.separatorColor
        if reward?.isValid == true && !itemIsLocked() {
            buyLabel.textColor = theme.tintColor
        }
        view.backgroundColor = theme.backgroundTintColor.darker(by: 50).withAlphaComponent(0.6)
        topContentView.backgroundColor = theme.windowBackgroundColor
    }
    
    func styleViews() {
        currencyCountView.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        
        hourglassCountView.currency = .hourglass
        gemCountView.currency = .gem
        goldCountView.currency = .gold
    }
    
    @objc
    private func modalTapped() { }
    
    @objc
    private func backgroundTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func refreshBalances() {
        if let user = self.user {
            gemCountView.amount = user.gemCount
            goldCountView.amount = Int(user.stats?.gold ?? 0)
            if let hourglasses = user.purchased?.subscriptionPlan?.consecutive?.hourglasses {
                hourglassCountView.amount = hourglasses
            }
        }
    }
    
    func setupItem() {
        if let contentView = closableShopModal.shopModalBgView.contentView {
            if let reward = self.reward {
                if reward.purchaseType == "customization" || reward.purchaseType == "backgrounds" {
                    itemView = AvatarShopItemView(withReward: reward, withUser: user, for: contentView)
                } else {
                    itemView = HRPGSimpleShopItemView(withReward: reward, withUser: user, for: contentView)
                }
            }
            if shopIdentifier == nil {
                isPinned = true
            }
            updateBuyButton()
            let key = reward?.key ?? ""
            if let itemView = itemView {
                switch getPurchaseType() {
                case "quests":
                    setupQuests(contentView, itemView: itemView, key: key)
                case "gear":
                    setupGear(contentView, itemView: itemView, key: key, shopIdentifier: shopIdentifier)
                case "mystery_set":
                    addItemSet(itemView: itemView, to: contentView)
                default:
                    addItemSet(itemView: itemView, to: contentView)
                }
            }
            contentView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.triggerLayout()
            
            userRepository.getInAppRewards().take(first: 1)
                .map({ (rewards, _) in
                    return rewards.map({ (reward) in
                        return reward.key
                    })
                }).on(value: {[weak self]rewards in
                    self?.isPinned = rewards.contains(self?.reward?.key)
                }).start()
        }
    }
    
    private func setupQuests(_ contentView: UIView, itemView: UIView, key: String) {
        let questView = QuestDetailView(frame: CGRect.zero)
        inventoryRepository.getQuest(key: key).take(first: 1).skipNil().on(value: { quest in
            questView.configure(quest: quest)
        }).start()
        addItemAndDetails(itemView, questView, to: contentView)
    }
    
    private func setupGear(_ contentView: UIView, itemView: UIView, key: String, shopIdentifier: String?) {
        if let identifier = shopIdentifier, identifier == Constants.TimeTravelersShopKey {
            addItemSet(itemView: itemView, to: contentView)
        } else {
            let statsView = HRPGItemStatsView(frame: CGRect.zero)
            inventoryRepository.getGear(keys: [key])
                .take(first: 1)
                .map { (gear, _) -> GearProtocol? in
                    return gear.first
                }
                .skipNil()
                .on(value: { gear in
                    statsView.configure(gear: gear)
                }).start()
            addItemAndDetails(itemView, statsView, to: contentView)
        }
    }
    
    func updateBuyButton() {
        if reward?.isValid == false {
            return
        }
        UIView.animate(withDuration: 0.2) {
            if self.isPurchasing {
                self.currencyCountView.isHidden = true
                self.buyLabel.isHidden = true
                self.activityIndicator.isHidden = false
            } else {
                self.currencyCountView.isHidden = false
                self.buyLabel.isHidden = false
                self.activityIndicator.isHidden = true
            }
        }
        
        var isLocked = itemIsLocked()
        if let reward = self.reward {
            let totalValue = Int(reward.value) * purchaseQuantity
            if let currencyString = reward.currency, let currency = Currency(rawValue: currencyString) {
                currencyCountView.currency = currency
                if reward.key == "gem" && user?.purchased?.subscriptionPlan?.gemsRemaining == 0 {
                    isLocked = true
                }
            } else {
                currencyCountView.currency = .gold
            }
            currencyCountView.amount = totalValue
        }
        if (Currency(rawValue: reward?.currency ?? "gold") != .gold || canAfford()) && !isLocked {
            buyLabel.textColor = .white
            currencyCountView.textColor = .white
            buyButton.backgroundColor = ThemeService.shared.theme.fixedTintColor
            currencyCountView.state = .normal
        } else {
            if currencyCountView.currency == .gold {
                buyLabel.textColor = ThemeService.shared.theme.dimmedTextColor
                currencyCountView.textColor = ThemeService.shared.theme.dimmedTextColor
            }
            buyButton.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            if isLocked {
                currencyCountView.state = .locked
            } else {
                currencyCountView.state = .cantAfford
            }
        }
        
        buyButton.shouldGroupAccessibilityChildren = true
        buyButton.isAccessibilityElement = true
        currencyCountView.isAccessibilityElement = false
        buyButton.accessibilityLabel = L10n.buyForX(currencyCountView.accessibilityLabel ?? "")
    }
    
    func canAfford() -> Bool {
        var currency: Currency?
        var price: Float = 0.0
        
        if let inAppReward = reward {
            if let currencyString = inAppReward.currency {
                currency = Currency(rawValue: currencyString)
            } else {
                currency = Currency.gold
            }
            price = inAppReward.value * Float(purchaseQuantity)
        }
        
        if let user = self.user, let selectedCurrency = currency {
            switch selectedCurrency {
            case .gold:
                return price <= user.stats?.gold ?? 0
            case .gem:
                return price <= Float(user.gemCount)
            case .hourglass:
                return price <= Float(user.purchased?.subscriptionPlan?.consecutive?.hourglasses ?? 0)
            }
        }
        return false
    }
    
    func itemIsLocked() -> Bool {
        var isLocked = false
        if let inAppReward = reward {
            isLocked = inAppReward.locked
        }
        return isLocked
    }
    
    func canBuy() -> Bool {
        return canAfford() && !itemIsLocked()
    }
    
    func getPurchaseType() -> String {
        if let reward = self.reward {
            return reward.purchaseType ?? ""
        } else {
            return ""
        }
    }
    
    func addItemAndDetails(_ itemView: UIView, _ detailView: UIView, to contentView: UIView) {
        let views = ["itemView": itemView, "detailView": detailView]
        contentView.addSubview(itemView)
        contentView.addSubview(detailView)
        contentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(itemView))
        if canBulkPurchase() {
            let bulkView = HRPGBulkPurchaseView(for: contentView)
            bulkView.onValueChanged = {[weak self] value in
                self?.purchaseQuantity = value
            }
            bulkView.maxValue = user?.purchased?.subscriptionPlan?.gemsRemaining ?? 0
            contentView.addSubview(bulkView)
            self.bulkView = bulkView
            contentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(bulkView))
            contentView.addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[itemView]-0-[detailView]-0-[bulkView]-20-|",
                                                                                     ["itemView": itemView, "detailView": detailView, "bulkView": bulkView]))
            if reward?.key != "gem" {
                bulkView.hideGemIcon(isHidden: true)
            }
        } else {
            contentView.addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[itemView]-0-[detailView]-20-|", views))
        }
        contentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(detailView))
    }
    
    func addItemSet(itemView: UIView, to contentView: UIView) {
        contentView.addSubview(itemView)
        contentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(itemView))
        if canBulkPurchase() {
            let bulkView = HRPGBulkPurchaseView(for: contentView)
            bulkView.onValueChanged = {[weak self] value in
                self?.purchaseQuantity = value
            }
            contentView.addSubview(bulkView)
            self.bulkView = bulkView
            if reward?.key != "gem" {
                bulkView.hideGemIcon(isHidden: true)
            }

            contentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(bulkView))
            contentView.addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[itemView]-0-[bulkView]-20-|", ["itemView": itemView, "bulkView": bulkView]))
        } else {
            contentView.addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[itemView]-20-|", ["itemView": itemView]))
        }
    }
    
    // MARK: actions

    @IBAction func pinPressed() {
        var path = ""
        var pinType = ""
        if let inAppReward = reward, inAppReward.isValid {
            path = inAppReward.path ?? ""
            pinType = inAppReward.pinType ?? ""
        }
        inventoryRepository.togglePinnedItem(pinType: pinType, path: path).observeValues {[weak self] (_) in
            self?.isPinned = !(self?.isPinned ?? false)
        }
    }
    
    private func canBulkPurchase() -> Bool {
        return reward?.key == "gem" || ["eggs", "hatchingPotions", "food"].contains(reward?.purchaseType ?? "")
    }
    
    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    @objc
    func buyPressed() {
        if reward?.isValid != true {
            dismiss(animated: true, completion: nil)
            return
        }
        if itemIsLocked() {
            return
        }
        
        if reward?.key?.isEmpty == false {
            var currency = Currency.gold
            if let currencyString = reward?.currency, let thisCurrency = Currency(rawValue: currencyString) {
                currency = thisCurrency
            }
            if !canBuy() {
                if reward?.key == "gem" {
                    HRPGBuyItemModalViewController.displayGemCapReachedModal()
                } else if !canAfford() {
                    if currency == .hourglass {
                        HRPGBuyItemModalViewController.displayInsufficientHourglassesModal(user: user)
                    } else if currency == .gem {
                        HRPGBuyItemModalViewController.displayInsufficientGemsModal(reward: reward)
                    } else {
                        HRPGBuyItemModalViewController.displayInsufficientGoldModal()
                    }
                }
                return
            }
            remainingPurchaseQuantity { remainingQuantity in
                if remainingQuantity >= 0 {
                    if remainingQuantity < self.purchaseQuantity {
                        self.displayPurchaseConfirmationDialog(quantity: remainingQuantity)
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                }
                self.isPurchasing = true
                self.buyItem(quantity: self.purchaseQuantity)
            }
        }
    }
    
    private func buyItem(quantity: Int) {
        var key = ""
        var purchaseType = ""
        var currency = Currency.gold
        var setIdentifier = ""
        var value = 0
        var successBlock = {
            if let action = self.onInventoryRefresh {
                action()
            }
        }
        var text = ""
        let failureBlock = {[weak self] in
            self?.isPurchasing = false
        }
        if let inAppReward = reward {
            key = inAppReward.key ?? ""
            purchaseType = inAppReward.purchaseType ?? ""
            setIdentifier = inAppReward.key ?? ""
            value = Int(inAppReward.value)
            text = inAppReward.text ?? ""
            if let currencyString = inAppReward.currency, let thisCurrency = Currency(rawValue: currencyString) {
                currency = thisCurrency
            }
            successBlock = {
                self.dismiss(animated: true, completion: nil)
                self.userRepository.retrieveInAppRewards().observeCompleted {
                }
                if let action = self.onInventoryRefresh {
                    action()
                }
            }
        }
        if currency == .hourglass {
            if purchaseType == "gear" || purchaseType == "mystery_set" {
                inventoryRepository.purchaseMysterySet(identifier: setIdentifier, text: text)
                .flatMap(.latest, { _ in
                    return self.userRepository.retrieveUser()
                }).observeResult({[weak self] (result) in
                    switch result {
                    case .success:
                        successBlock()
                    case .failure:
                        failureBlock()
                        HRPGBuyItemModalViewController.displayInsufficientHourglassesModal(user: self?.user)
                    }
                })
            } else {
                inventoryRepository.purchaseHourglassItem(purchaseType: purchaseType, key: key, text: text)
                .flatMap(.latest, { _ in
                    return self.userRepository.retrieveUser()
                }).observeResult({[weak self] (result) in
                    switch result {
                    case .success:
                        successBlock()
                    case .failure:
                        failureBlock()
                        HRPGBuyItemModalViewController.displayInsufficientHourglassesModal(user: self?.user)
                    }
                })
            }
        } else if purchaseType == "fortify" {
            userRepository.reroll().observeResult({ (result) in
                switch result {
                case .success:
                    successBlock()
                case .failure:
                    failureBlock()
                    HRPGBuyItemModalViewController.displayInsufficientGemsModal(reward: self.reward)
                }
            })
        } else if purchaseType == "backgrounds" {
            customizationRepository.unlock(path: "background.\(reward?.key ?? "")", value: reward?.value ?? 0).observeResult { result in
                switch result {
                case .success:
                    successBlock()
                case .failure:
                    failureBlock()
                    HRPGBuyItemModalViewController.displayInsufficientGemsModal(reward: self.reward)
                }
            }
        } else if currency == .gem || purchaseType == "gems" {
            inventoryRepository.purchaseItem(purchaseType: purchaseType, key: key, value: value, quantity: quantity, text: text)
            .flatMap(.latest, { _ in
                return self.userRepository.retrieveUser()
            }).observeResult({ (result) in
            switch result {
            case .success:
                successBlock()
            case .failure:
                failureBlock()
                    if key == "gem" {
                        HRPGBuyItemModalViewController.displayGemCapReachedModal()
                    } else {
                        HRPGBuyItemModalViewController.displayInsufficientGemsModal(reward: self.reward)
                    }
                }
            })
        } else {
            if currency == .gold && purchaseType == "quests" {
                inventoryRepository.purchaseQuest(key: key, text: text)
                    .flatMap(.latest, { _ in
                        return self.userRepository.retrieveUser()
                    })
                    .observeResult({ (result) in
                switch result {
                case .success:
                    successBlock()
                case .failure:
                    failureBlock()
                    HRPGBuyItemModalViewController.displayInsufficientGoldModal()
                    }
                })
            } else if purchaseType == "debuffPotion" {
                userRepository.useDebuffItem(key: key).observeResult { (result) in
                    switch result {
                    case .success:
                        successBlock()
                    case .failure:
                        failureBlock()
                        HRPGBuyItemModalViewController.displayInsufficientGoldModal()
                        }
                    }
            } else {
                inventoryRepository.buyObject(key: key, quantity: quantity, price: value, text: text)
                    .flatMap(.latest, { _ in
                        return self.userRepository.retrieveUser(forced: true)
                    })
                    .observeResult({ (result) in
                switch result {
                case .success:
                    successBlock()
                case .failure:
                    failureBlock()
                    HRPGBuyItemModalViewController.displayInsufficientGoldModal()
                    }
                })
            }
        }
    }
    
    static func displayInsufficientGemsModal(reward: InAppRewardProtocol? = nil, reason: String = "purchase modal", delayDisplay: Bool = true) {
        HabiticaAnalytics.shared.log("show insufficient gems modal", withEventProperties: ["reason": "purchase modal", "item": reward?.key ?? ""])
        let alert = prepareInsufficientModal(title: L10n.notEnoughGems, message: L10n.moreGemsMessage, image: Asset.insufficientGems.image)
        alert.addAction(title: L10n.purchaseGems, isMainAction: true, handler: { _ in
            let navigationController = StoryboardScene.Main.purchaseGemNavController.instantiate()
            UIApplication.topViewController()?.present(navigationController, animated: true, completion: nil)
        })
        alert.addCloseAction()
        if delayDisplay {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                alert.enqueue()
            }
        } else {
            alert.enqueue()
        }
    }
    
    private static func displayInsufficientGoldModal() {
        let alert = prepareInsufficientModal(title: L10n.notEnoughGold, message: L10n.completeMoreTasks, image: Asset.insufficientGold.image)
        alert.addAction(title: L10n.takeMeBack, isMainAction: true)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            alert.enqueue()
        }
    }
    
    private static func displayInsufficientHourglassesModal(user: UserProtocol?) {
        let alert = prepareInsufficientModal(title: L10n.notEnoughHourglasses, message: nil, image: Asset.insufficientHourglasses.image)
        if user?.isSubscribed == true {
            alert.message = L10n.insufficientHourglassesMessageSubscriber
            alert.addAction(title: L10n.takeMeBack, isMainAction: true)
        } else {
            alert.message = L10n.insufficientHourglassesMessage
            alert.addAction(title: L10n.learnMore, isMainAction: true, handler: { _ in
                let navigationController = StoryboardScene.Main.subscriptionNavController.instantiate()
                UIApplication.topViewController()?.present(navigationController, animated: true, completion: nil)
            })
            alert.addCloseAction()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            alert.enqueue()
        }
    }
    
    private static func displayGemCapReachedModal() {
        let alert = prepareInsufficientModal(title: L10n.monthlyGemCapReached, message: L10n.Inventory.noGemsLeft, image: Asset.insufficientGems.image)
        alert.addAction(title: L10n.takeMeBack, isMainAction: true)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            alert.enqueue()
        }
    }
    
    private static func prepareInsufficientModal(title: String, message: String?, image: UIImage) -> HabiticaAlertController {
        let alert = HabiticaAlertController(title: title, message: message)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        alert.contentView = imageView
        alert.containerViewSpacing = 20
        alert.arrangeMessageLast = true
        alert.messageFont = UIFontMetrics.default.scaledSystemFont(ofSize: 15)
        return alert
    }
    
    private func displayPurchaseConfirmationDialog(quantity: Int) {
        if quantity == 0 {
            displayNoRemainingConfirmationDialog()
        } else {
            displaySomeRemainingConfirmationDialog(quantity: quantity)
        }
    }
    
    private func displayNoRemainingConfirmationDialog() {
        let alert = HabiticaAlertController(title: L10n.excessItems, message: L10n.excessNoItemsLeft(reward?.text ?? "", purchaseQuantity, reward?.text ?? ""))
        alert.addAction(title: L10n.purchaseX(purchaseQuantity), isMainAction: true) { _ in
            self.buyItem(quantity: self.purchaseQuantity)
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addCancelAction()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.enqueue()
        }
    }
    
    private func displaySomeRemainingConfirmationDialog(quantity: Int) {
        let alert = HabiticaAlertController(title: L10n.excessItems, message: L10n.excessXItemsLeft(quantity, reward?.text ?? "", purchaseQuantity))
        alert.addAction(title: L10n.purchaseX(purchaseQuantity), isMainAction: true) { _ in
            self.buyItem(quantity: self.purchaseQuantity)
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(title: L10n.purchaseX(quantity), isMainAction: false) { _ in
            self.buyItem(quantity: quantity)
            alert.dismiss(animated: true, completion: nil)
        }
        alert.closeTitle = L10n.cancel
        alert.closeAction = {
            alert.dismiss(animated: true, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.enqueue()
        }
    }
    
    @objc
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        closableShopModal.shopModalBgView.maxHeightConstraint.constant = view.frame.size.height - 200
    }
    
    @objc
    func keyboardWillShowNotification(notification: NSNotification) {
        centerConstraint.constant = -50
    }
    
    @objc
    func keyboardWillHideNotification(notification: NSNotification) {
        centerConstraint.constant = 0
    }
    
    private func remainingPurchaseQuantity(onResult: @escaping ((Int) -> Void)) {
        var ownedCount = 0
        var shouldWarn = true
        var hasNoMounts = false
        if reward?.purchaseType == "eggs" {
            stableRepository.getPets(query: "type == 'quest' && egg == '\(reward?.key ?? "")'").take(first: 1).filter { pets -> Bool in
                shouldWarn = !pets.value.isEmpty
                return shouldWarn
            }.flatMap(.latest) { _ in
                return self.inventoryRepository.getOwnedItems(userID: nil, itemType: "eggs")
            }.flatMap(.latest) { eggs -> SignalProducer<ReactiveResults<[OwnedPetProtocol]>, ReactiveSwiftRealmError> in
                for egg in eggs.value where egg.key == self.reward?.key {
                    ownedCount += egg.numberOwned
                }
                return self.stableRepository.getOwnedPets()
            }.flatMap(.latest) { pets -> SignalProducer<ReactiveResults<[OwnedMountProtocol]>, ReactiveSwiftRealmError> in
                for pet in pets.value where pet.key?.contains(self.reward?.key ?? "") == true {
                    ownedCount += 1
                }
                return self.stableRepository.getOwnedMounts()
                }.take(first: 1)
                .on(completed: {
                    if !shouldWarn {
                        onResult(-1)
                        return
                    }
                    let remaining = 20 - ownedCount
                    onResult(max(0, remaining))
                }, value: { mounts in
                    for mount in mounts.value where mount.key?.contains(self.reward?.key ?? "") == true {
                        ownedCount += 1
                    }
                })
                .start()
        } else if reward?.purchaseType == "hatchingPotions" {
            stableRepository.getPets(query: "(type == 'premium' || type == 'wacky') && potion == '\(reward?.key ?? "")'").take(first: 1).filter { pets -> Bool in
            shouldWarn = !pets.value.isEmpty
                if pets.value.first?.type == "wacky" {
                    hasNoMounts = true
                }
            return shouldWarn
            }.flatMap(.latest) { _ in
                return self.inventoryRepository.getOwnedItems(userID: nil, itemType: "hatchingPotions")
            }.flatMap(.latest) { potions -> SignalProducer<ReactiveResults<[OwnedPetProtocol]>, ReactiveSwiftRealmError> in
                for potion in potions.value where potion.key == self.reward?.key {
                    ownedCount += potion.numberOwned
                }
                return self.stableRepository.getOwnedPets()
            }.flatMap(.latest) { pets -> SignalProducer<ReactiveResults<[OwnedMountProtocol]>, ReactiveSwiftRealmError> in
                for pet in pets.value where pet.key?.contains(self.reward?.key ?? "") == true {
                    ownedCount += 1
                }
                return self.stableRepository.getOwnedMounts()
                }.take(first: 1)
                .on(completed: {
                    if !shouldWarn {
                        onResult(-1)
                        return
                    }
                    let remaining = (hasNoMounts ? 9 : 18) - ownedCount
                    onResult(max(0, remaining))
                }, value: { mounts in
                    for mount in mounts.value where mount.key?.contains(self.reward?.key ?? "") == true {
                        ownedCount += 1
                    }
                })
                .start()
        } else {
            onResult(-1)
        }
    }
}

extension NSLayoutConstraint {
    static func defaultVerticalConstraints(_ visualFormat: String, _ views: [String: UIView]) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                              metrics: nil,
                                              views: views)
    }
    
    static func defaultHorizontalConstraints(_ view: UIView) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|",
                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                              metrics: nil,
                                              views: ["view": view])
    }
}

extension UIView {
    func addSingleViewWithConstraints(_ view: UIView) {
        addSubview(view)
        addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[view]-0-|", ["view": view]))
        addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(view))
    }
    
    func triggerLayout() {
        setNeedsUpdateConstraints()
        updateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
}
