//
//  EmptyTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 5/31/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstParagraphLabel: UILabel!
    @IBOutlet weak var secondParagraphLabel: UILabel!
    
    static func habitsStyle(cell: EmptyTableViewCell) {
        cell.emptyImageView.image = Asset.tabbarHabits.image
        cell.titleLabel.text = L10n.Empty.Habits.title
        cell.firstParagraphLabel.text = L10n.Empty.Habits.description
    }
    
    static func dailiesStyle(cell: EmptyTableViewCell) {
        cell.emptyImageView.image = Asset.tabbarDailies.image
        cell.titleLabel.text = L10n.Empty.Dailies.title
        cell.firstParagraphLabel.text = L10n.Empty.Dailies.description
    }
    
    static func todoStyle(cell: EmptyTableViewCell) {
        cell.emptyImageView.image = Asset.tabbarTodos.image
        cell.titleLabel.text = L10n.Empty.Todos.title
        cell.firstParagraphLabel.text = L10n.Empty.Todos.description
    }
    
    static func rewardsStyle(cell: EmptyTableViewCell) {
        cell.emptyImageView.image = Asset.tabbarRewards.image
        cell.titleLabel.text = L10n.Empty.Rewards.title
        cell.firstParagraphLabel.text = L10n.Empty.Rewards.description
    }
    
    static func notificationsStyle(cell: EmptyTableViewCell) {
        cell.emptyImageView.image = Asset.emptyNotificationsIcon.image
        cell.titleLabel.text = L10n.Empty.Notifications.title
        cell.firstParagraphLabel.text = L10n.Empty.Notifications.description
        cell.titleLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        cell.firstParagraphLabel.textColor = ThemeService.shared.theme.secondaryTextColor
    }
}
