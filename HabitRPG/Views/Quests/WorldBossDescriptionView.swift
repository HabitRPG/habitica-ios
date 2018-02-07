//
//  WorldBossDescriptionView.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class WorldBossDescriptionView: UIView {
    
    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet weak var firstBullet: UIView!
    @IBOutlet weak var secondBullet: UIView!
    @IBOutlet weak var thirdBullet: UIView!
    @IBOutlet weak var fourthBullet: UIView!
    @IBOutlet weak var actionPromptLabel: PaddedLabel!
    
    var title: String? {
        get {
            return titleView.text
        }
        set {
            titleView.text = newValue
        }
    }
    
    var bossName: String? {
        didSet {
            title = "The \(bossName ?? "") attacks!"
            actionPromptLabel.text = NSLocalizedString("Defeat the Boss to earn special rewards and save Habitica from The \(bossName ?? "") Terror!", comment: "")
            actionPromptLabel.horizontalPadding = 16
        }
    }
    
    var questColorLight: UIColor? {
        didSet {
            actionPromptLabel.textColor = questColorLight
        }
    }
    
    var questColorExtraLight: UIColor? {
        didSet {
            actionPromptLabel.layer.borderColor = questColorExtraLight?.cgColor
            
            firstBullet.viewWithTag(1)?.backgroundColor = questColorExtraLight
            secondBullet.viewWithTag(1)?.backgroundColor = questColorExtraLight
            thirdBullet.viewWithTag(1)?.backgroundColor = questColorExtraLight
            fourthBullet.viewWithTag(1)?.backgroundColor = questColorExtraLight
        }
    }
    
    override func awakeFromNib() {
        actionPromptLabel.horizontalPadding = 16
        actionPromptLabel.verticalPadding = 12
        actionPromptLabel.layer.borderWidth = 1
        
        super.awakeFromNib()
    }
}
