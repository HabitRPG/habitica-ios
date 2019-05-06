//
//  CustomizationHeaderView.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class CustomizationHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var currencyView: HRPGCurrencyCountView!
    @IBOutlet weak var purchaseButton: UIView!
    @IBOutlet weak var buyAllLabel: UILabel!
    
    var purchaseButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        currencyView.currency = .gem
        
        purchaseButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTapped)))
        
        buyAllLabel.text = L10n.buyAll
    }
    
    func configure(customizationSet: CustomizationSetProtocol, isBackground: Bool) {
        if isBackground {
            if customizationSet.key?.contains("incentive") == true {
                label.text = L10n.plainBackgrounds
            } else if let key = customizationSet.key?.replacingOccurrences(of: "backgrounds", with: "") {
                let index = key.index(key.startIndex, offsetBy: 2)
                let month = Int(key[..<index]) ?? 0
                let year = Int(key[index...]) ?? 0
                let dateFormatter = DateFormatter()
                let monthName = dateFormatter.monthSymbols[month-1]
                label.text = "\(monthName) \(year)"
            }
        } else {
            label.text = customizationSet.text
        }
        currencyView.amount = Int(customizationSet.setPrice)
        
        purchaseButton.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        purchaseButton.borderColor = ThemeService.shared.theme.tintColor
    }
    
    @objc
    private func buttonTapped() {
        if let action = purchaseButtonTapped {
            action()
        }
    }
    
}
