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
    
    @IBOutlet weak var mainRewardWrapper: UIView!
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
                buyButton.backgroundColor = UIColor.yellow500.withAlphaComponent(0.3)
                amountLabel.textColor = UIColor.yellow1.withAlphaComponent(0.85)
            } else {
                currencyImageView.alpha = 0.6
                buyButton.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor.withAlphaComponent(0.5)
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
        let theme = ThemeService.shared.theme
        titleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 15)
        if let text = reward.text {
            titleLabel.attributedText = try? Down(markdownString: text.unicodeEmoji).toHabiticaAttributedString(baseSize: 15, textColor: theme.primaryTextColor)
        } else {
            titleLabel.text = ""
        }
        notesLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 11)
        if let trimmedNotes = reward.notes?.trimmingCharacters(in: .whitespacesAndNewlines), trimmedNotes.isEmpty == false {
            notesLabel.attributedText = try? Down(markdownString: trimmedNotes.unicodeEmoji).toHabiticaAttributedString(baseSize: 11, textColor: theme.secondaryTextColor)
            notesLabel.isHidden = false
        } else {
            notesLabel.isHidden = true
        }
        amountLabel.text = String(reward.value)
        
        backgroundColor = theme.contentBackgroundColor
        mainRewardWrapper.backgroundColor = theme.windowBackgroundColor
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
