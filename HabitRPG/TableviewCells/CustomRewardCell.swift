//
//  CustomRewrdCell.swift
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import Down

class CustomRewardCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var currencyImageView: UIImageView!
    @IBOutlet weak var amountLabel: HRPGAbbrevNumberLabel!
    @IBOutlet weak var buyButton: UIView!

    var onBuyButtonTapped: (() -> Void)?
    
    public var canAfford: Bool = false {
        didSet {
            if canAfford {
                currencyImageView.alpha = 1.0
                buyButton.backgroundColor = UIColor.yellow500().withAlphaComponent(0.3)
                amountLabel.textColor = .yellow5()
            } else {
                currencyImageView.alpha = 0.3
                buyButton.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
                amountLabel.textColor = ThemeService.shared.theme.dimmedTextColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        currencyImageView.image = HabiticaIcons.imageOfGold
        
        buyButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyButtonTapped)))
    }
    
    func configure(reward: TaskProtocol) {
        if let text = reward.text {
            titleLabel.attributedText = try? Down(markdownString: text.unicodeEmoji).toHabiticaAttributedString()
        } else {
            titleLabel.text = ""
        }
        if let trimmedNotes = reward.notes?.trimmingCharacters(in: .whitespacesAndNewlines), trimmedNotes.isEmpty == false {
            notesLabel.attributedText = try? Down(markdownString: trimmedNotes.unicodeEmoji).toHabiticaAttributedString()
            notesLabel.isHidden = false
        } else {
            notesLabel.isHidden = true
        }
        amountLabel.text = String(reward.value)
        
        let theme = ThemeService.shared.theme
        backgroundColor = theme.contentBackgroundColor
        titleLabel.textColor = theme.primaryTextColor
        notesLabel.textColor = theme.secondaryTextColor
    }
    
    @objc
    func buyButtonTapped() {
        if let action = onBuyButtonTapped {
            action()
        }
    }
}
