//
//  ChallengeTableViewHeaderView.swift
//  Habitica
//
//  Created by Elliot Schrock on 1/12/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class ChallengeTableViewHeaderView: UITableViewHeaderFooterView, Themeable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func didMoveToWindow() {
        setup()
    }
    
    func setup() {

        countLabel.layer.cornerRadius = 11
        countLabel.clipsToBounds = true

        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        titleLabel.textColor = theme.primaryTextColor
        countLabel.backgroundColor = theme.windowBackgroundColor
        countLabel.textColor = theme.dimmedTextColor
        backgroundView?.backgroundColor = theme.contentBackgroundColor
        backgroundColor = theme.contentBackgroundColor
    }
}
