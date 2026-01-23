//
//  EquipmentOverviewItemView.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class EquipmentOverviewItemView: UIView {
    @IBOutlet weak var imageView: NetworkImageView!
    @IBOutlet weak var label: UILabel!
    
    let noEquipmentBorder = CAShapeLayer()
    
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
        if let view = viewFromNibForClass() {
            view.frame = bounds
            addSubview(view)
      
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))

            noEquipmentBorder.strokeColor = UIColor.gray50.cgColor
            noEquipmentBorder.lineWidth = 2
            noEquipmentBorder.lineDashPattern = [4, 4]
            noEquipmentBorder.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
            noEquipmentBorder.fillColor = nil
            noEquipmentBorder.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 60, height: 60), cornerRadius: UIConstants.smallCornerRadius).cgPath
            imageView.layer.addSublayer(noEquipmentBorder)
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
            
            shouldGroupAccessibilityChildren = true
            isAccessibilityElement = true
            
            imageView.cornerRadius = UIConstants.mediumCornerRadius
            label.numberOfLines = 2
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.pin.top().size(80).hCenter()
        label.pin.below(of: imageView).marginTop(6).left().right().bottom()
    }
    
    func setup(title: String, itemTapped: @escaping (() -> Void)) {
        label.text = title
        self.itemTapped = itemTapped
        
        accessibilityLabel = L10n.Accessibility.viewX(title)
    }
    
    func configure(_ gearKey: String?, isTwoHanded: Bool = false) {
        if let key = gearKey, !key.contains("base_0") {
            imageView.setImagewith(name: "shop_\(key)")
            imageView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
            noEquipmentBorder.isHidden = true
        } else {
            imageView.image = nil
            imageView.backgroundColor = ThemeService.shared.theme.isDark ? .gray5 : .gray500
            noEquipmentBorder.isHidden = false
        }
    }
    
    func applyTheme(theme: Theme) {
        label.textColor = ThemeService.shared.theme.secondaryTextColor
        noEquipmentBorder.strokeColor = theme.isDark ? UIColor.gray50.cgColor : UIColor.gray400.cgColor
    }
    
    @objc
    private func viewTapped() {
        if let action = itemTapped {
            action()
        }
    }
}
