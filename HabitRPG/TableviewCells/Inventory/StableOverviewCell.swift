//
//  StableOverviewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class StableOverviewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    func configure(item: StableOverviewItem) {
        backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        imageView.setImagewith(name: item.imageName)
        textLabel.text = item.text
        countLabel.text = "\(item.numberOwned)/\(item.totalNumber)"
        
        countLabel.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
        textLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        imageView.alpha = 1.0
        if item.numberOwned == 0 {
            countLabel.textColor = ThemeService.shared.theme.dimmedTextColor
            textLabel.textColor = ThemeService.shared.theme.dimmedTextColor
            imageView.alpha = 0.5
        } else if item.numberOwned == item.totalNumber {
            countLabel.backgroundColor = ThemeService.shared.theme.successColor
            countLabel.textColor = .white
        } else {
            countLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        }
        
        if item.type == "wacky" {
            textLabel.isHidden = true
        } else {
            textLabel.isHidden = false
        }
        
        shouldGroupAccessibilityChildren = true
        isAccessibilityElement = true
        accessibilityLabel = item.text + " " + L10n.Accessibility.xofx(item.numberOwned, item.totalNumber)
    }
    
}
