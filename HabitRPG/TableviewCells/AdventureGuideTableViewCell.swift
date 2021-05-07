//
//  AdventureGuideTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 04.05.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import UIKit
import PinLayout

class AdventureGuideTableViewCell: UITableViewCell, Themeable {
    
    var completedCount: Int = 0 {
        didSet {
            updateView()
        }
    }
    
    var totalCount: Int = 0 {
        didSet {
            updateView()
        }
    }
    
    private let gradientView: GradientView = {
        let view = GradientView()

        view.horizontalMode = true
        view.cornerRadius = 8
        return view
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.cornerRadius = 5
        return view
    }()
    
    private let backgroundStarView: UIImageView = {
        let view = UIImageView()
        view.image = Asset.adventureGuideBackground.image
        return view
    }()
    
    private let starView: UIImageView = {
        let view = UIImageView()
        view.image = Asset.adventureGuideStars.image
        view.contentMode = .center
        return view
    }()
    
    private let titleView: UILabel = {
        let view = UILabel()
        view.text = L10n.beginnerObjectives
        view.font = CustomFontMetrics.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        view.textAlignment = .center
        return view
    }()
    
    private let progressBar: ProgressBar = ProgressBar()
    
    private let progressText: UILabel = {
        let view = UILabel()
        view.font = CustomFontMetrics.scaledSystemFont(ofSize: 15, ofWeight: .bold)
        return view
    }()
    
    private let goldText: UILabel = {
        let view = UILabel()
        view.text = "100"
        view.font = CustomFontMetrics.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        return view
    }()
    
    private let goldView: UIImageView = {
        let view = UIImageView()
        view.image = HabiticaIcons.imageOfGold
        return view
    }()
    
    private let rewardBackground: UIView = {
        let view = UIView()
        view.cornerRadius = 11
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func updateView() {
        progressBar.value = CGFloat(completedCount)
        progressBar.maxValue = CGFloat(totalCount)
        progressText.text = "\(completedCount) / \(totalCount)"
        setNeedsLayout()
    }
    
    internal func setupView() {
        contentView.addSubview(gradientView)
        contentView.addSubview(overlayView)
        contentView.addSubview(backgroundStarView)
        contentView.addSubview(starView)
        contentView.addSubview(titleView)
        contentView.addSubview(progressBar)
        contentView.addSubview(progressText)
        
        contentView.addSubview(rewardBackground)
        contentView.addSubview(goldView)
        contentView.addSubview(goldText)
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        titleView.textColor = ThemeService.shared.theme.primaryTextColor
        goldText.textColor = ThemeService.shared.theme.primaryTextColor
        progressBar.barBackgroundColor = ThemeService.shared.theme.offsetBackgroundColor
        progressBar.barColor = ThemeService.shared.theme.tintColor
        progressText.textColor = ThemeService.shared.theme.tintColor
        overlayView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        contentView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        rewardBackground.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
        
        if theme.isDark {
            gradientView.startColor = .blue100
            gradientView.middleColor = .purple400
            gradientView.endColor = .red100
        } else {
            gradientView.startColor = UIColor("#A9DCF6")
            gradientView.middleColor = UIColor("#925CF3")
            gradientView.endColor = UIColor("#FFB6B8")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        gradientView.pin.top().bottom(4).horizontally(10)
        overlayView.pin.top(3).bottom(7).horizontally(13)
        backgroundStarView.pin.end(13).top(3).bottom(7).width(147)
        starView.pin.start(22).width(30).height(35).vCenter()
        titleView.pin.start(62).top(13).sizeToFit()
        progressText.pin.end(28).bottom(15).sizeToFit()
        progressBar.pin.start(62).bottom(21).before(of: progressText).marginEnd(10).height(5)
        
        rewardBackground.pin.top(11).end(23).width(58).height(22)
        goldView.pin.start(to: rewardBackground.edge.start).marginStart(5).top(to: rewardBackground.edge.top).marginTop(3).width(16).height(16)
        goldText.pin.after(of: goldView).marginStart(2).top(to: rewardBackground.edge.top).bottom(to: rewardBackground.edge.bottom).end(to: rewardBackground.edge.end)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 70)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 70)
    }
}
