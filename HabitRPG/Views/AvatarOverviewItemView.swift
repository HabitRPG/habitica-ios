//
//  AvatarOverviewItemView.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class AvatarOverviewItemView: UIView {
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        imageView.layer.cornerRadius = 4
        imageView.contentMode = .center
        return imageView
    }()
    var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray400()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 11)
        label.textAlignment = .center
        return label
    }()
    var noItemView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.gray10()
        imageView.layer.cornerRadius = 4
        imageView.contentMode = .center
        imageView.image = HabiticaIcons.imageOfBlankAvatarIcon
        return imageView
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
        addSubview(noItemView)
        
        noItemBorder.strokeColor = UIColor.gray50().cgColor
        noItemBorder.lineWidth = 2
        noItemBorder.lineDashPattern = [4, 4]
        noItemBorder.frame = CGRect(x: 10, y: 10, width: frame.size.width-20, height: 60)
        noItemBorder.fillColor = nil
        noItemBorder.path = UIBezierPath(rect: CGRect(x: 10, y: 10, width: frame.size.width-20, height: 60)).cgPath
        noItemView.layer.addSublayer(noItemBorder)
        
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
        noItemBorder.frame = noItemView.bounds
        noItemBorder.path = UIBezierPath(rect: CGRect(x: 10, y: 10, width: noItemView.bounds.size.width-20, height: noItemView.bounds.size.height-20)).cgPath
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
