//
//  QuestGoalView.swift
//  Habitica
//
//  Created by Phillip on 25.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class QuestGoalView: UIView {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var healthIcon: UIImageView!
    @IBOutlet weak var goalDetailLabel: UILabel!
    @IBOutlet weak var difficultyStackView: UIStackView!
    @IBOutlet weak var rageMeterView: PaddedLabel!
    @IBOutlet weak var typeBackgroundView: UIView!

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
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            rageMeterView.verticalPadding = 0
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func configure(quest: Quest) {
        if quest.bossHp.intValue > 0 {
            healthIcon.isHidden = false
            typeLabel.text = NSLocalizedString("Health", comment: "")
            goalDetailLabel.text = "\(quest.bossHp.intValue)"
            rageMeterView.isHidden = quest.bossRage.intValue == 0
            typeBackgroundView.backgroundColor = .red100()
            setQuestDifficulty(quest.bossStr.floatValue)
        } else {
            healthIcon.isHidden = true
            typeLabel.text = NSLocalizedString("Collect", comment: "")
            goalDetailLabel.text = ""
            rageMeterView.isHidden = true
            typeBackgroundView.backgroundColor = .green100()
            setQuestDifficulty(1)
        }
    }
    
    func setQuestDifficulty(_ difficulty: Float) {
        if let difficultyviews = difficultyStackView.arrangedSubviews as? [UIImageView] {
            for (index, subview) in difficultyviews.enumerated() {
                if Float(index) <= difficulty {
                    subview.image = #imageLiteral(resourceName: "difficulty_full")
                } else {
                    if Float(index) <= difficulty+0.5 {
                        subview.image = #imageLiteral(resourceName: "difficulty_half")
                    } else {
                        subview.image = #imageLiteral(resourceName: "difficulty_empty")
                    }
                }
            }
        }
    }
}
