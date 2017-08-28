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
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func configure(quest: Quest) {
        if quest.bossHp?.intValue ?? 0 > 0 {
            questTypeLabel.text = NSLocalizedString("Boss Quest", comment: "")
        } else {
            questTypeLabel.text = NSLocalizedString("Collection Quest", comment: "")
        }
        questGoalView.configure(quest: quest)
        
        if let experience = quest.dropExp?.intValue, experience > 0 {
            rewardsStackView.addArrangedSubview(makeRewardView(title: NSLocalizedString("\(experience) Experience Points", comment: ""), image: HabiticaIcons.imageOfExperienceReward))
        }
        if let gold = quest.dropGp?.intValue, gold > 0 {
            rewardsStackView.addArrangedSubview(makeRewardView(title: NSLocalizedString("\(gold) Gold", comment: ""), image: HabiticaIcons.imageOfGoldReward))
        }
        
        var hasOwnerRewards = false
        if let items = quest.itemDrops {
            for reward in items {
                let view = makeRewardView(title: reward.text, imageName: reward.getImageName())
                if reward.onlyOwner?.boolValue ?? false {
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
                HRPGManager.shared().setImage(imageName, withFormat: "png", on: imageView)
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
