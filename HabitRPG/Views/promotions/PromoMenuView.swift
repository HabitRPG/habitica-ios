//
//  PromoMenuView.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit

class PromoMenuView: UIView, Themeable {

    var onButtonTapped: (() -> Void)?
    var onCloseButtonTapped: (() -> Void)?

    var canClose = false {
        didSet {
            closeButton.isHidden = !canClose
        }
    }

    private let horizontalInset: CGFloat = 17
    private let cardHeight: CGFloat = 130
    private let cardCornerRadius: CGFloat = 20
    private let buttonHeight: CGFloat = 44

    let cardView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    private var cardGradientLayer: CAGradientLayer?

    let titleView: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 20, ofWeight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let titleImageView = UIImageView()
    let descriptionView: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let descriptionImageView = UIImageView()
    let actionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
        button.isPointerInteractionEnabled = true
        return button
    }()
    let leftImageView = {
        let view = UIImageView()
        view.contentMode = .topLeft
        return view
    }()
    let rightImageView = {
        let view = UIImageView()
        view.contentMode = .topRight
        return view
    }()

    let closeButton: UIButton = {
        let view = UIButton()
        view.setImage(Asset.close.image, for: .normal)
        view.tintColor = .white
        view.isHidden = true
        return view
    }()

    func setTitle(_ title: String) {
        titleView.isHidden = false
        titleView.text = title
    }

    func setTitleImage(_ image: UIImage) {
        titleImageView.isHidden = false
        titleImageView.image = image
    }

    func setDescription(_ description: String) {
        descriptionView.isHidden = false
        descriptionView.text = description
    }

    func setDescriptionImage(_ image: UIImage) {
        descriptionImageView.isHidden = false
        descriptionImageView.image = image
    }

    func setCardBackground(color: UIColor) {
        cardGradientLayer?.removeFromSuperlayer()
        cardGradientLayer = nil
        cardView.backgroundColor = color
    }

    func setCardGradient(startColor: UIColor, endColor: UIColor) {
        cardView.backgroundColor = nil
        let gradient = cardGradientLayer ?? CAGradientLayer()
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        if cardGradientLayer == nil {
            cardView.layer.insertSublayer(gradient, at: 0)
            cardGradientLayer = gradient
        }
        setNeedsLayout()
    }

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
        cardView.addSubview(leftImageView)
        cardView.addSubview(titleView)
        cardView.addSubview(titleImageView)
        cardView.addSubview(descriptionView)
        cardView.addSubview(descriptionImageView)
        cardView.addSubview(actionButton)
        cardView.addSubview(closeButton)

        cardView.cornerRadius = cardCornerRadius

        titleView.isHidden = true
        titleImageView.isHidden = true
        descriptionView.isHidden = true
        descriptionImageView.isHidden = true

        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        ThemeService.shared.addThemeable(themable: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }

    private func layout() {
        let verticalInset = max(0, (bounds.height - cardHeight) / 2)
        cardView.pin.top(verticalInset).bottom(verticalInset).horizontally(horizontalInset)
        cardGradientLayer?.frame = cardView.bounds

        let contentMaxWidth: CGFloat = 205

        leftImageView.pin.start().bottom().top(24).sizeToFit(.height)
        rightImageView.pin.end().bottom().top(24).sizeToFit(.height)

        let buttonWidth = min(cardView.frame.width - 32, max(170, actionButton.intrinsicContentSize.width))
        actionButton.pin.width(buttonWidth).height(buttonHeight)
        actionButton.cornerRadius = buttonHeight / 2

        if !titleView.isHidden {
            titleView.pin.width(contentMaxWidth).sizeToFit(.width)
        }
        if !titleImageView.isHidden {
            titleImageView.pin.sizeToFit()
        }
        if !descriptionView.isHidden {
            descriptionView.pin.width(contentMaxWidth).sizeToFit(.width)
        }
        if !descriptionImageView.isHidden {
            descriptionImageView.pin.sizeToFit()
        }

        var stack: [UIView] = []
        if !titleView.isHidden { stack.append(titleView) }
        if !titleImageView.isHidden { stack.append(titleImageView) }
        if !descriptionView.isHidden { stack.append(descriptionView) }
        if !descriptionImageView.isHidden { stack.append(descriptionImageView) }

        let textGap: CGFloat = 4
        let buttonGap: CGFloat = 12
        var textHeight: CGFloat = 0
        for (index, view) in stack.enumerated() {
            textHeight += view.frame.height
            if index < stack.count - 1 {
                textHeight += textGap
            }
        }
        let totalHeight = textHeight + (stack.isEmpty ? 0 : buttonGap) + buttonHeight
        var currentY = max(8, (cardView.frame.height - totalHeight) / 2)
        for view in stack {
            view.pin.top(currentY).hCenter()
            currentY += view.frame.height + textGap
        }
        currentY = currentY - textGap + buttonGap
        actionButton.pin.top(currentY).hCenter()

        closeButton.pin.top(6).end(6).size(32)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 168)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = CGSize(width: size.width, height: 168)
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: size.width, height: size.height)
        layout()
        return size
    }

    @objc
    private func actionButtonTapped() {
        if let action = onButtonTapped {
            action()
        }
    }

    @objc
    private func closeButtonTapped() {
        if let action = onCloseButtonTapped {
            action()
        }
    }

    func applyTheme(theme: any Theme) {
        backgroundColor = theme.isDark ? UIColor("#1A181D") : UIColor("#F6F4FC")
    }
}
