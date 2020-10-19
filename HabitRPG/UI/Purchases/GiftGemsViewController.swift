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
    @IBOutlet weak var bottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
     }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        view.backgroundColor = theme.contentBackgroundColor
        giftingExplanationLabel.textColor = theme.secondaryTextColor
        giftingDisclaimerLabel.textColor = theme.quadTextColor
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.backgroundColor = theme.contentBackgroundColor
        } else {
            navigationController?.navigationBar.backgroundColor = theme.contentBackgroundColor
        }
        collectionView.backgroundColor = theme.contentBackgroundColor
        gemBalanceCountView.backgroundColor = theme.contentBackgroundColor
        balanceAmountView.backgroundColor = theme.contentBackgroundColor
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
        guard let product = self.products?[indexPath.item] else {
            return
        }
        var amount = 0
        if product.productIdentifier == "com.habitrpg.ios.Habitica.4gems" {
            amount = 4
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.21gems" {
            amount = 21
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.42gems" {
            amount = 42
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.84gems" {
            amount = 84
        }
        purchaseGems(identifier: PurchaseHandler.IAPIdentifiers[indexPath.item], amount: amount)
        let cell = collectionView.cellForItem(at: indexPath)
        (cell as? GemPurchaseCell)?.setLoading(true)
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let product = self.products?[indexPath.item], let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? GemPurchaseCell else {
            return UICollectionViewCell()
        }
        cell.setPrice(product.localizedPrice)
        cell.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        
        var amount = 0
        if product.productIdentifier == "com.habitrpg.ios.Habitica.4gems" {
            amount = 4
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.21gems" {
            amount = 21
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.42gems" {
            amount = 42
        } else if product.productIdentifier == "com.habitrpg.ios.Habitica.84gems" {
            amount = 84
        }
        cell.setGemAmount(amount)
        cell.setLoading(false)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if configRepository.bool(variable: .enableGiftOneGetOne) {
            return CGSize(width: collectionView.frame.size.width, height: 320)
        } else {
            return CGSize(width: collectionView.frame.size.width, height: 239)
        }
    }
    
    func purchaseGems(identifier: String, amount: Int) {
        guard let user = self.giftedUser else {
            return
        }
        PurchaseHandler.shared.purchaseGems(identifier, applicationUsername: String(user.id?.hashValue ?? 0)) { success in
            if success {
                self.showConfirmationDialog(gemCount: amount)
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
                self?.showConfirmationDialog(gemCount: self?.balanceAmount ?? 0)
            }
        }
    }
    
    func showConfirmationDialog(gemCount: Int) {
        let alert = HabiticaAlertController(title: L10n.giftSentConfirmation, message: L10n.giftSentTo(displayNameLabel.text ?? ""))
        let mainView = UIView()
        mainView.translatesAutoresizingMaskIntoConstraints = true
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 112, height: 50))
        view.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        view.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        let innerStackView = UIStackView(frame: CGRect(x: 24, y: 0, width: 88, height: 50))
        innerStackView.distribution = .fill
        innerStackView.spacing = 12
        view.addSubview(innerStackView)
        let iconView = UIImageView(image: HabiticaIcons.imageOfGem)
        iconView.addWidthConstraint(width: 20)
        iconView.contentMode = .center
        innerStackView.addArrangedSubview(iconView)
        let label = UILabel()
        label.textColor = UIColor.green10
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 20, ofWeight: .semibold)
        label.text = "\(gemCount)"
        innerStackView.addArrangedSubview(label)
        mainView.addSubview(view)
        mainView.addHeightConstraint(height: 50)
        alert.contentView = mainView
        view.addWidthConstraint(width: 112)
        view.addHeightConstraint(height: 50)
        view.addCenterXConstraint()
        mainView.setNeedsUpdateConstraints()
        alert.addAction(title: L10n.onwards, isMainAction: true, handler: {[weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
        alert.enqueue()
    }
    
    @objc
    func keyboardWillShowNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        bottomSpacing.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        
        let rectInScrollView = scrollView.convert(balanceAmountView.frame, from: balanceAmountView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scrollView.scrollRectToVisible(rectInScrollView, animated: true)
        }
    }
    
    @objc
    func keyboardWillHideNotification(notification: NSNotification) {
        bottomSpacing.constant = 60
    }
}
