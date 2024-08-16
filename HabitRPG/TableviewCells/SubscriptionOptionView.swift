//
//  SubscriptionOptionView.swift
//  Habitica
//
//  Created by Phillip Thelen on 07/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionOptionView: UITableViewCell {

    // swiftlint:disable private_outlet
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var selectionView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gemCapLabel: PaddedLabel!
    @IBOutlet weak var mysticHourglassLabel: PaddedLabel!
    @IBOutlet weak var flagView: FlagView!
    // swiftlint:enable private_outlet
    
    private var isAlreadySelected = false
    
    func set(product: SKProduct?) {
        priceLabel.text = product?.localizedPrice
        titleLabel.text = product?.localizedTitle

        flagView.isHidden = true
        switch product?.productIdentifier {
        case PurchaseHandler.subscriptionIdentifiers[0]:
            setMonthCount(1)
        case PurchaseHandler.subscriptionIdentifiers[1]:
            setMonthCount(3)
        case PurchaseHandler.subscriptionIdentifiers[2]:
            setMonthCount(6)
        case PurchaseHandler.subscriptionIdentifiers[3]:
            setMonthCount(12)
            flagView.text = "Popular"
            flagView.textColor = .white
            flagView.isHidden = false
        default:
            break
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let animDuration = 0.3
        let theme = ThemeService.shared.theme
        if selected {
            UIView.animate(withDuration: animDuration, animations: {[weak self] () in
                self?.wrapperView.borderWidth = 2
                self?.selectionView.image = Asset.circleSelected.image
                if theme.isDark {
                    self?.titleLabel?.textColor = UIColor.white
                    self?.priceLabel?.textColor = UIColor.white
                } else {
                    self?.titleLabel?.textColor = UIColor.purple300
                    self?.priceLabel?.textColor = UIColor.purple300
                }
                self?.gemCapLabel.textColor = UIColor.white
                self?.gemCapLabel.backgroundColor = UIColor.purple400
                self?.mysticHourglassLabel.textColor = UIColor.white
                self?.mysticHourglassLabel.backgroundColor = UIColor.purple400
            })
        } else {
            UIView.animate(withDuration: animDuration, animations: {[weak self] () in
                self?.wrapperView.borderWidth = 0
                self?.selectionView.image = Asset.circleUnselected.image
                self?.titleLabel?.textColor = theme.ternaryTextColor
                self?.priceLabel?.textColor = theme.ternaryTextColor
                self?.gemCapLabel.textColor = theme.secondaryTextColor
                self?.gemCapLabel.backgroundColor = theme.offsetBackgroundColor
                self?.mysticHourglassLabel.textColor = theme.secondaryTextColor
                self?.mysticHourglassLabel.backgroundColor = theme.offsetBackgroundColor
            })
        }
        wrapperView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
    }
    
    func setMonthCount(_ count: Int) {
        switch count {
        case 1:
            setGemCap(25)
            showGemsPerMonth(true)
        case 3:
            setGemCap(25)
            showGemsPerMonth(true)
        case 6:
            setGemCap(25)
            showGemsPerMonth(true)
        case 12:
            setGemCap(50)
            showGemsPerMonth(false)
        default:
            break
        }
    }

    func setGemCap(_ count: Int) {
        gemCapLabel.text = L10n.gemCap(count)
    }
    
    private func showGemsPerMonth(_ show: Bool) {
        if show {
            mysticHourglassLabel.isHidden = false
            mysticHourglassLabel.text = L10n.twoGemsPerMonth
        } else {
            mysticHourglassLabel.isHidden = true
        }
    }
}
