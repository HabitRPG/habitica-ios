//
//  BaseNotificationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import PinLayout
import Habitica_Models

class BaseNotificationCell: UITableViewCell {
    
    let iconView = UIImageView()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 14)
        return label
    }()
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(asset: Asset.notificationsClose), for: .normal)
        return button
    }()
    
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
    
    private func setupView() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        layout()
        return CGSize(width: contentView.frame.width, height: cellHeight)
    }
    
    private func layout() {
        if isClosable {
            closeButton.pin.top(12).end(12).size(22)
        }
        var startEdge = contentView.edge.start
        if iconView.image != nil {
            startEdge = iconView.edge.end
            iconView.pin.start(20).top(9).sizeToFit()
        }
        titleLabel.pin.start(to: startEdge).marginStart(20).before(of: closeButton).top(15).sizeToFit(.width)
        if titleLabel.frame.totalHeight + 15 > cellHeight {
            cellHeight = titleLabel.frame.totalHeight + 15
        }
        if iconView.frame.totalHeight + 9 > cellHeight {
            cellHeight = iconView.frame.totalHeight + 9
        }
    }
    
    func configureFor(notification: NotificationProtocol) {
        titleLabel.textColor = ThemeService.shared.theme.primaryTextColor
        closeButton.tintColor = ThemeService.shared.theme.secondaryTextColor
    }

}
