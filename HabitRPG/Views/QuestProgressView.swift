//
//  QuestProgressTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class QuestProgressView: UIView {
    
    @IBOutlet weak var questImageView: UIImageView!
    @IBOutlet weak var healthProgressView: QuestProgressBarView!
    @IBOutlet weak var rageProgressView: QuestProgressBarView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var gradientView: GradientView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            translatesAutoresizingMaskIntoConstraints = true
            
            view.frame = bounds
            view.autoresizingMask = [
                UIViewAutoresizing.flexibleWidth,
                UIViewAutoresizing.flexibleHeight
            ]
            addSubview(view)
            
            healthProgressView.barColor = UIColor.red50()
            healthProgressView.icon = HabiticaIcons.imageOfHeartLightBg
            rageProgressView.barColor = UIColor.yellow50()
            rageProgressView.icon = #imageLiteral(resourceName: "icon_rage")
            
            contentStackView.layoutMargins = UIEdgeInsets(top: 16, left: 12, bottom: 12, right: 12)
            contentStackView.isLayoutMarginsRelativeArrangement = true
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    @objc
    func configure(quest: Quest) {
        healthProgressView.title = quest.bossName ?? ""
        healthProgressView.maxValue = quest.bossHp?.floatValue ?? 0
        if let bossRage = quest.bossRage?.floatValue, bossRage > 0 {
            rageProgressView.maxValue = quest.bossRage?.floatValue ?? 0
            rageProgressView.title = NSLocalizedString("Rage attack: \(quest.rageTitle ?? "")", comment: "")
        } else {
            rageProgressView.isHidden = true
        }
        HRPGManager.shared().setImage("quest_" + quest.key, withFormat: "png", on: questImageView)
        
        let colorDark = UIColor.init(quest.colorDark ?? "", defaultColor: UIColor.clear)
        let colorMedium = UIColor.init(quest.colorMedium ?? "", defaultColor: UIColor.clear)
        let colorLight = UIColor.init(quest.colorLight ?? "", defaultColor: UIColor.clear)
        let colorExtraLight = UIColor.init(quest.colorExtraLight ?? "", defaultColor: UIColor.clear)
        self.backgroundView.image = HabiticaIcons.imageOfQuestBackground(bossColorDark: colorDark, bossColorMedium: colorMedium, bossColorLight: colorExtraLight).resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10), resizingMode: UIImageResizingMode.stretch)
        
        gradientView.endColor = colorLight
    }
    
    @objc
    func configure(group: Group) {
        healthProgressView.currentValue = group.questHP.floatValue
        rageProgressView.currentValue = group.questRage.floatValue
    }
}
