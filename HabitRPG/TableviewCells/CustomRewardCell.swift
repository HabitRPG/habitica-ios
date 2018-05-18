//
//  CustomRewrdCell.swift
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

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
                buyButton.backgroundColor = .gray600()
                amountLabel.textColor = .gray300()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        currencyImageView.image = HabiticaIcons.imageOfGold
        
        buyButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyButtonTapped)))
    }
    
    func configure(reward: TaskProtocol) {
        titleLabel.text = reward.text
        if (reward.notes?.count ?? 0) > 0 {
            notesLabel.isHidden = false
            notesLabel.text = reward.notes
        } else {
            notesLabel.isHidden = true
        }
        amountLabel.text = String(reward.value)
    }
    
    @objc
    func buyButtonTapped() {
        if let action = onBuyButtonTapped {
            action()
        }
    }
}
