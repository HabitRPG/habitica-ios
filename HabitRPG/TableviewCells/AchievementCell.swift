//
//  AchievementCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class AchievementCell: UICollectionViewCell {
    var isHeightCalculated: Bool = false
    
    var isGridLayout = false {
        didSet {
            if isGridLayout && isRegularAchievement {
                titleLabel.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
                titleLabel.textAlignment = .center
                titleLabel.numberOfLines = 3
                descriptionlabel.isHidden = true
                contentBackgroundView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
                contentBackgroundView.isHidden = false
            } else {
                titleLabel.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
                titleLabel.textAlignment = .natural
                titleLabel.numberOfLines = 3
                descriptionlabel.isHidden = false
                contentBackgroundView.isHidden = true
            }
        }
    }
    
    private var contentBackgroundView: UIView = UIView()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 14, ofWeight: .medium)
        label.cornerRadius = 6
        label.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return label
    }()
    private var descriptionlabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    private var iconView: NetworkImageView = {
        let view = NetworkImageView()
        view.contentMode = .center
        return view
    }()
    
    private var countBadge = BadgeView()
    
    private var isRegularAchievement: Bool = false {
        didSet {
            if isRegularAchievement {
                countBadge.font = CustomFontMetrics.scaledSystemFont(ofSize: 13)
            } else {
                countBadge.font = CustomFontMetrics.scaledSystemFont(ofSize: 14, ofWeight: .medium)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        contentView.addSubview(contentBackgroundView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionlabel)
        contentView.addSubview(iconView)
        contentView.addSubview(countBadge)
        cornerRadius = 6
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            var newFrame = layoutAttributes.frame
            if isGridLayout && isRegularAchievement {
                newFrame.size.width = 156
                newFrame.size.height = 106
            } else {
                let totalWidth = superview?.frame.size.width ?? 100
                newFrame.size.width = totalWidth
                frame.size.width = totalWidth
                newFrame.size.height = heightForWidth(totalWidth)
            }
            layoutAttributes.frame = newFrame
        return layoutAttributes
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        if isGridLayout && isRegularAchievement {
            iconView.pin.start(4).top(4).end(4).height(66)
            titleLabel.pin.start(4).below(of: iconView).bottom().end(4)
            countBadge.pin.start().top().sizeToFit()
            contentBackgroundView.pin.top(to: iconView.edge.top).start(4).end(4).bottom(to: titleLabel.edge.bottom)
        } else {
            iconView.pin.start(16).width(48).height(52).vCenter()
            countBadge.pin.start(12).top(to: iconView.edge.top).marginTop(-4).sizeToFit()
            titleLabel.pin.after(of: iconView).marginStart(16).end(16).sizeToFit(.width)
            descriptionlabel.pin.after(of: iconView).marginStart(16).below(of: titleLabel).marginTop(4).end(16).sizeToFit(.width)
            let offset = (frame.size.height - (titleLabel.frame.size.height + descriptionlabel.frame.size.height)) / 2
            titleLabel.pin.top(offset)
            descriptionlabel.pin.below(of: titleLabel)
        }
        if !isRegularAchievement {
            countBadge.pin.size(40).start(20).vCenter()
        }
    }
    
    func heightForWidth(_ width: CGFloat) -> CGFloat {
        if isGridLayout && isRegularAchievement {
            return 106
        } else {
            var height = titleLabel.sizeThatFits(CGSize(width: width - 84, height: 200)).height
            height += descriptionlabel.sizeThatFits(CGSize(width: width - 84, height: 200)).height
            if !isRegularAchievement {
                return max(height + 16, 60)
            } else {
                return max(height + 16, 80)
            }
        }
    }
    
    func configure(achievement: AchievementProtocol) {
        titleLabel.text = achievement.title
        titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
        descriptionlabel.text = achievement.text
        descriptionlabel.textColor = ThemeService.shared.theme.secondaryTextColor
        if !achievement.isQuestAchievement {
            if achievement.isChallengeAchievement {
                iconView.image = Asset.wonChallengeIcon.image
            } else if achievement.earned {
                iconView.setImagewith(name: (achievement.icon ?? "") + "2x")
            } else {
                iconView.setImagewith(name: "achievement-unearned2x")
            }
            iconView.isHidden = false
            countBadge.backgroundColor = ThemeService.shared.theme.secondaryBadgeColor
            countBadge.textColor = ThemeService.shared.theme.lightTextColor
        } else {
            iconView.isHidden = true
            countBadge.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            countBadge.textColor = ThemeService.shared.theme.secondaryTextColor
        }
        if achievement.optionalCount > 0 {
            countBadge.number = achievement.optionalCount
            countBadge.isHidden = false
        } else {
            countBadge.isHidden = true
        }
        
        isRegularAchievement = !achievement.isQuestAchievement && !achievement.isChallengeAchievement
        
        setNeedsLayout()
    }
    
    func configure(achievement: AchievementProtocol, quest: QuestProtocol) {
        configure(achievement: achievement)
        titleLabel.text = quest.text
    }
}
