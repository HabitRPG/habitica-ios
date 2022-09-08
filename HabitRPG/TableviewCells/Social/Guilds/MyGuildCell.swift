//
//  MyGuildCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class MyGuildCell: UITableViewCell {
    
    @IBOutlet weak var contentBackgroundView: UIView!
    @IBOutlet weak var crestImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastActivityLabel: UILabel!
    @IBOutlet weak var labelSpacing: NSLayoutConstraint!
    
    func configure(group: GroupProtocol) {
        titleLabel.text = group.name
        lastActivityLabel.text = nil
        labelSpacing.constant = 0
        var countText = String(describing: group.memberCount).stringWithAbbreviatedNumber(maximumFractionDigits: 1)
        if group.memberCount > 10000 {
            countText = String(describing: group.memberCount).stringWithAbbreviatedNumber(maximumFractionDigits: 0)
        }
        crestImageView.image = HabiticaIcons.imageOfGuildCrest(isOwner: false,
                                                               isPublic: group.privacy == "public",
                                                               memberCount: CGFloat(group.memberCount),
                                                               memberCountLabel: countText)
        
        titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
        titleLabel.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        contentBackgroundView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
    }
}
