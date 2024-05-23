//
//  AvatarDetailCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class CustomizationDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: NetworkImageView!
    @IBOutlet weak var currencyView: CurrencyCountView!
    
    var isCustomizationSelected: Bool = false {
        didSet {
            if isCustomizationSelected {
                layer.borderWidth = 2
            } else {
                layer.borderWidth = 0
            }
        }
    }
    
    func configure(customization: CustomizationProtocol, preferences: PreferencesProtocol?) {
        if customization.key == "0" || customization.key?.isEmpty == true || customization.key == "none" {
            imageView.image = Asset.blankAvatar.image
        } else if customization.type == "background" {
            imageView.setImagewith(name: customization.imageName(forUserPreferences: preferences))
        } else {
            imageView.setImagewith(name: customization.iconName(forUserPreferences: preferences))
        }
        if customization.set?.key?.contains("timeTravel") == true {
            currencyView.currency = .hourglass
        } else {
            currencyView.currency = .gem
        }
        currencyView.amount = Int(customization.price)
        updateAccessibility(label: "\(customization.type ?? "") \(customization.key ?? "")")
        applyTheme()
    }
    
    func configure(gear: GearProtocol) {
        if gear.key?.isEmpty != false || gear.key?.contains("base_0") == true {
            imageView.image = Asset.blankAvatar.image
        } else {
            imageView.setImagewith(name: "shop_\(gear.key ?? "")")
        }
        if gear.gearSet == "animal" {
            currencyView.amount = 2
            currencyView.currency = .gem
        }
        updateAccessibility(label: gear.text ?? "")
        applyTheme()
    }
    
    func updateAccessibility(label: String) {
        isAccessibilityElement = true
        accessibilityTraits = (isCustomizationSelected ? [.button, .selected] : .button)
        shouldGroupAccessibilityChildren = true
        accessibilityLabel = label + (isCustomizationSelected ? ", selected" : "")
    }
    
    private func applyTheme() {
        let theme = ThemeService.shared.theme
        backgroundColor = theme.windowBackgroundColor
        currencyView.backgroundColor = theme.offsetBackgroundColor
        borderColor = theme.tintColor
    }
}
