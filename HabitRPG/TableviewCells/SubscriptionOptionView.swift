//
//  SubscriptionOptionView.swift
//  Habitica
//
//  Created by Phillip Thelen on 07/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class SubscriptionOptionView: UITableViewCell {

    //swiftlint:disable private_outlet
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var selectionView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gemCapLabel: PaddedLabel!
    @IBOutlet weak var mysticHourglassLabel: PaddedLabel!
    //swiftlint:enable private_outlet
    
    private var isAlreadySelected = false

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let animDuration = 0.3
        if selected {
            UIView.animate(withDuration: animDuration, animations: {[weak self] () in
                self?.selectionView.backgroundColor = .purple300()
                self?.selectionView.image = #imageLiteral(resourceName: "circle_selected")
                self?.gemCapLabel.textColor = UIColor.white
                self?.gemCapLabel.backgroundColor = UIColor.green100()
                self?.mysticHourglassLabel.textColor = UIColor.white
                self?.mysticHourglassLabel.backgroundColor = UIColor.green100()
            })
        } else {
            UIView.animate(withDuration: animDuration, animations: {[weak self] () in
                self?.selectionView.backgroundColor = .purple600()
                self?.selectionView.image = #imageLiteral(resourceName: "circle_unselected")
                self?.gemCapLabel.textColor = UIColor.gray50()
                self?.gemCapLabel.backgroundColor = UIColor.gray600()
                self?.mysticHourglassLabel.textColor = UIColor.gray50()
                self?.mysticHourglassLabel.backgroundColor = UIColor.gray600()
            })
        }
        wrapperView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
    }
    
    func setMonthCount(_ count: Int) {
        switch count {
        case 1:
            setGemCap(25)
            setHourglassCount(0)
        case 3:
            setGemCap(30)
            setHourglassCount(1)
        case 6:
            setGemCap(35)
            setHourglassCount(2)
        case 12:
            setGemCap(45)
            setHourglassCount(4)
        default: break
        }
    }

    func setGemCap(_ count: Int) {
        gemCapLabel.text = L10n.gemCap(count)
    }
    
    func setHourglassCount(_ count: Int) {
        // swiftlint:disable:next empty_count
        mysticHourglassLabel.isHidden = count == 0
        mysticHourglassLabel.text = L10n.hourglassCount(count)
    }
}
