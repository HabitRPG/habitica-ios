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
    var isGridLayout = false {
        didSet {
            if isGridLayout {
                titleLabel.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
            } else {
                titleLabel.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
            }
        }
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 14)
        return label
    }()
    private var iconView: UIImageView =  UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(titleLabel)
        addSubview(iconView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        titleLabel.pin.all()
    }
    
    func configure(achievement: AchievementProtocol) {
        titleLabel.text = achievement.title
    }
}
