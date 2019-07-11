//
//  QuestTitleView.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class QuestTitleView: UIView {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.cornerRadius = 6
        view.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        return view
    }()
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = CustomFontMetrics.scaledSystemFont(ofSize: 17)
        view.textColor = UIColor.gray10()
        view.numberOfLines = 2
        return view
    }()
    lazy var detailLabel: UILabel = {
        let view = UILabel()
        view.font = CustomFontMetrics.scaledSystemFont(ofSize: 15)
        view.textColor = UIColor.gray300()
        return view
    }()
    
    var insets = UIEdgeInsets.zero
    
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
        backgroundColor = theme.contentBackgroundColor
        titleLabel.textColor = theme.primaryTextColor
        detailLabel.textColor = theme.secondaryTextColor
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
