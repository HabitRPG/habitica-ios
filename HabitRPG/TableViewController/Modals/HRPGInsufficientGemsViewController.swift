//
//  HRPGInsufficientGemsViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/15/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import FirebaseAnalytics

class HRPGInsufficientGemsViewController: HRPGSingleOptionModalViewController {
    @IBOutlet weak var backgroundModalView: HRPGCloseableShopModalView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var buyWrapper: UIView!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    private var configRepository = ConfigRepository()

    private var iapIdentifier: String?
    var gemPrice: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundModalView.sendSubviewToBack(backgroundModalView.shopModalBgView)
        
        if (configRepository.bool(variable: .insufficientGemPurchase)) {
            buyWrapper.isHidden = false
            heightConstraint.constant = 400
            iapIdentifier = PurchaseHandler.IAPIdentifiers.first
            if configRepository.bool(variable: .insufficientGemPurchaseAdjust) && gemPrice > 4 {
                iapIdentifier = PurchaseHandler.IAPIdentifiers[1]
            }
            SwiftyStoreKit.retrieveProductsInfo(Set([iapIdentifier ?? ""])) { (result) in
                guard let product = result.retrievedProducts.first else {
                    return
                }
                self.buyLabel.text = product.localizedTitle
                self.buyButton.setTitle(product.localizedPrice, for: .normal)
            }
        } else {
            buyWrapper.isHidden = true
            heightConstraint.constant = 320
        }
    }
    
    override func populateText() {
        titleLabel.text = L10n.notEnoughGems
        if (configRepository.bool(variable: .insufficientGemPurchase)) {
            actionButton?.setTitle(L10n.moreOptions, for: .normal)
        } else {
            actionButton?.setTitle(L10n.purchaseGems, for: .normal)
        }
    }
    
    @IBAction func actionButtonPressed() {
        dismiss(animated: true, completion: nil)
        if let parentViewController = presentingViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "PurchaseGemNavController")
            parentViewController.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func buyButtonPressed() {
        if let identifier = iapIdentifier {
            PurchaseHandler.shared.purchaseGems(identifier, applicationUsername: String(AuthenticationManager.shared.currentUserId?.hashValue ?? 0)) {[weak self] _ in
                self?.dismiss(animated: true, completion: nil)
                Analytics.logEvent("purchase_gems_from_insufficient", parameters: [
                    "gemPrice": self?.gemPrice ?? 0,
                    "sku": identifier
                ])
            }
        }
    }
    
    @objc
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }

}
