//
//  QuestMenuHeader.swift
//  Habitica
//
//  Created by Phillip Thelen on 26.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class QuestMenuHeader: UIView {
    
    @IBOutlet weak var bossImageView: NetworkImageView!
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
    var isWorldBoss = false
    
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
        healthProgressBar.barColor = UIColor.red50
        healthProgressBar.stackedBarColor = UIColor.yellow50
        healthProgressBar.barBackgroundColor = UIColor(white: 1.0, alpha: 0.16)
                
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
        typeLabel.text = "Active Quest"
        statBarView.backgroundColor = quest.uicolorDark
        configureAccessibility()
    }
    
    @objc
    func configure(group: GroupProtocol) {
        healthProgressBar.value = CGFloat(group.quest?.progress?.health ?? 0)
        configureAccessibility()
    }
    
    @objc
    func configure(user: UserProtocol) {
        let pendingDamage: Float = user.party?.quest?.progress?.up ?? 0.0
        if pendingDamage > 0 {
            pendingDamageLabel.text = "+\(formatter.string(from: NSNumber(value: pendingDamage)) ?? "0")"
        } else {
            pendingDamageLabel.text = "+0"
        }
        healthProgressBar.stackedValue = CGFloat(pendingDamage)
        configureAccessibility()
    }
    
    private func configureAccessibility() {
        isAccessibilityElement = true
        shouldGroupAccessibilityChildren = true
        collapseButton.isAccessibilityElement = false
        accessibilityHint = L10n.Accessibility.tapHideBossArt
        accessibilityLabel = L10n.Accessibility.worldBossPendingDamage(quest?.boss?.name ?? "", pendingDamageLabel.text ?? "")
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
        userDefaults.set(false, forKey: "questMenuArtCollapsed")
    }
    
    @objc
    func hideBossArt() {
        topStackView.axis = .horizontal
        topStackView.alignment = .fill
        bossImageView.image = nil
        collapseButton.isHidden = true
        bossNameLabel.textAlignment = .left
        typeLabel.textColor = UIColor.red100
        
        let userDefaults = UserDefaults()
        userDefaults.set(true, forKey: "questMenuArtCollapsed")
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
        guard let quest = quest else {
            return
        }
        
        if !isWorldBoss {
            RouterHandler.shared.handle(urlString: "/party")
            return
        }
        
        let alertController = HabiticaAlertController.alert(title: L10n.whatsWorldBoss)
        let view = Bundle.main.loadNibNamed("questMenuArtCollapsed", owner: nil, options: nil)?.last as? WorldBossDescriptionView
        view?.bossName = quest.boss?.name
        view?.questColorLight = quest.uicolorLight
        view?.questColorExtraLight = quest.uicolorExtraLight
        alertController.contentView = view
        alertController.addCloseAction()
        alertController.show()
        alertController.titleLabel.textColor = .white
    }
}
