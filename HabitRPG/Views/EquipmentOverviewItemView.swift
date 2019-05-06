//
//  EquipmentOverviewItemView.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class EquipmentOverviewItemView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var noEquipmentLabel: UILabel!
    
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
      
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))

            noEquipmentBorder.strokeColor = UIColor.gray50().cgColor
            noEquipmentBorder.lineWidth = 2
            noEquipmentBorder.lineDashPattern = [4, 4]
            noEquipmentBorder.frame = CGRect(x: 10, y: 10, width: frame.size.width-20, height: 60)
            noEquipmentBorder.fillColor = nil
            noEquipmentBorder.path = UIBezierPath(rect: CGRect(x: 10, y: 10, width: frame.size.width-20, height: 60)).cgPath
            noEquipmentLabel.layer.addSublayer(noEquipmentBorder)
            
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.pin.top().left().right().aspectRatio(1.0)
        noEquipmentLabel.pin.top().left().right().aspectRatio(1.0)
        label.pin.below(of: imageView).left().right().bottom()
        noEquipmentLabel.layer.sublayers?.first?.frame = noEquipmentLabel.bounds
        noEquipmentBorder.path = UIBezierPath(rect: CGRect(x: 10, y: 10, width: noEquipmentLabel.bounds.size.width-20, height: noEquipmentLabel.bounds.size.height-20)).cgPath
    }
    
    func setup(title: String, itemTapped: @escaping (() -> Void)) {
        label.text = title
        self.itemTapped = itemTapped
    }
    
    func configure(_ gearKey: String?, isTwoHanded: Bool = false) {
        if let key = gearKey, !key.contains("base_0") {
            imageView.setImagewith(name: "shop_\(key)")
            imageView.isHidden = false
            noEquipmentLabel.isHidden = true
            imageView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        } else {
            imageView.isHidden = true
            noEquipmentLabel.isHidden = false
        }
    }
    
    @objc
    private func viewTapped() {
        if let action = itemTapped {
            action()
        }
    }
}
