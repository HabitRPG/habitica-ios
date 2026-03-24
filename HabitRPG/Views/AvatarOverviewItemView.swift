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
        imageView.layer.cornerRadius = UIConstants.mediumCornerRadius
        imageView.contentMode = .center
        return imageView
    }()
    var label: UILabel = {
        let label = UILabel()
        label.textColor = ThemeService.shared.theme.secondaryTextColor
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12, ofWeight: .medium)
        label.textAlignment = .center
        return label
    }()
    let noItemBorder = CAShapeLayer()

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
        
        noItemBorder.strokeColor = ThemeService.shared.theme.isDark ? UIColor.gray50.cgColor : UIColor.gray400.cgColor
        noItemBorder.lineWidth = 2
        noItemBorder.lineDashPattern = [4, 4]
        noItemBorder.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        noItemBorder.fillColor = nil
        noItemBorder.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 60, height: 60), cornerRadius: UIConstants.smallCornerRadius).cgPath
        imageView.layer.addSublayer(noItemBorder)
        
        setNeedsUpdateConstraints()
        updateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.pin.top().size(80).hCenter()
        label.pin.below(of: imageView).marginTop(6).left().right().bottom()
    }
    
    func setup(title: String, itemTapped: @escaping (() -> Void)) {
        label.text = title
        self.itemTapped = itemTapped
    }
    
    func configure(_ imagename: String?) {
        if let imagename = imagename, !imagename.contains("base_0") && !imagename.hasSuffix("background_") {
            imageView.setImagewith(name: imagename)
            noItemBorder.isHidden = true
            imageView.backgroundColor = ThemeService.shared.theme.isDark ? .gray50 : ThemeService.shared.theme.contentBackgroundColor
        } else {
            imageView.image = nil
            noItemBorder.isHidden = false
            imageView.backgroundColor = ThemeService.shared.theme.isDark ? .gray5 : .gray500
        }
    }
    
    @objc
    private func viewTapped() {
        if let action = itemTapped {
            action()
        }
    }
}
