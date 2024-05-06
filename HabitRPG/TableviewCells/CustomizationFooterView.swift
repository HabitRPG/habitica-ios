//
//  CustomizationFooterView.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.09.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import SwiftUIX

class CustomizationFooterView: UICollectionReusableView {
    
    @IBOutlet weak var hostingView: UIView!
    @IBOutlet weak var currencyView: CurrencyCountView!
    @IBOutlet weak var purchaseButton: UIView!
    @IBOutlet weak var buyAllLabel: UILabel!
    
    var purchaseButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        currencyView.currency = .gem
        
        purchaseButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTapped)))
        
        buyAllLabel.text = L10n.buyAll
    }
    
    func configure(customizationSet: CustomizationSetProtocol) {
        currencyView.amount = Int(customizationSet.setPrice)
        
        purchaseButton.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
        buyAllLabel.textColor = ThemeService.shared.theme.primaryTextColor
    }
    
    @objc
    private func buttonTapped() {
        if let action = purchaseButtonTapped {
            action()
        }
    }
    
}
