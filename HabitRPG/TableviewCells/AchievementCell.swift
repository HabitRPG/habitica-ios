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
            if isGridLayout {
                titleLabel.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
                titleLabel.textAlignment = .center
                titleLabel.cornerRadius = 6
                backgroundColor = ThemeService.shared.theme.windowBackgroundColor
            } else {
                titleLabel.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
                titleLabel.textAlignment = .natural
                titleLabel.cornerRadius = 0
                backgroundColor = ThemeService.shared.theme.contentBackgroundColor
            }
        }
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 14, ofWeight: .medium)
        if #available(iOS 11.0, *) {
            label.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        }
        return label
    }()
    private var descriptionlabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    private var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionlabel)
        contentView.addSubview(iconView)
        cornerRadius = 6
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            var newFrame = layoutAttributes.frame
            if isGridLayout {
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
        if isGridLayout {
            iconView.pin.start().top().end().height(66)
            titleLabel.pin.start().below(of: iconView).bottom().end()
        } else {
            iconView.pin.start(16).width(48).height(52).vCenter()
            titleLabel.pin.after(of: iconView).marginStart(16).end(16).sizeToFit(.width)
            descriptionlabel.pin.after(of: iconView).marginStart(16).below(of: titleLabel).marginTop(4).end(16).sizeToFit(.width)
            let offset = (frame.size.height - (titleLabel.frame.size.height + descriptionlabel.frame.size.height)) / 2
            titleLabel.pin.top(offset)
            descriptionlabel.pin.below(of: titleLabel)
        }
    }
    
    func heightForWidth(_ width: CGFloat) -> CGFloat {
        if isGridLayout {
            return 106
        } else {
            var height = titleLabel.sizeThatFits(CGSize(width: width - 84, height: 200)).height
            height += descriptionlabel.sizeThatFits(CGSize(width: width - 84, height: 200)).height
            return max(height + 16, 80)
        }
    }
    
    func configure(achievement: AchievementProtocol) {
        titleLabel.text = achievement.title
        if achievement.earned {
            iconView.setImagewith(name: (achievement.icon ?? "") + "2x")
        } else {
            iconView.setImagewith(name: "achievement-unearned2x")
        }
        if !isGridLayout {
            descriptionlabel.text = achievement.text
        }
    }
}
