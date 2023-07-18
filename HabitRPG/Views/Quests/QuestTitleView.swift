//
//  QuestTitleView.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class QuestTitleView: UIView {
    
    let imageView: NetworkImageView = {
        let view = NetworkImageView()
        view.cornerRadius = 6
        view.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        return view
    }()
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        view.textColor = UIColor.gray10
        view.numberOfLines = 2
        return view
    }()
    lazy var detailLabel: UILabel = {
        let view = UILabel()
        view.font = UIFontMetrics.default.scaledSystemFont(ofSize: 13, ofWeight: .medium)
        view.textColor = UIColor.gray300
        return view
    }()
    
    var insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(detailLabel)
        
        let theme = ThemeService.shared.theme
        imageView.backgroundColor = theme.windowBackgroundColor
        titleLabel.textColor = theme.primaryTextColor
        detailLabel.textColor = theme.ternaryTextColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        imageView.pin.start(insets.left).size(63).vCenter()
            titleLabel.pin.after(of: imageView).marginStart(16).end(insets.right).sizeToFit(.width)
            detailLabel.pin.after(of: imageView).marginStart(16).end(insets.right).sizeToFit(.width)
            titleLabel.pin.top((frame.size.height - titleLabel.frame.size.height - detailLabel.frame.size.height) / 2)
            detailLabel.pin.below(of: titleLabel)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.size.width, height: 87)
    }
}
