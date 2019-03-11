//
//  MyGuildCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import DateTools

class MyGuildCell: UITableViewCell {
    
    @IBOutlet weak var crestImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastActivityLabel: UILabel!
    @IBOutlet weak var labelSpacing: NSLayoutConstraint!
    
    func configure(group: GroupProtocol) {
        titleLabel.text = group.name
        /*if let lastActivity = (group.chat.first?.timestamp as NSDate?)?.timeAgoSinceNow() {
            lastActivityLabel.text = L10n.lastActivity(lastActivity)
            labelSpacing.constant = 4
        } else {*/
            lastActivityLabel.text = nil
            labelSpacing.constant = 0
        //}
        crestImageView.image = HabiticaIcons.imageOfGuildCrest(isOwner: false,
                                                               isPublic: group.privacy == "public",
                                                               memberCount: CGFloat(group.memberCount),
                                                               memberCountLabel: String(describing: group.memberCount).stringWithAbbreviatedNumber(roundingIncrement: 0.1))
        
        titleLabel.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
    }
}
