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
import ReactiveSwift
import Habitica_Models
import SwiftUIX

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
    
    private let stretchView = UIView()
    
    var isSubscribed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #unavailable(iOS 26.0) {
            navigationItem.rightBarButtonItem?.style = .done
        }

        let nib = UINib.init(nibName: "GemPurchaseView", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "Cell")
        retrieveProductList()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
        }).start())
        
        HabiticaAnalytics.shared.logNavigationEvent("navigated gem screen")
        
        activePromo = configRepository.activePromotion()
        
        collectionView.insertSubview(stretchView, at: 0)
        stretchView.backgroundColor = .purple400
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        if contentHeight > 0 {
            let bottomSize = max(0, scrollView.contentOffset.y - (contentHeight - scrollView.frame.size.height))
            stretchView.frame = CGRect(x: 0, y: contentHeight, width: scrollView.frame.size.width, height: bottomSize)
        }
        super.scrollViewDidScroll(scrollView)
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
            return CGSize(width: collectionView.frame.size.width, height: 392)
        } else {
            return CGSize(width: collectionView.frame.size.width, height: 302)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 222)
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
        let alertController = GiftingAlertController(title: L10n.giftSubscription, message: L10n.giftGemsAlertText) { username in
            RouterHandler.shared.handle(.giftSubscription(username: username))
        }
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
        let alertController = GiftingAlertController(title: L10n.giftGemsAlertTitle, message: L10n.giftGemsAlertText) {[weak self] username in
            self?.giftRecipientUsername = username
            self?.perform(segue: StoryboardSegue.Main.giftGemsSegue)
        }
        alertController.show()
    }
    
    @IBAction func unwindToList(_ segue: UIStoryboardSegue) {
    }
}
