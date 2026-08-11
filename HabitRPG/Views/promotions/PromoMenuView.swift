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

    var titleImageMaxHeight: CGFloat = 34 {
        didSet {
            setNeedsLayout()
        }
    }

    private let horizontalInset: CGFloat = 17
    private let cardCornerRadius: CGFloat = 20
    private let buttonHeight: CGFloat = 34
    private let cardVerticalPadding: CGFloat = 16
    private let minimumCardHeight: CGFloat = 130
    private let outerVerticalMargin: CGFloat = 8
    private var computedTotalHeight: CGFloat = 168

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
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        button.isPointerInteractionEnabled = true
        return button
    }()
    let leftImageView = {
        let view = UIImageView()
        view.contentMode = .bottomLeft
        return view
    }()
    let rightImageView = {
        let view = UIImageView()
        view.contentMode = .bottomRight
        return view
    }()

    let closeButton: UIButton = {
        let view = UIButton()
        view.setImage(Asset.close.image, for: .normal)
        view.tintColor = .white
        view.backgroundColor = UIColor.black.withAlphaComponent(0.22)
        view.cornerRadius = 16
        view.clipsToBounds = true
        view.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.isHidden = true
        return view
    }()

    func setTitle(_ title: String) {
        titleView.isHidden = false
        titleView.text = title
    }

    func setTitle(_ title: String, font: UIFont, color: UIColor, lineHeight: CGFloat, kern: CGFloat = 0) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
        titleView.isHidden = false
        titleView.font = font
        titleView.attributedText = NSAttributedString(string: title, attributes: [
            .font: font,
            .kern: kern,
            .foregroundColor: color,
            // counteracts the leading that the fixed line height adds above the text
            .baselineOffset: (lineHeight - font.lineHeight) / 4,
            .paragraphStyle: paragraph
        ])
    }

    func setTitleImage(_ image: UIImage) {
        titleImageView.isHidden = false
        titleImageView.image = image
    }

    func setDescription(_ description: String) {
        descriptionView.isHidden = false
        descriptionView.text = description
    }

    func setDescription(_ description: String, font: UIFont, color: UIColor, lineHeight: CGFloat, kern: CGFloat = 0, maxLines: Int = 0) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
        descriptionView.isHidden = false
        descriptionView.numberOfLines = maxLines
        descriptionView.font = font
        descriptionView.attributedText = NSAttributedString(string: description, attributes: [
            .font: font,
            .kern: kern,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ])
    }

    func setDescriptionImage(_ image: UIImage) {
        descriptionImageView.isHidden = false
        descriptionImageView.image = image
    }

    func setActionTitle(_ title: String, color: UIColor = .white) {
        let lineHeight: CGFloat = 20
        let font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
        actionButton.setAttributedTitle(NSAttributedString(string: title, attributes: [
            .font: font,
            .kern: -0.23,
            .foregroundColor: color,
            // counteracts the leading that the fixed line height adds above the text
            .baselineOffset: (lineHeight - font.lineHeight) / 4,
            .paragraphStyle: paragraph
        ]), for: .normal)
        actionButton.titleLabel?.textAlignment = .center
        actionButton.contentVerticalAlignment = .center
        actionButton.contentHorizontalAlignment = .center
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

    func fittingHeight(forWidth width: CGFloat) -> CGFloat {
        frame = CGRect(x: 0, y: 0, width: width, height: computedTotalHeight)
        layout()
        return computedTotalHeight
    }

    private func layout() {
        let contentMaxWidth: CGFloat = 205

        if !titleView.isHidden {
            titleView.pin.width(contentMaxWidth).sizeToFit(.width)
        }
        if !titleImageView.isHidden, let titleImage = titleImageView.image {
            titleImageView.contentMode = .scaleAspectFit
            let maxWidth: CGFloat = 220
            let scale = min(maxWidth / titleImage.size.width, titleImageMaxHeight / titleImage.size.height)
            titleImageView.pin.width(titleImage.size.width * scale).height(titleImage.size.height * scale)
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
        let innerHeight = textHeight + (stack.isEmpty ? 0 : buttonGap) + buttonHeight
        let cardHeight = max(minimumCardHeight, innerHeight + 2 * cardVerticalPadding)
        computedTotalHeight = cardHeight + 2 * outerVerticalMargin

        cardView.pin.top(outerVerticalMargin).horizontally(horizontalInset).height(cardHeight)
        cardGradientLayer?.frame = cardView.bounds

        leftImageView.pin.start().bottom().top(24).sizeToFit(.height)
        rightImageView.pin.end().bottom().top(24).sizeToFit(.height)

        let buttonWidth = min(cardView.frame.width - 32, max(110, actionButton.intrinsicContentSize.width))
        actionButton.pin.width(buttonWidth).height(buttonHeight)
        actionButton.cornerRadius = min(26, buttonHeight / 2)

        var currentY = (cardHeight - innerHeight) / 2
        for view in stack {
            view.pin.top(currentY).hCenter()
            currentY += view.frame.height + textGap
        }
        currentY = currentY - textGap + buttonGap
        actionButton.pin.top(currentY).hCenter()

        closeButton.pin.top(6).end(6).size(32)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: computedTotalHeight)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: size.width, height: computedTotalHeight)
        layout()
        return CGSize(width: size.width, height: computedTotalHeight)
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
