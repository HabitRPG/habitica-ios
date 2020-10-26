//
//  GemPurchaseCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

class GemPurchaseCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var gemsLabel: UILabel!
    @IBOutlet weak var leftDecorationImageView: UIImageView!
    @IBOutlet weak var rightDecorationImageView: UIImageView!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    func setGemAmount(_ amount: Int) {
        amountLabel.text = String(amount)
        amountLabel.textColor = ThemeService.shared.theme.primaryTextColor
        switch amount {
        case 4:
            imageView.image = Asset._4Gems.image
        case 21:
            imageView.image = Asset._21Gems.image
        case 42:
            imageView.image = Asset._42Gems.image
        case 84:
            imageView.image = Asset._84Gems.image
        default:
            break
        }
        gemsLabel.text = L10n.gems
        gemsLabel.textColor = ThemeService.shared.theme.tintColor
    }
    
    func setPrice(_ price: String?) {
        priceLabel.text = price
        priceLabel.backgroundColor = ThemeService.shared.theme.fixedTintColor
        priceLabel.textColor = .white
    }
    
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            priceLabel.isHidden = true
            loadingIndicator.isHidden = false
        } else {
                priceLabel.isHidden = false
                loadingIndicator.isHidden = true
        }
    }
}
