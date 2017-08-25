//
//  QuestDetailView.swift
//  Habitica
//
//  Created by Phillip on 25.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class QuestDetailView: UIView {
    @IBOutlet weak var questTypeLabel: UILabel!
    @IBOutlet weak var rewardsStackView: UIStackView!
    @IBOutlet weak var ownerRewardsStackView: UIStackView!
    @IBOutlet weak var questGoalView: QuestGoalView!
    
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
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func configure(quest: Quest) {
        if quest.bossHp.intValue > 0 {
            questTypeLabel.text = NSLocalizedString("Boss Quest", comment: "")
        } else {
            questTypeLabel.text = NSLocalizedString("Collection Quest", comment: "")
        }
        questGoalView.configure(quest: quest)
    }
}
