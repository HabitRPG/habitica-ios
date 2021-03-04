//
//  PublicGuildCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import TagListView

class PublicGuildCell: UITableViewCell {
    
    @IBOutlet weak var contentBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var joinLeaveButton: UIButton!
    @IBOutlet weak var crestIconView: UIImageView!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
    func configure(group: GroupProtocol) {
        titleLabel.text = group.name
        descriptionLabel.text = group.summary
        memberCountLabel.text = String(describing: group.memberCount).stringWithAbbreviatedNumber()
        crestIconView.image = HabiticaIcons.imageOfGuildCrestSmall(memberCount: CGFloat(group.memberCount))
        
        contentBackgroundView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
        descriptionLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        memberCountLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        tagListView.removeAllTags()
        group.categories.forEach { category in
            let view = tagListView.addTag(category.name?.split(separator: "_").map({ word in
                return word.capitalized
            }).joined(separator: " ") ?? "")
            if category.slug == "habitica_official" {
                view.tagBackgroundColor = UIColor.purple400
                view.textColor = UIColor.white
            } else {
                view.tagBackgroundColor = ThemeService.shared.theme.offsetBackgroundColor
                view.textColor = ThemeService.shared.theme.primaryTextColor
            }
        }
    }
    
}
