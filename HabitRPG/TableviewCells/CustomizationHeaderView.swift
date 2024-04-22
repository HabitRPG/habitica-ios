//
//  CustomizationHeaderView.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class CustomizationHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var label: UILabel!
    
    var purchaseButtonTapped: (() -> Void)?
    
    func configure(customizationSet: CustomizationSetProtocol, isBackground: Bool) {
        if isBackground {
            if customizationSet.key?.contains("incentive") == true {
                label.text = L10n.plainBackgrounds.localizedUppercase
            } else if customizationSet.key?.contains("timeTravel") == true {
                label.text = L10n.timeTravelBackgrounds.localizedUppercase
            } else if customizationSet.key?.contains("event") == true {
                label.text = L10n.eventBackgrounds.localizedUppercase
            } else if let key = customizationSet.key?.replacingOccurrences(of: "backgrounds", with: "") {
                let index = key.index(key.startIndex, offsetBy: 2)
                let month = Int(key[..<index]) ?? 0
                let year = Int(key[index...]) ?? 0
                let dateFormatter = DateFormatter()
                let monthName = month > 0 ? dateFormatter.monthSymbols[month-1] : ""
                label.text = "\(monthName) \(year)".localizedUppercase
            }
        } else {
            label.text = customizationSet.text?.uppercased()
        }
        label.textColor = ThemeService.shared.theme.quadTextColor
    }
    
    @objc
    private func buttonTapped() {
        if let action = purchaseButtonTapped {
            action()
        }
    }
    
}
