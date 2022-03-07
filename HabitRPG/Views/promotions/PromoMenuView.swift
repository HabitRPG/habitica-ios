//
//  PromoMenuView.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit

class PromoMenuView: UIView {
    
    var onButtonTapped: (() -> Void)?
    var onCloseButtonTapped: (() -> Void)?

    var canClose = false {
        didSet {
            closeButton.isHidden = !canClose
        }
    }
    
    let titleView: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 17, ofWeight: .semibold)
        return label
    }()
    let titleImageView = UIImageView()
    let descriptionView: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let descriptionImageView = UIImageView()
    let actionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.cornerRadius = 8
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        button.isPointerInteractionEnabled = true
        return button
    }()
    let leftImageView = UIImageView()
    let rightImageView = UIImageView()
    
    let closeButton: UIButton = {
        let view = UIButton()
        view.setImage(Asset.close.image, for: .normal)
        view.tintColor = ThemeService.shared.theme.dimmedTextColor
        view.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
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
        addSubview(leftImageView)
        addSubview(titleView)
        addSubview(titleImageView)
        addSubview(descriptionView)
        addSubview(descriptionImageView)
        addSubview(actionButton)
        addSubview(closeButton)
        
        titleView.isHidden = true
        titleImageView.isHidden = true
        descriptionView.isHidden = true
        descriptionImageView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        leftImageView.pin.start().bottom().sizeToFit()
        rightImageView.pin.end().bottom().sizeToFit()
        var upperEdge = edge.top
        if !titleView.isHidden {
            titleView.pin.top(to: upperEdge).marginTop(20).sizeToFit().hCenter()
            upperEdge = titleView.edge.bottom
        }
        if !titleImageView.isHidden {
            titleImageView.pin.top(to: upperEdge).marginTop(24).sizeToFit().hCenter()
            upperEdge = titleImageView.edge.bottom
        }
        if !descriptionView.isHidden {
            descriptionView.pin.top(to: upperEdge).hCenter().marginTop(8).maxWidth(250).sizeToFit(.width)
            upperEdge = descriptionView.edge.bottom
        }
        if !descriptionImageView.isHidden {
            descriptionImageView.pin.top(to: upperEdge).marginTop(8).sizeToFit().hCenter()
            upperEdge = descriptionImageView.edge.bottom
        }
        actionButton.pin.top(to: upperEdge).minWidth(110).sizeToFit().marginTop(16).hCenter().height(32)
        closeButton.pin.top(8).end(8).wrapContent(padding: 12)
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
}
