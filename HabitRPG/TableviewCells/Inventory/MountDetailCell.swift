//
//  MountDetailCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class MountDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: NetworkImageView!
    @IBOutlet weak var activeIndicator: UIImageView!
    
    func configure(mountItem: MountStableItem, currentMount: String?) {
        backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        imageView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        imageView.cornerRadius = 6
    
        if let key = mountItem.mount?.key {
            if mountItem.owned {
                imageView.setImagewith(name: "stable_Mount_Icon_\(key)")
                accessibilityLabel = mountItem.mount?.text
            } else {
                imageView.setImagewith(name: "stable_Mount_Icon_\(key)-outline")
                accessibilityLabel = L10n.Accessibility.unknownMount
            }
        }
        
        if ThemeService.shared.isDarkTheme == true && !mountItem.owned {
            imageView.alpha = 0.5
        } else {
            imageView.alpha = 1.0
        }
        
        activeIndicator.isHidden = currentMount != mountItem.mount?.key
        activeIndicator.backgroundColor = .teal100
        
        shouldGroupAccessibilityChildren = true
        isAccessibilityElement = true
    }
}
