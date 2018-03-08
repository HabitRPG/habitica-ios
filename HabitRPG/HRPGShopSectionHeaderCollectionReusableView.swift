//
//  HRPGShopSectionHeaderCollectionReusableView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/1/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class HRPGShopSectionHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gearCategoryLabel: PaddedLabel!
    
    var onGearCategoryLabelTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gearCategoryLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gearCategoryLabelTapped)))
        gearCategoryLabel.horizontalPadding = 8
    }
    
    @objc
    private func gearCategoryLabelTapped() {
        if let action = onGearCategoryLabelTapped {
            action()
        }
    }
}
