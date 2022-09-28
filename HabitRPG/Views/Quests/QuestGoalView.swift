//
//  QuestGoalView.swift
//  Habitica
//
//  Created by Phillip on 25.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class QuestGoalView: UIView {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var healthIcon: UIImageView!
    @IBOutlet weak var goalDetailLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var difficultyImageView: UIImageView!
    @IBOutlet weak var rageMeterView: PaddedLabel!
    @IBOutlet weak var typeBackgroundView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 154, height: 36))
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            translatesAutoresizingMaskIntoConstraints = false
            
            view.frame = bounds
            addSubview(view)
            
            difficultyLabel.text = L10n.difficulty
            rageMeterView.text = L10n.rageMeter
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            rageMeterView.verticalPadding = 0
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func configure(quest: QuestProtocol) {
        let theme = ThemeService.shared.theme
        bottomView.backgroundColor = theme.windowBackgroundColor
        difficultyLabel.textColor = theme.primaryTextColor
        if let bossHealth = quest.boss?.health, bossHealth > 0 {
            healthIcon.image = HabiticaIcons.imageOfHeartDarkBg
            healthIcon.isHidden = false
            typeLabel.text = L10n.health
            goalDetailLabel.text = "\(bossHealth)"
            rageMeterView.isHidden = (quest.boss?.rage?.value ?? 0) <= 0
            rageMeterView.backgroundColor = theme.dimmedColor
            rageMeterView.textColor = theme.secondaryTextColor
            typeBackgroundView.backgroundColor = theme.errorColor
            difficultyImageView.image = HabiticaIcons.imageOfDifficultyStars(difficulty: CGFloat(quest.boss?.strength ?? 0))
        } else {
            healthIcon.isHidden = true
            typeLabel.text = L10n.collect
            goalDetailLabel.text = ""
            rageMeterView.isHidden = true
            typeBackgroundView.backgroundColor = theme.successColor
            difficultyImageView.image = HabiticaIcons.imageOfDifficultyStars(difficulty: 1)
        }
    }
}
