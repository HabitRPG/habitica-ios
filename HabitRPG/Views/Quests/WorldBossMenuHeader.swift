//
//  WorldBossMenuHeader.swift
//  Habitica
//
//  Created by Phillip Thelen on 26.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class WorldBossMenuHeader: UIView {
    
    @IBOutlet weak var bossImageView: UIImageView!
    @IBOutlet weak var bossNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var hearthIconView: UIImageView!
    @IBOutlet weak var healthProgressBar: ProgressBar!
    @IBOutlet weak var statBarView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hearthIconView.image = HabiticaIcons.imageOfHeartDarkBg
        healthProgressBar.barColor = UIColor.red50()
        healthProgressBar.barBackgroundColor = UIColor(white: 1.0, alpha: 0.16)
    }
    
    @objc
    func configure(quest: Quest) {
        HRPGManager.shared().setImage("quest_\(quest.key ?? "")", withFormat: "png", on: bossImageView)
        bossImageView.backgroundColor = quest.uicolorMedium
        bossNameLabel.text = quest.bossName
        healthProgressBar.maxValue = CGFloat(quest.bossHp?.floatValue ?? 0)
        typeLabel.text = "World Boss"
        statBarView.backgroundColor = quest.uicolorDark
    }
    
    @objc
    func configure(group: Group) {
        healthProgressBar.value = CGFloat(group.questHP.floatValue)
    }
}
