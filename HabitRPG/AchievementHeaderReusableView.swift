
//
//  AchievementHeaderSupplementView.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class AchievementHeaderReusableView: UICollectionReusableView {
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 12, ofWeight: .medium)
        label.textColor = ThemeService.shared.theme.secondaryTextColor
        return label
    }()
    var earnedCountLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 10, ofWeight: .medium)
        label.textColor = ThemeService.shared.theme.secondaryTextColor
        label.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
        label.textAlignment = .center
        return label
    }()
    
    var onGearCategoryLabelTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(earnedCountLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        earnedCountLabel.pin.end(16).sizeToFit()
        earnedCountLabel.pin.width(earnedCountLabel.frame.size.width + 8).height(earnedCountLabel.frame.size.height + 4)
        earnedCountLabel.pin.vCenter()
        earnedCountLabel.cornerRadius = earnedCountLabel.frame.size.height / 2
        titleLabel.pin.start(16).before(of: earnedCountLabel).top().bottom()
    }
}
