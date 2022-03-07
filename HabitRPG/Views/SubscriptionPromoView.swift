//
//  SubscriptionPromoView.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.10.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit

class SubscriptionPromoView: UIView, Themeable {
    
    var onButtonTapped: (() -> Void)?
    
    let titleView: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledBoldSystemFont(ofSize: 14)
        label.text = L10n.subscriptionPromoTitle
        return label
    }()
    let descriptionView: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12)
        label.text = L10n.subscriptionPromoDescription
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let subscribeButton: UIButton = {
        let button = UIButton()
        button.setTitle(L10n.subscribe, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.cornerRadius = 8
        button.addTarget(self, action: #selector(subscribeButtonTapped), for: .touchUpInside)
        button.isPointerInteractionEnabled = true
        return button
    }()
    let leftImageView = UIImageView(image: Asset.subscriptionPromoGems.image)
    let rightImageView = UIImageView(image: Asset.subscriptionPromoGold.image)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(rightImageView)
        addSubview(titleView)
        addSubview(descriptionView)
        addSubview(subscribeButton)
        addSubview(leftImageView)
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        leftImageView.pin.start().bottom().width(75).height(85)
        rightImageView.pin.end().bottom().width(77).height(90)
        titleView.pin.top(14).sizeToFit().hCenter()
        descriptionView.pin.below(of: titleView).start(34).end(34).marginTop(8).maxWidth(400).sizeToFit(.width)
        subscribeButton.pin.below(of: descriptionView).minWidth(110).sizeToFit().marginTop(16).hCenter().height(32)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 148)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = CGSize(width: size.width, height: 148)
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: size.width, height: size.height)
        layout()
        return size
    }
    
    func applyTheme(theme: Theme) {
        titleView.textColor = theme.primaryTextColor
        descriptionView.textColor = theme.secondaryTextColor
        subscribeButton.backgroundColor = theme.backgroundTintColor
    }
    
    @objc
    private func subscribeButtonTapped() {
        if let action = onButtonTapped {
            action()
        }
    }
}
