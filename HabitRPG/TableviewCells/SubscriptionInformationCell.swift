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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
        
        descriptionTextView.font = CustomFontMetrics.scaledSystemFont(ofSize: 13)
        descriptionTextView.textColor = ThemeService.shared.theme.secondaryTextColor
    }
    
    var title: String {
        get {
            return titleLabel.text ?? ""
        }
        set {
            titleLabel.text = newValue
        }
    }

    var descriptionText: String {
        get {
            return descriptionTextView.text ?? ""
        }
        set {
            descriptionTextView.text = newValue
            descriptionTextView.textColor = ThemeService.shared.theme.primaryTextColor
        }
    }
    
    var icon: UIImage? {
        get {
            return iconView.image
        }
        set {
            iconView.image = newValue
        }
    }
}
