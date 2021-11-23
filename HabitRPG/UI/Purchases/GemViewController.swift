//
//  GemViewController.swift
//  Habitica
//
//  Created by Phillip on 13.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import Keys
import ReactiveSwift
import Habitica_Models

class GemViewController: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var products: [SKProduct]?
    var user: UserProtocol?
    var expandedList = [Bool](repeating: false, count: 4)
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private let userRepository = UserRepository()
    private let socialRepository = SocialRepository()
    private let configRepository = ConfigRepository.shared
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    private var activePromo: HabiticaPromotion?
    
    var isSubscribed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.title = L10n.done

        let nib = UINib.init(nibName: "GemPurchaseView", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "Cell")
        retrieveProductList()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
        }).start())
        
        navigationController?.navigationBar.standardAppearance.shadowColor = .clear
        navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
        
        HabiticaAnalytics.shared.logNavigationEvent("gem screen")
        
        activePromo = configRepository.activePromotion()
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        navigationController?.navigationBar.standardAppearance.backgroundColor = theme.contentBackgroundColor
        navigationController?.navigationBar.shadowImage = UIImage()
        collectionView.backgroundColor = theme.contentBackgroundColor
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        purchaseGems(identifier: PurchaseHandler.IAPIdentifiers[indexPath.item])
        let cell = collectionView.cellForItem(at: indexPath)
        (cell as? GemPurchaseCell)?.setLoading(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let product = self.products?[indexPath.item], let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? GemPurchaseCell else {
            return UICollectionViewCell()
        }
        cell.setPrice(product.localizedPrice)
        cell.backgroundColor = .purple400

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
                
        activePromo?.configureGemView(view: cell, regularAmount: amount)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if activePromo != nil && (activePromo?.promoType == .gemsAmount || activePromo?.promoType == .gemsPrice || activePromo?.promoType == .subscription) {
            return CGSize(width: collectionView.frame.size.width, height: 382)
        } else {
            return CGSize(width: collectionView.frame.size.width, height: 302)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 212)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var identifier = "nil"
        
        if kind == UICollectionView.elementKindSectionHeader {
            identifier = "HeaderView"
        }
        
        if kind == UICollectionView.elementKindSectionFooter {
            identifier = "FooterView"
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        
        if kind == UICollectionView.elementKindSectionFooter {
            if let label = view.viewWithTag(2) as? UILabel {
                label.text = L10n.giftGemsPrompt
                label.textColor = ThemeService.shared.theme.quadTextColor
            }
            if let promoView = view.viewWithTag(3) as? SubscriptionPromoView {
                promoView.onButtonTapped = { [weak self] in self?.performSegue(withIdentifier: StoryboardSegue.Main.subscriptionSegue.rawValue, sender: self) }
            }
            if let label = view.viewWithTag(4) as? UILabel {
                label.text = L10n.gemsSupportDevelopers
                label.textColor = .white
            }
            if let view = view.viewWithTag(5) {
                view.backgroundColor = .clear
            }
        } else if kind == UICollectionView.elementKindSectionHeader {
            if let headerImage = view.viewWithTag(1) as? UIImageView {
                if ThemeService.shared.theme.isDark {
                    headerImage.image = Asset.gemPurchaseHeaderDark.image
                } else {
                    headerImage.image = Asset.gemPurchaseHeader.image
                }
                headerImage.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
            }
            
            if let headerLabel = view.viewWithTag(3) as? UILabel {
                if ThemeService.shared.theme.isDark {
                    headerLabel.textColor = ThemeService.shared.theme.ternaryTextColor
                } else {
                    headerLabel.textColor = ThemeService.shared.theme.backgroundTintColor
                }
            }
            
            if let listLabel = view.viewWithTag(4) as? UILabel {
                if ThemeService.shared.theme.isDark {
                    listLabel.textColor = ThemeService.shared.theme.ternaryTextColor
                } else {
                    listLabel.textColor = ThemeService.shared.theme.backgroundTintColor
                }
            }
            
            if let stackView = view.viewWithTag(6) as? UIStackView {
                stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                stackView.isLayoutMarginsRelativeArrangement = true
            }
            
            if let promo = activePromo, promo.promoType == .gemsAmount || promo.promoType == .gemsPrice || promo.promoType == .subscription {
                if let promoView = view.viewWithTag(5) as? PromoBannerView {
                    promoView.isHidden = false
                    promo.configurePurchaseBanner(view: promoView)
                    promoView.onTapped = { [weak self] in self?.performSegue(withIdentifier: StoryboardSegue.Main.showPromoInfoSegue.rawValue, sender: self) }
                }
            }
        }
        
        return view
    }

    func purchaseGems(identifier: String) {
        guard let userID = self.user?.id ?? userRepository.currentUserId else {
            return
        }
        PurchaseHandler.shared.purchaseGems(identifier, applicationUsername: String(userID.hashValue)) { _ in
            self.collectionView?.reloadData()
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    private var giftRecipientUsername = ""
    
    private func showGiftSubscriptionModal() {
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
        alertController.containerViewSpacing = 4
        alertController.show()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.openGiftSubscriptionDialog.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let giftSubscriptionController = navigationController?.topViewController as? GiftSubscriptionViewController
            giftSubscriptionController?.giftRecipientUsername = giftRecipientUsername
        } else if segue.identifier == StoryboardSegue.Main.giftGemsSegue.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let giftSubscriptionController = navigationController?.topViewController as? GiftGemsViewController
            giftSubscriptionController?.giftRecipientUsername = giftRecipientUsername
        }
    }
    
    @IBAction func giftGemsTapped(_ sender: Any) {
        let alertController = HabiticaAlertController(title: L10n.giftGemsAlertTitle)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        let label = UILabel()
        label.text = L10n.giftGemsAlertPrompt
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 15)
        label.textColor = ThemeService.shared.theme.ternaryTextColor
        label.textAlignment = .center
        stackView.addArrangedSubview(label)
        let usernameTextField = PaddedTextField()
        usernameTextField.attributedPlaceholder = NSAttributedString(string: L10n.username, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        usernameTextField.autocapitalizationType = .none
        usernameTextField.spellCheckingType = .no
        usernameTextField.borderStyle = .none
        usernameTextField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        usernameTextField.borderColor = ThemeService.shared.theme.offsetBackgroundColor
        usernameTextField.borderWidth = 1
        usernameTextField.cornerRadius = 8
        usernameTextField.textInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        usernameTextField.textColor = ThemeService.shared.theme.secondaryTextColor
        stackView.addArrangedSubview(usernameTextField)
        alertController.contentView = stackView
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.isHidden = true
        stackView.addArrangedSubview(activityIndicator)
        
        let errorView = UILabel()
        errorView.isHidden = true
        errorView.textColor = ThemeService.shared.theme.errorColor
        errorView.text = L10n.Errors.userNotFound
        errorView.textAlignment = .center
        errorView.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
        stackView.addArrangedSubview(errorView)

        var foundUser = false
        alertController.addAction(title: L10n.continue, isMainAction: true, closeOnTap: false) {[weak self] _ in
            activityIndicator.isHidden = false
            errorView.isHidden = true
            activityIndicator.startAnimating()
            if let username = usernameTextField.text {
                self?.socialRepository.retrieveMember(userID: username).on(
                    value: { _ in
                        foundUser = true
                        alertController.dismiss(animated: true, completion: {
                            self?.giftRecipientUsername = username
                            self?.perform(segue: StoryboardSegue.Main.giftGemsSegue)
                        })
                }
                ).observeCompleted {
                    activityIndicator.isHidden = true
                    if !foundUser {
                        errorView.isHidden = false
                    }
                }
                
            }
        }
        alertController.addCancelAction()
        alertController.show()
        usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func unwindToList(_ segue: UIStoryboardSegue) {
    }
}
