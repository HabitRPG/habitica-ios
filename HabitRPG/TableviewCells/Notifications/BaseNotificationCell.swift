//
//  BaseNotificationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit
import PinLayout
import Habitica_Models

class BaseNotificationCell<NP>: UITableViewCell {
    
    private var containerView: UIView {
        let view = UIView()
        view.cornerRadius = 26
        return view
    }
    let iconView = NetworkImageView()
    internal let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    internal let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(asset: Asset.notificationsClose), for: .normal)
        button.isPointerInteractionEnabled = true
        return button
    }()
    let declineButton: UIButton = {
        let button = UIButton()
        button.setTitle(L10n.decline, for: .normal)
        button.titleLabel?.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12, ofWeight: .medium)
        if #available(iOS 26.0, *) {
            button.cornerConfiguration = .capsule()
        } else {
            button.cornerRadius = 13
        }
        button.setTitleColor(.red1, for: .normal)
        button.isPointerInteractionEnabled = true
        return button
    }()
    let acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle(L10n.accept, for: .normal)
        button.titleLabel?.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12, ofWeight: .medium)
        if #available(iOS 26.0, *) {
            button.cornerConfiguration = .capsule()
        } else {
            button.cornerRadius = 13
        }
        button.setTitleColor(.green1, for: .normal)
        button.isPointerInteractionEnabled = true
        return button
    }()
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    var attributedTitle: NSAttributedString? {
        get {
            return titleLabel.attributedText
        }
        set {
            titleLabel.attributedText = newValue
        }
    }
    var itemDescription: String? {
        get {
            return descriptionLabel.text
        }
        set {
            descriptionLabel.text = newValue
            if newValue?.isEmpty == false {
                titleLabel.font = UIFontMetrics.default.scaledBoldSystemFont(ofSize: 14)
                contentView.addSubview(descriptionLabel)
            } else {
                titleLabel.font = UIFontMetrics.default.scaledSystemFont(ofSize: 14)
                descriptionLabel.removeFromSuperview()
            }
        }
    }
    var hasDescription: Bool {
        return itemDescription?.isEmpty == false
    }
    var showResponseButtons: Bool = false {
        didSet {
            if showResponseButtons {
                addSubview(acceptButton)
                addSubview(declineButton)
            } else {
                acceptButton.removeFromSuperview()
                declineButton.removeFromSuperview()
            }
        }
    }
    
    var closeAction: (() -> Void)?
    var declineAction: (() -> Void)?
    var acceptAction: (() -> Void)?
    
    var cellHeight: CGFloat = 40
    var isClosable = true {
        didSet {
            if isClosable {
                if !subviews.contains(closeButton) {
                    contentView.addSubview(closeButton)
                }
            } else {
                closeButton.removeFromSuperview()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    internal func setupView() {
        contentView.addSubview(containerView)
        contentView.addSubview(closeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconView)
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(declineTapped), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
    }
    
    @objc
    private func closeTapped() {
        closeAction?()
    }
    
    @objc
    private func declineTapped() {
        declineAction?()
    }
    
    @objc
    private func acceptTapped() {
        acceptAction?()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width).height(51)
        layout()
        return CGSize(width: contentView.frame.width, height: cellHeight)
    }
    
    internal func layout() {
        var endEdge = contentView.edge.end
        if isClosable {
            closeButton.pin.top(16).end(33).size(22)
            endEdge = closeButton.edge.start
        }
        let offset: CGFloat = 56
        iconView.pin.start(25).top(20).minWidth(32).minHeight(32).sizeToFit()
        cellHeight = iconView.frame.totalHeight + 20
        var buttonEdge = contentView.edge.top
        if hasDescription {
            titleLabel.pin.start(offset).marginStart(20).end(to: endEdge).marginEnd(16).top(20).sizeToFit(.width)
            descriptionLabel.pin.start(offset).marginStart(20).end(to: endEdge).marginEnd(16).below(of: titleLabel).sizeToFit(.width)
            let height = titleLabel.frame.totalHeight + descriptionLabel.frame.totalHeight + 20
            if height > cellHeight {
                cellHeight = height
            }
            buttonEdge = descriptionLabel.edge.bottom
        } else {
            titleLabel.pin.start(offset).marginStart(20).end(to: endEdge).marginEnd(16).top(20).bottom(1).sizeToFit(.width)
            if titleLabel.frame.totalHeight + 20 > cellHeight {
                cellHeight = titleLabel.frame.totalHeight + 20
            }
            buttonEdge = titleLabel.edge.bottom
        }
        
        if showResponseButtons {
            layoutResponseButtons(to: buttonEdge)
            if declineButton.frame.totalHeight + 20 > cellHeight {
                cellHeight = declineButton.frame.totalHeight + 20
            }
        }
        containerView.pin.start().end().top(4).height(cellHeight)
        cellHeight += 8
    }
    
    func layoutResponseButtons(to edge: VerticalEdge) {
        declineButton.pin.start(16).top(to: edge).marginTop(12).minHeight(24).sizeToFit(.width).end(to: contentView.edge.hCenter).marginEnd(8)
        acceptButton.pin.start(to: contentView.edge.hCenter).marginStart(8).top(to: edge).marginTop(12).minHeight(24).sizeToFit(.width).end(16)
    }
    
    func configureFor(notification: NP) {
        containerView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
        descriptionLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        closeButton.tintColor = ThemeService.shared.theme.secondaryTextColor
        declineButton.backgroundColor = ThemeService.shared.theme.errorColor
        acceptButton.backgroundColor = ThemeService.shared.theme.successColor
    }

}
