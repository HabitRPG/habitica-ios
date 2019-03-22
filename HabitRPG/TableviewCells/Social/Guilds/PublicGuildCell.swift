//
//  PublicGuildCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class PublicGuildCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var joinLeaveButton: UIButton!
    @IBOutlet weak var crestIconView: UIImageView!
    @IBOutlet weak var memberCountLabel: UILabel!
    
    func configure(group: GroupProtocol) {
        titleLabel.text = group.name
        descriptionLabel.text = group.summary
        memberCountLabel.text = String(describing: group.memberCount).stringWithAbbreviatedNumber()
        crestIconView.image = HabiticaIcons.imageOfGuildCrestSmall(memberCount: CGFloat(group.memberCount))
        
        descriptionLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        memberCountLabel.textColor = ThemeService.shared.theme.secondaryTextColor
    }
    
}
