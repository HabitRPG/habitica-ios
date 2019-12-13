//
//  GiftOneGetOnePromoView.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.11.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

enum PromoViewSize {
    case small
    case large
}

class GiftOneGetOnePromoView: UIView, Themeable {
    
    var onTapped: (() -> Void)?
    
    var size: PromoViewSize = .small {
        didSet {
            if size == .large {
                label.text = L10n.giftOneGetOneDescription
                label.font = .systemFont(ofSize: 14, weight: .semibold)
                addSubview(titleLabel)
                addSubview(button)
            }
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.giftOneGetOneTitle
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = L10n.giftOneGetOne
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle(L10n.sendGift, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.teal10, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.cornerRadius = 8
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let leftImage = UIImageView(image: Asset.promoGiftsLeft.image)
    private let rightImage = UIImageView(image: Asset.promoGiftsRight.image)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        cornerRadius = 8
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        addSubview(leftImage)
        leftImage.contentMode = .bottom
        addSubview(rightImage)
        rightImage.contentMode = .bottom
        addSubview(label)
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        label.textColor = .white
        if theme.isDark {
            backgroundColor = UIColor.teal10
        } else {
            backgroundColor = UIColor.teal50
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        leftImage.pin.start().top().bottom().width(58)
        rightImage.pin.end().top().bottom().width(66)
        if size == .small {
            label.pin.start(80).end(80).top().bottom()
        } else {
            titleLabel.pin.top(20).start(80).end(80).sizeToFit(.width)
            label.pin.below(of: titleLabel).marginTop(4).start(80).end(80).sizeToFit(.width)
            button.pin.below(of: label).marginTop(12).height(32).width(110).hCenter()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 100, height: 81)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 81)
    }
    
    @objc
    private func viewTapped() {
        onTapped?()
    }
}
