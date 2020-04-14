//
//  EmptyTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 5/31/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell, Themeable {
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstParagraphLabel: UILabel!
    @IBOutlet weak var secondParagraphLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        backgroundColor = theme.windowBackgroundColor
        titleLabel.textColor = theme.ternaryTextColor
        firstParagraphLabel.textColor = theme.ternaryTextColor
        secondParagraphLabel.textColor = theme.ternaryTextColor
    }
    
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
    
    static func inboxChatStyle(cell: EmptyTableViewCell) {
        cell.firstParagraphLabel.text = L10n.Empty.Inbox.description
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    static func inboxChatStyleUsername(displayName: String, contributorTier: Int?, username: String) -> (EmptyTableViewCell) -> Void {
        return { cell in
            cell.secondParagraphLabel.text = displayName
            cell.secondParagraphLabel.textColor = UIColor.contributorColor(forTier: contributorTier ?? 0)
            cell.secondParagraphLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 16)
            cell.firstParagraphLabel.text = "@\(username)"
            cell.firstParagraphLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
            cell.titleLabel.text = L10n.Empty.Inbox.description
            cell.titleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 14)
            cell.titleLabel.numberOfLines = 0
            cell.secondParagraphLabel.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.firstParagraphLabel.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.titleLabel.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            cell.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        }
    }
}
