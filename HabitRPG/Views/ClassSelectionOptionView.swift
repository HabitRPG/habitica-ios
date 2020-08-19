//
//  ClassSelectionOptionView.swift
//  Habitica
//
//  Created by Phillip Thelen on 26.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class ClassSelectionOptionView: UIView {
    private let avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.showBackground = false
        avatarView.showPet = false
        avatarView.showMount = false
        avatarView.size = .compact
        return avatarView
    }()
    private let labelWrapper: UIView = {
        let labelWrapper = UIView()
        labelWrapper.backgroundColor = UIColor.gray700
        labelWrapper.layer.cornerRadius = 4
        return labelWrapper
    }()
    private let iconView = UIImageView()
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private var onSelected: (() -> Void)?
    
    var isSelected = false {
        didSet {
            let newWidth = self.isSelected ? 2 : 0
            let widthAnimation = CABasicAnimation(keyPath: "borderWidth")
            widthAnimation.fromValue = self.labelWrapper.layer.borderWidth
            widthAnimation.toValue = newWidth
            widthAnimation.duration = 0.2
            self.labelWrapper.layer.borderWidth = CGFloat(newWidth)
            self.labelWrapper.layer.add(widthAnimation, forKey: "border width")
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            labelWrapper.layer.borderColor = tintColor.cgColor
            label.textColor = tintColor
        }
    }
    
    var userStyle: UserStyleProtocol? {
        didSet {
            if let userStyle = self.userStyle {
                avatarView.avatar = AvatarViewModel(avatar: userStyle)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(avatarView)
        addSubview(labelWrapper)
        labelWrapper.addSubview(iconView)
        labelWrapper.addSubview(label)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))
        isUserInteractionEnabled = true
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.pin.width(76).height(60).top((bounds.size.height-103)/2).hCenter()
        labelWrapper.pin.width(116).height(43).hCenter().below(of: avatarView).marginTop(10)
        iconView.pin.size(32).vCenter()
        label.pin.vertically().sizeToFit(.height)
        let labelContentWidth = 32 + 4 + label.bounds.size.width
        iconView.pin.left((labelWrapper.bounds.size.width-labelContentWidth)/2)
        label.pin.right(of: iconView).marginLeft(4)
    }
    
    func configure(habiticaClass: HabiticaClass, onSelected: @escaping (() -> Void)) {
        self.onSelected = onSelected
        switch habiticaClass {
        case .warrior:
            iconView.image = HabiticaIcons.imageOfWarriorLightBg
            label.text = L10n.Classes.warrior
            tintColor = UIColor.red10
        case .mage:
            iconView.image = HabiticaIcons.imageOfMageLightBg
            label.text = L10n.Classes.mage
            tintColor = UIColor.blue10
        case .healer:
            iconView.image = HabiticaIcons.imageOfHealerLightBg
            label.text = L10n.Classes.healer
            tintColor = UIColor.yellow10
        case .rogue:
            iconView.image = HabiticaIcons.imageOfRogueLightBg
            label.text = L10n.Classes.rogue
            tintColor = UIColor.purple300
        }
    }
    
    @objc
    private func onTapped() {
        if let action = onSelected {
            action()
        }
    }
}
