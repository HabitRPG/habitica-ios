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

class HRPGBuyItemModalViewController: UIViewController, Themeable {
    @objc var reward: InAppRewardProtocol?
    @objc var shopIdentifier: String?
    private let inventoryRepository = InventoryRepository()
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
        
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var bottomButtons: UIView!
    
    @IBOutlet weak var hourglassCountView: HRPGCurrencyCountView!
    @IBOutlet weak var gemCountView: HRPGCurrencyCountView!
    @IBOutlet weak var goldCountView: HRPGCurrencyCountView!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var buyButton: UIView!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var currencyCountView: HRPGCurrencyCountView!
    @IBOutlet weak var closableShopModal: HRPGCloseableShopModalView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    @objc public weak var shopViewController: HRPGShopViewController?
    
    private var user: UserProtocol? {
        didSet {
            refreshBalances()
            updateBuyButton()
        }
    }

    private var isPinned: Bool = false {
        didSet {
            if isPinned {
                pinButton.setTitle(L10n.unpinFromRewards, for: .normal)
            } else {
                pinButton.setTitle(L10n.pinToRewards, for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topContentView.superview?.bringSubviewToFront(topContentView)
        bottomButtons.superview?.bringSubviewToFront(bottomButtons)
        styleViews()
        setupItem()
        
        closableShopModal.closeButton.addTarget(self, action: #selector(closePressed), for: UIControl.Event.touchUpInside)
        buyButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyPressed)))
        let inAppReward = reward
        pinButton.isHidden = inAppReward?.pinType == "armoire" || inAppReward?.pinType == "potion"
        
        ThemeService.shared.addThemeable(themable: self)
        
        populateText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
        }).start())
    }
    
    func populateText() {
        pinButton.setTitle(L10n.pinToRewards, for: .normal)
        buyLabel.text = L10n.buy.localizedCapitalized
        balanceLabel.text = L10n.yourBalance
    }
    
    func applyTheme(theme: Theme) {
        pinButton.setTitleColor(theme.tintColor, for: .normal)
        pinButton.backgroundColor = theme.backgroundTintColor.withAlphaComponent(0.05)
        pinButton.layer.borderColor = theme.dimmedColor.cgColor
        buyButton.backgroundColor = theme.backgroundTintColor.withAlphaComponent(0.05)
        buyButton.layer.borderColor = theme.dimmedColor.cgColor
        closableShopModal.closeButton.setTitleColor(theme.tintColor, for: .normal)
        closableShopModal.closeButton.backgroundColor = theme.contentBackgroundColor
        closableShopModal.shopModalBgView.backgroundColor = theme.contentBackgroundColor
        closableShopModal.shopModalBgView.contentView.backgroundColor = theme.contentBackgroundColor

        if !itemIsLocked() {
            buyLabel.textColor = theme.tintColor
        }
        view.backgroundColor = theme.backgroundTintColor.darker(by: 50).withAlphaComponent(0.6)
    }
    
    func styleViews() {
        pinButton.layer.borderWidth = 0.5
        
        buyButton.layer.borderWidth = 0.5
        currencyCountView.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        
        hourglassCountView.currency = .hourglass
        gemCountView.currency = .gem
        goldCountView.currency = .gold
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
            var itemView: HRPGSimpleShopItemView?
            if let reward = self.reward {
                itemView = HRPGSimpleShopItemView(withReward: reward, withUser: user, for: contentView)
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
                    contentView.addSingleViewWithConstraints(itemView)
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
        var isLocked = itemIsLocked()
        if let reward = self.reward {
            if let currencyString = reward.currency, let currency = Currency(rawValue: currencyString) {
                currencyCountView.currency = currency
                if reward.key == "gem" && user?.purchased?.subscriptionPlan?.gemsRemaining == 0 {
                    isLocked = true
                }
            } else {
                currencyCountView.currency = .gold
            }
            currencyCountView.amount = Int(reward.value)
        }
        if canAfford() && !isLocked {
            currencyCountView.state = .normal
        } else {
            if currencyCountView.currency == .gold {
                buyLabel.textColor = .gray400()
            }
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
            price = inAppReward.value
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
        contentView.addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[itemView]-0-[detailView]-20-|", views))
        contentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(detailView))
    }
    
    func addItemSet(itemView: UIView, to contentView: UIView) {
        contentView.addSubview(itemView)
        contentView.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(itemView))
        contentView.addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[itemView]-20-|", ["itemView": itemView]))
    }
    
    // MARK: actions

    @IBAction func pinPressed() {
        var path = ""
        var pinType = ""
        if let inAppReward = reward {
            path = inAppReward.path ?? ""
            pinType = inAppReward.pinType ?? ""
        }
        inventoryRepository.togglePinnedItem(pinType: pinType, path: path).observeValues {[weak self] (_) in
            self?.isPinned = !(self?.isPinned ?? false)
            if let shopViewController = self?.shopViewController {
            }
        }
    }
    
    //swiftlint:disable function_body_length
    //swiftlint:disable cyclomatic_complexity
    @objc
    func buyPressed() {
        if itemIsLocked() {
            return
        }
        var key = ""
        var purchaseType = ""
        var currency = Currency.gold
        var setIdentifier = ""
        var value = 0
        var successBlock = {}
        var text = ""
        /*if let shopItem = item {
            key = shopItem.key ?? ""
            purchaseType = shopItem.purchaseType ?? ""
            text = shopItem.text ?? ""
            imageName = shopItem.imageName ?? ""
            setIdentifier = shopItem.category?.identifier ?? shopItem.key ?? ""
            value = shopItem.value?.intValue ?? 0
            if let currencyString = shopItem.currency, let thisCurrency = Currency(rawValue: currencyString) {
                currency = thisCurrency
            }
            successBlock = {
                if purchaseType == "gear" {
                    self.inventoryRepository.retrieveShopInventory(identifier: GearMarketKey).observeCompleted {}
                } else if let identifier = self.shopIdentifier {
                    self.inventoryRepository.retrieveShopInventory(identifier: identifier).observeCompleted {}
                }
            }
        } else*/ if let inAppReward = reward {
            key = inAppReward.key ?? ""
            purchaseType = inAppReward.purchaseType ?? ""
            setIdentifier = inAppReward.key ?? ""
            value = Int(inAppReward.value)
            text = inAppReward.text ?? ""
            if let currencyString = inAppReward.currency, let thisCurrency = Currency(rawValue: currencyString) {
                currency = thisCurrency
            }
            successBlock = {
                self.userRepository.retrieveInAppRewards().observeCompleted {}
            }
        }
        
        if key.isEmpty == false {
            self.dismiss(animated: true, completion: nil)
            
            let topViewController = self.presentingViewController
            if !canBuy() {
                var viewControllerName: String?
                if !canAfford() {
                    if currency == .hourglass {
                        viewControllerName = "InsufficientHourglassesViewController"
                    } else if currency == .gem {
                        viewControllerName = "InsufficientGemsViewController"
                    } else {
                        viewControllerName = "InsufficientGoldViewController"
                    }
                } else if key == "gem" {
                    viewControllerName = "GemCapReachedViewController"
                }
                
                if let name = viewControllerName {
                    HRPGBuyItemModalViewController.displayViewController(name: name, parent: topViewController)
                }
                
                return
            }
            
            if currency == .hourglass {
                if purchaseType == "gear" || purchaseType == "mystery_set" {
                    inventoryRepository.purchaseMysterySet(identifier: setIdentifier, text: text).observeResult({ (result) in
                        if result.error != nil {
                            HRPGBuyItemModalViewController.displayViewController(name: "InsufficientHourglassesViewController", parent: topViewController)
                        } else {
                            successBlock()
                        }
                    })
                } else {
                    inventoryRepository.purchaseHourglassItem(purchaseType: purchaseType, key: key, text: text).observeResult({ (result) in
                        if result.error != nil {
                            HRPGBuyItemModalViewController.displayViewController(name: "InsufficientHourglassesViewController", parent: topViewController)
                        } else {
                            successBlock()
                        }
                    })
                }
            } else if currency == .gem || purchaseType == "gems" {
                inventoryRepository.purchaseItem(purchaseType: purchaseType, key: key, value: value, text: text).observeResult({ (result) in
                    if result.error != nil {
                        if key == "gem" {
                            HRPGBuyItemModalViewController.displayViewController(name: "GemCapReachedViewController", parent: topViewController)
                        } else {
                            HRPGBuyItemModalViewController.displayViewController(name: "InsufficientGemsViewController", parent: topViewController)
                        }
                    } else {
                        successBlock()
                    }
                })
            } else if purchaseType == "fortify" {
                userRepository.reroll().observeResult({ (result) in
                    if result.error != nil {
                        HRPGBuyItemModalViewController.displayViewController(name: "InsufficientGoldViewController", parent: topViewController)
                    } else {
                        successBlock()
                    }
                })
            } else {
                if currency == .gold && purchaseType == "quests" {
                    inventoryRepository.purchaseQuest(key: key, text: text).observeResult({ (result) in
                        if result.error != nil {
                            HRPGBuyItemModalViewController.displayViewController(name: "InsufficientGoldViewController", parent: topViewController)
                        } else {
                            successBlock()
                        }
                    })
                } else {
                    inventoryRepository.buyObject(key: key, price: value, text: text).observeResult({ (result) in
                        if result.error != nil {
                            HRPGBuyItemModalViewController.displayViewController(name: "InsufficientGoldViewController", parent: topViewController)
                        } else {
                            successBlock()
                        }
                    })
                }
            }
        }
    }
    
    private static func displayViewController(name: String, parent: UIViewController?) {
        let storyboard = UIStoryboard(name: "BuyModal", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: name)
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        parent?.present(viewController, animated: true, completion: nil)
    }
    
    @objc
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        closableShopModal.shopModalBgView.maxHeightConstraint.constant = view.frame.size.height - 200
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
        self.addSubview(view)
        self.addConstraints(NSLayoutConstraint.defaultVerticalConstraints("V:|-0-[view]-0-|", ["view": view]))
        self.addConstraints(NSLayoutConstraint.defaultHorizontalConstraints(view))
    }
    
    func triggerLayout() {
        self.setNeedsUpdateConstraints()
        self.updateConstraints()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
