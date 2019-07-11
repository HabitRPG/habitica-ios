//
//  ChallengeTableViewHeaderView.swift
//  Habitica
//
//  Created by Elliot Schrock on 1/12/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class ChallengeTableViewHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func didMoveToWindow() {
        setup()
    }
    
    func setup() {
        let theme = ThemeService.shared.theme
        titleLabel.textColor = theme.primaryTextColor

        countLabel.layer.cornerRadius = 11
        countLabel.backgroundColor = theme.contentBackgroundColor
        countLabel.textColor = theme.dimmedTextColor
        countLabel.clipsToBounds = true

        backgroundView?.backgroundColor = ThemeService.shared.theme.windowBackgroundColor

    }
}
