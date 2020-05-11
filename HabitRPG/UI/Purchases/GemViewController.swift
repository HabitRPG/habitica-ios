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
    
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    var isSubscribed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib.init(nibName: "GemPurchaseView", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "Cell")
        retrieveProductList()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
        }).start())
        
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.shadowColor = .clear
            navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.backgroundColor = theme.contentBackgroundColor
        } else {
            navigationController?.navigationBar.backgroundColor = theme.contentBackgroundColor
        }
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
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
                label.textColor = ThemeService.shared.theme.quadTextColor
            }
            if let view = view.viewWithTag(5) {
                view.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
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
                headerLabel.textColor = ThemeService.shared.theme.backgroundTintColor
            }
            
            if let listLabel = view.viewWithTag(4) as? UILabel {
                listLabel.textColor = ThemeService.shared.theme.backgroundTintColor
            }
            
            if configRepository.bool(variable: .enableGiftOneGetOne) {
                if let promoView = view.viewWithTag(2) as? GiftOneGetOnePromoView {
                    promoView.isHidden = false
                    promoView.onTapped = {[weak self] in
                        self?.showGiftSubscriptionModal()
                    }
                    //promoView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 411)
                }
            }
        }
        
        return view
    }

    func purchaseGems(identifier: String) {
        guard let user = self.user else {
            return
        }
        PurchaseHandler.shared.purchaseGems(identifier, applicationUsername: String(user.id?.hashValue ?? 0)) { _ in
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
        alertController.show()
        alertController.containerViewSpacing = 8
        alertController.containerView.spacing = 4
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.openGiftSubscriptionDialog.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let giftSubscriptionController = navigationController?.topViewController as? GiftSubscriptionViewController
            giftSubscriptionController?.giftRecipientUsername = giftRecipientUsername
        }
    }
}
