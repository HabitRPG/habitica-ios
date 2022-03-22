//
//  QuestProgressTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down
import Habitica_Models

class QuestProgressView: UIView {
    
    @IBOutlet weak var questImageView: NetworkImageView!
    @IBOutlet weak var healthProgressView: QuestProgressBarView!
    @IBOutlet weak var rageProgressView: QuestProgressBarView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var descriptionSeparator: UIView!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var descriptionTitleView: UIView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet weak var carretIconView: UIImageView!
    @IBOutlet weak var descriptionTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionTitleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bossArtTitle: UIView!
    @IBOutlet weak var bossArtTitleLabel: PaddedLabel!
    @IBOutlet weak var bossArtCreditLabel: UILabel!
    @IBOutlet weak var bossArtTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bossArtCarret: UIImageView!
    @IBOutlet weak var questArtSeparator: UIView!
    
    @IBOutlet weak var rageStrikeCountLabel: UILabel!
    @IBOutlet weak var rageStrikeCountLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var rageStrikeContainer: UIStackView!
    @IBOutlet weak var rageStrikeContainerHeight: NSLayoutConstraint!
    
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
                UIView.AutoresizingMask.flexibleWidth,
                UIView.AutoresizingMask.flexibleHeight
            ]
            addSubview(view)
            
            bossArtTitleHeightConstraint.constant = 46
            bossArtTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bossArtTitleTapped)))
            bossArtCarret.image = #imageLiteral(resourceName: "carret_down").withRenderingMode(.alwaysTemplate)
            
            healthProgressView.barColor = UIColor.red50
            healthProgressView.icon = HabiticaIcons.imageOfHeartLightBg
            healthProgressView.pendingBarColor = UIColor.red10.withAlphaComponent(0.3)
            healthProgressView.pendingTitle = L10n.pendingDamage
            rageProgressView.barColor = UIColor.orange100
            rageProgressView.icon = #imageLiteral(resourceName: "icon_rage")
            rageStrikeCountLabelHeight.constant = 30
            rageStrikeContainerHeight.constant = 84
            rageStrikeCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rageStrikeButtonTapped)))
            
            contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            contentStackView.isLayoutMarginsRelativeArrangement = true
            
            descriptionTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descriptionTitleTapped)))
            descriptionTitleHeightConstraint.constant = 47
            descriptionTitleTopConstraint.constant = 8
            descriptionTextView.contentInset = UIEdgeInsets.zero
            carretIconView.tintColor = .white
            carretIconView.image = #imageLiteral(resourceName: "carret_down").withRenderingMode(.alwaysTemplate)
            
            bossArtTitleLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 14, ofWeight: .semibold)
            descriptionTitle.font = UIFontMetrics.default.scaledSystemFont(ofSize: 14, ofWeight: .semibold)
            rageStrikeCountLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 14, ofWeight: .semibold)
            bossArtCreditLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12)
            
            let userDefaults = UserDefaults()
            if userDefaults.bool(forKey: "worldBossArtCollapsed") {
                hideBossArt()
            }
            if userDefaults.bool(forKey: "worldBossDescriptionCollapsed") {
                hideDescription()
            }
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    @objc
    func configure(quest: QuestProtocol) {
        healthProgressView.title = quest.boss?.name ?? ""
        healthProgressView.maxValue = Float(quest.boss?.health ?? 0)
        if let bossRage = quest.boss?.rage?.value, bossRage > 0 {
            rageProgressView.maxValue = Float(quest.boss?.rage?.value ?? 0)
            rageProgressView.title = L10n.Quests.rageAttack(quest.boss?.rage?.title ?? "")
        } else {
            rageProgressView.isHidden = true
        }
        questImageView.setImagewith(name: "quest_\(quest.key ?? "")", extension: "gif")
        
        let colorDark = quest.uicolorDark
        let colorMedium = quest.uicolorMedium
        let colorLight = quest.uicolorLight
        let colorExtraLight = quest.uicolorExtraLight
        backgroundView.image = HabiticaIcons.imageOfQuestBackground(bossColorDark: colorDark,
                                                                         bossColorMedium: colorMedium,
                                                                         bossColorLight: colorExtraLight)
            .resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10),
                            resizingMode: UIImage.ResizingMode.stretch)
        
        gradientView.endColor = colorLight
        descriptionSeparator.backgroundColor = colorLight
        questArtSeparator.backgroundColor = colorLight
        let description = try? Down(markdownString: quest.notes?.replacingOccurrences(of: "<br>", with: "\n") ?? "").toHabiticaAttributedString()
        description?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: description?.length ?? 0))
        description?.append(NSAttributedString(string: "\n"))
        descriptionTextView.attributedText = description
        
        bossArtCarret.tintColor = colorExtraLight
        bossArtCreditLabel.textColor = colorExtraLight
        
        for view in rageStrikeContainer.arrangedSubviews {
            if let rageStrikeView = view as? RageStrikeView {
                rageStrikeView.bossName = quest.boss?.name ?? ""
                rageStrikeView.questIdentifier = quest.key ?? ""
            }
        }
        
        descriptionTextView.sizeToFit()
    }
    
    @objc
    func configure(group: GroupProtocol) {
        healthProgressView.currentValue = group.quest?.progress?.health ?? 0
        rageProgressView.currentValue = group.quest?.progress?.rage ?? 0
        
        /*rageStrikeCountLabel.text = "Rage Strikes: \(group.rageStrikeCount)/\(group.totalRageStrikes)"
        
        rageStrikeContainer.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        if let rageStrikes = group.rageStrikes {
            for rageStrike in rageStrikes {
                let rageStrikeView = RageStrikeView()
                rageStrikeView.locationIdentifier = rageStrike.key
                rageStrikeView.isActive = rageStrike.value.boolValue
                rageStrikeContainer.addArrangedSubview(rageStrikeView)
            }
        }*/
    }
    
    @objc
    func configure(user: UserProtocol) {
        healthProgressView.pendingValue = user.party?.quest?.progress?.up ?? 0
    }
    
    @objc
    func descriptionTitleTapped() {
        if descriptionTextView.isHidden {
            showDescription()
        } else {
            hideDescription()
        }
    }
    
    private func showDescription() {
        carretIconView.image = #imageLiteral(resourceName: "carret_down").withRenderingMode(.alwaysTemplate)
        descriptionTextView.isHidden = false
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        
        let userDefaults = UserDefaults()
        userDefaults.set(false, forKey: "worldBossDescriptionCollapsed")
    }
    
    private func hideDescription() {
        carretIconView.image = #imageLiteral(resourceName: "carret_up").withRenderingMode(.alwaysTemplate)
        descriptionTextView.isHidden = true
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        
        let userDefaults = UserDefaults()
        userDefaults.set(true, forKey: "worldBossDescriptionCollapsed")
    }
    
    @objc
    func bossArtTitleTapped() {
        if questImageView.isHidden {
            showBossArt()
        } else {
            hideBossArt()
        }
    }
    
    private func showBossArt() {
        bossArtCarret.image = #imageLiteral(resourceName: "carret_down").withRenderingMode(.alwaysTemplate)
        questImageView.isHidden = false
        gradientView.isHidden = false
        
        let userDefaults = UserDefaults()
        userDefaults.set(false, forKey: "worldBossArtCollapsed")
    }
    
    private func hideBossArt() {
        bossArtCarret.image = #imageLiteral(resourceName: "carret_up").withRenderingMode(.alwaysTemplate)
        questImageView.isHidden = true
        gradientView.isHidden = true
        
        let userDefaults = UserDefaults()
        userDefaults.set(true, forKey: "worldBossArtCollapsed")
    }
    
    @objc
    func rageStrikeButtonTapped() {
        let string = L10n.WorldBoss.rageStrikeExplanation
        let attributedString = NSMutableAttributedString(string: string)
        let firstLineRange = NSRange(location: 0, length: string.components(separatedBy: "\n")[0].count)
        attributedString.addAttribute(.font, value: UIFontMetrics.default.scaledSystemFont(ofSize: 17), range: firstLineRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: firstLineRange)
        attributedString.addAttribute(.font, value: UIFontMetrics.default.scaledSystemFont(ofSize: 15),
                                      range: NSRange.init(location: firstLineRange.length, length: string.count - firstLineRange.length))
        let alertController = HabiticaAlertController.alert(title: L10n.WorldBoss.rageStrikeExplanationButton, attributedMessage: attributedString)
        alertController.addCloseAction()
        alertController.show()
        alertController.titleLabel.textColor = .white
    }
}
