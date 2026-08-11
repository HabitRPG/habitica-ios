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

    private let horizontalInset: CGFloat = 17
    private let cardHeight: CGFloat = 130
    private let cardCornerRadius: CGFloat = 20
    private let buttonHeight: CGFloat = 44

    let cardView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    let titleView: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledBoldSystemFont(ofSize: 14)
        label.text = L10n.subscriptionPromoTitle
        label.textAlignment = .center
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
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
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
        addSubview(cardView)
        cardView.addSubview(rightImageView)
        cardView.addSubview(titleView)
        cardView.addSubview(descriptionView)
        cardView.addSubview(subscribeButton)
        cardView.addSubview(leftImageView)
        cardView.cornerRadius = cardCornerRadius
        subscribeButton.addTarget(self, action: #selector(subscribeButtonTapped), for: .touchUpInside)
        ThemeService.shared.addThemeable(themable: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }

    private func layout() {
        let verticalInset = max(0, (bounds.height - cardHeight) / 2)
        cardView.pin.top(verticalInset).bottom(verticalInset).horizontally(horizontalInset)

        leftImageView.pin.start().bottom().width(75).height(85)
        rightImageView.pin.end().bottom().width(77).height(90)

        let buttonWidth = min(cardView.frame.width - 32, max(150, subscribeButton.intrinsicContentSize.width))
        subscribeButton.pin.width(buttonWidth).height(buttonHeight)
        subscribeButton.cornerRadius = buttonHeight / 2

        titleView.pin.width(210).sizeToFit(.width)
        descriptionView.pin.width(210).sizeToFit(.width)

        let textGap: CGFloat = 6
        let buttonGap: CGFloat = 14
        let totalHeight = titleView.frame.height + textGap + descriptionView.frame.height + buttonGap + buttonHeight
        var currentY = max(8, (cardView.frame.height - totalHeight) / 2)
        titleView.pin.top(currentY).hCenter()
        currentY += titleView.frame.height + textGap
        descriptionView.pin.top(currentY).hCenter()
        currentY += descriptionView.frame.height + buttonGap
        subscribeButton.pin.top(currentY).hCenter()
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
        cardView.backgroundColor = theme.contentBackgroundColor
        titleView.textColor = theme.primaryTextColor
        descriptionView.textColor = theme.secondaryTextColor
        subscribeButton.backgroundColor = UIColor("#925CF3")
        backgroundColor = theme.isDark ? UIColor("#1A181D") : UIColor("#F6F4FC")
    }

    @objc
    private func subscribeButtonTapped() {
        if let action = onButtonTapped {
            action()
        }
    }
}
