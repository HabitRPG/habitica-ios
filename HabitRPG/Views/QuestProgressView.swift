//
//  QuestProgressTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down
import YYImage

class QuestProgressView: UIView {
    
    @IBOutlet weak var questImageView: YYAnimatedImageView!
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
                UIViewAutoresizing.flexibleWidth,
                UIViewAutoresizing.flexibleHeight
            ]
            addSubview(view)
            
            bossArtTitleHeightConstraint.constant = 46
            bossArtTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bossArtTitleTapped)))
            bossArtCarret.image = #imageLiteral(resourceName: "carret_down").withRenderingMode(.alwaysTemplate)
            
            healthProgressView.barColor = UIColor.red50()
            healthProgressView.icon = HabiticaIcons.imageOfHeartLightBg
            rageProgressView.barColor = UIColor.orange100()
            rageProgressView.icon = #imageLiteral(resourceName: "icon_rage")
            rageStrikeCountLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 14, ofWeight: .semibold)
            rageStrikeCountLabelHeight.constant = 30
            rageStrikeContainerHeight.constant = 84
            rageStrikeCountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rageStrikeButtonTapped)))
            
            contentStackView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 12)
            contentStackView.isLayoutMarginsRelativeArrangement = true
            
            descriptionTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(descriptionTitleTapped)))
            descriptionTitleHeightConstraint.constant = 47
            descriptionTitleTopConstraint.constant = 8
            descriptionTextView.contentInset = UIEdgeInsets.zero
            carretIconView.tintColor = .white
            carretIconView.image = #imageLiteral(resourceName: "carret_down").withRenderingMode(.alwaysTemplate)
            
            hideDescription()
            
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
        HRPGManager.shared().setImage("quest_" + quest.key, withFormat: "gif", on: questImageView)
        
        let colorDark = UIColor.init(quest.colorDark ?? "", defaultColor: UIColor.clear)
        let colorMedium = UIColor.init(quest.colorMedium ?? "", defaultColor: UIColor.clear)
        let colorLight = UIColor.init(quest.colorLight ?? "", defaultColor: UIColor.clear)
        let colorExtraLight = UIColor.init(quest.colorExtraLight ?? "", defaultColor: UIColor.clear)
        self.backgroundView.image = HabiticaIcons.imageOfQuestBackground(bossColorDark: colorDark,
                                                                         bossColorMedium: colorMedium,
                                                                         bossColorLight: colorExtraLight)
            .resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10),
                            resizingMode: UIImageResizingMode.stretch)
        
        gradientView.endColor = colorLight
        descriptionSeparator.backgroundColor = colorLight
        questArtSeparator.backgroundColor = colorLight
        descriptionTextView.attributedText = try? Down(markdownString: quest.notes).toHabiticaAttributedString()
        
        bossArtCarret.tintColor = colorExtraLight
    }
    
    @objc
    func configure(group: Group) {
        healthProgressView.currentValue = group.questHP.floatValue
        rageProgressView.currentValue = group.questRage.floatValue
        
        rageStrikeCountLabel.text = "Rage Strikes: \(group.rageStrikeCount)/\(group.totalRageStrikes)"
        
        rageStrikeContainer.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        for rageStrike in group.rageStrikes {
            let rageStrikeView = RageStrikeView()
            rageStrikeView.isActive = rageStrike.value.boolValue
            rageStrikeContainer.addArrangedSubview(rageStrikeView)
        }
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
    }
    
    private func hideDescription() {
        carretIconView.image = #imageLiteral(resourceName: "carret_up").withRenderingMode(.alwaysTemplate)
        descriptionTextView.isHidden = true
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
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
    }
    
    private func hideBossArt() {
        bossArtCarret.image = #imageLiteral(resourceName: "carret_up").withRenderingMode(.alwaysTemplate)
        questImageView.isHidden = true
        gradientView.isHidden = true
    }
    
    @objc
    func rageStrikeButtonTapped() {
        let alertController = HabiticaAlertController.alert(title: NSLocalizedString("What's a Rage Strike?", comment: ""), message: NSLocalizedString("", comment: ""))
        alertController.titleBackgroundColor = UIColor.orange50()
        alertController.addCloseAction()
        alertController.show()
        alertController.titleLabel.textColor = .white
    }
}
