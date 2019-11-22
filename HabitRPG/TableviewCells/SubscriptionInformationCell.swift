//
//  SubscriptionInformationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class SubscriptionInformationCell: UITableViewCell {

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionTextView: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    var title: String {
        set {
            titleLabel.text = newValue
        }

        get {
            return titleLabel.text ?? ""
        }
    }

    var descriptionText: String {
        set {
            descriptionTextView.text = newValue
            descriptionTextView.textColor = ThemeService.shared.theme.primaryTextColor
        }

        get {
            return descriptionTextView.text ?? ""
        }
    }
    
    var icon: UIImage? {
        set {
            iconView.image = newValue
        }
        
        get {
            return iconView.image
        }
    }
}
