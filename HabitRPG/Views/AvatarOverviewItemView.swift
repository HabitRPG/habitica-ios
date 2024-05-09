//
//  AvatarOverviewItemView.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class AvatarOverviewItemView: UIView {
    var imageView: NetworkImageView = {
        let imageView = NetworkImageView()
        if ThemeService.shared.theme.isDark {
            imageView.backgroundColor = .gray50
        } else {
            imageView.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        }
        imageView.layer.cornerRadius = 4
        imageView.contentMode = .center
        return imageView
    }()
    var label: UILabel = {
        let label = UILabel()
        label.textColor = ThemeService.shared.theme.secondaryTextColor
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 11)
        label.textAlignment = .center
        return label
    }()
    var noItemView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = ThemeService.shared.theme.isDark ? UIColor.gray5 : UIColor.gray500
        imageView.layer.cornerRadius = 4
        imageView.contentMode = .center
        imageView.image = Asset.blankAvatar.image
        return imageView
    }()
        
    var itemTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 154, height: 36))
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        
        addSubview(imageView)
        addSubview(label)
        addSubview(noItemView)
        
        setNeedsUpdateConstraints()
        updateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.pin.top().left().right().aspectRatio(1.0)
        noItemView.pin.top().left().right().aspectRatio(1.0)
        label.pin.below(of: imageView).left().right().bottom()
    }
    
    func setup(title: String, itemTapped: @escaping (() -> Void)) {
        label.text = title
        self.itemTapped = itemTapped
    }
    
    func configure(_ imagename: String?) {
        if let imagename = imagename, !imagename.contains("base_0") {
            imageView.setImagewith(name: imagename)
            imageView.isHidden = false
            noItemView.isHidden = true
        } else {
            imageView.isHidden = true
            noItemView.isHidden = false
        }
    }
    
    @objc
    private func viewTapped() {
        if let action = itemTapped {
            action()
        }
    }
}
