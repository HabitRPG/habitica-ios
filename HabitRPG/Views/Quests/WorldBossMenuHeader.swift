//
//  WorldBossMenuHeader.swift
//  Habitica
//
//  Created by Phillip Thelen on 26.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class WorldBossMenuHeader: UIView {
    
    @IBOutlet weak var bossImageView: UIImageView!
    @IBOutlet weak var bossNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var hearthIconView: UIImageView!
    @IBOutlet weak var healthProgressBar: ProgressBar!
    @IBOutlet weak var statBarView: UIView!
    @IBOutlet weak var collapseButton: UIButton!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var pendingDamageIcon: UIImageView!
    @IBOutlet weak var pendingDamageLabel: UILabel!
    
    var formatter = NumberFormatter()
    
    private var quest: QuestProtocol?
    
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
        isCollapsed = userDefaults.bool(forKey: "worldBossArtCollapsed")
        
        topStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bossArtTapped)))
        pendingDamageIcon.image = HabiticaIcons.imageOfDamage
        
        formatter.maximumFractionDigits = 1
    }
    
    @objc
    func configure(quest: QuestProtocol) {
        self.quest = quest
        if !isCollapsed {
            bossImageView.setImagewith(name: "quest_\(quest.key ?? "")")
        }
        bossImageView.backgroundColor = quest.uicolorMedium
        bossNameLabel.text = quest.boss?.name
        healthProgressBar.maxValue = CGFloat(quest.boss?.health ?? 0)
        typeLabel.text = "World Boss"
        statBarView.backgroundColor = quest.uicolorDark
        configureAccessibility()
    }
    
    @objc
    func configure(group: GroupProtocol) {
        healthProgressBar.value = CGFloat(group.quest?.progress?.health ?? 0)

        let userDefaults = UserDefaults()
        isCollapsed = userDefaults.bool(forKey: "worldBossArtCollapsed")
        
        configureAccessibility()
    }
    
    @objc
    func configure(user: UserProtocol) {
        if (user.party?.quest?.progress?.up ?? 0) > 0 {
            pendingDamageLabel.text = "+\(formatter.string(from: NSNumber(value: user.party?.quest?.progress?.up ?? 0)) ?? "0")"
        } else {
            pendingDamageLabel.text = "+0"
        }
        configureAccessibility()
    }
    
    private func configureAccessibility() {
        isAccessibilityElement = true
        shouldGroupAccessibilityChildren = true
        collapseButton.isAccessibilityElement = false
        accessibilityHint = NSLocalizedString("Double tap to hide boss art", comment: "")
        accessibilityLabel = "\(quest?.boss?.name ?? ""), World Boss, pending damage: \(pendingDamageLabel.text ?? "")"
    }

    @IBAction func collapseButtonTapped(_ sender: Any) {
        isCollapsed = true
    }
    
    @objc
    func showBossArt() {
        topStackView.axis = .vertical
        topStackView.alignment = .trailing
        bossImageView.setImagewith(name: "quest_\(quest?.key ?? "")")
        collapseButton.isHidden = false
        bossNameLabel.textAlignment = .right
        typeLabel.textColor = .white
        
        let userDefaults = UserDefaults()
        userDefaults.set(false, forKey: "worldBossArtCollapsed")
    }
    
    @objc
    func hideBossArt() {
        topStackView.axis = .horizontal
        topStackView.alignment = .fill
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
    
    @objc
    func bossArtTapped() {
        guard let quest = self.quest else {
            return
        }
        let alertController = HabiticaAlertController.alert(title: NSLocalizedString("What’s a World Boss?", comment: ""))
        let view = Bundle.main.loadNibNamed("WorldBossDescription", owner: nil, options: nil)?.last as? WorldBossDescriptionView
        view?.bossName = quest.boss?.name
        view?.questColorLight = quest.uicolorLight
        view?.questColorExtraLight = quest.uicolorExtraLight
        alertController.contentView = view
        alertController.titleBackgroundColor = quest.uicolorLight
        alertController.addCloseAction()
        alertController.show()
        alertController.titleLabel.textColor = .white
    }
}
