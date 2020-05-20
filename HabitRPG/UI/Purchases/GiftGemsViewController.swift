//
//  GiftGemsViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.05.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit
import Keys
import ReactiveSwift
import Habitica_Models
import Crashlytics

class GiftGemsViewController: BaseUIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var giftModeControl: UISegmentedControl!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var displayNameLabel: UsernameLabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var giftingExplanationLabel: UILabel!
    @IBOutlet weak var giftingDisclaimerLabel: UITextView!
    @IBOutlet weak var balanceWrapperView: UIStackView!
    @IBOutlet weak var gemBalanceCountView: HRPGCurrencyCountView!
    @IBOutlet weak var sendGiftBalanceButton: UIButton!
    @IBOutlet weak var balanceAmountView: HRPGBulkPurchaseView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    var products: [SKProduct]?
    var selectedSubscriptionPlan: SKProduct?
    public var giftRecipientUsername: String?
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
    private var balanceAmount = 1
    
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
        
        balanceAmountView.onValueChanged = {[weak self] value in
            self?.balanceAmount = value
        }
        
        let nib = UINib.init(nibName: "GemPurchaseView", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        retrieveProductList()
        
        avatarView.showPet = false
        avatarView.showMount = false
        avatarView.showBackground = false
        avatarView.ignoreSleeping = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: ""), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage(named: "")
        
        if let username = giftRecipientUsername {
            disposable.inner.add(socialRepository.retrieveMemberWithUsername(username).observeValues({[weak self] member in
                self?.giftedUser = member
            }))
        }
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.gemBalanceCountView.amount = user.gemCount
            self?.gemBalanceCountView.currency = .gem
            self?.balanceAmountView.maxValue = user.gemCount
            }).start())
        
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.shadowColor = .clear
            navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        giftingExplanationLabel.textColor = theme.secondaryTextColor
        giftingDisclaimerLabel.textColor = theme.quadTextColor
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.backgroundColor = theme.contentBackgroundColor
        } else {
            navigationController?.navigationBar.backgroundColor = theme.contentBackgroundColor
        }
        collectionView.backgroundColor = theme.contentBackgroundColor
        giftingDisclaimerLabel.tintColor = theme.tintColor
    }
    
    func retrieveProductList() {
        SwiftyStoreKit.retrieveProductsInfo(Set(PurchaseHandler.IAPIdentifiers)) { (result) in
            self.products = Array(result.retrievedProducts)
            self.products?.sort(by: { (product1, product2) -> Bool in
                guard let firstIndex = PurchaseHandler.IAPIdentifiers.firstIndex(of: product1.productIdentifier) else {
                    return false
                }
                guard let secondIndex = PurchaseHandler.IAPIdentifiers.firstIndex(of: product2.productIdentifier) else {
                    return true
                }
                return firstIndex < secondIndex
            })
            self.collectionView?.reloadData()
        }
    }
    
    override func populateText() {
        giftingExplanationLabel.text = L10n.giftGemsExplanationPurchase
        giftingDisclaimerLabel.text = L10n.giftGemsDisclaimer
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        purchaseGems(identifier: PurchaseHandler.IAPIdentifiers[indexPath.item])
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let product = self.products?[indexPath.item], let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? HRPGGemPurchaseView else {
            return UICollectionViewCell()
        }
        cell.setPrice(product.localizedPrice)
        cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor

        if product.productIdentifier == "com.habitrpg.ios.Habitica.4gems" {
            cell.setGemAmount(4)
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.21gems" {
            cell.setGemAmount(21)
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.42gems" {
            cell.setGemAmount(42)
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.84gems" {
            cell.setGemAmount(84)
        }
        
        cell.setPurchaseTap {[weak self] (purchaseButton) in
            switch purchaseButton?.state {
            case .some(HRPGPurchaseButtonStateError), .some(HRPGPurchaseButtonStateLabel):
                purchaseButton?.state = HRPGPurchaseButtonStateLoading
                self?.purchaseGems(identifier: product.productIdentifier)
            case .some(HRPGPurchaseButtonStateDone):
                self?.dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if configRepository.bool(variable: .enableGiftOneGetOne) {
            return CGSize(width: collectionView.frame.size.width, height: 320)
        } else {
            return CGSize(width: collectionView.frame.size.width, height: 239)
        }
    }
    
    func purchaseGems(identifier: String) {
        guard let user = self.giftedUser else {
            return
        }
        PurchaseHandler.shared.purchaseGems(identifier, applicationUsername: String(user.id?.hashValue ?? 0)) { success in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func changeGiftMode(_ sender: Any) {
        if giftModeControl.selectedSegmentIndex == 0 {
            giftingExplanationLabel.text = L10n.giftGemsExplanationPurchase
            collectionView.isHidden = false
            balanceWrapperView.isHidden = true
        } else {
            giftingExplanationLabel.text = L10n.giftGemsExplanationBalance
            collectionView.isHidden = true
            balanceWrapperView.isHidden = false
        }
    }
    
    @IBAction func sendGemsFromBalance(_ sender: Any) {
        if let user = giftedUser {
            userRepository.sendGems(amount: balanceAmount, recipient: user.id ?? "").observeCompleted {[weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
