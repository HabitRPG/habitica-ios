//
//  PetDetailCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class PetDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: NetworkImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    func configure(petItem: PetStableItem) {
        backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        let percentage = Float(petItem.trained) / 50.0
        if let key = petItem.pet?.key {
            if petItem.trained != 0 {
                imageView.setImagewith(name: "stable_Pet-\(key)")
                if petItem.trained > 0 {
                    accessibilityLabel = L10n.petAccessibilityLabelRaised(petItem.pet?.text ?? "", Int(percentage*100))
                } else {
                    accessibilityLabel = L10n.petAccessibilityLabelMountOwned(petItem.pet?.text ?? "")
                }
            } else {
                ImageManager.getImage(name: "stable_Pet-\(key)") {[weak self] (image, _) in
                    DispatchQueue.main.async {
                        if let sprite = image?.withRenderingMode(.alwaysTemplate) {
                            self?.imageView.image = sprite
                            self?.imageView.tintColor = ThemeService.shared.theme.dimmedColor
                        }
                    }
                }
                accessibilityLabel = L10n.Accessibility.unknownPet
            }
        }
        if petItem.trained == -1 {
            imageView.alpha = 0.3
        } else {
            imageView.alpha = 1.0
        }
        progressView.tintColor = ThemeService.shared.theme.successColor
        progressView.trackTintColor = ThemeService.shared.theme.offsetBackgroundColor
        if petItem.pet?.type != " " && petItem.trained > 0 && petItem.canRaise == true {
            progressView.isHidden = false
            progressView.progress = percentage
        } else {
            progressView.isHidden = true
        }
        
        shouldGroupAccessibilityChildren = true
        isAccessibilityElement = true
    }
}
