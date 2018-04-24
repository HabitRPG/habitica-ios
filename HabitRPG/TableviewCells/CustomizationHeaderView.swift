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
    
    var purchaseButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        currencyView.currency = .gem
        
        purchaseButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTapped)))
    }
    
    func configure(customizationSet: CustomizationSetProtocol) {
        label.text = customizationSet.text
        currencyView.amount = Int(customizationSet.setPrice)
    }
    
    @objc
    private func buttonTapped() {
        if let action = purchaseButtonTapped {
            action()
        }
    }
    
}
