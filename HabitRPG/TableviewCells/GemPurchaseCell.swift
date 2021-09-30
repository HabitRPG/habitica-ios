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
    @IBOutlet weak var leftDecorationImageView: UIImageView!
    @IBOutlet weak var rightDecorationImageView: UIImageView!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceLabelBackground: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    func setGemAmount(_ amount: Int) {
        let attributedString = NSMutableAttributedString(string: "\(amount) GEMS")
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 15),
            .kern: 1.1
        ], range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttributesToSubstring(string: "\(amount)", attributes: [
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ])
        amountLabel.attributedText = attributedString
        amountLabel.textColor = .white
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
    }
    
    func setPrice(_ price: String?) {
        priceLabel.text = price
        priceLabel.backgroundColor = .white
        priceLabel.textColor = .purple400
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
