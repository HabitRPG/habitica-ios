//
//  QuestDetailView.swift
//  Habitica
//
//  Created by Phillip on 25.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class QuestDetailView: UIView {
    @IBOutlet weak var questTypeLabel: UILabel!
    @IBOutlet weak var rewardsStackView: UIStackView!
    @IBOutlet weak var ownerRewardsLabel: UILabel!
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
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            
            let theme = ThemeService.shared.theme
            view.backgroundColor = theme.contentBackgroundColor
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func configure(quest: QuestProtocol) {
        if quest.boss?.health ?? 0 > 0 {
            questTypeLabel.text = L10n.Quests.bossBattle
        } else {
            questTypeLabel.text = L10n.Quests.collectionQuest
        }
        questGoalView.configure(quest: quest)
        
        if let experience = quest.drop?.experience, experience > 0 {
            rewardsStackView.addArrangedSubview(makeRewardView(title: L10n.Quests.rewardExperience(experience), image: HabiticaIcons.imageOfExperienceReward))
        }
        if let gold = quest.drop?.gold, gold > 0 {
            rewardsStackView.addArrangedSubview(makeRewardView(title: L10n.Quests.rewardGold(gold), image: HabiticaIcons.imageOfGoldReward))
        }
        
        var hasOwnerRewards = false
        if let items = quest.drop?.items {
            for reward in items {
                let view = makeRewardView(title: reward.text, imageName: reward.imageName)
                if reward.onlyOwner {
                    ownerRewardsStackView.addArrangedSubview(view)
                    hasOwnerRewards = true
                } else {
                    rewardsStackView.addArrangedSubview(view)
                }
            }
        }
        if !hasOwnerRewards {
            ownerRewardsLabel.isHidden = true
        }
    }
    
    func makeRewardView(title: String?, imageName: String) -> UIView {
        if let view = UIView.fromNib(nibName: "QuestDetailRewardView") {
            if let imageView = view.viewWithTag(1) as? UIImageView {
                imageView.setImagewith(name: imageName)
            }
            if let label = view.viewWithTag(2) as? UILabel {
                label.text = title
            }
            return view
        }
        return UIView()
    }
    
    func makeRewardView(title: String?, image: UIImage) -> UIView {
        if let view = UIView.fromNib(nibName: "QuestDetailRewardView") {
            if let imageView = view.viewWithTag(1) as? UIImageView {
                imageView.image = image
            }
            if let label = view.viewWithTag(2) as? UILabel {
                label.text = title
            }
            return view
        }
        return UIView()
    }
}
