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
    @IBOutlet weak var collapseButton: UIButton!
    @IBOutlet weak var topStackView: UIStackView!
    
    private var quest: Quest?
    
    var isCollapsed: Bool = false {
        didSet {
            if isCollapsed {
                hideBossArt()
            } else {
                showBossArt()
            }
            superview?.setNeedsLayout()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hearthIconView.image = HabiticaIcons.imageOfHeartDarkBg
        healthProgressBar.barColor = UIColor.red50()
        healthProgressBar.barBackgroundColor = UIColor(white: 1.0, alpha: 0.16)
        
        let userDefaults = UserDefaults()
        if userDefaults.bool(forKey: "worldBossArtCollapsed") {
            hideBossArt()
        }
    }
    
    @objc
    func configure(quest: Quest) {
        self.quest = quest
        if !isCollapsed {
            HRPGManager.shared().setImage("quest_\(quest.key ?? "")", withFormat: "png", on: bossImageView)
        }
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

    @IBAction func collapseButtonTapped(_ sender: Any) {
        isCollapsed = true
    }
    
    @objc
    func showBossArt() {
        topStackView.axis = .vertical
        HRPGManager.shared().setImage("quest_\(quest?.key ?? "")", withFormat: "png", on: bossImageView)
        collapseButton.isHidden = false
        bossNameLabel.textAlignment = .right
        typeLabel.textColor = .white
        
        let userDefaults = UserDefaults()
        userDefaults.set(false, forKey: "worldBossArtCollapsed")
    }
    
    @objc
    func hideBossArt() {
        topStackView.axis = .horizontal
        bossImageView.image = nil
        collapseButton.isHidden = true
        bossNameLabel.textAlignment = .left
        typeLabel.textColor = UIColor.red100()
        
        let userDefaults = UserDefaults()
        userDefaults.set(true, forKey: "worldBossArtCollapsed")
    }
    
    override var intrinsicContentSize: CGSize {
        if isCollapsed {
            return CGSize(width: frame.width, height: 70)
        } else {
            return CGSize(width: frame.width, height: 99)
        }
    }
}
